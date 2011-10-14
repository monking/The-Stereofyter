<?php

require_from_inc_dir('array', 'error', 'db');

/** login_user
  * login a user by username or email address, and password
  */
function login_user($username, $password) {
	$user_id = check_user_pass($username, $password);
	if ($user_id === FALSE)
		return FALSE;
	$username = mysql_real_escape_string($username);
	$result = mysql_query("SELECT id, name, email, country, musician, subscribe_updates, created FROM sf_users WHERE id='$user_id'");
	if (!$result)
		return log_error('database error', FALSE);
	$row = mysql_fetch_assoc($result);
	session_start();
	$_SESSION['user'] = $row;
	return TRUE;
}
/** refresh_session_data
  * refresh the data in the logged-in user's session
  */
function refresh_session_data() {
	if (!isset($_SESSION)) return;
	$id = mysql_real_escape_string($_SESSION['user']['id']);
	$result = mysql_query("SELECT id, username, name, email, country, musician, subscribe_updates, created FROM sf_users WHERE id='$id'");
	if (!$result || !mysql_num_rows($result)) return;
	$row = mysql_fetch_assoc($result);
	$_SESSION['user'] = $row;
}
/** update_user
  * set the password on a user
  */
function update_user($id, $data, $hash = NULL) {
	if ($hash != NULL) {
		$hash_user_id = check_reset_password_hash($hash, FALSE, $id);
		if (!is_numeric($hash_user_id))
			return $hash_user_id;
		$id = $hash_user_id;
	}
	if (array_key_exists('password', $data)) {
		if (array_key_exists('old_password', $data)) {
			if (!check_user_pass($username, $data['old_password'])) return log_error('wrong old password');
		} else if (!$hash)
			return log_error('need old password');
		$data['password'] = make_pass_hash($data['password']);
	}
	$data['WHERE'] = array('id' => $id);
	if (!assoc_to_mysql(array($data), 'UPDATE', 'sf_users'))
		return log_error('database error');
	if ($hash) {
		delete_reset_password_hash($hash);
	}
}
/** send_reset_password_hash
  * email the hash to reset the password
  */
function send_reset_password_hash($email) {
	$email = mysql_real_escape_string($email);
	$result = mysql_query("SELECT id FROM sf_users WHERE email='$email'");
	if (!$result)
		return log_error('database error');
	if (!mysql_num_rows($result))
		return TRUE; // don't report incorrect email, for phishing
	$row = mysql_fetch_array($result);
	$id = $row[0];
	$hash = sha1(rand());
	delete_reset_password_hash(NULL, $id);
	$result = mysql_query("INSERT INTO sf_reset_hashes SET user_id='$id', hash='$hash', created=NOW()");
	if (!$result)
		return log_error(mysql_error());
	$mail_body = 'You are receiving this because a request was made to reset your password. If you wish to reset your password, please click the following link.'."\n\r";
	$mail_body .= 'http://'.$_SERVER['SERVER_NAME'].'/reset_password.php?hash='.$hash."\n\r\n\r";
	$mail_body .= 'This link will expire in 24 hours.'."\n\r\n\r";
	$mail_body .= "Regards,\n\r";
	$mail_body .= 'The Stereofyter Team';
	if (!@mail($email, 'The Stereofyter - Password Reset', $mail_body, 'From:"The Stereofyter" <noreply@stereofyter.org>'))
		return log_error('mail error', $hash);
}
/** check_reset_password_hash
  * verify that a hash exists and is not expired
  * if it's expired, remove it
  * RETURNS numeric ID, or String error
  */
function check_reset_password_hash($hash, $delete = FALSE, $match_id = NULL) {
	$HASH_LIFE = 86400; // 24 hours in seconds
	$hash = mysql_real_escape_string($hash);
	$expired = FALSE;
	$result = mysql_query("SELECT * FROM sf_reset_hashes WHERE hash='$hash'");
	if (!$result)
		return log_error('database error');
	if (!mysql_num_rows($result))
		return log_error('hash not on file');
	$row = mysql_fetch_assoc($result);
	if ($match_id != NULL) {
		if ($row['user_id'] != $match_id)
			return log_error('user id mismatch');
	}
	if (time() - strtotime($row['created']) > $HASH_LIFE) {
		$expired = TRUE;
		$delete = TRUE;
	}
	if ($delete)
		delete_reset_password_hash($hash);
	if ($expired)
		return log_error('hash expired');
	return $row['user_id'];
}
/** delete_reset_password_hash
  * delete a hash from the table by hash or by user_id
  */
function delete_reset_password_hash($hash, $user_id = NULL) {
	if ($user_id !== NULL)
		$where = "user_id='".mysql_real_escape_string($user_id)."'";
	else
		$where = "hash='".mysql_real_escape_string($hash)."'";
	mysql_query("DELETE FROM sf_reset_hashes WHERE $where");
}
/** check_user_pass
  * check for a password match on a user
  * using numeric id, alphanumeric username, or email address
  * RETURNS user ID or FALSE
  */
function check_user_pass($identifier, $password) {
	$identifier = mysql_real_escape_string($identifier);
	if (is_numeric($identifier))
		$user_where = "id='$identifier'";
	else if (strpos($identifier, "@"))
		$user_where = "email='$identifier'";
	else
		$user_where = "username='$identifier'";
	$query = "SELECT id, password FROM sf_users WHERE $user_where";
	$result = mysql_query($query);
	if (!$result)
		return log_error('database error', FALSE);
	if (!mysql_num_rows($result))
		return log_error('email and password don\'t match', FALSE);
	$row = mysql_fetch_assoc($result);
	if (!$row['password'])
		return log_error('password not set', FALSE);
	if (!check_pass_hash($password, $row['password']))
		return log_error('email and password don\'t match', FALSE);
	return $row['id'];
}
/** make_pass_hash
  * make a salted hash of the password
  */
function make_pass_hash($password) {
	$salt = substr(sha1(rand()), 0, 24);
	$hash = sha1($salt.$password);
	return $salt.$hash;
}
/** check_pass_hash
  * check a password against a salted hash
  */
function check_pass_hash($password, $hash) {
	$salt = substr($hash, 0, 24);
	if ($hash != $salt.sha1($salt.$password))
		return FALSE;
	return TRUE;
}
/** filter_sf_mysql_assoc
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
/** check_user_exists
  * $criteria (array) associative array of fields to reference
  * RETURNS TRUE or FALSE
  */
function check_user_exists($criteria) {
	$where = assoc_to_mysql_where($criteria);
	$query = "SELECT * FROM sf_users$where";
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
/** save_message
  * $mix_data (array)
		['message'] (string) message to be posted
		['mix_id'] (number) OPTIONAL id of a mix being sent with the message
		['response_to_msg'] (number) OPTIONAL id of message being responded to
		['user_id'] (number) OPTIONAL id of sending user (default is logged-in user)
  */
function save_message($mix_data) {
	if (!isset($_SESSION)) session_start();
	if (!assoc_to_mysql(
		array(array_conform(
			$mix_data,
			array(
				'mix_id' => -1,
				'user_id' => $_SESSION['user']['id'],
				'response_to_msg' => -1,
				'message' => ''
				),
			'')),
		isset($mix_data['WHERE'])? 'UPDATE': 'INSERT',
		'sf_messages'
	)) {
		return log_error(mysql_error());
	}
}
?>
