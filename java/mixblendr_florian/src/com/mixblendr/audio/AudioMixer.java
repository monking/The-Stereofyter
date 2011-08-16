/**
 *
 */
package com.mixblendr.audio;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.tritonus.share.sampled.FloatSampleBuffer;
import org.tritonus.share.sampled.FloatSampleInput;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.mixblendr.audio.AudioTrack.SoloState;
import com.mixblendr.util.XmlPersistent;

import static com.mixblendr.util.Debug.*;

/**
 * Class for mixing several Track objects to one stream that's provided to the
 * AudioOutput.
 * 
 * @author Florian Bomers
 */
public class AudioMixer implements FloatSampleInput, XmlPersistent {

	private final static boolean TRACE = false;
	private final static boolean TRACE_FADE = false;
	private final static boolean DEBUG_LOOPING = false;

	/** the zipped filename in the zipped .mixblendr output file */
	private static final String EXPORT_XML_ZIP_ENTRIES = "mixblendr.xml";
	/** the root XML element when exporting/importing the timeline */
	public static String EXPORT_XML_ROOT_ELEMENT = "Mixblendr";

	/** list of tracks that are read from */
	private List<AudioTrack> tracks;

	/** a temporary audio buffer used while reading */
	private FloatSampleBuffer scratchBuffer;

	private AudioState state;

	/**
	 * Create an instance of the AudioMixer
	 */
	public AudioMixer(AudioState state) {
		tracks = new ArrayList<AudioTrack>();
		this.state = state;
		trackChange = true;
	}

	// TRACK MANAGEMENT

	/**
	 * @return the number of tracks
	 */
	public final int getTrackCount() {
		return tracks.size();
	}

	/**
	 * Return the index track.
	 * 
	 * @param index the index of the list of tracks
	 * @return the track at the specified index, or null if index is out of
	 *         range
	 */
	public final AudioTrack getTrack(int index) {
		if (index < 0 || index >= tracks.size()) {
			return null;
		}
		return tracks.get(index);
	}

	/**
	 * Return the index of the given track in the list of tracks.
	 * 
	 * @param at the track to get the index
	 * @return the index of the track, or -1 if the track is not found
	 */
	public final int getTrackIndex(AudioTrack at) {
		return tracks.indexOf(at);
	}

	/**
	 * Add a new track. In play mode, this track will start playing immediately.
	 * 
	 * @param t the track to add
	 */
	public synchronized void addTrack(AudioTrack t) {
		if (t != null) {
			tracks.add(t);
			// no need to call updateTrackIndices(), since only adding to the
			// end
			t.index = tracks.size() - 1;
			updateSoloState();
			trackChange = true;
		}
	}

	/**
	 * @return true if no tracks or only empty tracks are loaded. automation
	 *         data is not considered, only audio regions.
	 */
	public synchronized boolean isEmpty() {
		if (tracks.size() == 0) {
			return true;
		}
		for (AudioTrack t : tracks) {
			if (t.getPlaylist().getAudioRegionCount() > 0) {
				return false;
			}
		}
		return true;
	}

	/**
	 * @return the number of samples of the longest track. Also automation data
	 *         can extend the duration.
	 */
	public synchronized long getDurationSamples() {
		long res = 0;
		for (AudioTrack t : tracks) {
			res += t.getPlaylist().getDurationSamples();
		}
		return res;
	}

	/** get the start time, in seconds, of the first region in all tracks. */
	public synchronized double getStartTimeSeconds() {
		double time = -1;
		for (AudioTrack t : tracks) {
			double trackTime = t.getPlaylist().getStartTimeSeconds();
			if (trackTime > -1) {
				if (time == -1 || time > trackTime) {
					time = trackTime;
				}
			}
		}
		return time;
	}

	/**
	 * Remove the track.
	 * 
	 * @param t the track to remove
	 * @return if the track was actually removed
	 */
	public synchronized boolean removeTrack(AudioTrack t) {
		boolean ret = false;
		if (t != null) {
			ret = tracks.remove(t);
			if (ret) {
				updateSoloState();
				updateTrackIndices();
				trackChange = true;
			}
			t.index = -1;
		}
		return ret;
	}

