<?php
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json; charset=utf-8');

require_once('../../config.php');
depends('sf/mix');
if (!$user->id)
  die('{"error":"user not logged in"}');
echo json_encode(get_user_mixes($user->id));
?>
