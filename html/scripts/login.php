<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf');

//header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['u'])) die('{"error":"no username or email given"}');
if (!isset($_REQUEST['p'])) die('{"error":"no password"}');
if (!login_user($_REQUEST['u'], $_REQUEST['p'])) die('{"error":"incorrect credentials"}');
$mix_data['data'] = $_POST['data'];
if (isset($_POST['id']))
	$mix_data['id'] = $_POST['id'];
if (isset($_POST['comment']))
	$mix_data['comment'] = $_POST['comment'];
		
$saved = save_mix($mix_data);
if ($saved === false)
	die('{"error":"'.implode('; ', $ERROR).'"}');
else
	{
	$user = mysql_to_json(
		"SELECT id, modified, created FROM sf_mixes WHERE id='$saved'",
		array('whitespace' => 'none', 'structure' => 'flat')
		);
	echo $user;
	}

?>