<?php

class Forum {
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