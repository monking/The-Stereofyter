<?php
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json; charset=utf-8');

require_once('../../_config.php');
depends('sf/mix');
if (!isset($_SESSION))
  session_start();
if (!isset($_SESSION['user']))
  die('{"error":"user not logged in"}');
$mixes = get_user_mixes($user->id);
echo assoc_to_json($mixes, array('structure' => 'array'));
?>