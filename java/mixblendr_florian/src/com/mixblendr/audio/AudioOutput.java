package com.mixblendr.audio;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.sound.sampled.*;
import org.tritonus.share.sampled.*;
import com.mixblendr.util.*;
import static com.mixblendr.util.Debug.*;

/**
 * Class for writing audio data to a soundcard.
 * 
 * @author Florian Bomers
 */
public class AudioOutput {

	private final static boolean TRACE = false;
	private final static boolean DEBUG = false;
	private final static boolean DEBUG_WRITE_TO_FILE = false;

	/** for debugging only: use java sound audio engine (if it exists) */
	private static final boolean FORCE_JAVA_SOUND_AUDIO_ENGINE = false;

	/** the stream from which data is read */
	protected FloatSampleInput input;

	protected AudioFormat format;

	public static final AudioFormat DEFAULT_FORMAT = new AudioFormat(44100f,
			16, 2, true, AudioUtils.isSystemBigEndian());

	private static final double DEFAULT_BUFFER_SIZE_MILLIS = 40;
	private static final double DEFAULT_SLICE_SIZE_MILLIS = 10;

	private static final double JAVASOUNDENGINE_BUFFER_SIZE_MILLIS = 60;
	private static final double JAVASOUNDENGINE_SLICE_SIZE_MILLIS = 15;

	/** the priority of the audio thread */
	private static final int THREAD_PRIORITY = Thread.MAX_PRIORITY;

	/** the thread instance feeding/reading the audio device */
	private AOThread thread = null;

	/**
	 * the mixer info to retrieve the data line from
	 */
	private Mixer.Info mixerInfo;
	
	/**
	 * the buffer size in milliseconds
	 */
	private double bufferSizeMillis;

	/**
	 * the slice size in milliseconds
	 */
	private double sliceSizeMillis;

	/** listener for exceptions in io thread */
	protected FatalExceptionListener fatalExceptionListener = null;

	protected AudioState state;

	/** create an instance of AudioOutput */
	public AudioOutput(AudioState state) {
		format = DEFAULT_FORMAT;
		this.state = state;
		setBufferSizeMillis(DEFAULT_BUFFER_SIZE_MILLIS);
		setSliceSizeMillis(DEFAULT_SLICE_SIZE_MILLIS);
		// populate some state fields
		state.setChannels(format.getChannels());
		state.setSampleRate(format.getSampleRate());
		if (FORCE_JAVA_SOUND_AUDIO_ENGINE) {
			Mixer.Info[] mi = AudioSystem.getMixerInfo();
			for (Mixer.Info m : mi) {
				if (AudioUtils.isJavaSoundAudioEngine(m)) {
					mixerInfo = m;
					break;
				}
			}
		}
		// create thread and sourcedataline
		try {
			init();
		} catch (Throwable t) {
			debug(t);
		}
	}

	/** create the thread and the source data line */
	protected void init() throws LineUnavailableException {
		SourceDataLine line = null;

		if (thread == null || thread.closed || thread.getLine() == null) {
			String mixerName = (mixerInfo != null) ? mixerInfo.getName() : "(default)";
			// retrieve data line
			if (DEBUG) {
				debug("creating audio device from mixer '" + mixerName + "'...");
			}
			line = AudioSystem.getSourceDataLine(format, mixerInfo);

			// use larger buffer for Java Sound Audio Engine
			if (AudioUtils.isJavaSoundAudioEngine(line)) {
				setBufferSizeMillis(JAVASOUNDENGINE_BUFFER_SIZE_MILLIS);
				setSliceSizeMillis(JAVASOUNDENGINE_SLICE_SIZE_MILLIS);
				debug("Java Sound Audio Engine detected: increase buffer size to "
						+ JAVASOUNDENGINE_BUFFER_SIZE_MILLIS + "ms");
			}
		}
		if (thread == null || thread.closed) {
			thread = new AOThread(line);
		} else if (line != null) {
			thread.setLine(line);
		}
	}

