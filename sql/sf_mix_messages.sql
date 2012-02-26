SET NAMES latin1;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `sf_mix_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_id` int(11) NOT NULL,
  `attachment_id` int(11) NOT NULL DEFAULT '-1',
  `reply_on_id` int(11) NOT NULL DEFAULT '-1',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


SET FOREIGN_KEY_CHECKS = 1;
