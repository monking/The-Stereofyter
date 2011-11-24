<?php
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Content-type: application/json');

$INCLUDE = array('sf/user');
require_once('../inc/includes.php');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['username']) || !$_REQUEST['username']) die('{"error":"no username or email given"}');
if (!isset($_REQUEST['password']) || !$_REQUEST['password']) die('{"error":"no password given"}');
if (!login_user($_REQUEST['username'], $_REQUEST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
echo get_session_data_json();
?>