	/** return true if writing to the Java Sound Audio Engine */
	public boolean isJavaSoundAudioEngine() {
		if (mixerInfo != null) {
			return AudioUtils.isJavaSoundAudioEngine(mixerInfo);
		} else if (thread != null) {
			return AudioUtils.isJavaSoundAudioEngine(thread.getLine());
		}
		return false;
	}

	/**
	 * get approximate lag from writing to the soundcard to when it's heard, in
	 * samples
	 */
	public long getSampleLag() {
		long ret = getBufferSizeSamples();
		if (isJavaSoundAudioEngine()) {
			ret += ret * 2 / 3;
		}
		return ret;
	}

	/**
	 * Set buffer size
	 * 
	 * @param bufferSizeMillis the bufferSizeMillis to set
	 */
	private void setBufferSizeMillis(double bufferSizeMillis) {
		this.bufferSizeMillis = bufferSizeMillis;
	}

	/**
	 * Set slice size, update AudioState
	 * 
	 * @param sliceSizeMillis the sliceSizeMillis to set
	 */
	private void setSliceSizeMillis(double sliceSizeMillis) {
		this.sliceSizeMillis = sliceSizeMillis;
		state.setSliceSize((int) AudioUtils.millis2Frames(sliceSizeMillis,
				format));
	}

	/**
	 * @return the number of slices that are rendered per audio hardware buffer
	 */
	protected int getSlicesPerBuffer() {
		return (int) (bufferSizeMillis / sliceSizeMillis);
	}

	/**
	 * @return number of samples to be rendered per slice
	 */
	protected int getSliceSampleCount() {
		return (int) AudioUtils.millis2Frames(sliceSizeMillis, format);
	}

	/**
	 * @return the buffer size in bytes
	 */
	protected int getBufferSizeBytes() {
		return getSliceSampleCount() * getSlicesPerBuffer()
				* format.getFrameSize();
	}

	/**
	 * @return the buffer size in samples
	 */
	protected int getBufferSizeSamples() {
		return getSliceSampleCount() * getSlicesPerBuffer();
	}

	/**
	 * open the audio device. If another device with different parameters is
	 * already started, close it first.
	 */
	private synchronized void startAudioDevice()
			throws LineUnavailableException {
		// open it
		try {
			init();
			if (!thread.getLine().isOpen()) {
				thread.getLine().open(format, getBufferSizeBytes());
				if (DEBUG) {
					debug("opened audio device, buffer size: "
							+ thread.getLine().getBufferSize()
							+ " bytes = "
							+ AudioUtils.bytes2MillisD(
									thread.getLine().getBufferSize(),
									thread.getLine().getFormat()) + "ms");
				}
			}
			thread.doResume();
			if (DEBUG) {
				debug("started audio device");
			}
		} catch (RuntimeException rte) {
			thread.doStop(true);
			debug("error, closed audio device.");
			throw rte;
		} catch (LineUnavailableException lue) {
			thread.doStop(true);
			thread.setLine(null);
			debug("error, closed audio device.");
			throw lue;
		}
	}

	/**
	 * Start the audio output thread. If an audio device is set, data is read
	 * from the input streams and written to the output device.
	 */
	public synchronized void start() throws LineUnavailableException {
		if (!state.isStarted()) {
			startAudioDevice();
			state.setStarted(true);
		}
	}

	/**
	 * Stop the audio output thread and IO.
	 */
	public synchronized void stop(boolean immediate) {
		if (state.isStarted()) {
			// quit thread
			if (thread != null) {
				thread.doStop(immediate);
			}
			state.setStarted(false);
		}
	}

	public synchronized void close() {
		stop(true);
		SourceDataLine sdl = null;
		// quit thread
		if (thread != null) {
			sdl = thread.getLine();
			thread.doClose();
			thread = null;
		}
		// close audio device
		if (sdl != null) {
			sdl.close();
			if (DEBUG) {
				debug("closed audio device.");
			}
		}
	}

	public void setInput(FloatSampleInput input) {
		this.input = input;
		if (thread != null) {
			thread.configChange = true;
			synchronized (thread) {
				thread.notifyAll();
			}
		}
	}

