<?php

/** json_escape
  */
function json_escape($string) {
  $string = preg_replace('/(\n\r|\n|\r)+/', '\n', $string);
  $string = preg_replace('/"/', '\"', $string);
	return $string;
}

?>