<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_POST['username']) || !$_POST['username']) die('{"error":"no username or email given"}');
if (!isset($_POST['password']) || !$_POST['password']) die('{"error":"no password given"}');
if (!login_user($_POST['username'], $_POST['password'])) die('{"error":"'.implode('; ', $ERROR).'"}');
?>
{"user":{"id":"<?=$_SESSION['user']['id']?>", "name":"<?=$_SESSION['user']['name']?>", "country":"<?=$_SESSION['user']['country']?>", "created":"<?=$_SESSION['user']['created']?>"}}