<?php

require_once('../../_config.php');

$entries = $forum->get(array(
  'ORDER BY'=>'date DESC',
  'LIMIT'=>3
));
if (!$entries)
  $entries = array();
echo json_encode($entries);

?>