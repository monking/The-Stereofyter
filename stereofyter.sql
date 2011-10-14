-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Oct 14, 2011 at 05:47 AM
-- Server version: 5.1.53
-- PHP Version: 5.3.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


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

--
-- Dumping data for table `sf_countries`
--

INSERT INTO `sf_countries` (`country_code`, `country_name`) VALUES
('AX', 'Aaland Islands'),
('AF', 'Afghanistan'),
('AL', 'Albania'),
('DZ', 'Algeria'),
('AS', 'American Samoa'),
('AD', 'Andorra'),
('AO', 'Angola'),
('AI', 'Anguilla'),
('AQ', 'Antarctica'),
('AG', 'Antigua And Barbuda'),
('AR', 'Argentina'),
('AM', 'Armenia'),
('AW', 'Aruba'),
('AU', 'Australia'),
('AT', 'Austria'),
('AZ', 'Azerbaijan'),
('BS', 'Bahamas'),
('BH', 'Bahrain'),
('BD', 'Bangladesh'),
('BB', 'Barbados'),
('BY', 'Belarus'),
('BE', 'Belgium'),
('BZ', 'Belize'),
('BJ', 'Benin'),
('BM', 'Bermuda'),
('BT', 'Bhutan'),
('BO', 'Bolivia'),
('BA', 'Bosnia And Herzegowina'),
('BW', 'Botswana'),
('BV', 'Bouvet Island'),
('BR', 'Brazil'),
('IO', 'British Indian Ocean Territory'),
('BN', 'Brunei Darussalam'),
('BG', 'Bulgaria'),
('BF', 'Burkina Faso'),
('BI', 'Burundi'),
('KH', 'Cambodia'),
('CM', 'Cameroon'),
('CA', 'Canada'),
('CV', 'Cape Verde'),
('KY', 'Cayman Islands'),
('CF', 'Central African Republic'),
('TD', 'Chad'),
('CL', 'Chile'),
('CN', 'China'),
('CX', 'Christmas Island'),
('CC', 'Cocos (Keeling) Islands'),
('CO', 'Colombia'),
('KM', 'Comoros'),
('CD', 'Congo, Democratic Republic of (was Zaire)'),
('CG', 'Congo, Republic of'),
('CK', 'Cook Islands'),
('CR', 'Costa Rica'),
('CI', 'Cote D''Ivoire'),
('HR', 'Croatia (local name: Hrvatska)'),
('CU', 'Cuba'),
('CY', 'Cyprus'),
('CZ', 'Czech Republic'),
('DK', 'Denmark'),
('DJ', 'Djibouti'),
('DM', 'Dominica'),
('DO', 'Dominican Republic'),
('EC', 'Ecuador'),
('EG', 'Egypt'),
('SV', 'El Salvador'),
('GQ', 'Equatorial Guinea'),
('ER', 'Eritrea'),
('EE', 'Estonia'),
('ET', 'Ethiopia'),
('FK', 'Falkland Islands (Malvinas)'),
('FO', 'Faroe Islands'),
('FJ', 'Fiji'),
('FI', 'Finland'),
('FR', 'France'),
('GF', 'French Guiana'),
('PF', 'French Polynesia'),
('TF', 'French Southern Territories'),
('GA', 'Gabon'),
('GM', 'Gambia'),
('GE', 'Georgia'),
('DE', 'Germany'),
('GH', 'Ghana'),
('GI', 'Gibraltar'),
('GR', 'Greece'),
('GL', 'Greenland'),
('GD', 'Grenada'),
('GP', 'Guadeloupe'),
('GU', 'Guam'),
('GT', 'Guatemala'),
('GN', 'Guinea'),
('GW', 'Guinea-Bissau'),
('GY', 'Guyana'),
('HT', 'Haiti'),
('HM', 'Heard And Mc Donald Islands'),
('HN', 'Honduras'),
('HK', 'Hong Kong'),
('HU', 'Hungary'),
('IS', 'Iceland'),
('IN', 'India'),
('ID', 'Indonesia'),
('IR', 'Iran (Islamic Republic Of)'),
('IQ', 'Iraq'),
('IE', 'Ireland'),
('IL', 'Israel'),
('IT', 'Italy'),
('JM', 'Jamaica'),
('JP', 'Japan'),
('JO', 'Jordan'),
('KZ', 'Kazakhstan'),
('KE', 'Kenya'),
('KI', 'Kiribati'),
('KP', 'Korea, Democratic People''S Republic Of'),
('KR', 'Korea, Republic Of'),
('KW', 'Kuwait'),
('KG', 'Kyrgyzstan'),
('LA', 'Lao People''S Democratic Republic'),
('LV', 'Latvia'),
('LB', 'Lebanon'),
('LS', 'Lesotho'),
('LR', 'Liberia'),
('LY', 'Libyan Arab Jamahiriya'),
('LI', 'Liechtenstein'),
('LT', 'Lithuania'),
('LU', 'Luxembourg'),
('MO', 'Macau'),
('MK', 'Macedonia, The Former Yugoslav Republic Of'),
('MG', 'Madagascar'),
('MW', 'Malawi'),
('MY', 'Malaysia'),
('MV', 'Maldives'),
('ML', 'Mali'),
('MT', 'Malta'),
('MH', 'Marshall Islands'),
('MQ', 'Martinique'),
('MR', 'Mauritania'),
('MU', 'Mauritius'),
('YT', 'Mayotte'),
('MX', 'Mexico'),
('FM', 'Micronesia, Federated States Of'),
('MD', 'Moldova, Republic Of'),
('MC', 'Monaco'),
('MN', 'Mongolia'),
('MS', 'Montserrat'),
('MA', 'Morocco'),
('MZ', 'Mozambique'),
('MM', 'Myanmar'),
('NA', 'Namibia'),
('NR', 'Nauru'),
('NP', 'Nepal'),
('NL', 'Netherlands'),
('AN', 'Netherlands Antilles'),
('NC', 'New Caledonia'),
('NZ', 'New Zealand'),
('NI', 'Nicaragua'),
('NE', 'Niger'),
('NG', 'Nigeria'),
('NU', 'Niue'),
('NF', 'Norfolk Island'),
('MP', 'Northern Mariana Islands'),
('NO', 'Norway'),
('OM', 'Oman'),
('PK', 'Pakistan'),
('PW', 'Palau'),
('PS', 'Palestinian Territory, Occupied'),
('PA', 'Panama'),
('PG', 'Papua New Guinea'),
('PY', 'Paraguay'),
('PE', 'Peru'),
('PH', 'Philippines'),
('PN', 'Pitcairn'),
('PL', 'Poland'),
('PT', 'Portugal'),
('PR', 'Puerto Rico'),
('QA', 'Qatar'),
('RE', 'Reunion'),
('RO', 'Romania'),
('RU', 'Russian Federation'),
('RW', 'Rwanda'),
('SH', 'Saint Helena'),
('KN', 'Saint Kitts And Nevis'),
('LC', 'Saint Lucia'),
('PM', 'Saint Pierre And Miquelon'),
('VC', 'Saint Vincent And The Grenadines'),
('WS', 'Samoa'),
('SM', 'San Marino'),
('ST', 'Sao Tome And Principe'),
('SA', 'Saudi Arabia'),
('SN', 'Senegal'),
('CS', 'Serbia And Montenegro'),
('SC', 'Seychelles'),
('SL', 'Sierra Leone'),
('SG', 'Singapore'),
('SK', 'Slovakia'),
('SI', 'Slovenia'),
('SB', 'Solomon Islands'),
('SO', 'Somalia'),
('ZA', 'South Africa'),
('GS', 'South Georgia And The South Sandwich Islands'),
('ES', 'Spain'),
('LK', 'Sri Lanka'),
('SD', 'Sudan'),
('SR', 'Suriname'),
('SJ', 'Svalbard And Jan Mayen Islands'),
('SZ', 'Swaziland'),
('SE', 'Sweden'),
('CH', 'Switzerland'),
('SY', 'Syrian Arab Republic'),
('TW', 'Taiwan'),
('TJ', 'Tajikistan'),
('TZ', 'Tanzania, United Republic Of'),
('TH', 'Thailand'),
('TL', 'Timor-Leste'),
('TG', 'Togo'),
('TK', 'Tokelau'),
('TO', 'Tonga'),
('TT', 'Trinidad And Tobago'),
('TN', 'Tunisia'),
('TR', 'Turkey'),
('TM', 'Turkmenistan'),
('TC', 'Turks And Caicos Islands'),
('TV', 'Tuvalu'),
('UG', 'Uganda'),
('UA', 'Ukraine'),
('AE', 'United Arab Emirates'),
('GB', 'United Kingdom'),
('US', 'United States'),
('UM', 'United States Minor Outlying Islands'),
('UY', 'Uruguay'),
('UZ', 'Uzbekistan'),
('VU', 'Vanuatu'),
('VA', 'Vatican City State (Holy See)'),
('VE', 'Venezuela'),
('VN', 'Viet Nam'),
('VG', 'Virgin Islands (British)'),
('VI', 'Virgin Islands (U.S.)'),
('WF', 'Wallis And Futuna Islands'),
('EH', 'Western Sahara'),
('YE', 'Yemen'),
('ZM', 'Zambia'),
('ZW', 'Zimbabwe');

