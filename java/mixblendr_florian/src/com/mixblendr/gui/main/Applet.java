/**
 *
 */
package com.mixblendr.gui.main;

import java.net.MalformedURLException;
import java.net.URL;

import javax.swing.JApplet;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;

import com.mixblendr.audio.AudioFile;
import com.mixblendr.audio.AudioFileDownloadListener;
import com.mixblendr.audio.AudioMixer;
import com.mixblendr.audio.AudioPlayer;
import com.mixblendr.audio.AudioRegion;
import com.mixblendr.audio.AudioTrack;
import com.mixblendr.audio.AudioPlayer.Listener;
import com.mixblendr.audio.AudioTrack.SoloState;
import com.mixblendr.audio.Playlist;
import com.mixblendr.util.Debug;

/**
 * The main GUI as an applet, modified to allow interface with JavaScript
 *
 * @author Florian Bomers
 * @author Christopher Lovejoy
 */
public class Applet extends JApplet {

	protected Main main;

	protected Exception exception;

	private AudioPlayer previewPlayer;
	private boolean IsPlaying;
	private int previewRegionIndex;
	private String previewUrl;
	private boolean previewIsPlaying;

	@Override
	public String getParameter(String arg) {
		String ret = super.getParameter(arg);
		if (ret == null) {
			return "";
		}
		return ret;
	}

