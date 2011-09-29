<?php

if (!isset($ERROR)) $ERROR = array();

if(isset($includes)) {
	array_unshift($includes, '../../_config');
	$includes = array_unique($includes);
	foreach($includes as $include_name) {
		$path = str_replace('//','/',dirname(__FILE__)).'/'.$include_name.'.php';
		if (strstr($path, ':')) $path = str_replace('/', '\\', $path);
		if(file_exists($path))
			require_once($path);
		else
			$ERROR[] = "include '$path' doesn't exist";
	}
}

?>