-- --------------------------------------------------------

--
-- Table structure for table `sf_mixes`
--

CREATE TABLE IF NOT EXISTS `sf_mixes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'automatically generated unique ID',
  `data` text COLLATE utf8_bin NOT NULL COMMENT 'mix data encoded in custom JSON format',
  `modified_by` int(11) NOT NULL,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date last saved',
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'date created',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=24 ;

--
-- Dumping data for table `sf_mixes`
--


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

--
-- Dumping data for table `sf_mix_lineage`
--


-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_messages`
--

CREATE TABLE IF NOT EXISTS `sf_mix_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `response_to_msg` int(11) NOT NULL DEFAULT '-1',
  `mix_id` int(11) NOT NULL DEFAULT '-1',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=1 ;

--
-- Dumping data for table `sf_mix_messages`
--


-- --------------------------------------------------------

--
-- Table structure for table `sf_mix_owners`
--

CREATE TABLE IF NOT EXISTS `sf_mix_owners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mix_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=23 ;

--
-- Dumping data for table `sf_mix_owners`
--

INSERT INTO `sf_mix_owners` (`id`, `mix_id`, `owner_id`) VALUES
(1, 1, 16),
(2, 2, 22),
(10, 5, 22),
(9, 4, 22),
(8, 3, 22),
(7, 2, 16),
(11, 6, 22),
(12, 7, 22),
(13, 8, 22),
(14, 9, 22),
(15, 10, 22),
(16, 11, 22),
(17, 12, 22),
(18, 19, 16),
(19, 20, 16),
(20, 21, 16),
(21, 22, 16),
(22, 23, 16);

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=15 ;

--
-- Dumping data for table `sf_reset_hashes`
--


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

--
-- Dumping data for table `sf_samples`
--


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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='users subscribed to the newsletter' AUTO_INCREMENT=23 ;

--
-- Dumping data for table `sf_users`
--

INSERT INTO `sf_users` (`id`, `username`, `name`, `email`, `password`, `country`, `musician`, `avatar`, `subscribe_updates`, `created`) VALUES
(16, '', NULL, 'lovejoy.chris@gmail.com', '95b0db6a991b6ec0b2f0465914b683687ea2cab4d0f569c67caa87dcc0b058f7', 'AX', 'no', '', 'yes', '2011-09-23 00:00:09');
