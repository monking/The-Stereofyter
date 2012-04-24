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
		* @$query (Array/String) an array or string query
		*		table (REQUIRED)
		*		method (String; default 'UPDATE') 'INSERT' or 'UPDATE'
		*		fields (Array) keys for column names.
		*			A key of 'WHERE' should have another associative array as a value, and will be
		*			turned into a MySQL 'WHERE' statement.
		*
		* NOTE: you must escape special characters in your values before calling get
		*/
	public function post($query) {
		if (is_array($query)) {
			$methods = array('insert'=>'INSERT INTO', 'update'=>'UPDATE');
			$query_string = '';
			if (array_key_exists($query['method'], $methods)) {
				$fields = array();
				foreach($query['fields'] as $field => $value) {
					if (is_array($value) && array_key_exists('function', $value))
						$value = $value['function'];
					else 
						$value = "'".str_replace("'", "\\'", $value)."'";
					$fields[] = "$field=$value";
				}
				$fields = implode(', ', $fields);
				$where = array_key_exists('where', $query) ? self::get_where($query['where']) : '';
				$query = "${methods[$query['method']]} ${query['table']} SET $fields $where;";
			} else {
				return false;
			}
		}
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
		* NOTE: you must escape special characters in your values before calling get
		*/
	public function get($query) {
		// Takes a string query, or 2-dimensional associative array and turns it into a SQL query.
		if (is_array($query)) {
			$join = '';
			$where = '';
			$orderby = '';
			$limit = '';
			if (array_key_exists('join', $query)) {
				$join = self::get_join($query);
			}
			if (array_key_exists('where', $query)) {
				$where = self::get_where($query['where']);
			}
			if (array_key_exists('order', $query)) {
				$orderby = ' ORDER BY '.$query['order'];
			}
			if (array_key_exists('limit', $query)) {
				$limit = ' LIMIT '.$query['limit'];
			}
			$fields = count(@$query['fields']) ? $query['fields'] : array($query['table'].'.*');
			if (@$query['join']) {
				if (count(@$query['join']['fields'])) {
					foreach ($query['join']['fields'] as &$field) {
						if (is_array($field))
							$field = $field[0];
						else
							$field = $query['join']['table'].'.'.$field;
					}
					$fields = array_merge($fields, $query['join']['fields']);
				} else {
					$fields[] = $query['join']['table'].'.*';
				}
			}
			$fields = implode(', ', $fields);
			$query = "SELECT $fields FROM ${query['table']}$join$where$orderby$limit;";
		}
		//echo $query;
		return mysql_query($query);
	}
	public function get_first_object($table_name, $query) {
		$result = $this->get($table_name, $query);
		$object = mysql_fetch_obj($result);
		if (@$query['filterObj'])
			$query['filterObj']->filter($object);
		return $object;
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
	/** get_join
		*/
	public static function get_join($query) {
        $join = '';
        if (is_array(@$query['join'])) {
            $alpha = array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');
            exit(count($alpha));
            for ($i = 0; $i < count($query['join']); $i++) {
                $as = ' AS '.$alpha[$i];
                @$query['join'] ? ' LEFT JOIN '.$query['join']['table'].$as.' ON '.$query['table'].'.'.$query['join']['remote_id'].'='.$query['join']['table'].'.id': '';
            }
        }
        return $join;
	}
	/** get_where
		*/
	public static function get_where($assoc) {
		return $assoc ? ' WHERE '.self::where_recurse($assoc, 'AND', FALSE) : '';
	}

	/** get_assoc
		* $query (string) MySQL QUERY whose result will be shown
		*/
	public function get_assoc($query) {
		global $ERROR;
		if (!($result = $this->get($query))) {
			if (DEBUG) $ERROR[] = mysql_error();
			return FALSE;
		}
		$result_array = array();
		while($row = mysql_fetch_assoc($result))
			$result_array[] = $row;
		return $result_array;
	}
	public function get_object($query) {
		global $ERROR;
		if (!($result = $this->get($query))) {
			if (DEBUG) $ERROR[] = mysql_error();
			return FALSE;
		}
		$result_array = array();
			$key_column = @$query['key_column'];
		while($row = mysql_fetch_object($result)) {
			if (@$query['filterObj'])
				$query['filterObj']->filter($row);
				if ($key_column)
					$result_array[$row->$key_column] = $row;
				else
					$result_array[] = $row;
		}
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
