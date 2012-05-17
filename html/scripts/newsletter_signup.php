<?php

require_once('../../config.php');
depends('localization','validation');

header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

if (!isset($_REQUEST['email']) || !$_REQUEST['email']) 
	die(json_encode((object) array('error'=>__('provide-email', true))));

if (!validate_email_address($_REQUEST['email'])) 
	die(json_encode((object) array('error'=>__('invalid-email', true))));

$email = $_REQUEST['email'];
$query = array(
    'table'=>'sf_users',
    'method'=>'insert',
    'fields'=>array(
        'subscribe_updates' => 'yes'
    )
);

$test = $db->get_first_object(array(
    'table'=>'sf_users',
    'fields'=>array('subscribe_updates'),
    'where'=>array('email'=>$email)
));
if ($test) {
    if ($test->subscribe_updates == 'yes')
        die('{"status":"ok"}');
    else {
        $query['method'] = 'UPDATE';
        $query['where'] = array('email' => $email);
    }
} else {
    $query['fields']['email'] = $email;
    $query['fields']['created'] = array('function' => 'NOW()');
}
if (@$_REQUEST['country']) $query['fields']['country'] = $_REQUEST['country'];
if (@$_REQUEST['musician']) $query['fields']['musician'] = $_REQUEST['musician'];
if (@$_REQUEST['password']) $query['fields']['password'] = make_pass_hash($_REQUEST['password']);
$result = $db->post($query);
if (!$result)
    die('{"error":"retry","note":"'.mysql_real_escape_string(mysql_error()).'"}');
$message = 'You\'ve subscribed to The Stereofyter newsletter. Thanks for your interest in The Stereofyter - we\'ll let you know as updates are available.'."\n\n";
$message .= 'If you no longer wish to receive this newsletter, you can unsubscribe by pasting this link into your browser:'."\n";
$message .= 'http://'.$_SERVER['SERVER_NAME'].'/unsubscribe.php?email='.$email."\n\n";
$message .= 'Please do not reply to this email directly. You will not receive a response.';
@mail($email, 'The Stereofyter - newsletter subscription', $message, 'From:"The Stereofyter" <news@stereofyter.org>');
echo '{"status":"ok"}';

?>
