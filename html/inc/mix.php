<?php

require_from_inc_dir('array', 'error', 'db', 'user');

/** filter_mysql_assoc
  * filter function for array_conform
  * removes elements with the value -1 and escapes values for MySQL input
  */
function filter_sf_mysql_assoc($key, &$value) {
	if ($value == -1) return FALSE;
	if (!count($value))
		$value = mysql_real_escape_string($value);
	return TRUE;
}
/** save_mix
  * $mix_data (array)
		['data'] (string) JSON-encoded mix data to be saved
		['id'] (number) OPTIONAL id of the mix. If omitted, a new mix is saved
		['comment'] (string) OPTIONAL message to save with this revision
  * RETURNS (number) id of saved mix, or -1 on error
  */
function save_mix($mix_data) {
	if (!isset($_SESSION)) session_start();

	if (!isset($_SESSION['user']['id']))
		return log_error('not logged in', FALSE);
	if (!isset($mix_data['data']))
		return log_error('no mix data received for saving', FALSE);

	if (isset($mix_data['id'])) {
		if (!check_mix_owner($mix_data['id'], $_SESSION['user']['id']))
			unset($mix_data['id']);
	}
	$mix = array_conform(
		$mix_data,
		array(
			'data' => '',
			'title' => 'Untitled',
			'tempo' => '',
			'chromatic_key' => '',
			'modified_by' => $_SESSION['user']['id']
		),
		'filter_sf_mysql_assoc'
	);
	if (isset($mix_data['id'])) {
		$mix['modified'] = array('function' => 'NOW()');
		$mix['WHERE'] = array('id' => $mix_data['id']);
		if (!assoc_to_mysql(array($mix), 'UPDATE', 'sf_mixes'))
			return log_error(mysql_error(), FALSE);
		$saved_mix_id = $mix_data['id'];
	} else {
		$mix['created'] = array('function' => 'NOW()');
		if (!assoc_to_mysql(array($mix), 'INSERT', 'sf_mixes'))
			return log_error(mysql_error(), FALSE);
		$saved_mix_id = mysql_insert_id();
		add_mix_owner($saved_mix_id, $_SESSION['user']['id']);
	}
	return $saved_mix_id;
}
/** add_mix_owner
  * $mix_id (number) id of the mix
  * $user_id (number) id of user being added as owner of the mix
  * RETURNS Boolean success
  */
function add_mix_owner($mix_id, $user_id) {
	global $ERROR;
	$mix_id = mysql_real_escape_string($mix_id);
	$user_id = mysql_real_escape_string($user_id);
	if (!check_user_exists(array('id' => $user_id))) 
		return log_error('user does not exist', FALSE);
	if (check_mix_owner($mix_id, $user_id)) return TRUE;
	$query = "INSERT INTO sf_mix_owners SET mix_id='$mix_id', owner_id='$user_id'";
	if (!mysql_query($query)) 
		return log_error(mysql_error());
	return TRUE;
}
/** remove_mix_owner
  * $mix_id (number) id of the mix
  * $owner_id (number) id of user being removed as owner of the mix
  */
function remove_mix_owner($mix_id, $owner_id) {
	$mix_id = mysql_real_escape_string($mix_id);
	$owner_id = mysql_real_escape_string($owner_id);
	$query = "DELETE sf_mix_owners WHERE mix_id='$mix_id' AND owner_id='$owner_id'";
	if (!mysql_query($query)) 
		return log_error(mysql_error(), FALSE);
	return TRUE;
}
/** check_mix_owner
  * $mix_id (number) id of the mix
  * $owner_id (number) id of user being checked as owner of the mix
  * RETURNS TRUE if the user is an owner, FALSE if now
  */
function check_mix_owner($mix_id, $owner_id) {
	$mix_id = mysql_real_escape_string($mix_id);
	$owner_id = mysql_real_escape_string($owner_id);
	$query = "SELECT * FROM sf_mix_owners WHERE mix_id='$mix_id' AND owner_id='$owner_id'";
	$result = mysql_query($query);
	if (!$result) 
		return log_error(mysql_error(), FALSE);
	if (!mysql_num_rows($result)) 
		return FALSE;
	return TRUE;
}
/** check_mix_owner
  * $mix_id (number) id of the mix
  * RETURNS array of mix owners
  */
function get_mix_owners($mix_id) {
	$owners = array();
	$result = mysql_query("SELECT owner_id FROM sf_mix_owners WHERE mix_id='$mix_id'");
	if (!$result) 
		return log_error(mysql_error());
	while ($owner = mysql_fetch_array($result))
		$owners[] = $owner[0];
	return $owners;
}
/** get_user_mixes
  * get an array of mix data for mixes owned by the given user
  * @user_id (int) the numeric ID of the user
  * RETURNS array of mix data
  */
function get_user_mixes($user_id) {
  if (!is_numeric($user_id)) return NULL;
  $result_array = array();
  $result = mysql_query("SELECT sf_mixes.id, title, duration, tempo, chromatic_key FROM sf_mixes, sf_mix_owners WHERE owner_id=$user_id AND mix_id=sf_mixes.id");
  while ($row = mysql_fetch_assoc($result))
    $result_array[] = $row;
  return $result_array;
}
?>