	/**
	 * Remove the track identified by the index.
	 * 
	 * @param index the index of the track to remove
	 * @return if the track was actually removed
	 */
	public synchronized boolean removeTrack(int index) {
		return removeTrack(getTrack(index));
	}

	/**
	 * Remove all tracks
	 */
	public synchronized void clear() {
		for (AudioTrack t : tracks) {
			t.index = -1;
		}
		tracks.clear();
		trackChange = true;
		updateSoloState();
	}

	/**
	 * @return a non-modifiable view of the list of tracks
	 */
	public synchronized List<AudioTrack> getTracks() {
		return Collections.unmodifiableList(tracks);
	}

	/**
	 * Move the selected track up or down in the list of tracks. If the track
	 * cannot be moved because it's already at top/bottom, this method returns
	 * false.
	 * 
	 * @param trackIndex the track to move
	 * @param up if true, move the track up, otherwise move it down.
	 * @return true if the track was actually moved
	 */
	public synchronized boolean moveTrack(int trackIndex, boolean up) {
		int newIndex = up ? trackIndex - 1 : trackIndex + 1;
		AudioTrack otherTrack = getTrack(newIndex);
		AudioTrack thisTrack = getTrack(trackIndex);
		if (otherTrack == null || thisTrack == null) {
			return false;
		}
		tracks.set(newIndex, thisTrack);
		tracks.set(trackIndex, otherTrack);
		updateTrackIndices();
		trackChange = true;
		return true;
	}

	/**
	 * update the index field of all the tracks. Should be called after each
	 * change to the list of tracks
	 */
	private synchronized void updateTrackIndices() {
		for (int i = 0; i < tracks.size(); i++) {
			tracks.get(i).index = i;
		}
	}

	// SOLO MANAGEMENT

	/**
	 * Return the currently solo'd tracks.<br>
	 * 
	 * @return the list of solo tracks, or an empty list if no solo
	 */
	public synchronized List<AudioTrack> getSoloTracks() {
		ArrayList<AudioTrack> ret = new ArrayList<AudioTrack>();
		for (AudioTrack t : tracks) {
			if (t.getSolo() == SoloState.SOLO) {
				ret.add(t);
			}
		}
		return ret;
	}

	/**
	 * A track is audible if not muted, and not in NO_SOLO state. A SOLO state
	 * will override the mute state.
	 * 
	 * @param isSolo if true, set this track to solo, otherwise remove the solo
	 *        flag
	 */
	public void setSolo(AudioTrack track, boolean isSolo) {
		if (track != null) {
			track.setSoloImpl(isSolo ? SoloState.SOLO : SoloState.NONE);
		}
		updateSoloState();
	}

	/**
	 * A track is audible if not muted, and not in NO_SOLO state. A SOLO state
	 * will override the mute state.
	 * 
	 * @param trackIndex the index of the track to change solo state
	 * @param isSolo if true, set this track to solo, otherwise remove the solo
	 *        flag
	 */
	public void setSolo(int trackIndex, boolean isSolo) {
		setSolo(getTrack(trackIndex), isSolo);
	}

	/**
	 * go through all tracks and see if there is any solo'd track. If yes, set
	 * all other tracks to OTHER_SOLO so that they're muted. This function
	 * should be called whenever a track's solo state is changed, or when
	 * removing or adding tracks.
	 */
	protected synchronized void updateSoloState() {
		// first find out if SOLO at all
		boolean hasSolo = false;
		for (AudioTrack t : tracks) {
			if (t.getSolo() == SoloState.SOLO) {
				hasSolo = true;
				break;
			}
		}
		// then set the other tracks accordingly.
		for (AudioTrack t : tracks) {
			if (!hasSolo) {
				t.setSoloImpl(SoloState.NONE);
			} else if (t.getSolo() != SoloState.SOLO) {
				t.setSoloImpl(SoloState.OTHER_SOLO);
			}
		}
	}

