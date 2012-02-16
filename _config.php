<?php
ini_set('display_errors', true);
define('DEBUG', FALSE);
define('MIXER_APP_VERSION', '06003');
define('MIXER_ENGINE_VERSION', '0103');
require_once('html/inc/includes.php');
depends(
  'database.class',
  'forum.class',
  'user.class'
);
$db = new Database();
$user = new User(json_decode(@$_COOKIE['user']));
$forum = new Forum(array(
  'table'=>'forum'
));
if (strpos($_SERVER['SERVER_NAME'], 'local') !== FALSE) {
  $db->connect(array(
    'host'=>'127.0.0.1',
    'user'=>'forum',
    'pass'=>'australia',
    'name'=>'stereofyter'
  ));
} elseif (strpos($_SERVER['SERVER_NAME'], 'chrislovejoy.com') !== FALSE) {
  $db->connect(array(
    'host'=>'internal-db.s7816.gridserver.com',
    'user'=>'db7816_stereofy',
    'pass'=>'australia',
    'name'=>'db7816_stereofyte'
  ));
} else {
  $db->connect(array(
    'host'=>'internal-db.s85217.gridserver.com',
    'user'=>'db85217_sfweb',
    'pass'=>'australia',
    'name'=>'db85217_stereofyte_app'
  ));
}

?>
