<?php

require_once('../../config.php');

if (@$_REQUEST['recalculate']) {
    $offset = @$_REQUEST['offset'] ? $_REQUEST['offset'] : '';
    $limit = @$_REQUEST['limit'] ? $_REQUEST['limit'] : 10;
    $list = $db->get_object(array(
        'table' => $this->table,
        'fields' => array('path','id'),
        'where' => array('path'=>''),
        'order' => 'path DESC',
        'limit' => $offset ? "$offset,$limit" : $limit
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
if (@$_REQUEST['limit'])
   $options['limit'] = $_REQUEST['limit'];
$entries = $forum->get($options);
if (!$entries)
    $entries = array();
echo json_encode($entries);

?>
