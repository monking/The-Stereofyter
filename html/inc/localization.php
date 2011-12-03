<?php

define('LOCALE_DIR', dirname(__FILE__).'/../locale/');

if (!isset($_SESSION)) session_start();
if (!isset($_SESSION['language'])) $_SESSION['language'] = 'en';
$_SESSION['language'] = 'en';
$po_file_path = LOCALE_DIR.$_SESSION['language'].'/messages.po';
if (!file_exists($po_file_path)) throw new Exception("locale message file '$po_file_path' does not exist.");
$raw_po = explode('msgid "', preg_replace('/[\n\r]+/', "\n", file_get_contents($po_file_path)));
array_shift($raw_po);
$po = array();
foreach($raw_po as $line) {
  global $po;
  $line = preg_replace('/(^"|[\n]+$)/', '', $line);
  $split = strpos($line, "\"\nmsgtxt ");
  $po[substr($line, 0, $split)] = substr($line, $split+9);
}

function __($key, $return = FALSE) {
  global $po;
  $message = array_key_exists($key, $po) ? $po[$key] : $key;
  if ($return) return $message;
  echo $message;
}

?>