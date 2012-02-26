<?php

class Database {
  public $db_conn;
  public function Database($params = array()) {
    if ($params)
      $this->connect($params);
  }
  public function connect($params) {
    $this->db_conn = mysql_connect($params['host'], $params['user'], $params['pass']);
    if (!$this->db_conn) return false;
    unset($pass);
    if (!mysql_select_db($params['name'])) return false;
  }
  /** post
  	* build and submit a MySQL query from an associative array
  	* @assoc (Array) keys for column names.
  	*		A key of 'WHERE' should have another associative array as a value, and will be
  	*		turned into a MySQL 'WHERE' statement.
  	* @method (String) 'INSERT' or 'UPDATE'
  	* @table_name (String)
  	*
  	* NOTE: you must escape special characters in your values before calling assoc_to_mysql
  	*/
  public function post($table_name, $method, $assoc) {
  	$methods = array('INSERT'=>'INSERT INTO', 'UPDATE'=>'UPDATE');
  	$reserved = array('WHERE');
  	$query = '';
  	if (array_key_exists($method, $methods)) {
  		$row_num = 0;
  		if (!array_key_exists(0, $assoc))
  		  $assoc = array($assoc);
  		foreach($assoc as $row) {
  			$row_num++;
  			$query .= "$methods[$method] $table_name SET";
  			$field_num = 0;
  			foreach($row as $field => $value) {
  				if (array_search($field, $reserved) !== false) continue;
  				$field_num++;
  				$field_delimiter = $field_num > 1? ',': '';
  				$query .= "$field_delimiter $field=";
  				if (is_array($value) && array_key_exists('function', $value))
  					$query .= $value['function'];
  				else 
  					$query .= "'".str_replace("'", "\\'", $value)."'";
  			}
  			if (array_key_exists('WHERE', $row)) {
  				$query .= self::assoc_to_mysql_where($row['WHERE']);
  			}
  			$query .= ';';
  		}
  	} else {
  		return false;
  	}
  	echo ($query);
  	if (!mysql_query($query)) return false;
  	return true;
  }
  /** get
  	* build and submit a MySQL query from an associative array
  	* @assoc (Array) keys for column names.
  	*		A key of 'WHERE' should have another associative array as a value, and will be
  	*		turned into a MySQL 'WHERE' statement.
  	* @method (String) 'INSERT' or 'UPDATE'
  	* @table_name (String)
  	*
  	* NOTE: you must escape special characters in your values before calling assoc_to_mysql
  	*/
  public function get($table_name, $assoc) {
  	// Takes a 2-dimensional associative array and turns it into a SQL query.
  	// VERY INCOMPLETE! 2011-04-29
  	$reserved = array('WHERE', 'ORDER BY', 'LIMIT');
  	$where = '';
  	$orderby = '';
  	$limit = '';
		if (array_key_exists('WHERE', $assoc)) {
			$where = self::assoc_to_mysql_where($assoc['WHERE']);
			unset($assoc['WHERE']);
		}
		if (array_key_exists('ORDER BY', $assoc)) {
			$orderby = ' ORDER BY '.$assoc['ORDER BY'];
			unset($assoc['ORDER BY']);
		}
		if (array_key_exists('LIMIT', $assoc)) {
			$limit = ' LIMIT '.$assoc['LIMIT'];
			unset($assoc['LIMIT']);
		}
		$fields = isset($assoc['fields']) ? implode(', ', $assoc['fields']) : '*';
		$query = "SELECT $fields FROM $table_name$where$orderby$limit;";
  	return mysql_query($query);
  }
  public function get_first_obj($table_name, $assoc) {
    $result = $this->get($table_name, $assoc);
    return mysql_fetch_obj($result);
  }
  /** where_recurse
    */
  public static function where_recurse($assoc, $conjunction = 'AND', $nested = TRUE) {
    $conditions = array();
    foreach($assoc as $field => $value) {
  		if ($field == 'OR' || is_array($value)) {
  	    $conditions[] = self::where_recurse($value, $field == 'OR' ? 'OR' : 'AND');
  		} else {
    		$field= mysql_real_escape_string($field);
  		  //if $value is stdClass with property 'function', use without quotes
  		  // as in th case of the value $value->function = 'NOW()'
    		$value = mysql_real_escape_string($value);
    		$conditions[] = "`$field`='$value'";
  		}
  	}
  	$where = $nested ? '(' : '';
  	$where .= implode(" $conjunction ", $conditions);
  	$where .= $nested ? ')' : '';
  	return $where;
  }
  /** assoc_to_mysql_where
  	*/
  public static function assoc_to_mysql_where($assoc) {
  	return $assoc ? ' WHERE '.self::where_recurse($assoc, 'AND', FALSE) : '';
  }

  /** mysql_to_assoc
  	* $query (string) MySQL QUERY whose result will be shown
  	*/
  public function get_assoc($table_name, $assoc) {
    global $ERROR;
  	if (!($result = $this->get($table_name, $assoc))) {
  		if (DEBUG) $ERROR[] = mysql_error();
  		return FALSE;
  	}
  	$result_array = array();
  	while($row = mysql_fetch_assoc($result))
  	  $result_array[] = $row;
  	return $result_array;
  }
  public function get_object($table_name, $assoc) {
    global $ERROR;
  	if (!($result = $this->get($table_name, $assoc))) {
  		if (DEBUG) $ERROR[] = mysql_error();
  		return FALSE;
  	}
  	$result_array = array();
  	while($row = mysql_fetch_object($result))
  	  $result_array[] = $row;
  	return $result_array;
  }
  /** mysql_to_table
  	*/
  public function mysql_to_table($query) {
  	$result = mysql_query($query);
  	if (!$result) {
  		if (DEBUG) $ERROR[] = mysql_error();
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
}

?>