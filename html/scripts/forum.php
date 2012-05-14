<?php

require_once('../../config.php');

if (@$_REQUEST['recalculate']) {
    $list = $forum->get(array(
        'where' => array('path'=>'')
    ));
    // define('DEBUG_DATABASE', true);
    if (empty($list)) {
        exit('no posts with empty paths to recalculate.');
    }
    foreach ($list as $key => $post) {
        $db->post(array(
            'method'=>'update',
            'fields'=>array(
                'path'=>Forum::toASCII($post->id).'.'
            ),
            'where' => array('id'=>$post->id),
            'table' => 'sf_mix_messages'
        ));
    }
}
if (@$_REQUEST['message']) {
    $forum->post(array(
    'message'=>$_REQUEST['message'],
    'title'=>$_REQUEST['title'],
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
