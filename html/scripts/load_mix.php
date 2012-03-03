<?php

//header('Content-type: application/json; charset=utf-8');

require_once('../../_config.php');
depends('sf/mix');

$mix_id = FALSE;
session_start();
if (isset($_GET['id']) && is_numeric($_GET['id'])) {
	$mix_id = mysql_real_escape_string($_GET['id']);
} else {
  // no mix ID given: get user's last edited mix
	if (isset($_SESSION['user'])) {
		$result = $db->get("SELECT id FROM sf_mixes WHERE modified_by='".$user->id."' ORDER BY modified DESC LIMIT 1");
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
$mix_data = $db->get_assoc("SELECT * FROM sf_mixes WHERE id='$mix_id'");
if ($mix_data === FALSE)
	die('{"error":"'.implode('; ', $ERROR).'"}');
$allow_access = FALSE;
if (!count($mix_data)) {
die('{"error":"The requested mix no longer exists."}');
} else if ($mix_data[0]['published'] == '1') {
  $allow_access = TRUE;
} else if (@$user) {
  $query = "SELECT '1' FROM sf_mix_owners WHERE owner_id='${$user->id}' AND mix_id='$mix_id'";
  $result = $db->get($query);
  if ($result && mysql_num_rows($result))
    $allow_access = TRUE;
}
if ($allow_access) {
  echo assoc_to_json($mix_data,
    array(
    	'structure' => 'flat',
    	'objects' => array('mix')
  	));
} else {
	die('{"error":"This mix is not published."}');
}

?>
