<?php
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Content-type: application/json');
header('Content-type: text/html; charset=UTF-8;');

$INCLUDE = array('sf/user', 'validation', 'localization');
require_once('../inc/includes.php');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['username']) || !$_REQUEST['username']) die('{"error":"'.__('provide-email', true).'"}');
if (!validate_email_address($_REQUEST['username'])) die('{"error":"'.__('invalid-email', true).'"}');
if (check_user_exists(array('email' => $_REQUEST['username']))) die('{"error":"'.__('email-exists', true).'"}');
if (!isset($_REQUEST['password']) || !$_REQUEST['password']) die('{"error":"'.__('provide-password', true).'"}');
if (!isset($_REQUEST['action']) || !$_REQUEST['action']) die('{"error":"'.__('login-form-incomplete', true).'"}');
if ('login' == $_REQUEST['action']) {
  if (!login_user($_REQUEST['username'], $_REQUEST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
} elseif ('register' == $_REQUEST['action']) {
  if (!isset($_REQUEST['password2']) || !$_REQUEST['password2']) die('{"error":"'.__('register: retype password', true).'"}');
  if ($_REQUEST['password'] != $_REQUEST['password2']) die('{"error":"'.__('password-mismatch', true).'"}');
  if (!register_user($_REQUEST['username'], $_REQUEST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
} else {
  die('{"error":"'.__('login-form-incomplete', true).'"}');
}
echo get_session_data_json();

?>
