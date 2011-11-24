<?php

header('Content-type: application/json; charset=utf-8');

$INCLUDE = array('sf/user');
require_once('../inc/includes.php');

$mix_id = FALSE;
if (isset($_GET['id']) && is_numeric($_GET['id'])) {
	$mix_id = mysql_real_escape_string($_GET['id']);
} else {
  // no mix ID given: get user's last edited mix
	session_start();
	if (isset($_SESSION['user'])) {
		$result = mysql_query("SELECT id FROM sf_mixes WHERE modified_by='".$_SESSION['user']['id']."' ORDER BY modified DESC LIMIT 1");
		if (!$result)
			die('{"error":"database error"}');
		if (mysql_num_rows($result)) {
			$row = mysql_fetch_array($result);
			$mix_id = $row[0];
		}
	}
}
if ($mix_id === FALSE)
	die('{"error":"no mix specified"}');
$mix_data = mysql_to_json(
	"SELECT * FROM sf_mixes WHERE id='$mix_id'",
	array(
		'structure' => 'flat',
		'objects' => array('mix')
		)
	);
if (!$mix_data)
	die('{"error":"'.implode('; ', $ERROR).'"}');
echo $mix_data;

?>
