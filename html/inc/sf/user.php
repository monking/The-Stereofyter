<?php

ini_set('display_errors', 1);
require_from_inc_dir('array', 'error', 'db');

/** login_user
  * login a user by username or email address, and password
  */
function login_user($username, $password) {
	$user_id = check_user_pass($username, $password);
	if ($user_id === FALSE)
		return FALSE;
	refresh_session_data($user_id);
	return TRUE;
}
  /** register_user
    * register a user
    */
function register_user($email, $password, $username = '') {
	$result = assoc_to_mysql('sf_users', 'INSERT', array(
    array(
      'username' => $username,
      'email' => $email,
      'password' => make_pass_hash($password),
      'created' => array('function' => 'NOW()')
      )
    ));
  if (!$result)
		return FALSE;
	refresh_session_data(mysql_insert_id());
	return TRUE;
}
/** refresh_session_data
  * refresh the data in the logged-in user's session
  */
function refresh_session_data($user_id = null) {
  if ($user_id !== null) {
    session_start();
  	$_SESSION['user']['id'] = $user_id;
  }
	if (!isset($_SESSION)) return;
	$id = mysql_real_escape_string($_SESSION['user']['id']);
	$result = mysql_query("SELECT id, username, name, email, country, musician, subscribe_updates, created FROM sf_users WHERE id='$id'");
	if (!$result || !mysql_num_rows($result)) return;
	$row = mysql_fetch_assoc($result);
	$_SESSION['user'] = $row;
}
/** get_session_data_json
  * format relevant session data into a JSON object
  */
function get_session_data_json() {
	if (!isset($_SESSION) || !isset($_SESSION['user'])) return '{}';
	$json = '{"user":{';
	$json .= '"id":"'.$_SESSION['user']['id'].'"';
	$json .= ', "name":"'.$_SESSION['user']['name'].'"';
	$json .= ', "country":"'.$_SESSION['user']['country'].'"';
	$json .= ', "created":"'.$_SESSION['user']['created'].'"';
	$json .= '}}';
	return $json;
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
	if (!assoc_to_mysql('sf_users', 'UPDATE', array($data)))
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
		return log_error('incorrect login', FALSE);
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
/** check_user_exists
  * $criteria (array) associative array of fields to reference
  * RETURNS TRUE or FALSE
  */
function check_user_exists($criteria) {
	$where = assoc_to_mysql_where($criteria);
	$query = "SELECT * FROM sf_users$where";
	$result = mysql_query($query);
	if (!$result) {
		return log_error(DEBUG ? mysql_error() : 'database error', FALSE);
	}
	if (!mysql_num_rows($result)) 
		return FALSE;
	return TRUE;
}
?>