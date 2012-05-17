<?php

depends('helpers', 'error', 'database.class');
class User {
    public static $publicParams = array('id', 'name', 'country', 'created');
    public $data, $id;
    public function User($options = array()) {
        $defaults = array(
            'table'=>''
        );
        foreach ($defaults as $key => $value) {
            $this->$key = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
        }
        if (!@$this->table) die('User requires a database table.');
        if ($_SESSION && isset($_SESSION['user']))
            $this->set($_SESSION['user']);
    }
        /**login_user
        * login a user by username or email address, and password
        */
    public function login($username, $password) {
        $user_id = $this->check_pass($username, $password);
        if ($user_id === FALSE)
            return FALSE;
        if (!$_SESSION) session_start();
        $_SESSION['user'] = $this->fetch($user_id);
        return TRUE;
    }
    /** register_user
        * register a user
        */
    public function register($email, $password, $username = '') {
        global $db;
        $result = $db->post(array(
            'table'=>$this->table,
            'method'=>'INSERT',
            'fields'=>array(
                'username' => $username,
                'email' => $email,
                'password' => $this->make_pass_hash($password),
                'created' => array('function' => 'NOW()')
            )
        ));
        if (!$result)
            return FALSE;
        $this->fetch(mysql_insert_id());
        return TRUE;
    }
    /** set
        * set the data object on the current user
        */
    public function set($data) {
        $data = array_conform(
            $data,
            array(
                'id'=>null,
                'username'=>null,
                'name'=>null,
                'email'=>null,
                'country'=>null,
                'musician'=>null,
                'subscribe_updates'=>null,
                'created'=>null
            )
        );
        $this->data = (object) $data;
        $this->id = $this->data->id;
    }
    /** fetch
        * fetch the user object's data
        */
    public function fetch($user_id = null) {
        global $db;
        if (!$user_id && !$this->data->id) return false;
        $id = mysql_real_escape_string($user_id ? $user_id : $this->data->id);
        $result = $db->get(
            array(
                'table'=>$this->table,
                'fields'=>array(
                    'id',
                    'username',
                    'name',
                    'email',
                    'country',
                    'musician',
                    'subscribe_updates',
                    'created'
                ),
                'where'=>array('id'=>$id)
            )
        );
        if (!$result) return false;
        $this->set(mysql_fetch_object($result));
        return $this->data;
    }
    /** update_user
        * set the password on a user
        */
    public function update($id, $data, $hash = NULL) {
        global $db;
        if ($hash != NULL) {
            $hash_user_id = check_reset_password_hash($hash, FALSE, $id);
            if (!is_numeric($hash_user_id))
                return $hash_user_id;
            $id = $hash_user_id;
        }
        if (array_key_exists('password', $data)) {
            if (array_key_exists('old_password', $data)) {
                if (!$this->check_pass($data['old_password'])) return log_error('wrong old password');
            } else if (!$hash)
                return log_error('need old password');
            $data['password'] = $this->make_pass_hash($data['password']);
        }
        if (!$db->post(array(
         'table'=>$this->table,
         'method'=>'UPDATE',
         'fields'=>$data,
         'where'=>array('id' => $id)
        )))
            return log_error('database error');
        if ($hash) {
            delete_reset_password_hash($hash);
        }
    }
    /** send_reset_password_hash
        * email the hash to reset the password
        */
    private function send_reset_password_hash($email) {
        $email = mysql_real_escape_string($email);
        $result = mysql_query("SELECT id FROM ${$this->table} WHERE email='$email'");
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
    private function check_reset_password_hash($hash, $delete = FALSE, $match_id = NULL) {
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
    private function delete_reset_password_hash($hash, $user_id = NULL) {
        if ($user_id !== NULL)
            $where = "user_id='".mysql_real_escape_string($user_id)."'";
        else
            $where = "hash='".mysql_real_escape_string($hash)."'";
        mysql_query("DELETE FROM sf_reset_hashes WHERE $where");
    }
    /** check_pass
        * check for a password match on a user
        * using numeric id, alphanumeric username, or email address
        * RETURNS user ID or FALSE
        */
    private function check_pass($identifier, $password) {
        global $db;
        $identifier = mysql_real_escape_string($identifier);
        if (is_numeric($identifier))
            $user_where = 'id';
        else if (strpos($identifier, "@"))
            $user_where = 'email';
        else
            $user_where = 'username';
        $result = $db->get(
            array(
                'table'=>$this->table,
                'fields'=>array('id', 'password'),
                'where'=>array($user_where=>$identifier)
            )
        );
        if (!$result)
            return log_error('database error', FALSE);
        if (!mysql_num_rows($result))
            return log_error('email and password don\'t match', FALSE);
        $row = mysql_fetch_assoc($result);
        if (!$row['password'])
            return log_error('password not set', FALSE);
        if (!$this->check_pass_hash($password, $row['password']))
            return log_error('incorrect login', FALSE);
        return $row['id'];
    }
    /** make_pass_hash
        * make a salted hash of the password
        */
    private function make_pass_hash($password) {
        $salt = substr(sha1(rand()), 0, 24);
        $hash = sha1($salt.$password);
        return $salt.$hash;
    }
    /** check_pass_hash
        * check a password against a salted hash
        */
    private function check_pass_hash($password, $hash) {
        $salt = substr($hash, 0, 24);
        if ($hash != $salt.sha1($salt.$password))
            return FALSE;
        return TRUE;
    }
    /** check_user_exists
        * $criteria (array) associative array of fields to reference
        * RETURNS TRUE or FALSE
        */
    public function check_user_exists($criteria) {
        global $db;
        $result = $db->get_first_object(array('table'=>$this->table, 'fields'=>array('email'), 'where'=>$criteria));
        return !!$result;
    }
}
?>
