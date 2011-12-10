<?php

$INCLUDE = array('sf/user', 'validation');
require_once('../inc/includes.php');

header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

if (!isset($_REQUEST['email'])) {
	die('{"error":"no email"}');
}

$email = mysql_real_escape_string($_REQUEST['email']);
if (!check_email_address($email)) die('{"error":"invalid email"}');
$updates = 'yes';

$result = mysql_query("SELECT subscribe_updates AS subscribed FROM sf_users WHERE email='$email';");
if (!$result) die('{"error":"retry","note":"'.mysql_real_escape_string(mysql_error()).'"}');

$method = 'INSERT';
if (mysql_num_rows($result)) {
	$row = mysql_fetch_assoc($result);
	if ($row['subscribed'] == 'yes')
		die('{"status":"ok"}');
  else
		$method = 'UPDATE';
}

$query = array(
	'email' => $email,
	'subscribe_updates' => $updates
);
if (isset($_REQUEST['country'])) $query['country'] = $_REQUEST['country'];
if (isset($_REQUEST['musician'])) $query['musician'] = $_REQUEST['musician'];
if (isset($_REQUEST['password'])) $query['password'] = make_pass_hash($_REQUEST['password']);
if ($method == 'UPDATE')
	$query['WHERE'] = array('email' => $email);
else
	$query['created'] = array('function' => 'NOW()');
if (!assoc_to_mysql('sf_users', $method, array($query))) die('{"error":"retry","note":"'.mysql_real_escape_string(mysql_error()).'"}');
$message = 'You\'ve subscribed to The Stereofyter newsletter. Thanks for your interest in The Stereofyter - we\'ll let you know as updates are available.'."\n\n";
$message .= 'If you no longer wish to receive this newsletter, you can unsubscribe by pasting this link into your browser:'."\n";
$message .= 'http://'.$_SERVER['SERVER_NAME'].'/unsubscribe.php?email='.$email."\n\n";
$message .= 'Please do not reply to this email directly. You will not receive a response.';
@mail($email, 'The Stereofyter - newsletter subscription', $message, 'From:"The Stereofyter" <news@stereofyter.org>');
echo '{"status":"ok"}';

?>
