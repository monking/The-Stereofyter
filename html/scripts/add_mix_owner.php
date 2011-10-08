<?php

require_once('../inc/includes.php');
require_from_inc_dir('db_sf');
// TODO: uncomment JSON header when finished debugging
//header('Content-type: application/json');

if (!isset($_POST['mix_id']) || $_POST['mix_id'] === '') die('{"error":"no mix id given"}');
if (!isset($_POST['user_id']) || $_POST['user_id'] === '') die('{"error":"no user id given"}');
$mix_id = mysql_real_escape_string($_POST['mix_id']);
$user_id = mysql_real_escape_string($_POST['user_id']);
		
$saved = add_mix_owner($mix_id, $user_id);
if ($saved === false)
	die('{"error":"'.implode('; ', $ERROR).'"}');
else
	{
	$owners = get_mix_owners($mix_id);
	if (!$owners)
		die('{"error":"'.implode('; ', $ERROR).'"}');
	else
		echo '{"mix_id":"'.$mix_id.'","owners":['.implode(',', $owners).']}';
	}

?>