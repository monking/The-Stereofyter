<?php
ini_set('display_errors', 0);
define('DEBUG', FALSE);
define('MIXER_APP_VERSION', '06003');
define('MIXER_ENGINE_VERSION', '0102');
if (strpos($_SERVER['SERVER_NAME'], 'local') !== FALSE) {
  define('DB_HOST', '127.0.0.1');
  define('DB_USER', 'forum');
  define('DB_PASS', 'australia');
  define('DB_NAME', 'stereofyter');
} elseif (strpos($_SERVER['SERVER_NAME'], 'chrislovejoy.com') !== FALSE) {
  define('DB_HOST', 'internal-db.s7816.gridserver.com');
  define('DB_USER', 'db7816_stereofy');
  define('DB_PASS', 'australia');
  define('DB_NAME', 'db7816_stereofyte');
} else {
  define('DB_HOST', 'internal-db.s85217.gridserver.com');
  define('DB_USER', 'db85217_sfweb');
  define('DB_PASS', 'australia');
  define('DB_NAME', 'db85217_stereofyte_app');
}

?>
