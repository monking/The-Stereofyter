<?php

class Basic {
    protected $default_options = array();
    public function Basic($options = array()) {
        foreach ($this->default_options as $key => $value) {
            $this->$key = @array_key_exists($key, $options) ? $options[$key] : $this->default_options[$key];
        }
    }
    protected function resultObject($status, $message = '', $other = array()) {
        $other['status'] = $status;
        $other['message'] = $message;
        return (object) $other;
    }
}

?>
