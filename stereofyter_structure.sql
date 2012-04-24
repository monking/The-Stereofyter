-- phpMyAdmin SQL Dump
-- version 3.5.0
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2012 at 12:52 PM
-- Server version: 5.5.15
-- PHP Version: 5.3.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `stereofyter`
--

-- --------------------------------------------------------

--
-- Table structure for table `sf_countries`
--

CREATE TABLE IF NOT EXISTS `sf_countries` (
  `country_code` varchar(2) CHARACTER SET latin1 NOT NULL,
  `country_name` varchar(64) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`country_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='cross reference for country codes';

-- --------------------------------------------------------

--
-- Table structure for table `sf_mixes`
--

CREATE TABLE IF NOT EXISTS `sf_mixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'automatically generated unique ID',
  `title` varchar(64) COLLATE utf8_bin NOT NULL,
  `chromatic_key` varchar(4) COLLATE utf8_bin NOT NULL,
  `tempo` smallint(6) NOT NULL,
  `duration` smallint(6) NOT NULL,
  `mix` text COLLATE utf8_bin NOT NULL COMMENT 'mix data encoded in custom JSON format',
  `modified_by` int(11) NOT NULL,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date last saved',
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'date created',
  `published` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=52 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_lineage`
--

CREATE TABLE IF NOT EXISTS `sf_mix_lineage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ancestor` int(11) NOT NULL,
  `parent` int(11) NOT NULL,
  `child` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_messages`
--

CREATE TABLE IF NOT EXISTS `sf_mix_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_id` int(11) NOT NULL,
  `attachment_id` int(11) NOT NULL,
  `reply_on_id` int(11) NOT NULL DEFAULT '-1',
  `link_id` int(11) NOT NULL DEFAULT '-1',
  `attachment_id` int(11) NOT NULL DEFAULT '-1',
  `reply_on_id` int(11) NOT NULL DEFAULT '-1',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` text COLLATE utf8_bin NOT NULL,
  `title` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_owners`
--

CREATE TABLE IF NOT EXISTS `sf_mix_owners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mix_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=46 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_reset_hashes`
--

CREATE TABLE IF NOT EXISTS `sf_reset_hashes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `hash` varchar(40) COLLATE utf8_bin NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_samples`
--

CREATE TABLE IF NOT EXISTS `sf_samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(64) CHARACTER SET latin1 NOT NULL,
  `key` varchar(4) CHARACTER SET latin1 NOT NULL,
  `tempo` smallint(6) NOT NULL,
  `family` varchar(16) CHARACTER SET latin1 NOT NULL,
  `genre` varchar(32) CHARACTER SET latin1 NOT NULL,
  `artist` varchar(64) CHARACTER SET latin1 NOT NULL,
  `name` varchar(32) CHARACTER SET latin1 NOT NULL,
  `length` int(11) NOT NULL,
  `beats` smallint(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `sf_users`
--

CREATE TABLE IF NOT EXISTS `sf_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) COLLATE utf8_bin NOT NULL,
  `name` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `email` varchar(320) COLLATE utf8_bin NOT NULL,
  `password` varchar(64) COLLATE utf8_bin NOT NULL,
  `country` varchar(2) COLLATE utf8_bin NOT NULL,
  `musician` enum('yes','no') COLLATE utf8_bin NOT NULL DEFAULT 'no',
  `avatar` varchar(64) COLLATE utf8_bin NOT NULL,
  `subscribe_updates` enum('yes','no') COLLATE utf8_bin NOT NULL DEFAULT 'yes',
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='users subscribed to the newsletter' AUTO_INCREMENT=29 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
