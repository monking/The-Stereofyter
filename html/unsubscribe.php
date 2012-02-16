<?php
$includes = array('database.class', 'validation');
$CSS = array('unsubscribe');
require_once('inc/header.php');
?>
<h1>The Stereofyter Newsletter</h1>
<?php

if (!isset($_POST['email'])):
?>
<form method="POST">
	<p>Enter your email address below to unsubscribe from The Stereofyter newsletter.</p>
	<p>Email:
	<input type="text" name="email">
	<input type="submit" value="Unsubscribe" /></p>
</form>
<?php
else:
?>
<div class="response">
<?php

	$email = mysql_real_escape_string($_POST['email']);

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
	if (!$db->assoc_to_mysql('users', 'UPDATE', $query))
		exit('There was a problem processing your request. Please try again in a moment.');
	die('You have unsubscribed from the Stereofyte Newsletter.');
?>
</div>
<?php
endif;

require_once('inc/footer.php');
?>
