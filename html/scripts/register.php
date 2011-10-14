<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf', 'validation');

header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

if (!isset($_POST['email'])) {
	die('{"error":"no email"}');
}

$email = mysql_real_escape_string($_POST['email']);
if (!check_email_address($email)) die('{"error":"invalid email"}');
$updates = 'yes';

$result = mysql_query("SELECT subscribe_updates AS subscribed FROM sf_users WHERE email='$email';");
if (!$result) die('{"error":"retry","note":"'.mysql_real_escape_string(mysql_error()).'"}');

$method = 'INSERT';
if (mysql_num_rows($result)) {
	$row = mysql_fetch_assoc($result);
	if ($row['subscribed'] == 'yes')
		die('{"error":"email exists"}');
  else
		$method = 'UPDATE';
}

$query = array(
	'email' => $email,
	'subscribe_updates' => $updates
);
if (isset($_POST['country'])) $query['country'] = $_POST['country'];
if (isset($_POST['musician'])) $query['musician'] = $_POST['musician'];
if ($method == 'UPDATE')
	$query['WHERE'] = array('email' => $email);
else
	$query['created'] = array('function' => 'NOW()');
if (!assoc_to_mysql(array($query), $method, 'sf_users')) die('{"error":"retry","note":"'.mysql_real_escape_string(mysql_error()).'"}');
$message = 'You\'ve subscribed to The Stereofyter newsletter. Thanks for your interest in The Stereofyter - we\'ll let you know as updates are available.'."\n\n";
$message .= 'If you no longer wish to receive this newsletter, you can unsubscribe by pasting this link into your browser:'."\n";
$message .= 'http://'.$_SERVER['SERVER_NAME'].'/unsubscribe.php?email='.$email."\n\n";
$message .= 'Please do not reply to this email directly. You will not receive a response.';
@mail($email, 'The Stereofyter - newsletter subscription', $message, 'From:"The Stereofyter" <news@stereofyter.org>');
echo '{"status":"ok"}';

?>
