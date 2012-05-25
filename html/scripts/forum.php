<?php

require_once('../../config.php');

$offset = @$_REQUEST['offset'] ? $_REQUEST['offset'] : 0;
$limit = @$_REQUEST['limit'] ? $_REQUEST['limit'] : 10;
$limit = "$offset,$limit";
if (@$_REQUEST['recalculate']) {
    $list = $db->get_object(array(
        'table' => $forum->table,
        'fields' => array('path','id'),
        'where' => array('CHAR_LENGTH(path) <'=>'5'),
        'limit' => $limit
    ));
    if (empty($list)) {
        exit('no posts with empty paths to recalculate.');
    }
    foreach ($list as $key => $post) {
        $db->post(array(
            'method'=>'update',
            'fields'=>array(
                'path'=>$forum->toASCII($post->id).'.'
            ),
            'where' => array('id'=>$post->id),
            'table' => 'sf_mix_messages'
        ));
    }
}
if (@$_REQUEST['message']) {
    $result = $forum->post(array(
    'message'=>@$_REQUEST['message'],
    'title'=>@$_REQUEST['title'],
    'user_id'=>$user->id,
    'reply_on_id'=>@$_REQUEST['reply_on'] ? $_REQUEST['reply_on'] : -1,
    'link_id'=>@$_REQUEST['mix_id'] ? $_REQUEST['mix_id'] : -1
    ));
    exit(json_encode($result));
}
$options = array();
if (@$_REQUEST['thread']) {
   $options['thread'] = $_REQUEST['thread'];
   $options['order'] = 'path ASC';
}
$options['limit'] = $limit;
$options['search'] = @$_REQUEST['search'];
$entries = $forum->get($options);
if (!$entries)
    $entries = array();
echo json_encode($entries);

?>