	// FLOATAUDIOINPUT methods

	/**
	 * Will just return the AudioState's channels.
	 * 
	 * @see org.tritonus.share.sampled.FloatSampleInput#getChannels()
	 */
	public int getChannels() {
		return state.getChannels();
	}

	/**
	 * Will just return the AudioState's sample rate.
	 * 
	 * @see org.tritonus.share.sampled.FloatSampleInput#getSampleRate()
	 */
	public float getSampleRate() {
		return state.getSampleRate();
	}

	/**
	 * NOT USED: This implementation is never done (returns silence if no input
	 * tracks are registered)
	 * 
	 * @see org.tritonus.share.sampled.FloatSampleInput#isDone()
	 */
	public boolean isDone() {
		return false;
	}

	/**
	 * if set, read will first read a couple of samples from the current
	 * position for fade out, then jump to the requested position and read from
	 * there
	 */
	private long requestedNewPositionSamples = -1;

	/** serialize access to requestedNewPositionSamples field */
	private Object newPositionLock = new Object();

	/**
	 * remember this new position. The next read() call will then fade from the
	 * old playback pos to the new one and update state accordingly
	 */
	void setRequestedPlaybackPosition(long newPos) {
		synchronized (newPositionLock) {
			requestedNewPositionSamples = newPos;
		}
	}

	/**
	 * use a local copy of the track list to not lock the tracks list during
	 * processing
	 */
	private AudioTrack[] trackCache = null;

	/** set when the order or contents of the tracks changed */
	private volatile boolean trackChange = false;

	private FloatSampleBuffer fadeOutBuffer = null;

	/** return number of samples to perform the fade */
	private int getFadeSampleCount() {
		return ((int) state.getSampleRate()) / 400;
	}

	/**
	 * Main mixing method: go through all tracks and mix them together.
	 * 
	 * @see org.tritonus.share.sampled.FloatSampleInput#read(org.tritonus.share.sampled.FloatSampleBuffer,
	 *      int, int)
	 */
	public void read(FloatSampleBuffer buffer, int offset, int sampleCount) {
		// use a local copy of the tracks to not lock this class unneccessarily
		if (trackChange) {
			trackChange = false;
			synchronized (this) {
				int trackCount = tracks.size();
				if (trackCache == null || trackCache.length != trackCount) {
					trackCache = new AudioTrack[trackCount];
				}
				trackCache = tracks.toArray(trackCache);
			}
		}

		if (scratchBuffer == null) {
			scratchBuffer = new FloatSampleBuffer(buffer.getChannelCount(),
					sampleCount, buffer.getSampleRate());
		} else {
			scratchBuffer.init(buffer.getChannelCount(), sampleCount,
					buffer.getSampleRate());
		}

		long samplePos = state.getSampleSlicePosition();

		long requestedNewPosition;
		synchronized (newPositionLock) {
			requestedNewPosition = requestedNewPositionSamples;
			requestedNewPositionSamples = -1;
		}

		long nextSlicePos;
		if (requestedNewPosition >= 0) {
			nextSlicePos = requestedNewPosition;
		} else {
			nextSlicePos = samplePos + sampleCount;
		}

		// read each track
		boolean first = true;
		if (TRACE) onnl("<");
		for (AudioTrack t : trackCache) {
			if (TRACE) onnl("" + t.index + "y,");
			// read this track, including looping and microfades for
			// click-prevention
			nextSlicePos = readImpl1(samplePos, requestedNewPosition, t,
					scratchBuffer, 0, sampleCount);
			// then apply this track's effects
			t.readEffects(samplePos, scratchBuffer);
			if (first) {
				// copy first track directly into the outgoing buffer
				scratchBuffer.copyTo(buffer, offset, sampleCount);
				first = false;
			} else {
				// mix to the outgoing buffer
				buffer.mix(scratchBuffer, 0, offset, sampleCount);
			}
		}
		if (first) {
			if (TRACE) onnl("s");
			// if nothing was written to buffer, silence it
			buffer.makeSilence(offset, sampleCount);
		}
		if (TRACE) onnl(">");

		// init new position
		state.setSampleSlicePosition(nextSlicePos);
	}

