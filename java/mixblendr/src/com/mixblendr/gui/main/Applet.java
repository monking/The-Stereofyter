/**
 *
 */
package com.mixblendr.gui.main;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import javax.swing.JApplet;
import javax.swing.SwingUtilities;

import com.mixblendr.audio.AudioMixer;
import com.mixblendr.audio.AudioPlayer.Listener;
import com.mixblendr.audio.AudioPlayer;
import com.mixblendr.audio.AudioRegion;
import com.mixblendr.audio.AudioTrack;
import com.mixblendr.audio.AudioTrack.SoloState;
import com.mixblendr.util.Debug;

/**
 * The main GUI as an applet.
 * 
 * @author Florian Bomers
 */
public class Applet extends JApplet {
	
	static final long serialVersionUID = 1;

	protected Main main;

	protected Exception exception;

	/**
	 * Method called by browser before display of the applet.
	 */
	@Override
	public void init() {
		exception = null;
		try {
			System.out.println("Start " + Main.NAME + " " + Main.VERSION);
			Performance.setDefaultUI();
			Performance.preload();
            String url = getParameter("URL");
            String redirectURL = getParameter("REDIRECT_URL");
            String defaultTempo = getParameter("DEFAULT_TEMPO");
            	
            double tempo = 96.0;
            try
            {
                if (defaultTempo != null) {
                    tempo = Double.parseDouble(defaultTempo);
                }
            }
            catch (NumberFormatException e)
            {
                tempo = 96.0;
            }

            main = new Main();
            main.setDefaultTempo(tempo);
            main.createGUI();
			main.createEngine();
            main.setUrl(url);
            main.setRedirectUrl(redirectURL);
            main.setApplet(this);
            
            JavaScriptListener listener = new JavaScriptListener();
            main.globals.getPlayer().addListener(listener);
            //main.loadDefaultSong();
            callJS("dispatchMBEvent", "'ready'");

/*
 * comment out this to hide the UI
 *
            SwingUtilities.invokeAndWait(new Runnable() {
				public void run() {
					Applet.this.setContentPane(main.getMasterPanel());
				}
			});
/*
 * end UI escape
 */
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
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					main.start();
				}
			});
		}
	}

	/** called by the browser when the user navigates away from this page */
	@Override
	public void stop() {
		main.stop();
	}

	/** called by the browser when removing this applet completely */
	@Override
	public void destroy() {
		main.close();
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
		return ((long) (beats * main.globals.getPlayer().getMixer().getSampleRate() * 60 / main.getDefaultTempo()));
	}
	
	public float getBeatsFromSamples(long samples) {
		return ((float) (samples * main.getDefaultTempo() / main.globals.getPlayer().getMixer().getSampleRate() / 60 ));
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
		AudioRegion region = java.security.AccessController.doPrivileged(
		    new java.security.PrivilegedAction<AudioRegion>() {
		        public AudioRegion run() {
		        	AudioRegion newRegion = null;
		    		try {
		    			AudioMixer mixer = main.globals.getPlayer().getMixer(); 
		    			AudioTrack track = mixer.getTrack(trackIndex);
		    			int trackCount = mixer.getTrackCount();
		    			if (trackIndex >= trackCount) {
		    				for (int i = trackCount; i <= trackIndex; i++) {
		    					AudioTrack newTrack = main.globals.getPlayer().addAudioTrack();
		    					if (i == trackIndex) {
		    						track = newTrack;
		    					}
		    				} 
		    			}
		    			newRegion = main.globals.addRegion(track, new URL(url), pos);
		    		} catch (Exception e) {
		    			e.printStackTrace();
		    		}
		    		return newRegion;
		        }
		    }
		);
		main.updateTracks();
		int i = regions.size();
		regions.set(i, region);
		return i;
		
	}
	/**
	 * Move a region to a track at the given index.
	 * @param id
	 * @param trackIndex
	 * @param beat
	 */
	public void moveRegion(int id, int trackIndex, float beat) {
		long pos = getSamplesFromBeats(beat);
		AudioRegion region = regions.get(id);
		try {
			//main.globals.addRegion(main.globals.getPlayer().getMixer().getTrack(trackIndex), new URL(url), pos);
		} catch (Exception e) {
			e.printStackTrace();
		}
		main.updateTracks();
		
	}
	
	public void startPlayback() {
		main.globals.startPlayback();
	}
	
	public void stopPlayback() {
		main.globals.stopPlayback();
	}
	
	public float getPlaybackPosition() {
		return getBeatsFromSamples(main.globals.getPlayer().getPositionSamples());
	}
	
	public void setPlaybackPosition(float beats) {
		boolean wasPlaying = isPlaying();
		//if (wasPlaying) stopPlayback();
		main.globals.getPlayer().setPositionSamples(getSamplesFromBeats(beats));
		if (wasPlaying) startPlayback();
	}
	
	public boolean isPlaying() {
		return main.globals.getPlayer().getOutput().IsPlaying();
	}
	
	public boolean toggleMute(int trackIndex) {
		AudioTrack track = main.globals.getPlayer().getMixer().getTrack(trackIndex);
		boolean isMute = !track.isMute();
		track.setMute(isMute);
		return isMute;
	}
	
	public List toggleSolo(int trackIndex) {
		AudioMixer mixer = main.globals.getPlayer().getMixer();
		List tracks = null;
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
			tracks.set(i, mixer.getTrack(1).getSolo().toString());
		}
		return tracks;
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
