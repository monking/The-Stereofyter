<?php
if ($_SERVER['SERVER_NAME'] == 'local.stereofyter.org') {
  $DB_HOST = '127.0.0.1';
  $DB_USER = 'forum';
  $DB_PASS = 'australia';
  $DB_NAME = 'stereofyter';
} elseif ($_SERVER['SERVER_NAME'] == 'stereofyte.chrislovejoy.com') {
  $DB_HOST = 'internal-db.s7816.gridserver.com';
  $DB_USER = 'db7816_stereofy';
  $DB_PASS = 'australia';
  $DB_NAME = 'db7816_stereofyte';
} else {
  $DB_HOST = 'internal-db.s85217.gridserver.com';
  $DB_USER = 'db85217_sfweb';
  $DB_PASS = 'australia';
  $DB_NAME = 'db85217_stereofyte_app';
}
?>
