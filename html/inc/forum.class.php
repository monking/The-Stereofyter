<?php

// NOTE (Christopher Lovejoy):
// Implementing threads using sortable character-encoded paths.
// e.g. ".A^@B.sw^5.a32j."
// each tier has 4 bytes, "." dot delimited
//   current encoding supports 133 sorted characters
//   (133^4, 312,900,721 possible posts in the whole forum)
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
class Forum extends Basic {
    public $markup = '
    <div id="forum-tab">Show Forum</div>
    <div id="forum">
        <div class="glance">
                <div class="right">
                    <a href="#" class="toggle-hide">hide</a>
                    <a href="#" class="set-view" rel="preview">more ▲</a>
                </div>
            <h3>Latest in the Forum</h3>
            <ul class="list"></ul>
        </div>
        <div class="preview">
            <div class="right">
				<form class="search">
					<input type="text" name="term" placeholder="Search" />
					<input type="submit" value="Search" class="away" />
				</form>
                <a href="#" class="toggle-hide">hide</a>
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
        <div class="detail">
            <h2>Forum</h2>
            <div class="right">
                <a href="#" class="toggle-hide">hide</a>
            </div>
            <h3 class="title"></h3>
            <div class="body"></div>
            <form class="reply">
                <input type="hidden" name="reply_on" value="" />
                <h3>Reply</h3>
                <div class="form-field">
                    <textarea class="message" name="message" rows="3"></textarea>
                </div>
                <div class="form-field a-right">
                    <input type="submit" class="button" value="Send" /></input>
                </div>
            </form>
            <div class="reply-status">Your reply has been posted.</div>
            <div class="footer">
                <div class="right">
                    <a href="#" class="back-view">back &raquo;</a>
                </div>
            </div>
        </div>
    </div>';
    const path_enc_set = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
    protected $path_encode_base = 0;
    protected $default_options = array(
        'table'=>'',
        'interfaces'=>array(),
        'path_tier_bytes'=>5
    );
    public function Forum($options = array()) {
        parent::__construct($options);
		$this->path_encode_base = strlen(self::path_enc_set);
        if (!$this->table) die('Forum requires a database table.');
        if ($this->interfaces) {
            foreach ($this->interfaces as $key => $name) {
                require_once(dirname(__FILE__).'/'.strtolower($name).'.class.php');
                $this->interfaces[$key] = new $name();
            }
        }
    }
    public function post($data) {
        global $db, $user;
        if (!is_array($data))
            return $this->resultObject('empty', 'no data to post');
        if (!@$data['message'])
            return $this->resultObject('empty', 'post data does not contain a message');
        if (!$user->id)
            return $this->resultObject('user', 'invalid user');
        $data['user_id'] = $user->data->id;
        $data['message'] = Forum::htmlEncode($data['message']);
        if (@$data['id']) {
            $update_allowed = $db->get_first_object(array(
                'table' => $this->table,
                'fields' => array('COUNT(*)'),
                'where' => array('id'=>$data['id'], 'user_id'=>$data['user_id'])
            ));
            if (!$update_allowed) {
                return $this->resultObject('user', 'user may not edit another user\'s posts');
            }
            $result = $db->post(array(
                'table' => $this->table,
                'method' => 'update',
                'fields' => array_conform(
                    $data,
                    array(
                        'message' => '',
                        'title' => '',
                        'user_id' => -1,
                        'link_id' => -1,
                        'attachment_id' => -1,
                        'created' => array('function'=>'NOW()')
                    ),
                    'filter_mysql_assoc'
                ),
                'where' => array('id'=>$data['id'])
            ));
            if (!$result)
                $data['id'] = false;
        } else {
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
                        'attachment_id' => -1,
                        'created' => array('function'=>'NOW()')
                    ),
                    'filter_mysql_assoc'
                )
            ));
            $data['id'] = mysql_insert_id();
			if ($data['id']) {
				$path = $this->pathSegmentEncode($data['id']) . '.';
				if (@$data['reply_on_id'] && $data['reply_on_id'] != -1) {
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
						'id' => $data['id']
					)
				));
			}
        }
        if ($data['id']) {
            return $this->resultObject('ok', 'message posted', array(
                'id'=>$data['id']
            ));
        } else {
            return $this->resultObject('error', 'post failed');
        }
    }
    public function get($options = array()) {
        global $db;
        $options = array_conform(
            $options,
            array(
                'limit' => 30,
                'search' => '',
                'thread' => null,
                'order' => 'created DESC'
            )
        );
        $query = array(
            'fields' => array(
                'id',
                'FLOOR(CHAR_LENGTH('.$this->table.'.path) / '.($this->path_tier_bytes + 1).' - 1) AS depth',
                'link_id',
                'attachment_id',
                'user_id',
                'created',
                'modified',
                'message',
                'title',
                'SUBSTR('.$this->table.'.path, 1, '.$this->path_tier_bytes.') AS thread_path'
            ),
            'table' => $this->table,
            'order' => $options['order'],
            'limit' => $options['limit'],
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
        if ($options['thread'] !== NULL) {
            $first = $db->get_first_object(array(
                'table' => $this->table,
                'fields' => array(
                    'path',
                    'SUBSTR('.$this->table.'.path, 1, '.$this->path_tier_bytes.') AS thread_path'
                ),
                'where' => array('id'=>$options['thread'])
            ));
            if ($first) {
                $query['where'] = array('a.path LIKE'=>$first->thread_path . '%');
            }
        } else if ($options['search'] != '') {
			$searchColumns = array('`'.$this->table.'`.`title`');
			foreach ($this->interfaces['link']->searches as $search) {
				$searchColumns[] = '`'.$this->interfaces['link']->table.'`.`'.$search.'`';
			}
			$searches = array();
			foreach ($searchColumns as $column) {
				$searches[$column.' LIKE'] = '%'.$options['search'].'%';
			}
			$query['where'] = array('OR'=>$searches);
        } else {
            $query['where'] = array('CHAR_LENGTH(a.path) <'=>($this->path_tier_bytes + 2));
        }
        $list = $db->get_object($query);
        return $list;
    }
    public function pathSegmentEncode($number) {
        // throw an exception if the number is too large
        if ($number > pow($this->path_encode_base, $this->path_tier_bytes)) {
            exit(''.$number);
            throw new Exception('number exceeds size for decimal to path base conversion. change path_tier_bytes setting.');
        }
        $output = '';
        for ($i = 0; $i < $this->path_tier_bytes; $i++) {
            $index = $number % $this->path_encode_base;
            $number = ($number - $index) / $this->path_encode_base;
            $output = substr(self::path_enc_set, $index, 1) . $output;
        }
        return $output;
    }
    public function pathSegmentDecode($string) {
        // throw an exception if the string is too long
        if (strlen($string) > $this->path_tier_bytes) {
            throw new Exception('string exceeds length for path base to decimal conversion. change path_tier_bytes setting.');
        }
        $output = 0;
        while ($len = strlen($string)) {
            $index = strpos(self::path_enc_set, substr($string, 0, 1));
            $string = substr($string, 1);
            $output += $index * pow($this->path_encode_base, $len - 1);
        }
        return $output;
    }
    public static function htmlEncode($message) {
        $message = preg_replace('/\r\s/', '<br />', $message);
        $message = preg_replace('/(<br \/>){2,}/', '</p><p>', '<p>'.$message.'</p>');
        return $message;
    }
}

?>
