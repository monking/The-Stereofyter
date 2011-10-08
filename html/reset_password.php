<?php
$css = array('unsubscribe');
require_once('inc/header.php');
require_from_inc_dir('db_sf');
?>
<h1>The Stereofyter Newsletter</h1>
<?php

if (!isset($_REQUEST['email'])):
?>
<form method="POST">
	<p>Choose a new password</p>
	<p>Password
	<input type="password" name="password" /></p>
	<p>Confirm Password
	<input type="password" name="password2" /></p>
	<input type="submit" value="Update" />
</form>
<?php
else:
?>
<div class="response">
<?php

	$email = mysql_real_escape_string($_REQUEST['email']);

	$result = mysql_query("SELECT COUNT(*) AS existing FROM users WHERE email='$email';");
	if (!$result)
		exit('There was a problem processing your request. Please try again in a moment.');
	$row = mysql_fetch_assoc($result);
	if ($row['existing'] == 0) {
		die('You have unsubscribed from the Stereofyte Newsletter.');
	}

	$query = array(
		'WHERE' => array('email' => $email),
		'subscribe_updates' => 'no'
	);
	if (!assoc_to_mysql(array($query), 'UPDATE', 'users'))
		exit('There was a problem processing your request. Please try again in a moment.');
	die('You have unsubscribed from the Stereofyte Newsletter.');
?>
</div>
<?php
endif;

require_once('inc/footer.php');
?>
