<?php

class Forum {
  public function Forum($options = array()) {
    $defaults = array(
      'table'=>''
    );
    foreach ($defaults as $key => $value) {
      $this->$key = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
    }
    if (!@$this->table) die('Forum requires a database table.');
  }
  public function post($data) {
    global $db, $user;
    if (!is_array($data)
      || !@$data['message']
      || !$user->data->id)
      return false;
    $data['user_id'] = $user->data->id;
    $db->post(
      $this->table,
      'INSERT',
      array_conform(
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
    );
  }
  public function get($options) {
    global $db;
    $list = $db->get_assoc(
      $this->table,
      array_conform(
        $options,
        array(
          'WHERE' => '',
          'ORDER BY' => 'date DESC',
          'LIMIT' => '10'
        )
      )
    );
    return $list;
  }
}

?>