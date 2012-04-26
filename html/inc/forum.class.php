<?php

class Forum {
    public $markup = '
    <div id="forum">
        <div class="glance">
                <div class="right">
                    <a href="#" class="set-view" rel="preview">more &raquo;</a>
                </div>
            <h3>Latest in the Forum</h3>
            <ul class="list"></ul>
        </div>
        <div class="list preview">
            <div class="right">
                <a href="#" class="set-view" rel="glance">less &raquo;</a>
            </div>
            <h2>Forum</h2>
            <ul class="list"></ul>
            <div class="footer">
                <div class="right">
                    <a href="#" class="set-view" rel="glance">less &raquo;</a>
                </div>
                <pager></pager>
            </div>
        </div>
        <div class="list detail">
            <h2>Forum</h2>
            <h3 class="title"></h3>
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
            $interfaceName = $this->linkInterface;
            require_once(dirname(__FILE__).'/'.strtolower($interfaceName).'.class.php');
            $this->linkInterface = new $interfaceName();
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
                        $this->linkInterface->table => array(
                            'fields' => $this->linkInterface->fields,
                            'remote_key' => 'link_id'
                        )
                    ),
                    'filterObj' => $this->linkInterface
                )
            )
        );
        return $list;
    }
}

?>
