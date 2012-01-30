<?php
//header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Content-type: application/json');
//header('Content-type: text/html; charset=UTF-8;');

$INCLUDE = array('sf/user', 'validation', 'localization', 'json');
require_once('../inc/includes.php');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['action']) || !$_REQUEST['action']) die('{"error":"'.json_escape(__('login-form-incomplete', true)).'"}');
if (!isset($_REQUEST['username']) || !$_REQUEST['username']) die('{"error":"'.json_escape(__('provide-email', true)).'"}');
if (!validate_email_address($_REQUEST['username'])) die('{"error":"'.json_escape(__('invalid-email', true)).'"}');
if (!isset($_REQUEST['password']) || !$_REQUEST['password']) die('{"error":"'.json_escape(__('provide-password', true)).'"}');
if ('login' == $_REQUEST['action']) {
  if (!login_user($_REQUEST['username'], $_REQUEST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
} elseif ('register' == $_REQUEST['action']) {
  if (check_user_exists(array('email' => $_REQUEST['username']))) die('{"error":"'.json_escape(__('email-exists', true)).'"}');
  if (!isset($_REQUEST['password2']) || !$_REQUEST['password2']) die('{"error":"'.json_escape(__('register: retype password', true)).'"}');
  if ($_REQUEST['password'] != $_REQUEST['password2']) die('{"error":"'.json_escape(__('password-mismatch', true)).'"}');
  if (check_user_exists(array('email' => $_REQUEST['username'])))die('{"error":"'.json_escape(__('user exists', true)).'"}');
  if (!register_user($_REQUEST['username'], $_REQUEST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
} else {
  die('{"error":"'.json_escape(__('login-form-incomplete', true)).'"}');
}
echo get_session_data_json();

?>