	/**
	 * read at the current position, handling looping.
	 * 
	 * @return the next sample position
	 */
	private long readImpl1(long samplePos, long requestedNewPosition,
			AudioTrack track, FloatSampleBuffer buffer, int offset,
			int sampleCount) {
		// handle looping
		if (state.isLoopEnabled()) {
			long loopEnd = state.getLoopEndSamples();
			if (requestedNewPosition >= 0 && requestedNewPosition <= loopEnd
					&& (requestedNewPosition + sampleCount) > loopEnd) {
				// special case: user changed position just before a loop
				// position: loop directly back
				requestedNewPosition = state.getLoopStartSamples();
			} else if (requestedNewPosition < 0 && samplePos <= loopEnd
					&& (samplePos + sampleCount) > loopEnd) {
				// this buffer is the loop region
				int count = (int) (loopEnd - samplePos);
				if (count > 0) {
					readImpl2(samplePos, requestedNewPosition, track, buffer,
							offset, count);
				}
				if (DEBUG_LOOPING && track.index == 0) {
					debug("Looping: play " + count + " samples from end, and "
							+ (sampleCount - count)
							+ " samples from looped-back position");
				}
				sampleCount -= count;
				offset += count;
				requestedNewPosition = state.getLoopStartSamples();
			}
		}
		long ret;
		if (sampleCount > 0) {
			ret = readImpl2(samplePos, requestedNewPosition, track, buffer,
					offset, sampleCount);
		} else {
			if (requestedNewPosition < 0) {
				ret = samplePos;
			} else {
				ret = requestedNewPosition;
			}
		}
		return ret;
	}

	/**
	 * read at the current position, and cross-fade if jumping
	 * 
	 * @return the next playback position
	 */
	private long readImpl2(long samplePos, long requestedNewPosition,
			AudioTrack track, FloatSampleBuffer buffer, int offset,
			int sampleCount) {
		boolean doFade = false;
		// if true, only mix to buffer, do not overwrite
		if (requestedNewPosition >= 0) {
			// read at the old position and then perform a fade-out
			if (fadeOutBuffer == null) {
				fadeOutBuffer = new FloatSampleBuffer(buffer.getChannelCount(),
						getFadeSampleCount(), buffer.getSampleRate());
			}
			track.readSource(samplePos, fadeOutBuffer, 0,
					fadeOutBuffer.getSampleCount());
			doFade = true;
			samplePos = requestedNewPosition;
		}

		// read full buffer
		track.readSource(samplePos, buffer, offset, sampleCount);

		if (doFade) {
			int fadeLen;
			if (fadeOutBuffer != null) {
				fadeLen = fadeOutBuffer.getSampleCount();
			} else {
				fadeLen = getFadeSampleCount();
			}
			if (fadeLen > sampleCount) {
				fadeLen = sampleCount;
			}
			// perform fade-in on current buffer (not many samples to keep
			// "snappy" loops)
			buffer.linearFade(0, 1, offset, fadeLen / 2);
			// perform fade on fade out buffer
			fadeOutBuffer.linearFade(1, 0, 0, fadeLen);
			// mix fade-buffer to this buffer
			buffer.mix(fadeOutBuffer, 0, offset, fadeLen);
			if (TRACE_FADE) onnl("MixerFade ");
		}
		return samplePos + sampleCount;

	}

	/*
	 * (non-Javadoc)
	 * @see
	 * org.tritonus.share.sampled.FloatSampleInput#read(org.tritonus.share.sampled
	 * .FloatSampleBuffer)
	 */
	public void read(FloatSampleBuffer buffer) {
		read(buffer, 0, buffer.getSampleCount());
	}

	// PERSISTENCE
	
