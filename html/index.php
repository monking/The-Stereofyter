<?php
require_once('../config.php');
depends('sf/user');
$CSS = array('home', 'pop', 'forum');
$JS = array('jquery', 'swfobject', 'javaobject', 'mixblendr', 'pop', 'forum', 'home');

include 'views/header.php';
?>
        <script type="text/javascript">
            var flashvars = {
                user:"<?=str_replace('"', '\"', json_encode((object) $user->data));?>",
                webRoot:"http://<?=$_SERVER['SERVER_NAME'];?>",
                sampleListUrl:"scripts/samples.json.php",
                mixListUrl:"scripts/my_mixes.json.php",
                countryListUrl:"js/country_codes.json",
                saveUrl:"scripts/save_mix.php",
                loadUrl:"scripts/load_mix.php",
                registerUrl:"scripts/newsletter_signup.php"<?
$demoMix = $db->get_assoc(
  array(
    'table'=>'sf_mixes',
    'fields'=>array('id'),
    'where' => array(
      'title'=>'TheDemoMix'
    ),
    'limit'=>1
  )
);
$demoMix = count($demoMix) ? $demoMix[0] : array();
if ($demoMix && is_numeric($demoMix['id'])):?>,
                demoMixID:"<?=$demoMix['id']?>"<?
endif;
if (isset($_GET['mix'])):?>,
                loadMix:"<?=$_GET['mix']?>"<?
endif; ?>

            };
            var flashparams = {
                wmode:"<?=/*TODO: remove this*/(isset($_GET['wmode'])? $_GET['wmode']: 'transparent')?>"
            };
            swfobject.embedSWF(
                "swf/main.swf?v<?=MIXER_APP_VERSION?>",
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
            <div id="sfapp_loading">
                Welcome to <strong>The Stereofyter</strong> - a place to meet the world, one loop at a time.<br />
                <img src="/images/site_loading.png" width="268" height="226" /><br />
                <span class="loading">loading...</span>
            </div>
            <div id="sfapp">
                <div class="noflash">
                    <h1>Stereofyter requires Adobe Flash.</h1>
                    <p>Please update your browser's Flash plugin by clicking the button below.</p>
                    <p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
                </div>
            </div>
        </div>
        <div class="page-footer">
            The Stereofyter is a project of On the Map Records (OtMR), a non-profit organization that uses music to fight stereotypes.<br />
            OtMR is fiscally sponsored by Artspire, a project of the New York Foundation for the Arts (NYFA). Visit <a href="http://www.onthemaprecords.org" target="_blank">www.onthemaprecords.org</a> for more information. 
        </div>
        <div id="mbapp">
            <applet CODE="com/mixblendr/gui/main/Applet" ARCHIVE="mixblendr/mixblendr.jar?v<?=MIXER_ENGINE_VERSION?>" WIDTH="1" HEIGHT="1" ALT="Your browser is not configured to view the applet. Please install Jave Runtime JRE 1.5 or higher. www.java.com/getjava" id="mixblendr"><PARAM name="url" value="competition/getfile" /><PARAM name="REDIRECT_URL" value="competition/competition-entries/" /><PARAM name="DEFAULT_TEMPO" value="120.0" /></applet>
        </div>
        <?=$forum->markup?>
        <form id="pop_login" action="scripts/login_register.php" class="login" style="display: none;">
            <input type="hidden" name="action" value="login" />
            <h2 class="login">Log In</h2>
            <h2 class="register">Sign Up</h2>
            <div class="login notice">
                New to Stereofyter? <a href="#" class="toggle-register">Sign Up</a>.
            </div>
            <div class="register notice">
                Already registered? <a href="#" class="toggle-login">Log In</a>.
            </div>
            <div class="line">
                <label><span class="login">Username or </span>Email Address</label>
                <input type="text" name="username" />
            </div>
            <div class="line">
                <label>Password</label>
                <input type="password" name="password" />
                <div class="hint login">
                    <a href="reset_password.php" target="_blanki">Forgot password?</a>
                </div>
            </div>
            <div class="line register">
                Retype Password<br />
                <input type="password" name="password2" />
            </div>
            <div class="line">
                <input type="submit" class="login" value="Log In" />
                <input type="submit" class="register" value="Register" />
            </div>
        </form>
        <div id="instructions" style="display: none;">
            <img src="images/instructions.jpg" width="1000" height="603" />
        </div>
<?php include 'views/footer.php'; ?>
