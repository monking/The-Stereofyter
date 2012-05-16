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
        if (defined('DEBUG') && DEBUG) echo "$query\r\n";
		if (!mysql_query($query)) return false;
		return true;
	}
	/** get
		* submit a MySQL query from an associative array, or a string
		* @query (Array/String) array for query parameters, or query string
        *   @table (String)
        *
        *   @fields (Array)
        *
        *   @where (Array) : An associative array with field names as keys.  
        *     For special operators, (e.g. LIKE), include the operator in the 
        *     field name, with a preceding space.
        *
        *   @order (String)
        *
        *   @limit (Number)
        *
        *   @join (Array) : An associative array with table names as keys
        *     @fields (Array)
        *     @remote_key (String) : The field on the base table to match a 
        *       column 'id' on the joining table
		*/
	public function get($query) {
		// Takes a string query, or 2-dimensional associative array and turns it into a SQL query.
		if (is_array($query)) {
			$join = '';
			$where = '';
			$orderby = '';
			$limit = '';
			$fields = count(@$query['fields']) ? $query['fields'] : array('*');
            for ($i = 0; $i < count($fields); $i++) {
                $fields[$i] = str_replace($query['table'], 'a', $fields[$i]);
            }
			if (array_key_exists('join', $query)) {
                $join_data = self::process_join($query);
				$join = $join_data->join;
				$fields = array_merge($fields, $join_data->fields);
			}
			if (array_key_exists('where', $query)) {
                foreach ($query['where'] as $field => $condition) {
                    if (preg_match('/\./', $field))
                        continue;
                    $query['where']['a.'.$field] = $condition;
                    unset($query['where'][$field]);
                }
				$where = self::get_where($query['where']);
			}
			if (array_key_exists('order', $query)) {
				$orderby = ' ORDER BY '.$query['order'];
			}
			if (array_key_exists('limit', $query)) {
				$limit = ' LIMIT '.$query['limit'];
			}
			$fields = implode(', ', $fields);
			$query = "SELECT $fields FROM ${query['table']} AS a$join$where$orderby$limit;";
		}
        if (defined('DEBUG') && DEBUG) echo "$query\r\n";
		return mysql_query($query);
	}
	public function get_first_object($query) {
		$result = $this->get($query);
		$object = mysql_fetch_object($result);
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
				$field = mysql_real_escape_string($field);
                $operator = '=';
                if ($like_pos = strpos($field, ' LIKE')) {
                    $field = substr($field, 0, $like_pos);
                    $operator = ' LIKE ';
                }
				$field = implode('`.`', explode('.', $field));
				//if $value is stdClass with property 'function', use without quotes
				// as in th case of the value $value->function = 'NOW()'
				$value = mysql_real_escape_string($value);
				$conditions[] = "`$field`$operator'$value'";
			}
		}
		$where = $nested ? '(' : '';
		$where .= implode(" $conjunction ", $conditions);
		$where .= $nested ? ')' : '';
		return $where;
	}
	/** process_join
		*/
	public static function process_join($query) {
        $join = '';
        $fields = array();
        if (is_array(@$query['join'])) {
            $alpha = array('b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');
            $i = -1;
            foreach ($query['join'] as $table => $options) {
                $i++;
                $as = $alpha[$i];
                $join .= ' LEFT JOIN '.$table.' AS '.$as.' ON a.'.$options['remote_key'].'='.$as.'.id';
                foreach ($options['fields'] as $field) {
                    $fields[] = is_array($field) ? $field[0] : $as.'.'.$field;
                }
            }
        }
        return (object) array('join'=>$join, 'fields'=>$fields);
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
			if (defined('DEBUG') && DEBUG) $ERROR[] = mysql_error();
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
			if (defined('DEBUG') && DEBUG) $ERROR[] = mysql_error();
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
			if (defined('DEBUG') && DEBUG) $ERROR[] = mysql_error();
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
