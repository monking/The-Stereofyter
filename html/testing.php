<?php
$includes = array('layout');
$css = array('test_home');
$js = array('swfobject', 'javaobject', 'mixblendr', 'test_home');
require('inc/header.php');
?>
		<div id="app_container">
			<div id="sfapp">
				<h1>Stereofyter requires Adobe Flash.</h1>
				<p>Please update your browser's Flash plugin by clicking the button below.</p>
				<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
			</div>
		</div>
		<div class="footer">
			The Stereofyter is a project of On the Map Records (OtMR), a non-profit organization that uses music to fight stereotypes.<br />
			OtMR is fiscally sponsored by Artspire, a project of the New York Foundation for the Arts (NYFA). Visit <a href="http://www.onthemaprecords.org" target="_blank">www.onthemaprecords.org</a> for more information. 
		</div>
		<div id="mbapp">
			<applet CODE="com/mixblendr/gui/main/Applet" ARCHIVE="mixblendr/mixblendr.jar?TIMESTAMP=<?=time();?>" WIDTH="1000" HEIGHT="500" ALT="Your browser is not configured to view the applet. Please install Jave Runtime JRE 1.5 or higher." id="mixblendr"><PARAM name="url" value="competition/getfile"><PARAM name="REDIRECT_URL" value="competition/competition-entries/"><PARAM name="DEFAULT_TEMPO" value="120.0"></applet>
		</div>
<?php require('inc/footer.php'); ?>
