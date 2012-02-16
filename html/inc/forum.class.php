<?php

class Forum {
  public function Forum($options = array()) {
    $defaults = array();
    foreach ($defaults as $key => $value) {
      $this->$key = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
    }
  }
  public function post($data) {
    global $db;
    if (!is_array($data) || !@$data['']) return false;
  }
  public function get($options) {
    global $db;
    $defaults = array(
      'WHERE' => '',
      'ORDER BY' => 'date DESC',
      'LIMIT' => '10'
    );
    foreach ($defaults as $key => $value) {
      $options[$key] = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
    }
    $list = $db->get(FORUM_TABLE, $options);
  }
}

?>