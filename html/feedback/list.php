<html>
	<head>
		<title>The Stereofyter | Download Feedback</title>
		<link type="text/css" rel="stylesheet" href="/css/reset.css" />
		<style type="text/css">
			body {margin: 1em;}
		</style>
	</head>
	<body>
<?php

$file_count = -2;// decrement for '.' and '..';
$dir_ref = opendir('uploaded_feedback');
while ($entry = readdir($dir_ref)) {
	$file_count++;
}
closedir($dir_ref);

?>
<h1>Download uploaded feedback</h2>
<? if($file_count): ?>
uploaded_feedback.zip (<?=$file_count;?> files) <a href="download.php">Download</a>
<? else: ?>
No uploaded feedback yet.
<? endif ?>
	</body>
</html>
