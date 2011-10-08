<?php

require_from_inc_dir('array');
require_from_inc_dir('db');

// TODO: log in user, so that this value is already set
$_SESSION['user_id'] = '22';

/** login_user
  * login a user by username or email address, and password
  */
function login_user($username, $password)
	{
	if (!check_user_pass($username, $password))
		return false;
	$username = mysql_real_escape_string($username);
	$result = mysql_query("SELECT id, name, email, country, musician, subscribe_updates, created FROM sf_users WHERE username='$username'");
	if (!$result)
		{
		$ERROR[] = 'database error';
		return false;
		}
	if (!mysql_num_rows($result)) return false;
	$row = mysql_fetch_assoc($result);
	session_start();
	$_SESSION['user'] = $row;
	return true;
	}
/** reset_password_with_hash
  * login a user by a temporary hash code
  */
function reset_password_with_hash($password, $hash)
	{
	$hash = mysql_real_escape_string($hash);
	$result = mysql_query("SELECT id, user_id, created FROM sf_reset_hashes WHERE hash='$hash'");
	if (!$result)
		{
		$ERROR[] = 'database error';
		return false;
		}
	if (!mysql_num_rows($result)) return false;
	$row = mysql_fetch_assoc($result);
	$result = mysql_query("DELETE FROM sf_reset_hashes WHERE user_id='".$row['user_id']."'");
	if (!$result)
		{
		$ERROR[] = 'database error';
		return false;
		}
	$password_hash = make_pass_hash($password);
	$result = mysql_query("UPDATE sf_users SET password='$password_hash'");
	if (!result) return false;
	return true;
	}
/** refresh_user_session
  * refresh the data in the logged-in user's session
  */
function refresh_user_session($id = NULL)
	{
	if (!isset($_SESSION)) return false;
	$id = mysql_real_escape_string($_SESSION['id']);
	$result = mysql_query("SELECT id, username, name, email, country, musician, subscribe_updates, created FROM sf_users WHERE id='$id'");
	if (!$result) return false;
	$row = mysql_fetch_assoc($result);
	$_SESSION['user'] = $row;
	return true;
	}
/** update_user
  * set the password on a user
  */
function update_user($id, $data)
	{
	if (array_key_exists($data, 'password')) {
		if (array_key_exists($data, 'old_password')) {
			if (!check_user_pass($username, $data['old_password'])) return false;
		} else if (
		$data['password'] = make_pass_hash($password);
	}
	$data['WHERE'] = array('id' => $id);
	if (!assoc_to_mysql($data, 'UPDATE', 'sf_users'))
		return false;
	refresh_user_session();
	return true;
	}
/** send_reset_password_hash
  * email the hash to reset the password
  */
function send_reset_password_hash($email)
	{
	$email = mysql_real_escape_string($email);
	$result = mysql_query("SELECT id FROM sf_users WHERE email='$email'");
	if (!$result || !mysql_num_rows($result)) return false;
	$row = mysql_fetch_array();
	$id = $row[0];
	$hash = hash('sha1', rand());
	$result = mysql_query("INSERT INTO sf_reset_hashes SET user_id='$id', hash='$hash', created=NOW()");
	$mail_body = 'http://'.$_SERVER['host_name'].'/reset.php?hash='.$hash;
	mail($email, 'The Stereofyter - Password Reset', $mail_body);
	/*debug*/ return $hash; /*debug*/
	return true;
	}
/** set_user_password
  * set the password on a user
  */
function set_user_password($id, $password, $old_password)
	{
	if (!check_user_pass($id, $old_password)) return false;
	$hash = make_pass_hash($password);
	$query .= "UPDATE sf_users SET password='$hash' WHERE id='$id'";
	$result = mysql_query($query);
	if (!result) return false;
	return true;
	}
/** check_user_pass
  * check for a password match on a user
  * using numeric id, alphanumeric username, or email address
  */
function check_user_pass($identifier, $password)
	{
	$identifier = mysql_real_escape_string($identifier);
	if (is_numeric($identifier))
		$user_where = "id='$identifier'";
	else if (strpos($identifier, "@"))
		$user_where = "email='$identifier'";
	else
		$user_where = "username='$identifier'";
	$query = "SELECT id, password FROM sf_users WHERE $user_where";
	$result = mysql_query($query);
	if (!$result) return false;
	$row = mysql_fetch_assoc($result);
	if (!check_pass_hash($password, $row['password']))
		return false;
	return $row['id'];
	}
/** make_pass_hash
  * make a salted hash of the password
  */
function make_pass_hash($password)
	{
	$salt = substr(hash('sha1', rand()), 0, 24);
	$hash = hash('sha1', $salt.$password);
	return $salt.hash;
	}
/** check_pass_hash
  * check a password against a salted hash
  */
function check_pass_hash($password, $hash)
	{
	$salt = substr($hash, 0, 24);
	if ($hash != $salt.hash('sha1', $salt.$password))
		return false;
	return true;
	}
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
	if (!isset($_SESSION)) session_start();
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