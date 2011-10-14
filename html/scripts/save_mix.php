<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf');

header('Content-type: application/json; charset=utf-8');

if (!isset($_POST['data'])) die('{"error":"no data to save"}');
$mix_data['data'] = $_POST['data'];
if (isset($_POST['id']))
	$mix_data['id'] = $_POST['id'];
if (isset($_POST['comment']))
	$mix_data['comment'] = $_POST['comment'];
		
$saved = save_mix($mix_data);
if (!is_numeric($saved))
	die('{"error":"'.$saved'"}');
else
	{
	$mix = mysql_to_json(
		"SELECT id, modified, created FROM sf_mixes WHERE id='$saved'",
		array('whitespace' => 'none', 'structure' => 'flat')
		);
	echo $mix;
	}

?>