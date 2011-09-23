<?php

header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

if (!isset($_POST['email'])) {
	die('{"error":"no email"}');
}
require_once('../inc/_config.php');
require_once('../inc/db.php');
require_once('../inc/validation.php');

$email = mysql_real_escape_string($_POST['email']);
if (!check_email_address($email)) die('{"error":"invalid email"}');
$updates = 'yes';

$result = mysql_query("SELECT COUNT(*) AS existing FROM users WHERE email='$email';");
if (!$result) die('{"error":"retry"}');
$row = mysql_fetch_assoc($result);
if ($row['existing'] > 0) {
	die('{"error":"email exists"}');
}

$query = array(
	'email' => $email,
	'created' => array('function' => 'NOW'),
	'subscribe_updates' => $updates
);
if (isset($_POST['country'])) $query[] = $_POST['country'];
if (isset($_POST['musician'])) $query[] = $_POST['musician'];
if (!assoc_to_mysql(array($query), 'INSERT', 'users')) die('{"error":"retry"}');
echo '{"status":"ok"}';

?>