<?php
if ($_SERVER['SERVER_NAME'] == 'local.stereofyter.org') {
  $DB_HOST = '127.0.0.1';
  $DB_USER = 'root';
  $DB_PASS = '';
  $DB_NAME = 'stereofyte';
} elseif ($_SERVER['SERVER_NAME'] == 'stereofyte.chrislovejoy.com') {
  $DB_HOST = 'internal-db.s7816.gridserver.com';
  $DB_USER = 'db7816_stereofy';
  $DB_PASS = 'australia';
  $DB_NAME = 'db7816_stereofyte';
} else {
  $DB_HOST = '127.0.0.1';
  $DB_USER = 'root';
  $DB_PASS = '0';
  $DB_NAME = 'database';
}
?>
