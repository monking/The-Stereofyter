/**
 *
 */
package com.mixblendr.gui.main;

import java.net.MalformedURLException;
import java.net.URL;
import javax.swing.JApplet;
import javax.swing.SwingUtilities;

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

            double  tempo = 96.0;
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
            //main.loadDefaultSong();
            callJS("dispatchMBEvent", "'ready'");


            SwingUtilities.invokeAndWait(new Runnable() {
				public void run() {
					Applet.this.setContentPane(main.getMasterPanel());
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
	
	/**
	 * start the player playing
	 */
	public void playerStart() {
		try {
			main.globals.getPlayer().start();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * Add a new region to a track at the given index.
	 * @param trackIndex
	 * @param url
	 * @param beat
	 */
	public void addRegion(int trackIndex, String url, float beat) {
		try {
			long pos = ((long) (beat * Main.QUARTER_BEAT * 4));
			main.globals.addRegion(main.globals.getPlayer().getMixer().getTrack(trackIndex), new URL(url), pos);
			main.updateTracks();
		} catch (Exception e) {
			callJS("alert", "'"+e+"'");
			e.printStackTrace();
		}
	}
	
}