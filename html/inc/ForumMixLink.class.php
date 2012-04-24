<?php

class ForumMixLink {
    public
        $name = 'ForumMixLink',
        $table = 'sf_mixes',
        $fields = array(
            'title AS link_name',
            array('CONCAT(\'/?mix=\', link_id) AS link')
        );
    public function filter(&$row) {
        echo 'mess';
        $row->link = "/?mix_id=$row->link_id";
    }
}

?>
