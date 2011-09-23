<?php
if ( $_SERVER[ 'SERVER_NAME' ] == 'local.stereofyter.org' ) {
  $DB_HOST = '127.0.0.1';
  $DB_USER = 'root';
  $DB_PASS = '';
  $DB_NAME = 'stereofyte';
} elseif ( $_SERVER[ 'SERVER_NAME' ] == 'stereofyte.chrislovejoy.com' ) {
  $DB_HOST = 'localhost';
  $DB_USER = 'user';
  $DB_PASS = 'password';
  $DB_NAME = 'my_database';
} else {
  $DB_HOST = '127.0.0.1';
  $DB_USER = 'root';
  $DB_PASS = '0';
  $DB_NAME = 'database';
}
?>
