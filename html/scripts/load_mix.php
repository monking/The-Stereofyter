<?php

header('Content-type: application/json; charset=utf-8');

$includes = array('db', 'db_sf');
require_once('../inc/includes.php');

if (!isset($_GET['id'])) die('{"error":"no id for mix to load"}');
$mix_id = mysql_real_escape_string($_GET['id']);
$mix_data = mysql_to_json(
	"SELECT * FROM sf_mixes WHERE id='$mix_id'",
	array(
		'structure' => 'flat',
		'objects' => array('data')
		)
	);
if (!$mix_data)
	die('{"error":"'.implode('; ', $ERROR).'"}');
echo $mix_data;

?>