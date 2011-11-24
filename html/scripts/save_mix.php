<?php

$INCLUDE = array('sf/mix');
require_once('../inc/includes.php');

header('Content-type: application/json; charset=utf-8');
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');

if (!isset($_REQUEST['mix'])) die('{"error":"no data to save"}');
$mix_data['mix'] = $_REQUEST['mix'];
if (isset($_REQUEST['id']))
	$mix_data['id'] = $_REQUEST['id'];
if (isset($_REQUEST['title']))
	$mix_data['title'] = $_REQUEST['title'];
if (isset($_REQUEST['key']))
	$mix_data['chromatic_key'] = $_REQUEST['key'];
if (isset($_REQUEST['tempo']))
	$mix_data['tempo'] = $_REQUEST['tempo'];
if (isset($_REQUEST['duration']))
	$mix_data['duration'] = $_REQUEST['duration'];
$saved = save_mix($mix_data);
if ($saved === FALSE)
	die('{"error":"'.implode('; ', $ERROR).'"}');
else {
	$mix = mysql_to_json(
		"SELECT id, title, duration, tempo, chromatic_key, modified_by, modified, created FROM sf_mixes WHERE id='$saved'",
		array('whitespace' => 'none', 'structure' => 'flat', 'objects' => array('mix'))
		);
	echo $mix;
}

?>
