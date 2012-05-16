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
				<h3>Reply<span class="reply-to"></span></h3>
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
    </div>';
    const ascii = '+.0123456789<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~';
    protected $ascii_depth = 0;
    protected $default_options = array(
        'table'=>'',
        'interfaces'=>array(),
        'path_tier_bytes'=>4
    );
    public function Forum($options = array()) {
        parent::__construct($options);
        if (!$this->table) die('Forum requires a database table.');
        if ($this->interfaces) {
            foreach ($this->interfaces as $key => $name) {
                require_once(dirname(__FILE__).'/'.strtolower($name).'.class.php');
                $this->interfaces[$key] = new $name();
            }
        }
        $this->ascii_depth = strlen(self::ascii);
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
        $path = $this->toASCII($id) . '.';
        if ($data['reply_on_id'] != -1) {
            $parent = $db->get_first_object(array(
                'table'=>$this->table,
                'fields'=>array('path'),
                'where'=>array('id'=>$data['reply_on_id'])
            ));
            if (!empty($parent))
                $path = $parent->path . $path;
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
            'fields' => array($this->table.'.*', 'FLOOR(CHAR_LENGTH('.$this->table.'.path) / '.($this->path_tier_bytes + 1).') AS depth'),
            'table' => $this->table,
            'order' => 'path DESC',
            'limit' => $limit,
            'join' => array(
                $this->interfaces['link']->table => array(
                    'fields' => $this->interfaces['link']->fields,
                    'on' => array('link_id',$this->interfaces['link']->id_column)
                ),
                $this->interfaces['user']->table => array(
                    'fields' => $this->interfaces['user']->fields,
                    'on' => array('user_id',$this->interfaces['user']->id_column)
                )
            ),
            'filterObjects' => $this->interfaces
        );
        if ($thread_post_id !== NULL) {
            $first = $db->get_first_object(array(
                'table' => $this->table,
                'fields' => array('path'),
                'where' => array('id'=>$thread_post_id)
            ));
            if ($first) {
                $options['where'] = array('a.path LIKE'=>$first->path . '%');
            }
        }
        $list = $db->get_object($options);
        return $list;
    }
    public function toASCII($number) {
        // throw an exception if the number is too large
        if ($number > pow($this->ascii_depth, $this->path_tier_bytes)) {
            exit(''.$number);
            throw new Exception('number exceeds size for decimal to ASCII conversion. change path_tier_bytes setting.');
        }
        $output = '';
        for ($i = 0; $i < $this->path_tier_bytes; $i++) {
            $index = $number % $this->ascii_depth;
            $number = ($number - $index) / $this->ascii_depth;
            $output = substr(self::ascii, $index, 1) . $output;
        }
        return $output;
    }
    public function fromASCII($string) {
        // throw an exception if the string is too long
        if (strlen($string) > $this->path_tier_bytes) {
            throw new Exception('string exceeds length for ASCII to decimal conversion. change path_tier_bytes setting.');
        }
        $output = 0;
        while ($len = strlen($string)) {
            $index = strpos(self::ascii, substr($string, 0, 1));
            $string = substr($string, 1);
            $output += $index * pow($this->ascii_depth, $len - 1);
        }
        return $output;
    }
}

?>
