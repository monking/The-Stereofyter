<?php

$INCLUDE = array('sf/user', 'url');
require_once('../inc/includes.php');

if ($_POST['hash']) {
	$hash = $_POST['hash'];
	$user_id = NULL;
} else {
	if (!isset($_POST['id'])) return 'no user id given';
	session_start();
	if (!isset($_SESSION['user'])
	|| !isset($user->id)
	|| $_POST['id'] != $user->id)
		return 'log in as this user before updating';

	$hash = NULL;
	$user_id = $_SESSION['id'];
}
$update_data = array();
if (isset($_POST['password'])) {
	if (isset($_POST['password2']) && $_POST['password'] != $_POST['password2'])
		return 'new passwords don\'t match';
	if (!$hash) {
		if (!isset($_POST['old_password']))
			return 'please provide the old password';
		if (!check_user_pass($user_id, $old_password))
			return 'incorrect existing password';
	}
	$update_data['password'] = $_POST['password'];
}
if (isset($_POST['username'])) $update_data['username'] = $_POST['username'];
if (isset($_POST['name'])) $update_data['name'] = $_POST['name'];
if (isset($_POST['email'])) $update_data['email'] = $_POST['email'];
if (isset($_POST['country'])) $update_data['country'] = $_POST['country'];
if (isset($_POST['musician'])) $update_data['musician'] = $_POST['musician'];
if (isset($_POST['subscribe_updates'])) $update_data['subscribe_updates'] = $_POST['subscribe_updates'];

update_user($user_id, $update_data, $hash);

if ($ERROR)
	if(isset($_POST['fail'])) {
		header('Location: '.url_append_get($_POST['fail'], 'error='.$ERROR));
	} else {
		header('Content-type: application/json; charset=utf-8');
		printf('{"error":"'.implode('; ', $ERROR).'"}');
	}
else if(isset($_POST['success'])) {
	header('Location: '.$_POST['success']);
} else {
	header('Content-type: application/json; charset=utf-8');
	printf('{"user":{');
	printf('"id":"'.$user->id.'"');
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
