<?php

depends('array', 'error', 'database.class');

/** save_message
  * $mix_data (array)
		['message'] (string) message to be posted
		['mix_id'] (number) OPTIONAL id of a mix being sent with the message
		['response_to_msg'] (number) OPTIONAL id of message being responded to
		['user_id'] (number) OPTIONAL id of sending user (default is logged-in user)
  */
function save_message($mix_data) {
	if (!isset($_SESSION)) session_start();
	if (!assoc_to_mysql(
		'sf_messages',
		isset($mix_data['WHERE'])? 'UPDATE': 'INSERT',
		array(array_conform(
			$mix_data,
			array(
				'mix_id' => -1,
				'user_id' => $_SESSION['user']['id'],
				'response_to_msg' => -1,
				'message' => ''
				),
			''))
	)) {
		return log_error(mysql_error());
	}
}
?>