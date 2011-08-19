/**
 *
 */
package com.mixblendr.gui.main;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import javax.swing.JApplet;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;

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
						
						// commenting to hide UI
						Applet.this.setContentPane(main.getMasterPanel());

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
	 * @param beat
	 */
	private List<AudioRegion> regions = null;
	
	public int addRegion(final int trackIndex, final String url, float beats) {
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
	
	public AudioRegion getRegion(int index, int trackIndex) {
		return (AudioRegion) main.getGlobals().getPlayer().getMixer().getTrack(trackIndex).getPlaylist().getObject(index);
	}
	
	/**
	 * remove a region from a track.
	 * @param id
	 * @param trackIndex
	 * @param beat
	 */
	public AudioRegion removeRegion(int id, int trackIndex) {
		Playlist playlist = main.getGlobals().getPlayer().getMixer().getTrack(trackIndex).getPlaylist();
		AudioRegion region = (AudioRegion) playlist.getObject(id);
		playlist.removeObject(region);
		main.updateTracks();
		return region;
	}
	
	/**
	 * Move a region to a track at the given index.
	 * @param id
	 * @param fromTrackIndex
	 * @param trackIndex
	 * @param beat
	 */
	public int moveRegion(int id, int fromTrackIndex, int trackIndex, float beats) {
		AudioRegion region = removeRegion(id, fromTrackIndex);
		region.setStartTimeSamples(getSamplesFromBeats(beats));
		Playlist playlist = main.getGlobals().getPlayer().getMixer().getTrack(trackIndex).getPlaylist();
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
	
	/*
	public boolean isPlaying() {
		return main.getGlobals().getPlayer().getOutput().IsPlaying();
	}
	*/
	
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
