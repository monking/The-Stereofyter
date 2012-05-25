<?php

class Mix {
    /** save
        * $mix_data (array)
            ['mix'] (string) JSON-encoded mix data to be saved
            ['title'] (string) OPTIONAL title of the mix; needed for a new mix
            ['tempo'] (string) OPTIONAL the mix's BPM
            ['chromatic_key'] (string) OPTIONAL the key of the music in shorthand (e.g. C, F#m)
            ['id'] (number) OPTIONAL id of the mix. If omitted, a new mix is saved
        * RETURNS (number) id of saved mix, or -1 on error
        */
    public static function save($mix_data) {
        global $user, $db;
        if (!isset($user->id))
            return log_error('not logged in', FALSE);
        if (!isset($mix_data['mix']))
            return log_error('no mix data received for saving', FALSE);

        if (isset($mix_data['id'])) {
            if (!self::check_owner($mix_data['id'], $user->id))
                unset($mix_data['id']);
        }
        $mix_fields = array_conform(
            $mix_data,
            array(
                'mix' => '',
                'title' => 'Untitled',
                'chromatic_key' => '',
                'tempo' => '',
                'duration' => '',
                'modified_by' => $user->id,
                'published' => 0
            ),
            'filter_mysql_assoc'
        );
        if (isset($mix_data['id'])) {
            $mix_fields['modified'] = array('function' => 'NOW()');
            if (!$db->post(array(
                'table'=>'sf_mixes',
                'method'=>'update',
                'fields'=>$mix_fields,
                'where'=>array('id' => $mix_data['id'])
            )))
                return log_error(mysql_error(), FALSE);
            $saved_mix_id = $mix_data['id'];
        } else {
            $mix_fields['created'] = array('function' => 'NOW()');
            if (!$db->post(array(
                    'table'=>'sf_mixes',
                    'method'=>'insert',
                    'fields'=>$mix_fields,
            )))
                return log_error(mysql_error(), FALSE);
            $saved_mix_id = mysql_insert_id();
            self::add_owner($saved_mix_id, $user->id);
        }
        return $saved_mix_id;
    }
    /** add_owner
        * $mix_id (number) id of the mix
        * $user_id (number) id of user being added as owner of the mix
        * RETURNS Boolean success
        */
    public static function add_owner($mix_id, $user_id) {
        global $ERROR, $user;
        $mix_id = mysql_real_escape_string($mix_id);
        $user_id = mysql_real_escape_string($user_id);
        $user_exists = $user->check_user_exists(array('id' => $user_id));
        if (!$user_exists) 
            return log_error('user does not exist', FALSE);
        if (self::check_owner($mix_id, $user_id)) return TRUE;
        $query = "INSERT INTO sf_mix_owners SET mix_id='$mix_id', owner_id='$user_id'";
        if (!mysql_query($query)) 
            return log_error(mysql_error());
        return TRUE;
    }
    /** remove_owner
        * $mix_id (number) id of the mix
        * $owner_id (number) id of user being removed as owner of the mix
        */
    public static function remove_owner($mix_id, $owner_id) {
        $mix_id = mysql_real_escape_string($mix_id);
        $owner_id = mysql_real_escape_string($owner_id);
        $query = "DELETE sf_mix_owners WHERE mix_id='$mix_id' AND owner_id='$owner_id'";
        if (!mysql_query($query)) 
            return log_error(mysql_error(), FALSE);
        return TRUE;
    }
    /** check_owner
        * $mix_id (number) id of the mix
        * $owner_id (number) id of user being checked as owner of the mix
        * RETURNS TRUE if the user is an owner, FALSE if now
        */
    public static function check_owner($mix_id, $owner_id) {
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
    /** get_owners
        * $mix_id (number) id of the mix
        * RETURNS array of mix owners
        */
    public static function get_owners($mix_id) {
        $owners = array();
        $result = mysql_query("SELECT owner_id FROM sf_mix_owners WHERE mix_id='$mix_id'");
        if (!$result) 
            return log_error(mysql_error());
        while ($owner = mysql_fetch_array($result))
            $owners[] = $owner[0];
        return $owners;
    }
    /** load
        * get a mix as an object
        * @mix_id (int) the numeric ID of the mix
        * RETURNS sdClass of mix data
        */
    public static function load($mix_id) {
        global $db;
        if (!is_numeric($mix_id)) return NULL;
        return $db->get_first_object(array(
            'table'=>'sf_mixes',
            'join'=>array(
                'sf_mix_messages'=>array(
                    'fields'=>array('message'),
                    'on'=>array('id', 'link_id')
                )
            ),
            'where'=>array('sf_mixes.id'=>$mix_id)
        ));
    }
    /** get_user_mixes
        * get an array of mix data for mixes owned by the given user
        * @user_id (int) the numeric ID of the user
        * RETURNS array of mix data
        */
    public static function get_user_mixes($user_id) {
        global $db;
        if (!is_numeric($user_id)) return NULL;
        return $db->get_object(array(
            'table'=>'sf_mixes',
            'fields'=>array('id','title','duration','tempo','chromatic_key','published'),
            'join'=>array(
                'sf_mix_owners'=>array(
                    'fields'=>array(),
                    'on'=>array('id', 'mix_id')
                ),
                'sf_mix_messages'=>array(
                    'fields'=>array('message'),
                    'on'=>array('id', 'link_id')
                )
            ),
			'where'=>array('sf_mix_owners.owner_id'=>$user_id),
			'order'=>'sf_mixes.modified DESC'
        ));
    }
    public static function mix_json_encode($mix_data) {
        $mix = $mix_data->mix;
        $mix_data->mix = '--SUBSITUTE MIX--';
        $json = json_encode($mix_data);
        return str_replace('"--SUBSITUTE MIX--"', $mix, $json);
    }
}

?>
