-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Oct 28, 2011 at 09:31 AM
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

--
-- Dumping data for table `sf_countries`
--

REPLACE INTO `sf_countries` (`country_code`, `country_name`) VALUES
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

--
-- Dumping data for table `sf_mixes`
--

REPLACE INTO `sf_mixes` (`id`, `title`, `mix`, `modified_by`, `modified`, `created`, `duration`, `tempo`, `chromatic_key`) VALUES
(12, '', '{"tracks":[[{"S":0,"v":100,"s":0,"b":0,"m":0}],[{"S":1,"v":100,"s":0,"b":8,"m":0}],[{"S":2,"v":100,"s":0,"b":16,"m":0}]],"samples":["http://local.stereofyter.org/audio/samples/Djembe.ogg","http://local.stereofyter.org/audio/samples/Electro_Transistor_Beat.ogg","http://local.stereofyter.org/audio/samples/Tremolo_Organ.ogg"],"properties":{"tempo":90,"key":null,"name":null,"volume":100}}', 22, '2011-10-05 02:29:27', '2011-10-05 02:29:27', 0, 0, ''),
(1, '', '{"tracks":[]}', 16, '2011-10-03 20:07:26', '2011-10-03 20:06:37', 0, 0, ''),
(2, '', '{"tracks":[]}', 22, '2011-10-03 21:03:32', '2011-10-03 20:13:19', 0, 0, ''),
(3, '', '{"tracks":[]}', 22, '2011-10-03 21:03:30', '2011-10-03 21:03:30', 0, 0, ''),
(4, '', '{"properties":{"volume":"1","key":"*","name":"","tempo":"120"},"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_1.ogg"],"tracks":[{"0":{"volume":1,"sample":0,"solo":"","mute":false}}]}', 22, '2011-10-03 21:17:51', '2011-10-03 21:17:51', 0, 0, ''),
(5, '', '{"properties":{"volume":"1","key":"*","name":"","tempo":"120"},"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_1.ogg"],"tracks":[{"0":{"volume":1,"sample":0,"solo":"","mute":false}}]}', 22, '2011-10-03 21:42:17', '2011-10-03 21:42:17', 0, 0, ''),
(6, '', '{"tracks":[],"properties":{"tempo":"120","volume":"1","name":"","key":"*"},"samples":[]}', 22, '2011-10-03 22:58:10', '2011-10-03 22:58:10', 0, 0, ''),
(7, '', '{"samples":[],"tracks":[],"properties":{"volume":"1","tempo":"120","key":"*","name":""}}', 22, '2011-10-03 22:59:47', '2011-10-03 22:59:47', 0, 0, ''),
(8, '', '{"tracks":[{"0":{"s":"","m":0,"v":100,"S"},"112":{"s":"","m":0,"v":100,"S"},"232":{"s":"","m":0,"v":100,"S"},"96":{"s":"","m":0,"v":100,"S"},"136":{"s":"","m":0,"v":100,"S"},"120":{"s":"","m":0,"v":100,"S"},"176":{"s":"","m":0,"v":100,"S"},"168":{"s":"","m":0,"v":100,"S"},"208":{"s":"","m":0,"v":100,"S"},"64":{"s":"","m":0,"v":100,"S"},"56":{"s":"","m":0,"v":100,"S"},"88":{"s":"","m":0,"v":100,"S"},"72":{"s":"","m":0,"v":100,"S"},"128":{"s":"","m":0,"v":100,"S"},"32":{"s":"","m":0,"v":100,"S"},"16":{"s":"","m":0,"v":100,"S"},"8":{"s":"","m":0,"v":100,"S"},"192":{"s":"","m":0,"v":100,"S"},"40":{"s":"","m":0,"v":100,"S"},"152":{"s":"","m":0,"v":100,"S"},"144":{"s":"","m":0,"v":100,"S"},"200":{"s":"","m":0,"v":100,"S"},"48":{"s":"","m":0,"v":100,"S"},"224":{"s":"","m":0,"v":100,"S"},"24":{"s":"","m":0,"v":100,"S"},"80":{"s":"","m":0,"v":100,"S"},"184":{"s":"","m":0,"v":100,"S"},"104":{"s":"","m":0,"v":100,"S"},"160":{"s":"","m":0,"v":100,"S"},"216":{"s":"","m":0,"v":100,"S"}},{"0":{"s":"","m":0,"v":100,"S"},"112":{"s":"","m":0,"v":100,"S"},"232":{"s":"","m":0,"v":100,"S"},"96":{"s":"","m":0,"v":100,"S"},"136":{"s":"","m":0,"v":100,"S"},"120":{"s":"","m":0,"v":100,"S"},"176":{"s":"","m":0,"v":100,"S"},"168":{"s":"","m":0,"v":100,"S"},"208":{"s":"","m":0,"v":100,"S"},"64":{"s":"","m":0,"v":100,"S"},"56":{"s":"","m":0,"v":100,"S"},"88":{"s":"","m":0,"v":100,"S"},"72":{"s":"","m":0,"v":100,"S"},"128":{"s":"","m":0,"v":100,"S"},"32":{"s":"","m":0,"v":100,"S"},"16":{"s":"","m":0,"v":100,"S"},"8":{"s":"","m":0,"v":100,"S"},"192":{"s":"","m":0,"v":100,"S"},"40":{"s":"","m":0,"v":100,"S"},"152":{"s":"","m":0,"v":100,"S"},"144":{"s":"","m":0,"v":100,"S"},"200":{"s":"","m":0,"v":100,"S"},"48":{"s":"","m":0,"v":100,"S"},"224":{"s":"","m":0,"v":100,"S"},"24":{"s":"","m":0,"v":100,"S"},"80":{"s":"","m":0,"v":100,"S"},"184":{"s":"","m":0,"v":100,"S"},"104":{"s":"","m":0,"v":100,"S"},"160":{"s":"","m":0,"v":100,"S"},"216":{"s":"","m":0,"v":100,"S"}},{"0":{"s":"","m":0,"v":100,"S"},"112":{"s":"","m":0,"v":100,"S"},"232":{"s":"","m":0,"v":100,"S"},"96":{"s":"","m":0,"v":100,"S"},"136":{"s":"","m":0,"v":100,"S"},"120":{"s":"","m":0,"v":100,"S"},"176":{"s":"","m":0,"v":100,"S"},"168":{"s":"","m":0,"v":100,"S"},"208":{"s":"","m":0,"v":100,"S"},"64":{"s":"","m":0,"v":100,"S"},"56":{"s":"","m":0,"v":100,"S"},"88":{"s":"","m":0,"v":100,"S"},"72":{"s":"","m":0,"v":100,"S"},"128":{"s":"","m":0,"v":100,"S"},"32":{"s":"","m":0,"v":100,"S"},"16":{"s":"","m":0,"v":100,"S"},"8":{"s":"","m":0,"v":100,"S"},"192":{"s":"","m":0,"v":100,"S"},"40":{"s":"","m":0,"v":100,"S"},"152":{"s":"","m":0,"v":100,"S"},"144":{"s":"","m":0,"v":100,"S"},"200":{"s":"","m":0,"v":100,"S"},"48":{"s":"","m":0,"v":100,"S"},"224":{"s":"","m":0,"v":100,"S"},"24":{"s":"","m":0,"v":100,"S"},"80":{"s":"","m":0,"v":100,"S"},"184":{"s":"","m":0,"v":100,"S"},"104":{"s":"","m":0,"v":100,"S"},"160":{"s":"","m":0,"v":100,"S"},"216":{"s":"","m":0,"v":100,"S"}},{"0":{"s":"","m":0,"v":100,"S"},"112":{"s":"","m":0,"v":100,"S"},"232":{"s":"","m":0,"v":100,"S"},"96":{"s":"","m":0,"v":100,"S"},"136":{"s":"","m":0,"v":100,"S"},"120":{"s":"","m":0,"v":100,"S"},"176":{"s":"","m":0,"v":100,"S"},"168":{"s":"","m":0,"v":100,"S"},"208":{"s":"","m":0,"v":100,"S"},"64":{"s":"","m":0,"v":100,"S"},"56":{"s":"","m":0,"v":100,"S"},"88":{"s":"","m":0,"v":100,"S"},"72":{"s":"","m":0,"v":100,"S"},"128":{"s":"","m":0,"v":100,"S"},"32":{"s":"","m":0,"v":100,"S"},"16":{"s":"","m":0,"v":100,"S"},"8":{"s":"","m":0,"v":100,"S"},"192":{"s":"","m":0,"v":100,"S"},"40":{"s":"","m":0,"v":100,"S"},"152":{"s":"","m":0,"v":100,"S"},"144":{"s":"","m":0,"v":100,"S"},"200":{"s":"","m":0,"v":100,"S"},"48":{"s":"","m":0,"v":100,"S"},"224":{"s":"","m":0,"v":100,"S"},"24":{"s":"","m":0,"v":100,"S"},"80":{"s":"","m":0,"v":100,"S"},"184":{"s":"","m":0,"v":100,"S"},"104":{"s":"","m":0,"v":100,"S"},"160":{"s":"","m":0,"v":100,"S"},"216":{"s":"","m":0,"v":100,"S"}},{"0":{"s":"","m":0,"v":100,"S"},"112":{"s":"","m":0,"v":100,"S"},"232":{"s":"","m":0,"v":100,"S"},"96":{"s":"","m":0,"v":100,"S"},"136":{"s":"","m":0,"v":100,"S"},"120":{"s":"","m":0,"v":100,"S"},"176":{"s":"","m":0,"v":100,"S"},"168":{"s":"","m":0,"v":100,"S"},"208":{"s":"","m":0,"v":100,"S"},"64":{"s":"","m":0,"v":100,"S"},"56":{"s":"","m":0,"v":100,"S"},"88":{"s":"","m":0,"v":100,"S"},"72":{"s":"","m":0,"v":100,"S"},"128":{"s":"","m":0,"v":100,"S"},"32":{"s":"","m":0,"v":100,"S"},"16":{"s":"","m":0,"v":100,"S"},"8":{"s":"","m":0,"v":100,"S"},"192":{"s":"","m":0,"v":100,"S"},"40":{"s":"","m":0,"v":100,"S"},"152":{"s":"","m":0,"v":100,"S"},"144":{"s":"","m":0,"v":100,"S"},"200":{"s":"","m":0,"v":100,"S"},"48":{"s":"","m":0,"v":100,"S"},"224":{"s":"","m":0,"v":100,"S"},"24":{"s":"","m":0,"v":100,"S"},"80":{"s":"","m":0,"v":100,"S"},"184":{"s":"","m":0,"v":100,"S"},"104":{"s":"","m":0,"v":100,"S"},"160":{"s":"","m":0,"v":100,"S"},"216":{"s":"","m":0,"v":100,"S"}},{"0":{"s":"","m":0,"v":100,"S"0},"112":{"s":"","m":0,"v":100,"S"1},"232":{"s":"","m":0,"v":100,"S"0},"96":{"s":"","m":0,"v":100,"S"1},"136":{"s":"","m":0,"v":100,"S"0},"120":{"s":"","m":0,"v":100,"S"1},"176":{"s":"","m":0,"v":100,"S"1},"168":{"s":"","m":0,"v":100,"S"1},"208":{"s":"","m":0,"v":100,"S"0},"64":{"s":"","m":0,"v":100,"S"1},"56":{"s":"","m":0,"v":100,"S"1},"88":{"s":"","m":0,"v":100,"S"0},"72":{"s":"","m":0,"v":100,"S"0},"128":{"s":"","m":0,"v":100,"S"0},"32":{"s":"","m":0,"v":100,"S"0},"16":{"s":"","m":0,"v":100,"S"1},"8":{"s":"","m":0,"v":100,"S"1},"192":{"s":"","m":0,"v":100,"S"1},"40":{"s":"","m":0,"v":100,"S"0},"152":{"s":"","m":0,"v":100,"S"0},"144":{"s":"","m":0,"v":100,"S"0},"200":{"s":"","m":0,"v":100,"S"0},"48":{"s":"","m":0,"v":100,"S"1},"224":{"s":"","m":0,"v":100,"S"0},"24":{"s":"","m":0,"v":100,"S"1},"80":{"s":"","m":0,"v":100,"S"0},"184":{"s":"","m":0,"v":100,"S"1},"104":{"s":"","m":0,"v":100,"S"1},"160":{"s":"","m":0,"v":100,"S"1},"216":{"s":"","m":0,"v":100,"S"0}},{"0":{"s":"","m":0,"v":100,"S"2},"112":{"s":"","m":0,"v":100,"S"2},"232":{"s":"","m":0,"v":100,"S"2},"96":{"s":"","m":0,"v":100,"S"2},"136":{"s":"","m":0,"v":100,"S"2},"120":{"s":"","m":0,"v":100,"S"2},"176":{"s":"","m":0,"v":100,"S"2},"168":{"s":"","m":0,"v":100,"S"2},"208":{"s":"","m":0,"v":100,"S"2},"64":{"s":"","m":0,"v":100,"S"2},"56":{"s":"","m":0,"v":100,"S"2},"88":{"s":"","m":0,"v":100,"S"2},"72":{"s":"","m":0,"v":100,"S"2},"128":{"s":"","m":0,"v":100,"S"2},"32":{"s":"","m":0,"v":100,"S"2},"16":{"s":"","m":0,"v":100,"S"2},"8":{"s":"","m":0,"v":100,"S"2},"192":{"s":"","m":0,"v":100,"S"2},"40":{"s":"","m":0,"v":100,"S"2},"152":{"s":"","m":0,"v":100,"S"2},"144":{"s":"","m":0,"v":100,"S"2},"200":{"s":"","m":0,"v":100,"S"2},"48":{"s":"","m":0,"v":100,"S"2},"224":{"s":"","m":0,"v":100,"S"2},"24":{"s":"","m":0,"v":100,"S"2},"80":{"s":"","m":0,"v":100,"S"2},"184":{"s":"","m":0,"v":100,"S"2},"104":{"s":"","m":0,"v":100,"S"2},"160":{"s":"","m":0,"v":100,"S"2},"216":{"s":"","m":0,"v":100,"S"2}},{"0":{"s":"","m":0,"v":100,"S"3},"112":{"s":"","m":0,"v":100,"S"3},"232":{"s":"","m":0,"v":100,"S"3},"96":{"s":"","m":0,"v":100,"S"3},"136":{"s":"","m":0,"v":100,"S"3},"120":{"s":"","m":0,"v":100,"S"3},"176":{"s":"","m":0,"v":100,"S"3},"168":{"s":"","m":0,"v":100,"S"3},"208":{"s":"","m":0,"v":100,"S"3},"64":{"s":"","m":0,"v":100,"S"3},"56":{"s":"","m":0,"v":100,"S"3},"88":{"s":"","m":0,"v":100,"S"3},"72":{"s":"","m":0,"v":100,"S"3},"128":{"s":"","m":0,"v":100,"S"3},"32":{"s":"","m":0,"v":100,"S"3},"16":{"s":"","m":0,"v":100,"S"3},"8":{"s":"","m":0,"v":100,"S"3},"192":{"s":"","m":0,"v":100,"S"3},"40":{"s":"","m":0,"v":100,"S"3},"152":{"s":"","m":0,"v":100,"S"3},"144":{"s":"","m":0,"v":100,"S"3},"200":{"s":"","m":0,"v":100,"S"3},"48":{"s":"","m":0,"v":100,"S"3},"224":{"s":"","m":0,"v":100,"S"3},"24":{"s":"","m":0,"v":100,"S"3},"80":{"s":"","m":0,"v":100,"S"3},"184":{"s":"","m":0,"v":100,"S"3},"104":{"s":"","m":0,"v":100,"S"3},"160":{"s":"","m":0,"v":100,"S"3},"216":{"s":"","m":0,"v":100,"S"3}}],"properties":{"v":"1","tempo":"120","name":"","key":"*"},"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_1.ogg","http://local.stereofyter.org/audio/samples/Jazz_Piano.ogg","http://local.stereofyter.org/audio/samples/African_Mist_Voice_2.ogg","http://local.stereofyter.org/audio/samples/Cuban_Voice.ogg","http://local.stereofyter.org/audio/samples/Backroads_Banjo.ogg","http://local.stereofyter.org/audio/samples/Eastern_Gold_Voice.ogg","http://local.stereofyter.org/audio/samples/Cuban_Percussion.ogg","http://local.stereofyter.org/audio/samples/Koto.ogg","http://local.stereofyter.org/audio/samples/Djembe.ogg","http://local.stereofyter.org/audio/samples/Sine_Bass.ogg","http://local.stereofyter.org/audio/samples/Electro_Transistor_Beat.ogg","http://local.stereofyter.org/audio/samples/Tremolo_Organ.ogg","http://local.stereofyter.org/audio/samples/Hip_Hop_Wakka_Guitar.ogg","http://local.stereofyter.org/audio/samples/House_Lazy_Beat.ogg"]}', 22, '2011-10-03 23:22:26', '2011-10-03 23:08:21', 0, 0, ''),
(9, '', '{"tracks":[[{"S":0,"b":16,"m":0,"s":0,"v":100},{"S":0,"b":48,"m":0,"s":0,"v":100},{"S":0,"b":24,"m":0,"s":0,"v":100},{"S":0,"b":40,"m":1,"s":0,"v":100},{"S":0,"b":8,"m":0,"s":0,"v":100},{"S":0,"b":32,"m":0,"s":0,"v":100}],[{"S":1,"b":16,"m":0,"s":0,"v":100},{"S":1,"b":48,"m":0,"s":0,"v":100},{"S":1,"b":40,"m":1,"s":0,"v":100},{"S":1,"b":8,"m":0,"s":0,"v":100},{"S":1,"b":24,"m":0,"s":0,"v":100},{"S":1,"b":32,"m":0,"s":0,"v":100}],[{"S":2,"b":8,"m":0,"s":0,"v":100},{"S":2,"b":16,"m":0,"s":0,"v":100},{"S":2,"b":40,"m":0,"s":0,"v":16},{"S":2,"b":24,"m":0,"s":0,"v":5},{"S":2,"b":32,"m":0,"s":0,"v":5},{"S":2,"b":48,"m":0,"s":0,"v":16}],[{"S":3,"b":16,"m":0,"s":0,"v":100},{"S":4,"b":40,"m":0,"s":0,"v":100}],[{"S":5,"b":24,"m":0,"s":0,"v":100},{"S":5,"b":32,"m":0,"s":0,"v":100}]],"samples":["Cuban_Percussion.ogg","Backroads_Banjo.ogg","House_Lazy_Beat.ogg","Eastern_Gold_Voice.ogg","Cuban_Voice.ogg","Jazz_Piano.ogg"],"properties":{"key":null,"name":null,"tempo":120,"volume":100}}', 22, '2011-10-13 23:37:43', '2011-10-04 17:41:52', 0, 0, ''),
(10, '', '{"tracks":[[{"m":0,"s":0,"S":0,"v":0,"b":0}],[{"m":1,"s":0,"S":1,"v":0,"b":8}]],"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_1.ogg","http://local.stereofyter.org/audio/samples/Cuban_Percussion.ogg"],"properties":{"volume":100,"tempo":90,"key":null,"name":null}}', 22, '2011-10-04 21:42:06', '2011-10-04 19:02:51', 0, 0, ''),
(13, '', '{"tracks":[[{"S":0,"v":100,"s":0,"b":0,"m":0}],[{"S":1,"v":100,"s":0,"b":8,"m":0}],[{"S":2,"v":100,"s":0,"b":16,"m":0}]],"samples":["http://local.stereofyter.org/audio/samples/Djembe.ogg","http://local.stereofyter.org/audio/samples/Electro_Transistor_Beat.ogg","http://local.stereofyter.org/audio/samples/Tremolo_Organ.ogg"],"properties":{"tempo":90,"key":null,"name":null,"volume":100}}', 0, '2011-10-05 02:30:20', '2011-10-05 02:30:20', 0, 0, ''),
(14, '', '{"tracks":[],"samples":[],"properties":{"tempo":90,"name":null,"key":null,"volume":100}}', 0, '2011-10-05 02:39:16', '2011-10-05 02:39:16', 0, 0, ''),
(15, '', '{"tracks":[],"samples":[],"properties":{"tempo":90,"name":null,"key":null,"volume":100}}', 0, '2011-10-05 02:39:19', '2011-10-05 02:39:19', 0, 0, ''),
(16, '', '{"tracks":[],"samples":[],"properties":{"tempo":90,"name":null,"key":null,"volume":100}}', 0, '2011-10-05 02:39:20', '2011-10-05 02:39:20', 0, 0, ''),
(17, '', '{"tracks":[],"samples":[],"properties":{"tempo":90,"name":null,"key":null,"volume":100}}', 0, '2011-10-05 02:39:22', '2011-10-05 02:39:22', 0, 0, ''),
(18, '', '{"properties":{"volume":100,"key":null,"name":null,"tempo":120},"tracks":[],"samples":[]}', 0, '2011-10-05 02:44:55', '2011-10-05 02:44:55', 0, 0, ''),
(19, '', '{"properties":{"key":null,"name":null,"volume":100,"tempo":120},"tracks":[[{"S":0,"v":100,"s":0,"b":0,"m":0}]],"samples":["http://local.stereofyter.org/audio/samples/Djembe.ogg"]}', 16, '2011-10-05 02:49:35', '2011-10-05 02:49:25', 0, 0, ''),
(20, '', '{"properties":{"tempo":120,"key":null,"name":null,"volume":100},"tracks":[[{"S":0,"v":100,"s":0,"b":0,"m":0}],null,[{"S":0,"v":100,"s":0,"b":8,"m":0}]],"samples":["http://local.stereofyter.org/audio/samples/Djembe.ogg"]}', 16, '2011-10-05 03:06:35', '2011-10-05 03:06:35', 0, 0, ''),
(21, '', '{"tracks":[[{"S":0,"v":100,"s":0,"b":0,"m":0}],null,[{"S":0,"v":100,"s":0,"b":8,"m":0}]],"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_2.ogg"],"properties":{"tempo":120,"key":null,"name":null,"volume":100}}', 16, '2011-10-05 03:09:51', '2011-10-05 03:09:51', 0, 0, ''),
(22, '', '{"properties":{"tempo":120,"name":null,"key":null,"volume":100},"tracks":[[{"S":0,"b":0,"m":0,"s":0,"v":100}],null,[{"S":0,"b":8,"m":0,"s":0,"v":100}]],"samples":["http://local.stereofyter.org/audio/samples/African_Mist_Voice_1.ogg"]}', 16, '2011-10-05 03:11:23', '2011-10-05 03:11:23', 0, 0, ''),
(23, '', '{"properties":{"tempo":120,"name":null,"key":null,"volume":100},"tracks":[[{"S":0,"b":0,"m":0,"s":0,"v":100}],null,[{"S":0,"b":8,"m":0,"s":0,"v":100}]],"samples":["http://local.stereofyter.org/audio/samples/Backroads_Banjo.ogg"]}', 16, '2011-10-05 03:15:54', '2011-10-05 03:13:37', 0, 0, ''),
(24, '', '{"tracks":[]}', 22, '2011-10-13 23:37:52', '2011-10-13 23:37:52', 0, 0, ''),
(25, '', '{"properties":{"key":null,"tempo":120,"name":null,"volume":100},"tracks":[[{"S":0,"b":0,"m":0,"s":0,"v":100}]],"samples":["African_Mist_Voice_2.ogg"]}', 22, '2011-10-13 23:38:10', '2011-10-13 23:38:10', 0, 0, ''),
(26, '', '{"properties":{"key":null,"tempo":120,"name":null,"volume":100},"tracks":[[{"S":0,"b":0,"m":0,"s":0,"v":100}]],"samples":["African_Mist_Voice_2.ogg"]}', 16, '2011-10-13 23:50:40', '2011-10-13 23:48:53', 0, 0, ''),
(27, '', '{"properties":{"key":null,"tempo":120,"name":null,"volume":100},"tracks":[[{"S":0,"b":0,"m":0,"s":0,"v":100}]],"samples":["African_Mist_Voice_2.ogg"]}', 22, '2011-10-14 00:00:20', '2011-10-13 23:51:49', 0, 0, ''),
(28, '', '{"tracks":[[{"S":0,"b":16,"m":0,"s":0,"v":100},{"S":0,"b":48,"m":0,"s":0,"v":100},{"S":0,"b":24,"m":0,"s":0,"v":100},{"S":0,"b":40,"m":1,"s":0,"v":100},{"S":0,"b":8,"m":0,"s":0,"v":100},{"S":0,"b":32,"m":0,"s":0,"v":100}],[{"S":1,"b":16,"m":0,"s":0,"v":100},{"S":1,"b":48,"m":0,"s":0,"v":100},{"S":1,"b":40,"m":1,"s":0,"v":100},{"S":1,"b":8,"m":0,"s":0,"v":100},{"S":1,"b":24,"m":0,"s":0,"v":100},{"S":1,"b":32,"m":0,"s":0,"v":100}],[{"S":2,"b":8,"m":0,"s":0,"v":100},{"S":2,"b":16,"m":0,"s":0,"v":100},{"S":2,"b":40,"m":0,"s":0,"v":16},{"S":2,"b":24,"m":0,"s":0,"v":5},{"S":2,"b":32,"m":0,"s":0,"v":5},{"S":2,"b":48,"m":0,"s":0,"v":16}],[{"S":3,"b":16,"m":0,"s":0,"v":100},{"S":4,"b":40,"m":0,"s":0,"v":100}],[{"S":5,"b":24,"m":0,"s":0,"v":100},{"S":5,"b":32,"m":0,"s":0,"v":100}]],"samples":["Cuban_Percussion.ogg","Backroads_Banjo.ogg","House_Lazy_Beat.ogg","Eastern_Gold_Voice.ogg","Cuban_Voice.ogg","Jazz_Piano.ogg"],"properties":{"key":null,"name":null,"tempo":120,"volume":100}}', 16, '2011-10-14 00:46:21', '2011-10-14 00:22:43', 0, 0, ''),
(29, '', '{"properties":{"key":null,"tempo":120,"name":null,"volume":100},"tracks":[[{"S":0,"b":8,"m":0,"s":0,"v":100},{"S":1,"b":48,"m":0,"s":0,"v":100},{"S":1,"b":32,"m":0,"s":0,"v":100}],[{"S":2,"b":32,"m":0,"s":0,"v":100}],[{"S":3,"b":16,"m":0,"s":0,"v":25},{"S":4,"b":24,"m":0,"s":0,"v":100},{"S":4,"b":32,"m":0,"s":0,"v":100}],[{"S":5,"b":16,"m":0,"s":0,"v":100},{"S":5,"b":24,"m":0,"s":0,"v":100},{"S":6,"b":48,"m":1,"s":0,"v":100},{"S":5,"b":32,"m":0,"s":0,"v":100},{"S":5,"b":40,"m":0,"s":0,"v":100}],[{"S":7,"b":0,"m":0,"s":0,"v":19},{"S":7,"b":32,"m":0,"s":0,"v":100},{"S":7,"b":16,"m":0,"s":0,"v":100},{"S":7,"b":24,"m":0,"s":0,"v":100},{"S":7,"b":40,"m":1,"s":0,"v":100}],[{"S":8,"b":0,"m":0,"s":0,"v":100},{"S":8,"b":8,"m":0,"s":0,"v":100},{"S":8,"b":32,"m":0,"s":0,"v":100},{"S":8,"b":16,"m":0,"s":0,"v":100},{"S":8,"b":24,"m":0,"s":0,"v":100},{"S":8,"b":40,"m":0,"s":0,"v":100}]],"samples":["Eastern_Gold_Voice.ogg","Cuban_Voice.ogg","Backroads_Banjo.ogg","Koto.ogg","Jazz_Piano.ogg","Cuban_Percussion.ogg","Electro_Transistor_Beat.ogg","House_Lazy_Beat.ogg","Sine_Bass.ogg"]}', 16, '2011-10-14 01:04:26', '2011-10-14 01:04:26', 0, 0, '');

