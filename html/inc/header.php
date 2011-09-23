<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title><? isset($page_title) || ( $page_title = 'stereofyter' ); print $page_title ?></title>
<?php
if(isset($includes)) {
	array_unshift($includes, '_config');
	$includes = array_unique($includes);
	foreach($includes as $include_name) {
		if(file_exists("inc/$include_name.php"))
			require_once("inc/$include_name.php");
		else
			echo "<!--inc/$include_name.php doesn't exist-->";
	}
}
?>
<?php
if(!isset($css)) {
	$css = array();
}
array_unshift($css, 'reset');
$css = array_unique($css);
foreach($css as $stylesheet):
?>
		<link type="text/css" rel="stylesheet" media="screen" href="css/<?=$stylesheet?>.css"/>
<?php
endforeach;
?>
<?php
if(!isset($js)) {
	$js = array();
}
$js = array_unique($js);
foreach($js as $script):
?>
		<script type="text/javascript" src="js/<?=$script?>.js"></script>
<?php
endforeach;
?>
	</head>
	<body>
<?php if(function_exists('top')) top(); ?>
