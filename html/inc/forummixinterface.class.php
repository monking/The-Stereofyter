<?php

class ForumMixInterface {
    public
        $name = 'ForumMixInterface',
        $table = 'sf_mixes',
        $id_column = 'id',
        $fields = array(
            'title AS link_name',
            'CONCAT(\'/?mix=\', b.id) AS link'
        ),
        $searches = array(
            'title'
        );
    public function filter(&$row) {
        // $row->link = "/?mix_id=$row->link_id";
    }
}

?>
