CREATE TABLE `vehicle_keys` (
  `id` int(11) NOT NULL,
  `identifier` varchar(22) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `state` longtext,
  `label` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `vehicle_keys`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `vehicle_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
  
ALTER TABLE `vehicle_keys` CHANGE `identifier` `identifier` VARCHAR(41) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL; 

COMMIT;
