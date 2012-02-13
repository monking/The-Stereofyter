<?php

class DB {

	private $db_conn;
	/** Database
	  * same as connect()
	  */
	public function Database($host, $user, &$pass, $database) {
		self::connect($host, $user, $pass, $database);
	}
	
	/** connect
	  * connect to a server & choose a database
	  * @host (String) address of the database host server
	  * @user (String) username
	  * @pass (String) password
	  * @database (String) name of the database to use
	  */
	public function connect($host, $user, &$pass, $database) {
		$this->db_conn = mysql_connect($host, $user, $pass);
		mysql_select_db($database);
		unset($pass);
	}
	
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
	public function assoc_to_mysql($table_name, $method, $assoc, $db_name = null) {
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
						$query .= "'".str_replace("'", "\\'", $value)."'";
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
	/** where_recurse
	  */
	private function where_recurse($assoc, $conjunction = 'AND', $nested = TRUE) {
	  $conditions = array();
	  foreach($assoc as $field => $value) {
			if ($field == 'OR' || is_array($value)) {
			$conditions[] = where_recurse($value, $field == 'OR' ? 'OR' : 'AND');
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
	private function assoc_to_mysql_where($assoc) {
		return ' WHERE '.where_recurse($assoc, 'AND', FALSE);
	}

	/** mysql_to_assoc
	  * $query (string) MySQL QUERY whose result will be shown
	  * $options (array) see assoc_to_json documentation
	  */
	public function mysql_to_assoc($query, $options = array()) {
	  global $ERROR;
		if (!($result = mysql_query($query))) {
			if (DEBUG) $ERROR[] = mysql_error();
			return FALSE;
		}
		$result_array = array();
		while($row = mysql_fetch_assoc($result))
		  $result_array[] = $row;
		return $result_array;
	}
	/** mysql_to_json
	  * $query (string) MySQL QUERY whose result will be shown
	  * $options (array) see assoc_to_json documentation
	  */
	public function mysql_to_json($query, $options = array()) {
		return assoc_to_json(mysql_to_assoc($query, $options), $options);
	}
	/** mysql_to_html_table
	  */
	public function mysql_to_html_table($query) {
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