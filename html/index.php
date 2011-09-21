﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Stereofyte.org</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<style type="text/css" media="screen">
			html, body { height: 100%; }
			body { height: 100%; margin: 0; padding: 0; /*overflow: hidden;*/ }
			#app_container { width: 100%; height: 100%; min-height: 740px; min-width: 1000px; margin: 0 auto; }
			#sfapp { outline:none; position: relative; z-index: 1; min-height: 740px; min-width: 1000px; }
			#mbapp { position: absolute; width: 1px; height: 1px; bottom: 0; left: 0; z-index: 0; }
			/* debug **
			#app_container { width: 1000px; height: 740px; min-height: 740px; min-width: 1000px; margin: 0; }
			#mbapp { position: absolute; width: 1000px; height: 500px; top: 0; left: 1000px; z-index: 2; }
			** debug */
		</style>
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript" src="js/javaobject.js"></script>
		<script type="text/javascript" src="js/mixblendr.js"></script>
		<script type="text/javascript">
			function loadMixblendr() {
				embedMixblendr( {
					containerId: "mbapp",
					id: "mixblendr",
					code: "com/mixblendr/gui/main/Applet",
					archive: "mixblendr/mixblendr.jar?TIMESTAMP="+(new Date()).getTime(),
/*
					width: 1,
					height: 1,
*/
					width: 1000,
					height: 500,
					params: {
						url: "mixblendr/competition/getfile",
						REDIRECT_URL: "mixblendr/competition/competition-entries/",
						DEFAULT_TEMPO: "120.0"
					}
				} );
			};
			var flashvars = {
				samplelist:"samples.json.php"
			};
			var attributes = {
				menu: "false"
			};
			swfobject.embedSWF(
				"swf/main.swf",
				"sfapp",
				"100%",
				"100%",
				"9.0.0",
				"swf/expressInstall.swf",
				flashvars,
				null,
				attributes,
				function(e){
					e.success && mbinterface.addEventListenerObject(e.ref);
				}
			);
		</script>
	</head>
	<body>
		<div id="app_container">
			<div id="sfapp">
				<h1>Alternative content</h1>
				<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
			</div>
		</div>
		<div id="mbapp">
			<!--<applet CODE="com/mixblendr/gui/main/Applet" ARCHIVE="mixblendr/mixblendr.jar" WIDTH="800" HEIGHT="600" ALT="Your browser is not configured to view the applet. Please install Jave Runtime JRE 1.5 or higher." id="mixblendr"><PARAM name="url" value="competition/getfile"><PARAM name="REDIRECT_URL" value="competition/competition-entries/"><PARAM name="DEFAULT_TEMPO" value="120.0"></applet>-->
		</div>
	</body>
</html>
