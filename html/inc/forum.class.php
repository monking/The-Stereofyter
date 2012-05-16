<?php

// NOTE (Christopher Lovejoy):
// Implementing threads using ASCII-encoded paths.
// e.g. ".A^@B.sw^5.a32j."
// each tier has 4 bytes, "." dot delimited
//   (256^4, 4,294,967,296 possible posts in the whole forum)
// ------------------------------
// RETRIEVE A THREAD AT ANY DEPTH
// ------------------------------
// get the path of the parent of the thread ($path).
// SELECT * FROM `forum_table` WHERE `path` LIKE '%$path%';
// ...all children paths will include the parent path
// ------------------------------
// PRO
//   easy to retrieve
//   easy to add to the tree
// CON
//   forum size limited by tree tier byte-size (4 bytes in this version)
//   thread depth limited by byte-size of path (51 bytes for 10 tiers)
//
class Forum extends Basic {
    public $markup = '
    <div id="forum">
        <div class="glance">
                <div class="right">
                    <a href="#" class="set-view" rel="preview">more ▲</a>
                </div>
            <h3>Latest in the Forum</h3>
            <ul class="list"></ul>
        </div>
        <div class="list preview">
            <div class="right">
                <a href="#" class="set-view" rel="glance">less ▼</a>
            </div>
            <h2>Forum</h2>
            <ul class="list"></ul>
            <div class="footer">
                <div class="right">
                    <a href="#" class="set-view" rel="glance">less ▼</a>
                </div>
                <pager></pager>
            </div>
        </div>
        <div class="list detail">
            <h2>Forum</h2>
            <h3 class="title"></h3>
            <div class="body"></div>
			<form class="reply">
				<h3>Reply</h3>
				<div class="form-field">
					<textarea class="message" name="message" rows="3"></textarea>
				</div>
				<div class="form-field a-right">
					<input type="submit" class="button" value="Send" /></input>
				</div>
			</form>
            <div class="footer">
                <div class="right">
					<a href="#" class="back-view">back &raquo;</a>
                </div>
            </div>
        </div>
        <div class="actions hide">
            <form class="reply" action="/scripts/forum.php" method="POST">
                <div class="message" contenteditable="true"></div>
                <a class="submit" href="#">Send</a>
            </form>
        </div>
    </div>';
    protected $default_options = array(
        'table'=>'',
        'linkInterface'=>'',
        'path_tier_bytes'=>4
    );
    public function Forum($options = array()) {
        parent::__construct($options);
        if (!$this->table) die('Forum requires a database table.');
        if ($this->linkInterface) {
            $interfaceName = $this->linkInterface;
            require_once(dirname(__FILE__).'/'.strtolower($interfaceName).'.class.php');
            $this->linkInterface = new $interfaceName();
        }
    }
    public function post($data) {
        global $db, $user;
        if (!is_array($data))
            return $this->resultObject(false, 'no data to post');
        if (!@$data['message'])
            return $this->resultObject(false, 'post data does not contain a message');
        if (!$user->id)
            return $this->resultObject(false, 'user not logged in');
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
                    'attachment_id' => -1
                ),
                'filter_mysql_assoc'
            )
        ));
        $id = mysql_insert_id();
        $path = self::toASCII($id) . '.';
        if ($data['reply_on_id'] != -1) {
            $parent = self::get(array('where'=>array('id'=>$data['reply_on_id'])));
            if (!empty($parent))
                $path = $parent[0]->path . $path;
        }
        $db->post(array(
            'table' => $this->table,
            'method' => 'update',
            'fields' => array(
                'path' => $path
            ),
            'where' => array(
                'id' => $id
            )
        ));
        return $this->resultObject(true, 'message posted', array(
            'id'=>$id,
            'path'=>$path
        ));
    }
    public function get($thread_post_id = NULL, $limit = 30) {
        global $db;
        $options = array(
            'fields' => array('*', 'FLOOR(CHAR_LENGTH('.$this->table.'.path) / '.($this->path_tier_bytes + 1).') AS depth'),
            'table' => $this->table,
            'order' => 'path DESC',
            'limit' => $limit,
            'join' => array(
                $this->linkInterface->table => array(
                    'fields' => $this->linkInterface->fields,
                    'remote_key' => 'link_id'
                )
            ),
            'filterObj' => $this->linkInterface
        );
        if ($thread_post_id !== NULL)
            $options['where'] = array('a.id'=>$thread_post_id);
        $list = $db->get_object($options);
        return $list;
    }
    public static function toASCII($number) {
        // throw an exception if the number is too large
        if ($number > pow(256, $this->path_tier_bytes)) {
            throw new Exception('number exceeds size for decimal to ASCII conversion. change path_tier_bytes setting.');
        }
        $output = '';
        for ($i = 0; $i < $this->path_tier_bytes; $i++) {
            $index = $number % 256;
            $number = ($number - $index) / 256;
            $output = chr($index) . $output;
        }
        return $output;
    }
    public static function fromASCII($string) {
        // throw an exception if the string is too long
        if (strlen($string) > $this->path_tier_bytes) {
            throw new Exception('string exceeds length for ASCII to decimal conversion. change path_tier_bytes setting.');
        }
        $output = 0;
        while ($len = strlen($string)) {
            $index = ord(substr($string, 0, 1));
            $string = substr($string, 1);
            $output += $index * pow(256, $len - 1);
        }
        return $output;
    }
}

?>
