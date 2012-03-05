-- phpMyAdmin SQL Dump
-- version 2.11.11.3
-- http://www.phpmyadmin.net
--
-- Host: internal-db.s7816.gridserver.com
-- Generation Time: Mar 05, 2012 at 09:18 AM
-- Server version: 5.0.32
-- PHP Version: 4.4.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `db7816_stereofyte`
--

-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_messages`
--

CREATE TABLE `sf_mix_messages` (
  `id` int(11) NOT NULL auto_increment,
  `link_id` int(11) NOT NULL,
  `attachment_id` int(11) NOT NULL,
  `reply_on_id` int(11) NOT NULL default '-1',
  `mix_id` int(11) NOT NULL default '-1',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `message` text collate utf8_bin NOT NULL,
  `title` varchar(255) collate utf8_bin NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=1 ;
