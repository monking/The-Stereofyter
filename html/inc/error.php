<?php

$ERROR = NULL;

function log_error($error_message, $pass_thru = NULL) {
	global $ERROR;
	if (!$ERROR) $ERROR = array();
	$ERROR[] = $error_message;
	if (defined('DEBUG') && DEBUG) print_r(debug_backtrace());
	return $pass_thru;
}

?>