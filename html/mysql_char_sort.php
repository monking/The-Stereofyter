<?php
require_once '../config.php';
$string = ' `1234567890-=~!@#$%^&*()_+`¡™£¢∞§¶•ªº–≠`⁄€‹›ﬁﬂ‡°·‚—±qwertyuiop[]\\QWERTYUIOP{}|œ∑´®†¨ˆøπ“‘«Œ„´‰ˇÁ¨ˆØ∏”’»asdfghjkl;\'ASDFGHJKL:"åß∂ƒ©˙∆˚¬…æÅÍÎÏ˝ÓÔÒÚÆzxcvbnm,./ZXCVBNM<>?Ω≈ç√∫˜µ≤≥÷¸˛Ç◊ı˜Â¯˘¿';
$len = strlen($string);
$db->query('DROP TABLE IF EXISTS `sorted`;');
$db->query('CREATE TABLE `sorted` (
		`chr` varchar(1) NOT NULL default \'\'
	) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;');
for ($i = 0; $i < $len; $i++) {
	$letter = substr($string, $i, 1);
	$db->post(array(
		'method'=>'insert',
		'table'=>'sorted',
		'fields'=>array('chr'=>$letter)
	));
}
$result = $db->get_object(array(
	'table'=>'sorted',
	'value_column'=>'chr',
	'order'=>'chr ASC'
));
// $db->query('DROP TABLE IF EXISTS `sorted`;');
?>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	</head>
	<body>
<?=implode('',$result);?>
	</body>
</html>
