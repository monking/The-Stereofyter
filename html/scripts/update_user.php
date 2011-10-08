<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['id'])) die('{"error":"no user id given"}');
session_start();
if (!isset($_SESSION['user'])
|| !isset($_SESSION['user']['id'])
|| $_REQUEST['id'] != $_SESSION['user']['id'])
	die('{"error":"log in as this user before updating"}');

$update_data = array();
if (isset($_REQUEST['password']) && isset($_REQUEST['password2']) && isset($_REQUEST['old_password'])) {
	if ($_REQUEST['password'] != $_REQUEST['password2'])
		die('{"error":"new passwords don\'t match"}');
	$update_data['password'] = $_REQUEST['password'];
	$update_data['old_password'] = $_REQUEST['old_password'];
}
$saved = update_user($_SESSION['id'], $update_data);
if (!$saved)
	die('{"error":"'.implode('; ', $ERROR).'"}');
else
	{
	printf('{"user":{');
	printf('"id":"'.$_SESSION['user']['id'].'"');
	printf('"username":"'.$_SESSION['user']['username'].'"');
	printf('"name":"'.$_SESSION['user']['name'].'"');
	printf('"email":"'.$_SESSION['user']['email'].'"');
	printf('"country":"'.$_SESSION['user']['country'].'"');
	printf('"musician":"'.$_SESSION['user']['musician'].'"');
	printf('"subscribe_updates":"'.$_SESSION['user']['subscribe_updates'].'"');
	printf('"created":"'.$_SESSION['user']['created'].'"');
	printf('}');
	}

?>