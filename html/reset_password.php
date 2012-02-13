<?php
$CSS = array('unsubscribe');
require_once('inc/header.php');
require_from_inc('user');

$view = 'default';
if (isset($_GET['error'])) log_error($_GET['error']);

if(isset($_POST['username'])) {
	send_reset_password_hash($_POST['username']);
	$view = 'reset_confirmation_sent';
} else if (isset($_GET['hash'])) {
	$user_id = check_reset_password_hash($_GET['hash']);
	if (!is_numeric($user_id)) {
		log_error('The code you provided is expired');
	} else
		$view = 'reset_choose_password';
}
?>
	<h1>The Stereofyter - Reset Password</h1>
<?php
if ($ERROR)://TODO: don't show the "confirmation sent" message if there's an error
?>
	<p class="error"><?=implode('; ',$ERROR)?></p>
<?php
elseif (isset($_GET['success'])):
?>
	<p class="success">Your password has been set. Please proceed to <a href="/#login">log in</a>.</p>
<?php
endif;

switch ($view):
	case 'reset_confirmation_sent':
?>
	<p>A confirmation email will be sent to you in a moment. Plase follow the link in the email to reset your password.</p><?php
		break;
	case 'reset_choose_password':
?>
	<form method="POST" action="/scripts/update_user.php">
		<p>Choose a new password</p>
		<p>Password
		<input type="password" name="password" /></p>
		<p>Confirm Password
		<input type="password" name="password2" /></p>
		<input type="hidden" name="hash" value="<?=$_GET['hash']?>" />
		<input type="hidden" name="success" value="/reset_password.php?success" />
		<input type="hidden" name="fail" value="<?=$_SERVER['REQUEST_URI'];?>" />
		<input type="submit" value="Update" />
	</form>
<?php
		break;
	default:
?>
	<form method="POST">
		<p>Enter your email address or username to reset your password</p>
		<p>Username / Email Address
		<input type="text" name="username" /></p>
		<input type="submit" value="Submit" />
	</form>
<?php
endswitch;
require_once('inc/footer.php');
?>