--
-- Dumping data for table `sf_mix_lineage`
--


--
-- Dumping data for table `sf_mix_messages`
--

INSERT INTO `sf_mix_messages` (`id`, `link_id`, `attachment_id`, `reply_on_id`, `mix_id`, `user_id`, `date`, `message`, `title`) VALUES
(1, 28, 0, -1, -1, 16, '2012-03-05 09:19:05', 0x4669727374206d6978206f766572203230207365636f6e647321, ''),
(2, 32, 0, -1, -1, 23, '2012-03-05 09:24:12', 0x536565207768617420796f752063616e20646f20776974682061206c6974746c6520696d6167696e6174696f6e2e, ''),
(3, 29, 0, -1, -1, 16, '2012-03-05 09:29:10', 0x4d79207365636f6e64206d69782e2049207265616c6c79206c696b65207468657365204c6174696e20766f6963652073616d706c65732e, ''),
(6, 35, 0, -1, -1, 23, '2012-03-07 15:17:27', 0x4c6f7665207468652053616e64205261626162206c6f6f702e2057686174206b696e64206f66206d7573696320646f2070656f706c65206c697374656e20746f20696e2041666768616e697374616e3f20416e796f6e652074726176656c6564207468657265206f722066726f6d20746865726520616e64206b6e6f77733f, '');


