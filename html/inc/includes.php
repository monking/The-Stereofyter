<?php

if (!isset($ERROR)) $ERROR = array();

define('INCLUDE_DIRNAME', dirname(__FILE__));

function require_from_inc_dir($include_name)
	{
	$path = str_replace('//','/',INCLUDE_DIRNAME).'/'.$include_name.'.php';
	if (strstr($path, ':')) $path = str_replace('/', '\\', $path);
	if(file_exists($path))
		require_once($path);
	else
		$ERROR[] = "include '$path' doesn't exist";
	}

if(isset($includes)) {
	array_unshift($includes, '../../_config');
	$includes = array_unique($includes);
	foreach($includes as $include_name)
		require_from_inc_dir($include_name);
}

?>