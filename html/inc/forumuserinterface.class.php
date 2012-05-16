<?php

class ForumUserInterface {
    public
        $name = 'ForumUserInterface',
        $table = 'sf_users',
        $id_column = 'id',
        $fields = array('email AS username');
    public function filter(&$row) {
        $row->username = preg_replace('/@.*/', '', $row->username);
    }
}

?>
