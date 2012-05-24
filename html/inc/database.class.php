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
        *     @on (Array) : An array of two columns to match on the join: the 
        *       column on the main table, and the joining table, respectively
        */
    public function get($query) {
        // Takes a string query, or 2-dimensional associative array and turns it into a SQL query.
		if (is_array($query) && isset($query['query'])) $query = $query['query'];
        if (is_array($query)) {
            $join = '';
            $where = '';
            $orderby = '';
            $limit = '';
            $query['as'] = array($query['table']=>'a');
            $fields = count(@$query['fields']) ? $query['fields'] : array($query['table'].'.*');
            if (array_key_exists('join', $query)) {
                $join_data = self::process_join($query);
                $join = $join_data->join;
                $fields = array_merge($fields, $join_data->fields);
            }
            for ($i = 0; $i < count($fields); $i++) {
                if (!preg_match('/[.(]/', $fields[$i])) {
                    $fields[$i] = $query['table'].'.'.$fields[$i];
                }
                $fields[$i] = preg_replace('/(\w+)\.([\w*]+)/', '`$1`.`$2`', $fields[$i]);
                $fields[$i] = str_replace('`*`', '*', $fields[$i]);
            }
            if (array_key_exists('where', $query)) {
                foreach ($query['where'] as $field => $condition) {
                    if (preg_match('/[.(]/', $field))
                        continue;
                    $query['where']['`a`.'.$field] = $condition;
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
            $query_string = "SELECT $fields FROM `${query['table']}` AS `a`$join$where$orderby$limit;";
            foreach ($query['as'] as $table => $as) {
                $query_string = str_replace("`$table`.", "`$as`.", $query_string);
            }
            $query = $query_string;
        }
        return $this->query($query);
    }
    /** post
        * build and submit a MySQL query from an associative array
        * @$query (Array/String) an array or string query
        *        table (REQUIRED)
        *        method (String; default 'UPDATE') 'INSERT' or 'UPDATE'
        *        fields (Array) keys for column names.
        *            A key of 'WHERE' should have another associative array as a value, and will be
        *            turned into a MySQL 'WHERE' statement.
        *
        * NOTE: you must escape special characters in your values before calling get
        */
    public function post($query) {
        if (is_array($query)) {
            $methods = array('insert'=>'INSERT INTO', 'update'=>'UPDATE');
            $query_string = '';
            $query['method'] = strtolower($query['method']);
            if (array_key_exists($query['method'], $methods)) {
                $fields = array();
                foreach($query['fields'] as $field => $value) {
                    if (is_array($value) && array_key_exists('function', $value)) {
                        $value = $value['function'];
					} else {
						if (get_magic_quotes_gpc()) $value = stripslashes($value);
                        $value = "'".mysql_real_escape_string($value)."'";
					}
                    $fields[] = "$field=$value";
                }
                $fields = implode(', ', $fields);
                $where = array_key_exists('where', $query) ? self::get_where($query['where']) : '';
                $query = "${methods[$query['method']]} ${query['table']} SET $fields $where;";
            } else {
                return false;
            }
        }
        if (!$this->query($query)) return false;
        return true;
    }
	public function query($query) {
        if (defined('DEBUG') && DEBUG) echo "$query\r\n";
        return mysql_query($query);
	}
    public function get_first_object($query) {
        $result = $this->get($query);
        $row = mysql_fetch_object($result);
        if (@$query['filterObjects']) {
            try {
                foreach ($query['filterObjects'] as $filterObj) {
                    $filterObj->filter($row);
                }
            } catch(Exception $e) { }
        }
        return $row;
    }
    /** where_recurse
        */
    public static function where_recurse($assoc, $conjunction = 'AND', $nested = TRUE) {
        $conditions = array();
        foreach($assoc as $field => $value) {
            if ($field == 'OR' || is_array($value)) {
                $conditions[] = self::where_recurse($value, $field == 'OR' ? 'OR' : 'AND');
            } else {
                $operator = '=';
                if ($operator_pos = strpos($field, ' ')) {
                    $operator = substr($field, $operator_pos) . ' ';
                    $field = substr($field, 0, $operator_pos);
                }
                $field = preg_replace('/(\w+)\.([\w*]+)/', '`$1`.`$2`', $field);
                //if $value is stdClass with property 'function', use without quotes
                // as in th case of the value $value->function = 'NOW()'
				if (get_magic_quotes_gpc()) $value = stripslashes($value);
                $value = mysql_real_escape_string($value);
                $conditions[] = "$field$operator'$value'";
            }
        }
        $where = $nested ? '(' : '';
        $where .= implode(" $conjunction ", $conditions);
        $where .= $nested ? ')' : '';
        return $where;
    }
    /** process_join
        */
    public static function process_join(&$query) {
        $join = '';
        $fields = array();
        if (is_array(@$query['join'])) {
            $alpha = 'bcdefghijklmnopqrstuvwxyz';
            $i = -1;
            foreach ($query['join'] as $table => $options) {
                $i++;
                $as = substr($alpha, $i, 1);
                $join .= " LEFT JOIN `$table` AS `$as` ON `a`.`".$options['on'][0]."`=`$as`.`".$options['on'][1]."`";
                if (@$options['fields']) {
                    foreach ($options['fields'] as $field) {
                        if (!preg_match('/[.(]/', $field))
                            $field = "$as.$field";
                        $fields[] = $field;
                    }
                }
                $query['as'][$table] = $as;
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
		$value_column = @$query['value_column'];
        while($row = mysql_fetch_object($result)) {
            if (@$query['filterObjects']) {
                try {
                    foreach ($query['filterObjects'] as $filterObj) {
                        $filterObj->filter($row);
                    }
                } catch(Exception $e) { }
            }
			if ($value_column)
				$value = $row->$value_column;
			else
				$value = $row;
            if ($key_column)
                $result_array[$row->$key_column] = $value;
            else
                $result_array[] = $value;
        }
        return $result_array;
    }
    /** mysql_to_table
        */
    public function mysql_to_table($query) {
        $result = $this->query($query);
        if (!$result) {
            if (defined('DEBUG') && DEBUG) $ERROR[] = mysql_error();
            return false;
        }
        if (!mysql_num_rows($result)) {
            $output .= "\r\n";
            $output .= '<table>'."\r\n";
            $output .= '    <tbody>'."\r\n";
            $output .= '        <tr>'."\r\n";
            $output .= '            <td>empty set</td>'."\r\n";
            $output .= '        </tr>'."\r\n";
            $output .= '    </tbody>'."\r\n";
            $output .= '</table>'."\r\n";
            echo $output;
            return false;
        }
        $output = "\r\n";
        $output .= '<table>'."\r\n";
        $output .= '    <thead>'."\r\n";
        $i = 0;
        $output .= '        <tr>'."\r\n";
        while ($i < mysql_num_fields($result)) {
            $col = mysql_fetch_field($result, $i);
            $output .= '            <td>'."$col->name".'</td>'."\r\n";
            $i++;
        }
        $output .= '        </tr>'."\r\n";
        $output .= '    </thead>'."\r\n";
        $output .= '    <tbody>'."\r\n";
        while($row = mysql_fetch_assoc($result)) {
            $output .= '        <tr>'."\r\n";
            foreach($row as $field => $value) {
                $output .= '            <td>'.$value.'</td>'."\r\n";
            }
            $output .= '        </tr>'."\r\n";
        }
        $output .= '    </tbody>'."\r\n";
        $output .= '</table>'."\r\n";
        echo $output;
    }
}

?>
