<?php

$ERROR = NULL;

function log_error($error_message, $pass_thru = NULL) {
	global $ERROR;
	if (!$ERROR) $ERROR = array();
	$ERROR[] = $error_message;
    if (defined('DEBUG') && DEBUG && $pass_thru === NULL)
        return print_r(debug_backtrace(), true);
    else
        return $pass_thru;
}

?>