	/**
	 * Method called by browser before display of the applet.
	 */
	@Override
	public void init() {
		exception = null;
		try {
			System.out.println("Start " + Main.NAME + " " + Main.VERSION);
			
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					JLabel label = new JLabel("loading, please wait...");
					label.setHorizontalAlignment(JLabel.CENTER);
					label.setOpaque(true);
					Applet.this.setContentPane(label);
				}
			});
			

		} catch (Exception e) {
			exception = e;
		}
	}

	/** called by the browser upon starting the applet */
	@Override
	public void start() {
		if (exception != null) {
			Debug.displayErrorDialog(this, exception, "at startup");
		} else {
			// the Java Plugin 6.0 kills the VM if init() or start() takes more than 30 seconds or so.
			// therefore, execute all the init stuff (which will cause loading of classes, etc.)
			// asynchronously
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					try {
						Performance.setDefaultUI();
						Performance.preload();
						main = new Main();

						String url = getParameter("URL");
						String redirectURL = getParameter("REDIRECT_URL");
						String defaultTempo = getParameter("DEFAULT_TEMPO");
						String loadURL = getParameter("LOAD_DIR_URL");
						main.createGUI();
						main.createEngine();
						main.getProgressDialog().setSaveToServerScriptURL(url);
						main.getProgressDialog().setLoadFromServerURL(loadURL);
						main.setRedirectAfterPublishURL(redirectURL);
						main.setApplet(Applet.this);

						try {
							if (defaultTempo != null && defaultTempo.length() > 0) {
								double tempo = Double.parseDouble(defaultTempo);
								main.setDefaultTempo(tempo);
							}
						} catch (NumberFormatException e) {
						}
						
						// commenting to hide UI (breaks auto-mix length measurement)
						Applet.this.setContentPane(main.getMasterPanel());

						previewPlayer = new AudioPlayer(main, new previewDownloadListener());
						previewPlayer.addListener(new JavaScriptPreviewListener());
						//previewPlayer.setLoopEnabled(true);
						previewPlayer.init();
						previewRegionIndex = -1;
						previewUrl = "";
						previewIsPlaying = false;

						main.start();
						
			            callJS("dispatchMBEvent", "'ready'");
			            main.getGlobals().getPlayer().addListener(new JavaScriptListener());
					} catch (Exception e) {
						Debug.displayErrorDialogAsync(Applet.this, e, "at startup");
					}
				}
			});
		}
	}

	/** called by the browser when the user navigates away from this page */
	@Override
	public void stop() {
		if (main != null) {
			main.stop();
		}
	}

	/** called by the browser when removing this applet completely */
	@Override
	public void destroy() {
		if (main != null) {
			main.close();
		}
	}
	
	/*
	 * Begin methods to expose for JavaScript
	 */
	
	/**
	 * Call a JavaScript function on the document.
	 * @param fn
	 * @param args:
	 */
	public void callJS(String fn, String args) {
		try {
			getAppletContext().showDocument(new URL("javascript:(function(){"+fn+".apply(this,arguments);})("+args+")"));
		}
		catch (MalformedURLException e) { }
	}
	
	public long getSamplesFromBeats(float beats) {
		return ((long) (beats * main.getGlobals().getPlayer().getMixer().getSampleRate() * 60 / main.getDefaultTempo()));
	}
	
	public float getBeatsFromSamples(long samples) {
		return ((float) (samples * main.getDefaultTempo() / main.getGlobals().getPlayer().getMixer().getSampleRate() / 60 ));
	}

	/**
	 * Add a new region to a track at the given index.
	 * @param trackIndex
	 * @param url
	 * @param beats
	 */
	public int addRegion(final int trackIndex, final String url, float beats) {
		if (previewIsPlaying) {
			previewStop();
		}
		final long pos = getSamplesFromBeats(beats);
		final AudioMixer mixer = main.getGlobals().getPlayer().getMixer();
		if (trackIndex >= mixer.getTrackCount()) {
			for (int i = mixer.getTrackCount(); i <= trackIndex; i++) {
				main.getGlobals().getPlayer().addAudioTrack();
			}
		}
		final AudioTrack track = main.getGlobals().getPlayer().getMixer().getTrack(trackIndex);
		final AudioRegion region = java.security.AccessController.doPrivileged(
		    new java.security.PrivilegedAction<AudioRegion>() {
		        public AudioRegion run() {
		        	AudioRegion newRegion = null;
		    		try {
		    			newRegion = main.getGlobals().addRegion(track, new URL(url), pos);
		    		} catch (Exception e) {
		    			e.printStackTrace();
		    		}
		    		return newRegion;
		        }
		    }
		);
		main.updateTracks();
		return track.getPlaylist().indexOf(region);
	}
	
	public AudioRegion getRegion(int regionIndex, int trackIndex) {
		return (AudioRegion) main.getGlobals().getPlayer().getMixer().getTrack(trackIndex).getPlaylist().getObject(regionIndex);
	}
	
	/**
	 * remove a region from a track.
	 * @param regionIndex
	 * @param trackIndex
	 */
	public AudioRegion removeRegion(int regionIndex, int trackIndex) {
		Playlist playlist = main.getGlobals().getPlayer().getMixer().getTrack(trackIndex).getPlaylist();
		AudioRegion region = (AudioRegion) playlist.getObject(regionIndex);
		playlist.removeObject(region);
		main.updateTracks();
		return region;
	}
	
	/**
	 * Move a region to a track at the given index.
	 * @param regionIndex
	 * @param fromTrackIndex
	 * @param trackIndex
	 * @param beat
	 */
	public int moveRegion(int regionIndex, int fromTrackIndex, int trackIndex, float beats) {
		AudioRegion region = removeRegion(regionIndex, fromTrackIndex);
		region.setStartTimeSamples(getSamplesFromBeats(beats));
		AudioPlayer player = main.getGlobals().getPlayer();
		AudioMixer mixer = player.getMixer();
		if (trackIndex >= mixer.getTrackCount()) {
			for (int i = mixer.getTrackCount(); i <= trackIndex; i++) {
				player.addAudioTrack();
			}
		}
		Playlist playlist = mixer.getTrack(trackIndex).getPlaylist();
		playlist.addObject(region);
		main.updateTracks();
		return playlist.indexOf(region);
	}
	
	public void setRegionMuted(int index, int trackIndex, boolean muted) {
		getRegion(index, trackIndex).setMuted(muted);
	}
	
	public void setRegionVolume(int index, int trackIndex, double level) {
		getRegion(index, trackIndex).setLevel(level);
	}
	
	public void startPlayback() {
		main.getGlobals().startPlayback();
	}
	
	public void stopPlayback() {
		main.getGlobals().stopPlayback();
	}
	
	public float getPlaybackPosition() {
		return getBeatsFromSamples(main.getGlobals().getPlayer().getPositionSamples());
	}
	
	public void setPlaybackPosition(float beats) {
		//boolean wasPlaying = isPlaying();
		main.getGlobals().getPlayer().setPositionSamples(getSamplesFromBeats(beats));
		//if (wasPlaying) startPlayback();
	}
	
	
	public boolean isReady() {
		return true;
	}
	
	
	public boolean isPlaying() {
		return IsPlaying;
	}
	
	
	public boolean toggleMute(int trackIndex) {
		AudioTrack track = main.getGlobals().getPlayer().getMixer().getTrack(trackIndex);
		boolean isMute = !track.isMute();
		track.setMute(isMute);
		return isMute;
	}
	
	public void toggleSolo(int trackIndex) {
		AudioMixer mixer = main.getGlobals().getPlayer().getMixer();
		boolean settingSolo = mixer.getTrack(trackIndex).getSolo() != SoloState.SOLO;
		for (int i = 0; i < mixer.getTrackCount(); i++) {
			if (settingSolo) {
				if (i == trackIndex) {
					mixer.getTrack(i).setSoloImpl(SoloState.SOLO);
				} else {
					mixer.getTrack(i).setSoloImpl(SoloState.OTHER_SOLO);
				}
			} else {
				mixer.getTrack(i).setSoloImpl(SoloState.NONE);
			}
		}
	}
	
	public void save(boolean toWeb) {
		LoadSave ls = new LoadSave(main.getGlobals());
		ls.save(toWeb);
	}
	public void load(boolean fromWeb) {
		LoadSave ls = new LoadSave(main.getGlobals());
		ls.load(fromWeb);
		main.updateAll();		
	}
	
	/**
	 * Toggle a preview of a given URL
	 * @param url
	 */
	public boolean previewToggle(String url) {
		if (previewUrl.equals(url) && previewIsPlaying) {
			previewStop();
			return false;
		} else {
			previewStart(url);
			return true;
		}
	}
	
	/**
	 * Preview a sound file
	 * @param url
	 */
	public void previewStart(final String url) {
		AudioFile af;
		final AudioTrack at;
		if (previewPlayer.getMixer().getTrackCount() == 0) {
			at = previewPlayer.addAudioTrack();
		} else {
			at = previewPlayer.getMixer().getTrack(0);
		}
		if (url != previewUrl) {
			if (previewRegionIndex != -1) {
	            callJS("dispatchMBEvent", "'previewStop', {url:'"+previewUrl+"'}");
	            callJS("dispatchMBEvent", "'previewStart', {url:'"+url+"'}");
				Playlist playlist = at.getPlaylist();
				AudioRegion region = (AudioRegion) playlist.getObject(previewRegionIndex);
				playlist.removeObject(region);
			}
			af = java.security.AccessController.doPrivileged(
			    new java.security.PrivilegedAction<AudioFile>() {
			        public AudioFile run() {
			        	AudioFile newFile = null;
			        	AudioRegion newRegion = null;
			    		try {
			    			newFile = previewPlayer.getFactory().getAudioFile(new URL(url));
			    			newRegion = at.addRegion(newFile, 0, -1);
			    			previewUrl = url;
			    			previewRegionIndex = at.getPlaylist().indexOf(newRegion);
			    		} catch (Exception e) {
			    			e.printStackTrace();
			    		}
		    			return newFile;
			        }
			    }
			);
		} else {
			AudioRegion ar = (AudioRegion) at.getPlaylist().getObject(previewRegionIndex);
			af = ar.getAudioFile();
		}
		previewIsPlaying = true;
		if (af.isFullyLoaded()) {
			try {
				previewPlayer.setPositionSamples(0);
				previewPlayer.start();
			} catch (Throwable t) {
			}
		}
	}
	
	/**
	 * stop previewing a sound file
	 */
	public void previewStop() {
		try {
			previewPlayer.stop(false);
		} catch (Throwable t) {
		}
		previewIsPlaying = false;
	}
	
	public class previewDownloadListener implements AudioFileDownloadListener {
		public void downloadStarted(AudioFile af) {
			
		}
	
		public void downloadEnded(AudioFile af) {
			if (previewIsPlaying) {
				try {
					previewPlayer.setPositionSamples(0);
					previewPlayer.start();
				} catch (Throwable t) {
				}
			}
		}
	}
	
	public class JavaScriptPreviewListener implements Listener {
		/**
		 * this event is called to registered listeners when playback starts.
		 * This event is called synchronously in the context of the thread
		 * calling the start method.
		 */
		public void onPlaybackStart(AudioPlayer player) {
			IsPlaying = true;
            callJS("dispatchMBEvent", "'previewStart', {url:'"+previewUrl+"'}");
		}

		/**
		 * this event is called to registered listeners when playback stops.
		 * This event is called synchronously in the context of the thread
		 * calling the stop method.
		 */
		public void onPlaybackStop(AudioPlayer player, boolean immediate) {
			IsPlaying = false;
			previewIsPlaying = false;
            callJS("dispatchMBEvent", "'previewStop', {url:'"+previewUrl+"'}");
		}

		/**
		 * this event is called to registered listeners when the sample position
		 * is changed in non-playback mode This event is called synchronously in
		 * the context of the thread calling the setSamplePosition() method.
		 */
		public void onPlaybackPositionChanged(AudioPlayer player, long samplePos) {
		}
		
	}
	
	public class JavaScriptListener implements Listener {
		/**
		 * this event is called to registered listeners when playback starts.
		 * This event is called synchronously in the context of the thread
		 * calling the start method.
		 */
		public void onPlaybackStart(AudioPlayer player) {
            callJS("dispatchMBEvent", "'playbackStart', {position:"+getPlaybackPosition()+"}");
		}

		/**
		 * this event is called to registered listeners when playback stops.
		 * This event is called synchronously in the context of the thread
		 * calling the stop method.
		 */
		public void onPlaybackStop(AudioPlayer player, boolean immediate) {
            callJS("dispatchMBEvent", "'playbackStop', {immediate:"+immediate+", position:"+getPlaybackPosition()+"}");
		}

		/**
		 * this event is called to registered listeners when the sample position
		 * is changed in non-playback mode This event is called synchronously in
		 * the context of the thread calling the setSamplePosition() method.
		 */
		public void onPlaybackPositionChanged(AudioPlayer player, long samplePos) {
            //callJS("dispatchMBEvent", "'playbackPositionChanged', {position:"+getBeatsFromSamples(samplePos)+"}");
            callJS("dispatchMBEvent", "'playbackPositionChanged', {position:"+getBeatsFromSamples(samplePos)+"}");
		}
		
	}

}
