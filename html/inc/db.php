<?php

require_from_inc_dir('../../_config', 'array');

$DB_CONN = mysql_connect(DB_HOST, DB_USER, DB_PASS);
$DB_SELECT = mysql_select_db(DB_NAME);
/** assoc_to_mysql
	* build and submit a MySQL query from an associative array
	* @assoc (Array) keys for column names.
	*		A key of 'WHERE' should have another associative array as a value, and will be
	*		turned into a MySQL 'WHERE' statement.
	* @method (String) 'INSERT' or 'UPDATE'
	* @table_name (String)
	* @db_name (OPTIONAL String)
	*
	* NOTE: you must escape special characters in your values before calling assoc_to_mysql
	*/
function assoc_to_mysql($assoc, $method, $table_name, $db_name = null) {
	// Takes a 2-dimensional associative array and turns it into a SQL query.
	// VERY INCOMPLETE! 2011-04-29
	$methods = array('INSERT'=>'INSERT INTO', 'UPDATE'=>'UPDATE');
	$query = '';
	if (array_key_exists($method, $methods)) {
		$row_num = 0;
		foreach($assoc as $row) {
			$row_num++;
			$query .= "$methods[$method] $table_name SET";
			$field_num = 0;
			foreach($row as $field => $value) {
				if ('WHERE' == $field) continue;
				$field_num++;
				$field_delimiter = $field_num > 1? ',': '';
				$query .= "$field_delimiter $field=";
				if (is_array($value) && array_key_exists('function', $value))
					$query .= $value['function'];
				else 
					$query .= "'$value'";
			}
			if (array_key_exists('WHERE', $row)) {
				$query .= assoc_to_mysql_where($row['WHERE']);
			}
			$query .= ';';
		}
	} else {
		return false;
	}
	if (!mysql_query($query)) return false;
	return true;
}
/** assoc_to_mysql_where
	*/
function assoc_to_mysql_where($assoc) {
	// how can an associated array represent an AND/OR string, and should it?
	// or should I just expect the string?
	// currently assuming AND.
	$cond_num = 0;
	$query = ' WHERE';
	foreach($assoc as $field => $value) {
		$cond_num++;
		$field = mysql_real_escape_string($field);
		$value = mysql_real_escape_string($value);
		$where_delim = $cond_num > 1? 'AND': '';
		$query .= "$where_delim $field='$value'";
	}
	return $query;
}
/** mysql_to_json
	* $query (string) MySQL QUERY whose result will be shown
	* $options (array) see assoc_to_json documentation
	*/
function mysql_to_json($query, $options = array()) {
	if (!($result = mysql_query($query)))
		die(mysql_error());
	$result_array = array();
	while($row = mysql_fetch_assoc($result))
	  $result_array[] = $row;
	return assoc_to_json($result_array, $options);
}
/** mysql_to_table
	*/
function mysql_to_table($query) {
	$result = mysql_query($query);
	if (!$result) {
		$output = "<!-- $query -->";
		$output .= "\r\n";
		$output .= '<table>'."\r\n";
		$output .= '	<tbody>'."\r\n";
		$output .= '		<tr>'."\r\n";
		$output .= '			<td>'.mysql_error().'</td>'."\r\n";
		$output .= '		</tr>'."\r\n";
		$output .= '	</tbody>'."\r\n";
		$output .= '</table>'."\r\n";
		echo $output;
		return false;
	}
	if (!mysql_num_rows($result)) {
		$output .= "\r\n";
		$output .= '<table>'."\r\n";
		$output .= '	<tbody>'."\r\n";
		$output .= '		<tr>'."\r\n";
		$output .= '			<td>empty set</td>'."\r\n";
		$output .= '		</tr>'."\r\n";
		$output .= '	</tbody>'."\r\n";
		$output .= '</table>'."\r\n";
		echo $output;
		return false;
	}
	$output = "\r\n";
	$output .= '<table>'."\r\n";
	$output .= '	<thead>'."\r\n";
	$i = 0;
	$output .= '		<tr>'."\r\n";
	while ($i < mysql_num_fields($result)) {
		$col = mysql_fetch_field($result, $i);
		$output .= '			<td>'."$col->name".'</td>'."\r\n";
		$i++;
	}
	$output .= '		</tr>'."\r\n";
	$output .= '	</thead>'."\r\n";
	$output .= '	<tbody>'."\r\n";
	while($row = mysql_fetch_assoc($result)) {
		$output .= '		<tr>'."\r\n";
		foreach($row as $field => $value) {
			$output .= '			<td>'.$value.'</td>'."\r\n";
		}
		$output .= '		</tr>'."\r\n";
	}
	$output .= '	</tbody>'."\r\n";
	$output .= '</table>'."\r\n";
	echo $output;
}
?>