	/**
	 * Set the output device.
	 */
	public synchronized void setAudioDevice(Mixer.Info mixerInfo)
			throws LineUnavailableException {
		this.mixerInfo = mixerInfo;
		if (state.isStarted()) {
			stop(true);
			thread.setLine(null);
			start();
		}
	}

	/**
	 * @return the fatalExceptionListener
	 */
	FatalExceptionListener getFatalExceptionListener() {
		return fatalExceptionListener;
	}

	/**
	 * @param fatalExceptionListener the fatalExceptionListener to set
	 */
	void setFatalExceptionListener(FatalExceptionListener fatalExceptionListener) {
		this.fatalExceptionListener = fatalExceptionListener;
	}

	/**
	 * Thread to continuously read audio data from the source, convert it to a
	 * byte stream, and write to the selected sound card.
	 * 
	 * @author Florian Bomers
	 */
	private class AOThread extends Thread {

		/** flag to signal a requested stop of this thread */
		private volatile boolean stopped = true;

		/** flag to signal a requested closing of this thread */
		protected volatile boolean closed = false;

		protected volatile boolean configChange = false;

		private SourceDataLine line;

		private FloatSampleBuffer floatBuffer;
		private byte[] byteBuffer;

		/** create a new instance of the IO thread */
		public AOThread(SourceDataLine line) {
			super("Audio Output Thread");
			this.line = line;
			setPriority(THREAD_PRIORITY);
			start();
		}

		/**
		 * @return the line
		 */
		SourceDataLine getLine() {
			return line;
		}

		/**
		 * @param line the line to set
		 */
		void setLine(SourceDataLine line) {
			if (this.line != null) {
				this.line.close();
			}
			this.line = line;
			configChange = true;
		}

		/** create the temporary float and byte buffers for reading */
		private void createBuffers() {
			// get the slice size in terms of the buffer size
			int sliceSizeSamples = getSliceSampleCount();
			// (line.getBufferSize() / getSlicesPerBuffer() /
			// line.getFormat().getFrameSize());
			int sliceSizeBytes = sliceSizeSamples * format.getFrameSize();
			// sliceSizeSamples * line.getFormat().getFrameSize();
			if (DEBUG) {
				debug(getName() + ": slice time: " + sliceSizeBytes
						+ " bytes = "
						+ AudioUtils.bytes2MillisD(sliceSizeBytes, format)
						+ "ms");
			}
			// calculate number of samples
			floatBuffer = new FloatSampleBuffer(format.getChannels(),
					sliceSizeSamples, format.getSampleRate());
			byteBuffer = new byte[sliceSizeBytes];
		}

		/** return the flag if this thread should cease operation immediately. */
		@SuppressWarnings("unused")
		protected final boolean isClosed() {
			return closed;
		}

		/** call this method to pause this thread */
		public void doResume() {
			stopped = false;
			doDrain = false;
			configChange = true;
			synchronized (this) {
				this.notifyAll();
			}
		}

		/** call this method to pause this thread */
		public void doStop(boolean immediate) {
			if (immediate) {
				stopped = true;
				configChange = true;
			}
			doDrain = false;
			synchronized (this) {
				if (line != null) {
					if (immediate) {
						line.stop();
						if (DEBUG) {
							debug("stopped audio device.");
						}
						line.flush();
					} else {
						if (line.isRunning()) {
							doFadeOut = true;
						}
					}
				}
				if (!doFadeOut) {
					stopped = true;
					configChange = true;
				}
				this.notifyAll();
			}
		}

		/** call this method to terminate this thread */
		public void doClose() {
			closed = true;
			doStop(true);
			try {
				if (TRACE) {
					debug(getName() + ": waiting for audio thread to exit...");
				}
				join(2000);
				if (!isAlive()) {
					if (DEBUG) {
						debug(getName() + ": thread exited.");
					}
				} else {
					if (Debug.DEBUG) {
						debug(getName()
								+ ": thread is persistent, interrupt it");
					}
					interrupt();
					join(1000);
					if (!isAlive()) {
						if (DEBUG) {
							debug(getName() + ": thread exited.");
						}
					} else {
						if (Debug.DEBUG) {
							debug(getName() + ": could not stop thread");
						}
					}
				}
			} catch (InterruptedException ie) {
				// nothing
			} catch (Exception e) {
				// nothing
			}
		}

