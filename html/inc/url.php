<?php

function url_append_get($url, $params) {
	$separator = strpos($url, '?') === FALSE? '?': '&';
	if (is_array($params)) {
		foreach ($params as $key => $value) {
			$url .= $separator.$key.'='.$value;
			$separator = '&';
		}
	} else {
		$url .= $separator.$params;
	}
	return $url;
}

?>