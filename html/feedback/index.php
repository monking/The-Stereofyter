<html>
	<head>
		<title>The Stereofyter | Upload Feedback</title>
		<link type="text/css" rel="stylesheet" href="/css/reset.css" />
		<style type="text/css">
			body {margin: 1em;}
			form {
				border: 1px solid #ccc;
				padding: 1em;
			}
			.note {
				color: #666;
				font-size: 70%;
			}
		</style>
	</head>
	<body>
		<h1>Survey Response</h2>
<? if (isset($_GET['success'])): ?>

		<p>Your upload was successful.<br />
		Thank you! Your feedback is very valuable to us.</p>

<? else: ?>

	<? if (isset($_GET['error'])): ?>

		<p>There was a problem uploading your file.<br />
		<? if ($_GET['error'] == 'size'): ?>
		Your file is over 200KB.
		<? endif ?>
		Please try again.
	
	<? endif ?>


		<p>Anonymously upload your completed survey below</p>
		<form action="upload.php" method="post" enctype="multipart/form-data">
			<input type="file" name="file" id="file" />
			<span class="note">maxiumum file size 200KB</span><br />
			<input type="submit" name="submit" value="Upload" />
		</form>

<? endif ?>
	</body>
</html>