		/** set to true in the run loop for a smooth stop */
		private volatile boolean doDrain = false;

		/** set to true in the stop method for a smooth stop */
		private volatile boolean doFadeOut = false;

		/**
		 * main thread method: read from input, convert to byte data, write to
		 * audio device.
		 */
		@Override
		public void run() {
			if (TRACE) debug(getName() + ": started.");
			AudioFormat localFormat = format;
			SourceDataLine localLine = null;
			FloatSampleInput localInput = input;
			configChange = true;
			boolean doFadeIn = false;
			OutputStream debugOut = null;
			if (DEBUG_WRITE_TO_FILE) {
				try {
					debugOut = new FileOutputStream("mixblendr.pcm");
				} catch (FileNotFoundException fnfe) {
				}
			}
			try {
				while (!closed) {
					if (stopped || configChange) {
						configChange = false;
						localInput = input;
						if (doDrain) {
							doDrain = false;
							stopped = true;
							if (!closed && localLine != null
									&& localLine.isRunning()) {
								if (TRACE) debug(getName() + ": playing out...");
								localLine.drain();
								localLine.stop();
								localLine.flush();
								if (DEBUG) {
									debug(getName() + ": audio device stopped");
								}
							}
						}
						if (localLine != line) {
							if (TRACE) debug(getName()
									+ ": configuring audio device");
							localLine = line;
							if (localLine != null && !closed) {
								localFormat = format;
								createBuffers();
							}
						}
						if ((stopped || localLine == null || localInput == null)
								&& !closed) {
							if (DEBUG) {
								String reason = "";
								if (stopped) {
									reason = "stopped, ";
								}
								if (localLine == null) {
									reason += "device not open,";
								}
								if (localInput == null) {
									reason += "no input line, ";
								}
								debug(getName() + ": " + reason
										+ " waiting for start");
							}
							synchronized (this) {
								wait();
							}
							if (TRACE) debug(getName() + ": woke up");
						}
						if (!stopped && localLine != null
								&& !localLine.isRunning() && !doFadeIn) {
							// init playback with a couple zero samples to
							// prevent click
							int len = (int) (state.getSampleRate() / 400)
									* localLine.getFormat().getFrameSize();
							if (len > byteBuffer.length) {
								len = byteBuffer.length;
							}
							if (DEBUG) {
								debug("Writing "
										+ len
										+ " samples silence at beginning of playback");
							}
							for (int i = 0; i < len; i++) {
								byteBuffer[i] = 0;
							}
							localLine.flush();
							localLine.write(byteBuffer, 0, len);
							localLine.start();
							doFadeIn = true;
						}
					} else if (localLine != null) {
						// read from the input line
						if (localInput != null) {
							localInput.read(floatBuffer);
							if (doFadeIn) {
								floatBuffer.linearFade(0, 1);
								if (TRACE) debug(getName() + ": doing fade-in");
								doFadeIn = false;
							} else if (doFadeOut) {
								floatBuffer.linearFade(1, 0);
								if (TRACE) debug(getName() + ": doing fade-out");
								doFadeOut = false;
								doDrain = true;
								configChange = true;
							}
						}
						// convert to byte
						int n = floatBuffer.convertToByteArray(byteBuffer, 0,
								localFormat);
						if (!stopped) {
							// write the audio data to soundcard
							if (!localLine.isRunning()) {
								localLine.start();
							}
							localLine.write(byteBuffer, 0, n);
							if (debugOut != null) {
								debugOut.write(byteBuffer, 0, n);
							}
							// update the state with this new buffer
							state.bufferWrittenToOutput();
						}
					}
				}
			} catch (Throwable t) {
				if (!closed) {
					if (fatalExceptionListener != null) {
						fatalExceptionListener.fatalExceptionOccured(t,
								getName());
					} else {
						error(t);
					}
				}
			}
			if (TRACE) debug(getName() + ": exit.");
			closed = true;
			if (debugOut != null) {
				try {
					debugOut.close();
				} catch (IOException ioe) {
				}
			}
		}
	}

}
