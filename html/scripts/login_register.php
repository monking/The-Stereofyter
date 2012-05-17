<?php

require_once('../../config.php');
depends('validation', 'localization');
header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Content-type: text/html; charset=UTF-8;');
header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['action']) || !$_REQUEST['action'])
	die(json_encode((object) array('error'=>__('login-form-incomplete', true))));

if (!isset($_REQUEST['username']) || !$_REQUEST['username']) 
	die(json_encode((object) array('error'=>__('provide-email', true))));

if (!validate_email_address($_REQUEST['username'])) 
	die(json_encode((object) array('error'=>__('invalid-email', true))));

if (!isset($_REQUEST['password']) || !$_REQUEST['password']) 
	die(json_encode((object) array('error'=>__('provide-password', true))));

if ('login' == $_REQUEST['action']) {
  if (!$user->login($_REQUEST['username'], $_REQUEST['password'])) 
	die(json_encode((object) array('error'=>implode('; ', $ERROR))));
} elseif ('register' == $_REQUEST['action']) {
  if ($user->check_user_exists(array('email' => $_REQUEST['username']))) 
	die(json_encode((object) array('error'=>__('email-exists', true))));

  if (!isset($_REQUEST['password2']) || !$_REQUEST['password2']) 
	die(json_encode((object) array('error'=>__('register: retype password', true))));

  if ($_REQUEST['password'] != $_REQUEST['password2']) 
	die(json_encode((object) array('error'=>__('password-mismatch', true))));

  if (!$user->register($_REQUEST['username'], $_REQUEST['password'])) 
	die(json_encode((object) array('error'=>implode('; ', $ERROR))));
} else {
	die(json_encode((object) array('error'=>__('login-form-incomplete', true))));
}
echo json_encode((object) $user->data);

?>
