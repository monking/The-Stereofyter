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

$saved_id = save_mix($mix_data);

if ($saved_id === FALSE) {
	die('{"error":"'.implode('; ', $ERROR).'"}');
} else {
  if ($mix_data['published']) {
    $post = array(
      'message'=>$_REQUEST['message'],
      'link_id'=>$saved_id
    );
    $entries = $forum->get(array(
      'where'=>array(
        'link_id'=>$saved_id,
        'user_id'=>$user->id
      ),
      'order'=>'date ASC',
      'limit'=>1
    ));
    if ($entries) {
      $post['reply_on_id'] = $entries[0]->id;
    }
    $forum->post($post);
  }
	$mix = $db->get_assoc(array(
	  'table'=>'sf_mixes',
    'fields'=>array('id', 'title', 'duration', 'tempo', 'chromatic_key', 'modified_by', 'modified', 'created'),
    'where'=>array('id'=>$saved_id)
	));
	echo assoc_to_json($mix, array('whitespace' => 'none', 'structure' => 'flat', 'objects' => array('mix')));
}

?>