	/**
	 * Export the tracks and their contents to an XML file. If file exists, it
	 * is overwritten. Throws an exception on error.
	 * 
	 * @throws IOException on i/o error
	 * @throws ParserConfigurationException on XML error
	 * @throws TransformerException
	 * @throws TransformerFactoryConfigurationError
	 */
	public void xmlExport(File file) throws IOException,
			ParserConfigurationException, TransformerFactoryConfigurationError,
			TransformerException {
		OutputStream os = new FileOutputStream(file);
		try {
			xmlExport(os);
		} finally {
			os.close();
		}
	}

	/**
	 * Export the tracks and their contents to an XML file. Throws an exception
	 * on error. The stream is not closed by this implementation, but since
	 * binary data (ZIP) is written, you should not prepend or append any data
	 * to it.
	 */
	public void xmlExport(OutputStream stream)
			throws ParserConfigurationException,
			TransformerFactoryConfigurationError, TransformerException, IOException {
		ZipOutputStream zip = new ZipOutputStream(stream);
		zip.putNextEntry(new ZipEntry(EXPORT_XML_ZIP_ENTRIES));
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		Document doc = builder.newDocument();
		Element root = doc.createElement(EXPORT_XML_ROOT_ELEMENT);
		xmlExport(root);
		doc.appendChild(root);

		// write to file using transformer
		Source source = new DOMSource(doc);
		Result result = new StreamResult(zip);
		Transformer transformer = TransformerFactory.newInstance().newTransformer();
		transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
		transformer.transform(source, result);
		zip.closeEntry();
		zip.finish();
		zip.flush();
	}

	/**
	 * Export the state and the entire timeline to the given element.
	 * 
	 * @param element the element to export to
	 * @see com.mixblendr.util.XmlPersistent#xmlImport(org.w3c.dom.Element)
	 */
	public synchronized Element xmlExport(Element element) {
		if (!element.getTagName().equals(EXPORT_XML_ROOT_ELEMENT)) {
			element = (Element) element.appendChild(element.getOwnerDocument().createElement(
					EXPORT_XML_ROOT_ELEMENT));
		}
		element.getOwnerDocument().createComment("Exported " + (new Date()).toString());
		state.xmlExport(element);
		for (AudioTrack t : tracks) {
			t.xmlExport(element);
		}
		return element;
	}

	/**
	 * Import all tracks and their contents from an XML file. At first, all
	 * tracks and settings of this mixer are deleted. Throws an exception on
	 * error.
	 */
	public void xmlImport(File file) throws Exception {
		InputStream is = new FileInputStream(file);
		try {
			xmlImport(is);
		} finally {
			is.close();
		}
	}

	/**
	 * Import all tracks and their contents from an XML file. At first, all
	 * tracks and settings of this mixer are deleted. The stream is not closed
	 * after reading it. Throws an exception on error.
	 */
	public void xmlImport(InputStream stream) throws Exception {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = factory.newDocumentBuilder();
		ZipInputStream zip = new ZipInputStream(stream);
		while (true) {
			ZipEntry entry = zip.getNextEntry();
			if (entry == null) {
				throw new Exception("Not a valid " + EXPORT_XML_ROOT_ELEMENT + " file.");
			}
			if (entry.getName().equalsIgnoreCase(EXPORT_XML_ZIP_ENTRIES)) {
				Document doc = builder.parse(zip);
				xmlImport(doc.getDocumentElement());
				break;
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * @see com.mixblendr.util.XmlPersistent#xmlImport(org.w3c.dom.Element)
	 */
	public void xmlImport(Element element) throws Exception {
		assert (element.getTagName().equals(EXPORT_XML_ROOT_ELEMENT));
		clear();

		// go through all child elements
		NodeList nodes = element.getChildNodes();
		for (int i = 0; i < nodes.getLength(); i++) {
			Node node = nodes.item(i);
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				Element child = (Element) node;
				if (child.getTagName().equalsIgnoreCase(
						AudioState.EXPORT_XML_ELEMENT)) {
					// read state
					state.xmlImport(child);
				} else if (child.getTagName().equalsIgnoreCase(
						AudioTrack.EXPORT_XML_ELEMENT)) {
					// read track
					addTrack(new AudioTrack(state, child));
				}
			}
		}
		updateSoloState();
	}
}