--
-- Dumping data for table `sf_mix_owners`
--

REPLACE INTO `sf_mix_owners` (`id`, `mix_id`, `owner_id`) VALUES
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
(22, 23, 16),
(23, 24, 16),
(24, 25, 22),
(25, 26, 16),
(26, 27, 22),
(27, 28, 16),
(28, 29, 16);

--
-- Dumping data for table `sf_reset_hashes`
--

REPLACE INTO `sf_reset_hashes` (`id`, `user_id`, `hash`, `created`) VALUES
(15, 16, '0abf14be371e47b9f5ebb5aefdc217e191b8db2c', '2011-10-27 19:40:56');

--
-- Dumping data for table `sf_samples`
--


--
-- Dumping data for table `sf_users`
--

REPLACE INTO `sf_users` (`id`, `username`, `name`, `email`, `password`, `country`, `musician`, `avatar`, `subscribe_updates`, `created`) VALUES
(16, '', NULL, 'lovejoy.chris@gmail.com', '95b0db6a991b6ec0b2f0465914b683687ea2cab4d0f569c67caa87dcc0b058f7', 'AX', 'no', '', 'yes', '2011-09-23 00:00:09'),
(22, '', NULL, 'c@chrislovejoy.com', '6afe3227bdc2e95761be0b5544f138c3521505e7f307515aae1cac9a1bbdf4b3', 'AO', 'no', '', 'yes', '2011-10-03 20:12:36');
