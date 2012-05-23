<?php

require_once('../../config.php');
depends('sf/mix');

header('Content-type: application/json; charset=utf-8');
header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');

if (!isset($_REQUEST['mix']))
    die('{"error":"no data to save"}');

$mix_data['mix'] = $_REQUEST['mix'];

if (isset($_REQUEST['id']))
    $mix_data['id'] = $_REQUEST['id'];
if (isset($_REQUEST['title']))
    $mix_data['title'] = $_REQUEST['title'];
if (isset($_REQUEST['key']))
    $mix_data['chromatic_key'] = $_REQUEST['key'];
if (isset($_REQUEST['tempo']))
    $mix_data['tempo'] = $_REQUEST['tempo'];
if (isset($_REQUEST['duration']))
    $mix_data['duration'] = $_REQUEST['duration'];
if (isset($_REQUEST['published']))
    $mix_data['published'] = $_REQUEST['published'];

$saved_id = Mix::save($mix_data);

if ($saved_id === FALSE) {
    die('{"error":"'.implode('; ', $ERROR).'"}');
} else {
    if ($mix_data['published']) {
        $post = array(
            'message'=>@$_REQUEST['message'],
            'link_id'=>$saved_id
        );
        $existing_entry = $db->get_first_object(array(
            'table'=>$forum->table,
            'fields'=>array('id'),
            'where'=>array(
                'link_id'=>$saved_id,
                'user_id'=>$user->id
            ),
            'order'=>'created ASC',
            'limit'=>1
        ));
        if ($existing_entry) {
            if ($post['message']) {
                $post['id'] = $existing_entry->id;
            }
        }
        if (isset($post))
            $forum->post($post);
    }
    echo Mix::mix_json_encode(Mix::load($saved_id));
}

?>
