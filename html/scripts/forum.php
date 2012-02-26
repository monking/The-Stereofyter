<?php

require_once('../../_config.php');

if (@$_REQUEST['message']) {
  $forum->post(array(
    'message'=>$_REQUEST['message'],
    'user_id'=>$user->id,
    'reply_on_id'=>@$_REQUEST['reply_on'] ? $_REQUEST['reply_on'] : -1,
    'link_id'=>@$_REQUEST['mix_id'] ? $_REQUEST['mix_id'] : -1
  ));
}
$order = @$_REQUEST['order'] ? $_REQUEST['order'] : 'date';
$sort = @$_REQUEST['sort'] ? $_REQUEST['sort'] : 'DESC';
$limit = @$_REQUEST['limit'] ? $_REQUEST['limit'] : 3;
$entries = $forum->get(array(
  'ORDER BY'=>"$order $sort",
  'LIMIT'=>$limit
));
if (!$entries)
  $entries = array();
echo json_encode($entries);

?>