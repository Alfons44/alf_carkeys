CREATE TABLE `vehicle_keys` (
  `id` int(11) NOT NULL,
  `identifier` longtext NOT NULL,
  `plate` varchar(12) NOT NULL,
  `state` longtext,
  `label` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `vehicle_keys`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `vehicle_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;
