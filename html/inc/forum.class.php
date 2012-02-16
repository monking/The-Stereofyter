<?php

class Forum {
  private $table;
  public function Forum($options) {
    $defaults = array(
      'table'=>null
    );
    foreach ($defaults as $key => $value) {
      $this->$key = @array_key_exists($key, $options) ? $options[$key] : $defaults[$key];
    }
  }
  public function post($data) {
    if (!is_array($data) || !@$data['']) return false;
  }
}

?>