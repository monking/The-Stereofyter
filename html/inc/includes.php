<?php

if (!isset($ERROR)) $ERROR = array();

define('INCLUDE_DIRNAME', dirname(__FILE__));

function require_from_inc()
	{
	foreach (func_get_args() as $include_name)
		{
		$path = str_replace('//','/',INCLUDE_DIRNAME).'/'.$include_name.'.php';
		if (strstr($path, ':')) $path = str_replace('/', '\\', $path);
		if(file_exists($path))
			require_once($path);
		else
			$ERROR[] = "include '$path' doesn't exist";
		}
	}

if(!isset($INCLUDE)) $INCLUDE = array();
array_unshift($INCLUDE, '../../_config');
$INCLUDE = array_unique($INCLUDE);
call_user_func_array('require_from_inc', $INCLUDE);

?>
