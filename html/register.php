<?php

header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

if (!isset($_REQUEST['email'])) {
	die('{"error":"no email"}');
}
require_once('inc/_config.php');
require_once('inc/db.php');
require_once('inc/validation.php');

$email = mysql_real_escape_string($_REQUEST['email']);
if (!check_email_address($email)) die('{"error":"invalid email"}');
$updates = 'yes';

$result = mysql_query("SELECT subscribe_updates AS subscribed FROM users WHERE email='$email';");
if (!$result) die('{"error":"retry"}');

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
if (isset($_REQUEST['country'])) $query['country'] = $_REQUEST['country'];
if (isset($_REQUEST['musician'])) $query['musician'] = $_REQUEST['musician'];
if ($method == 'UPDATE')
	$query['WHERE'] = array('email' => $email);
else
	$query['created'] = array('function' => 'NOW');
if (!assoc_to_mysql(array($query), $method, 'users')) die('{"error":"retry"}');
$message = 'You\'ve subscribed to the Stereofyter Newsletter.'."\n\n";
$message .= 'Thank you for your interest in Stereofyter. We\'ll let you know as updates are available on the site.'."\n\n";
$message .= 'If you no longer wish to receive this newsletter, you can unsubscribe by pasting this link into your browser:'."\n";
$message .= 'http://'.$_SERVER['SERVER_NAME'].'/unsubscribe.php?email='.$email."\n\n";
$message .= 'Please do not reply to this email directly. You will not receive a response.';
@mail($email, 'Stereofyter Newsletter Subscription', $message, 'From:"Stereofyter Newsletter" <news@stereofyter.org>');
echo '{"status":"ok"}';

?>
