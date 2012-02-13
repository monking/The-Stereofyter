<?php
ini_set('display_errors', true);
define('DEBUG', FALSE);
define('MIXER_APP_VERSION', '06003');
define('MIXER_ENGINE_VERSION', '0103');
global $DB_HOST, $DB_USER, $DB_PASS, $DB_NAME;
if (strpos($_SERVER['SERVER_NAME'], 'local') !== FALSE) {
  $DB_HOST ='127.0.0.1';
  $DB_USER ='forum';
  $DB_PASS ='australia';
  $DB_NAME ='stereofyter';
} elseif (strpos($_SERVER['SERVER_NAME'], 'chrislovejoy.com') !== FALSE) {
  $DB_HOST ='internal-db.s7816.gridserver.com';
  $DB_USER ='db7816_stereofy';
  $DB_PASS ='australia';
  $DB_NAME ='db7816_stereofyte';
} else {
  $DB_HOST ='internal-db.s85217.gridserver.com';
  $DB_USER ='db85217_sfweb';
  $DB_PASS ='australia';
  $DB_NAME ='db85217_stereofyte_app';
}

?>
