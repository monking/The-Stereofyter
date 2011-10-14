<?php
$includes = array('layout');
$CSS = array('home', 'pop');
$js = array('jquery', 'swfobject', 'javaobject', 'mixblendr', 'home');
require('inc/header.php');
?>
		<script type="text/javascript">
			var flashvars = {
				webRoot:"http://<?=$_SERVER['SERVER_NAME'];?>",
				sampleListUrl:"scripts/samples.json.php",
				countryListUrl:"js/country_codes.json",
				saveUrl:"scripts/save_mix.php",
				loadUrl:"scripts/load_mix.php",
				registerUrl:"scripts/register.php",
				demoMixUrl:"audio/mixes/demo_mix_01.mp3"<?
if (isset($_GET['mix'])):?>,
				loadMix:"<?=$_GET['mix']?>"<?
endif;?>
			};
			var flashparams = {
				wmode:"<?=/*TODO: remove this*/(isset($_GET['wmode'])? $_GET['wmode']: 'opaque')?>"
			};
			swfobject.embedSWF(
				"swf/main.swf",
				"sfapp",
				"100%",
				"100%",
				"9.0.0",
				"swf/expressInstall.swf",
				flashvars,
				flashparams,
				null,
				function(e){
					e.success && mbinterface.addEventListenerObject(e.ref);
				}
			);
		</script>
		<div id="app_container">
			<div id="sfapp">
				<h1>Stereofyter requires Adobe Flash.</h1>
				<p>Please update your browser's Flash plugin by clicking the button below.</p>
				<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
			</div>
		</div>
		<div class="footer">
			<div class="temp">
				<a href="#" onclick="pop('HEY THERE');return false;">test pop</a>
			</div>
			The Stereofyter is a project of On the Map Records (OtMR), a non-profit organization that uses music to fight stereotypes.<br />
			OtMR is fiscally sponsored by Artspire, a project of the New York Foundation for the Arts (NYFA). Visit <a href="http://www.onthemaprecords.org" target="_blank">www.onthemaprecords.org</a> for more information. 
		</div>
		<div id="mbapp">
			<applet CODE="com/mixblendr/gui/main/Applet" ARCHIVE="mixblendr/mixblendr.jar?TIMESTAMP=<?=time();?>" WIDTH="1" HEIGHT="1" ALT="Your browser is not configured to view the applet. Please install Jave Runtime JRE 1.5 or higher. www.java.com/getjava" id="mixblendr"><PARAM name="url" value="competition/getfile"><PARAM name="REDIRECT_URL" value="competition/competition-entries/"><PARAM name="DEFAULT_TEMPO" value="120.0"></applet>
		</div>
		<form id="pop_login" style="display: none;">
			<h2>Log In</h2>
			<div class="line">
				Username / Email Address<br />
				<input type="text" name="username" />
			</div>
			<div class="line">
				Password<br />
				<input type="password" name="password" />
				<div class="hint">
					<a href="reset_password.php" target="_blanki">Forgot password?</a>
				</div>
			</div>
			<div class="line">
				<input type="submit" value="Log In" />
			</div>
		</form>
<?php require('inc/footer.php'); ?>
