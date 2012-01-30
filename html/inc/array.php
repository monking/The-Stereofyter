<?php

require_from_inc_dir('json');

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
function array_conform($input, $default, $filter = '')
	{
	foreach ($default as $key => $value)
		{
		if (!array_key_exists($key, $input)) $input[$key] = $value;
		}
	foreach ($input as $key => $value)
		{
		if (!array_key_exists($key, $default))
			{
			unset($input[$key]);
			continue;
			}
		if ($filter && function_exists($filter))
			if (!$filter($key, $input[$key]))
				unset($input[$key]);
				
		}
	return $input;
	}
  
/** assoc_to_json
	* $assoc (array)
	* $options (array)
		['whitespace'] (string) 'none' or 'newline' (default 'none')
		['structure'] (string) 'object', 'array', 'column' or 'flat' (default 'object')
			'object': an object containing rows as objects, indexed by the first column selected
			'array': an array containing rows as elements counting from 0
			'column': an array of the values in the first column
			'flat': an object of only the first row
		['indent'] (string) whitespace to prepend to each line (overridden by ['whitespace'] => 'none')
		['objects'] (array) array of column names whose data are already JSON-compatible objects.
	*/
function assoc_to_json($assoc, $options = array()) {
	$json = '';
	foreach (
		array(
			'whitespace' => 'none',
			'structure' => 'object',
			'indent' => '',
			'objects' => array()
			)
		as $key => $value) {
		if (!array_key_exists($key, $options))
			$options[$key] = $value;
	}
	if ($options['structure'] != 'flat')
		$json .= $options['structure'] == 'object'? '{': '[';
	$row_count = 0;
	foreach($assoc as $row) {
		$row_count++;
		$field_count = 0;
		$first_field = true;
		foreach($row as $field => $value) {
			if ($first_field) {
				if ($options['whitespace'] == 'newline')
					$json .= "\n".$options['indent']."	";
				if ($options['structure'] == 'object')//object: use first column as the key for the row
					$json .= '"'.json_escape($value).'":';
				if ($options['structure'] != 'column')
					$json .= "{";
				$first_field = false;
			}
			if ($options['structure'] != 'column') {
				$field_count++;
				if ($options['whitespace'] == 'newline')
					$json .= "\n".$options['indent'].'		';
				$json .= '"'.json_escape($field).'":';
				if (is_numeric($value)) {
					$json .= $value;
				} else if(array_search($field, $options['objects']) !== false) {
					if (empty($value))
						$json .= 'null';
					else
						$json .= $value;
				} else {
					$json .= '"'.json_escape($value).'"';
				}
				$field_count < count($row) && $json .= ",";
			}
		}
		if ($options['whitespace'] == 'newline')
			$json .= "\n".$options['indent']."	";
		$json .= "}";		
		if ($options['structure'] == 'flat')
			break;
		$row_count < count($assoc) && $json .= ",";
	}
	if ($options['whitespace'] == 'newline')
		$json .= "\n".$options['indent'];
	if ($options['structure'] != 'flat')
		$json .= $options['structure'] == 'object'? '}': ']';
	return $json;
}
?>