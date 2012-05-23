<?php

function json_escape($string) {
  $string = preg_replace('/(\n\r|\n|\r)+/', '\n', $string);
  $string = preg_replace('/"/', '\"', $string);
	return $string;
}
/** array_conform
  *	$input (array) : array to conform to default
  * $default (array) : array on which to model input
  * $filter (string) : name of a function which takes an array key and value (value passed as
		reference). Must return true or false. If false, the element is removed from the array.
		EXAMPLE:
		function filter($key, &$value)
			{
			if ($key == 'temp') return false;
			$value = 'prefix_'.$value;
			return true
			}
		
		Disregarding $default, for the sake of the example, this filter would turn
			['temp' => 1, 'a' => 'thing', 'b' => 'other']
		into
			['a' => 'prefix_thing', 'b' => 'prefix_other']
		
  */
function array_conform($input, $default, $filter = '') {
  if (!$input) $input = array();
	foreach ($default as $key => $value) {
		if (!array_key_exists($key, $input)) {
		  if (is_array($default[$key]))
		    $input[$key] = array_conform($value, $default[$key], $filter);
		  else
    		$input[$key] = $value;
		}
	}
	foreach ($input as $key => $value) {
		if (!array_key_exists($key, $default)) {
			unset($input[$key]);
			continue;
		}
		if ($filter && function_exists($filter)) {
			if (!$filter($key, $input[$key]))
				unset($input[$key]);
		}
	}
	return $input;
}

/** filter_mysql_assoc
  * filter function for array_conform
  * removes elements with the value -1 and escapes values for MySQL input
  */
function filter_mysql_assoc($key, &$value) {
	if ($value == -1) return FALSE;
	if (!count($value))
		$value = mysql_real_escape_string($value);
	return TRUE;
}

?>
