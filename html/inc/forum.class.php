<?php

class Forum {
    public $markup = '
    <div id="forum">
        <div class="glance">
            <h3>Latest in the Forum</h3>
            <ul class="list">
                <li>
                    <div class="title"></div>
                    <div class="body"></div>
                </li>
            </ul>
            <div class="footer">
                <a href="#" class="set-view" rel="preview">more...</a>
            </div>
        </div>
        <div class="preview">
            <ul class="list">
                <li>
                    <div class="title"></div>
                    <div class="body"></div>
                </li>
            </ul>
            <div class="footer">
                <a href="#" class="set-view" rel="glance">less...</a>
            </div>
        </div>
        <div class="detail">
            <h4 class="title"></h4>
            <div class="body"></div>
            <div class="footer">
                <a href="#" class="back-view">back &raquo;</a>
            </div>
        </div>
        <div class="actions hide">
            <form class="reply" action="/scripts/forum.php" method="POST">
                <div class="message" contenteditable="true"></div>
                <a class="submit" href="#">Send</a>
            </form>
        </div>
    </div>';
    public function Forum($options = array()) {
        $defaults = array(
            'table'=>'',
            'linkInterface'=>''
        );
        foreach ($defaults as $key => $value) {
            $this->$key = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
        }
        if (!$this->table) die('Forum requires a database table.');
        if ($this->linkInterface) {
            require_once(dirname(__FILE__).'/'.$this->linkInterface.'.class.php');
            $this->linkInterface = new $this->linkInterface();
        }
    }
    public function post($data) {
        global $db, $user;
        if (!is_array($data)
            || !@$data['message']
            || !$user->id)
            return false;
        $data['user_id'] = $user->data->id;
        $db->post(array(
            'table' => $this->table,
            'method' => 'insert',
            'fields' => array_conform(
                $data,
                array(
                    'message' => '',
                    'title' => '',
                    'user_id' => -1,
                    'link_id' => -1,
                    'reply_on_id' => -1,
                    'attachment_id' => -1
                ),
                'filter_mysql_assoc'
            )
        ));
    }
    public function get($options) {
        global $db;
        $options['table'] = $this->table;
        $list = $db->get_object(
            array_conform(
                $options,
                array(
                    'table' => $this->table,
                    'where' => '',
                    'order' => 'date DESC',
                    'limit' => '10',
                    'join' => array(
                        'table' => $this->linkInterface->table,
                        'fields' => $this->linkInterface->fields,
                        'remote_id' => 'link_id'
                    ),
                    'filter' => $this->linkInterface->filter
                )
            )
        );
        return $list;
    }
}

?>