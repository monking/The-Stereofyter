<?php

require_from_inc_dir('array');

/** filter_sf_mysql_assoc
  * filter function for array_conform
  * removes elements with the value -1 and escapes values for MySQL input
  */
function filter_sf_mysql_assoc($key, &$value)
	{
	if ($value == -1) return false;
	if (!count($value))
		$value = mysql_real_escape_string($value);
	return true;
	}
/** save_mix
  * $mix_data (array)
		['data'] (string) JSON-encoded mix data to be saved
		['id'] (number) OPTIONAL id of the mix. If omitted, a new mix is saved
		['comment'] (string) OPTIONAL message to save with this revision
  * RETURNS (number) id of saved mix
  */
function save_mix($mix_data)
	{
	global $ERROR;
	if (!isset($_SESSION)) session_start();
	// TODO: log in user, so that this value is already set
	$_SESSION['user_id'] = '22';

	if (!isset($_SESSION['user_id']))
		{
		$ERROR[] = 'not logged in';
		return false;
		}
	if (!isset($mix_data['data']))
		{
		$ERROR[] = 'no mix data received for saving';
		return false;
		}

	$mix = array_conform(
		$mix_data,
		array(
			'data' => '',
			'modified_by' => $_SESSION['user_id']
			),
		'filter_sf_mysql_assoc'
		);
	if (isset($mix_data['id']))
		{
		if (!check_mix_owner($mix_data['id'], $_SESSION['user_id']))
			{
			$ERROR[] = 'user does not own this mix';
			return false;
			}
		$mix['modified'] = array('function' => 'NOW()');
		$mix['WHERE'] = array('id' => $mix_data['id']);
		if (!assoc_to_mysql(array($mix), 'UPDATE', 'sf_mixes'))
			{
			$ERROR[] = mysql_error();
			return false;
			}
		}
	else
		{
		$mix['created'] = array('function' => 'NOW()');
		if (!assoc_to_mysql(array($mix), 'INSERT', 'sf_mixes'))
			{
			$ERROR[] = mysql_error();
			return false;
			}
		$mix_data['id'] = mysql_insert_id();
		add_mix_owner($mix_data['id'], $_SESSION['user_id']);
		}
	return $mix_data['id'];
	}
/** add_mix_owner
  * $mix_id (number) id of the mix
  * $user_id (number) id of user being added as owner of the mix
  */
function add_mix_owner($mix_id, $user_id)
	{
	global $ERROR;
	$mix_id = mysql_real_escape_string($mix_id);
	$user_id = mysql_real_escape_string($user_id);
	if (!check_user_exists(array('id' => $user_id)))
		{
		$ERROR[] = 'user does not exist';
		return false;
		}
	if (check_mix_owner($mix_id, $user_id)) return true;
	$query = "INSERT INTO sf_mixowners SET mix_id='$mix_id', owner_id='$user_id'";
	if (!mysql_query($query))
		{
		$ERROR[] = mysql_error();
		return false;
		}
	return true;
	}
/** remove_mix_owner
  * $mix_id (number) id of the mix
  * $owner_id (number) id of user being removed as owner of the mix
  */
function remove_mix_owner($mix_id, $owner_id)
	{
	$mix_id = mysql_real_escape_string($mix_id);
	$owner_id = mysql_real_escape_string($owner_id);
	$query = "DELETE sf_mixowners WHERE mix_id='$mix_id' AND owner_id='$owner_id'";
	if (!mysql_query($query))
		{
		$ERROR[] = mysql_error();
		return false;
		}
	return true;
	}
/** check_mix_owner
  * $mix_id (number) id of the mix
  * $owner_id (number) id of user being checked as owner of the mix
  * RETURNS true if the user is an owner, false if now
  */
function check_mix_owner($mix_id, $owner_id)
	{
	$mix_id = mysql_real_escape_string($mix_id);
	$owner_id = mysql_real_escape_string($owner_id);
	$query = "SELECT * FROM sf_mixowners WHERE mix_id='$mix_id' AND owner_id='$owner_id'";
	$result = mysql_query($query);
	if (!$result || !mysql_num_rows($result))
		{
		$ERROR[] = mysql_error();
		return false;
		}
	return true;
	}
/** check_user_exists
  * $criteria (array) associative array of fields to reference
  * RETURNS true or false
  */
function check_user_exists($criteria)
	{
	$where = assoc_to_mysql_where($criteria);
	$query = "SELECT * FROM sf_users$where";
	$result = mysql_query($query);
	if (!$result || !mysql_num_rows($result))
		{
		$ERROR[] = mysql_error();
		return false;
		}
	return true;
	}
/** check_mix_owner
  * $mix_id (number) id of the mix
  * RETURNS array of mix owners
  */
function get_mix_owners($mix_id)
	{
	$owners = array();
	$result = mysql_query("SELECT owner_id FROM sf_mixowners WHERE mix_id='$mix_id'");
	if (!$result)
		{
		$ERROR[] = mysql_error();
		return false;
		}
	while ($owner = mysql_fetch_array($result))
		$owners[] = $owner[0];
	return $owners;
	}
/** save_message
  * $mix_data (array)
		['message'] (string) message to be posted
		['mix_id'] (number) OPTIONAL id of a mix being sent with the message
		['response_to_msg'] (number) OPTIONAL id of message being responded to
		['user_id'] (number) OPTIONAL id of sending user (default is logged-in user)
  */
function save_message($mix_data)
	{
	if (!assoc_to_mysql(
		array(array_conform(
			$mix_data,
			array(
				'mix_id' => -1,
				'user_id' => $_SESSION['user_id'],
				'response_to_msg' => -1,
				'message' => ''
				),
			'')),
		isset($mix_data['WHERE'])? 'UPDATE': 'INSERT',
		'sf_messages'
		))
		{
		$ERROR[] = mysql_error();
		return false;
		}
	}
?>