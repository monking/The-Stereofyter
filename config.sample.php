<?php

// copy this file  to config.php and update
// database settings for your environment.
ini_set('display_errors', true);
define('DEBUG', false);
define('MIXER_APP_VERSION', '06003');
define('MIXER_ENGINE_VERSION', '0103');
require_once(dirname(__FILE__) . '/html/inc/includes.php');
depends(
    'array_helpers',
    'basic.class',
    'database.class',
    'forum.class',
    'user.class'
);
session_start();
$db = new Database();
$user = new User(array('table'=>'sf_users'));
$forum = new Forum(array(
    'table'=>'sf_mix_messages',
    'interfaces'=>array(
        'link'=>'ForumMixInterface',
        'user'=>'ForumUserInterface'
    )
));
if (strpos($_SERVER['SERVER_NAME'], 'local.') !== FALSE) {
    // local staging
    $db_options = array(
        'host'=>'127.0.0.1',
        'user'=>'root',
        'pass'=>'',
        'name'=>'database_name'
    );
} elseif (strpos($_SERVER['SERVER_NAME'], 'chrislovejoy.com') !== FALSE) {
    // remote staging
    $db_options = array(
        'host'=>'remote-staging.com',
        'user'=>'root',
        'pass'=>'',
        'name'=>'database_name'
    );
} else {
    // live
    $db_options = array(
        'host'=>'live-server.com',
        'user'=>'root',
        'pass'=>'',
        'name'=>'database_name'
    );
}
$db->connect($db_options);
unset($db_options['pass']);

?>
