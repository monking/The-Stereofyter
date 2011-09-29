<?php

$file_count = -2;// decrement for '.' and '..';
$dir_ref = opendir('uploaded_feedback');
while ($entry = readdir($dir_ref)) {
	$file_count++;
}
closedir($dir_ref);



if (($_FILES["file"]["size"] < 204800))
	{
	if ($_FILES["file"]["error"] > 0)
		{
		header("Location: ./?error");
		}
	else
		{
		$new_index = $file_count + 1;
		$ext = preg_replace('/^.*(\.\w+)$/', '$1', $_FILES["file"]["name"]);
		$new_name = 'feedback_'.$new_index.$ext;

		if (file_exists("uploaded_feedback/" . $new_name))
			{
			header("Location: ./?error=exists");
			}
		else
			{
			move_uploaded_file($_FILES["file"]["tmp_name"],
			"uploaded_feedback/" . $new_name);
			}
			header("Location: ./?success");
		}
	}
else
	{
	header("Location: ./?error=size");
	}

?>
