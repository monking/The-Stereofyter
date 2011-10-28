<?php

require_once('../inc/includes.php');
require_from_inc_dir('mix');

header('Content-type: application/json; charset=utf-8');

if (!isset($_REQUEST['data'])) die('{"error":"no data to save"}');
$mix_data['data'] = $_REQUEST['data'];
if (isset($_REQUEST['id']))
	$mix_data['id'] = $_REQUEST['id'];
if (isset($_REQUEST['comment']))
	$mix_data['comment'] = $_REQUEST['comment'];
		
$saved = save_mix($mix_data);
if ($saved === FALSE)
	die('{"error":"'.implode('; ', $ERROR).'"}');
else {
	$mix = mysql_to_json(
		"SELECT id, modified, created FROM sf_mixes WHERE id='$saved'",
		array('whitespace' => 'none', 'structure' => 'flat')
		);
	echo $mix;
}

?>