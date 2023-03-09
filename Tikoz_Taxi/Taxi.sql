INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_taxi','taxi',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_taxi','taxi',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_taxi', 'taxi', 1)
;

INSERT INTO `jobs` (`name`, `label`) VALUES
('taxi', "Taxi")
;

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('taxi', 0, 'novice', 'Nouveau', 200, 'null', 'null'),
('taxi', 1, 'expert', 'Chauffeur', 400, 'null', 'null'),
('taxi', 2, 'chef', "Responsable", 600, 'null', 'null'),
('taxi', 3, 'boss', 'Patron', 1000, 'null', 'null')
;

CREATE TABLE `tikoz_calltaxi` (
  `id` int(3) NOT NULL,
  `idclient` int(3) NOT NULL,
  `nom` varchar(20) NOT NULL,
  `prenom` varchar(20) NOT NULL,
  `num` int(15) NOT NULL,
  `pos` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tikoz_stockweapon` (
  `id` int(5) NOT NULL,
  `name` varchar(30) NOT NULL,
  `label` varchar(30) NOT NULL,
  `balle` int(4) NOT NULL,
  `job` varchar(15) NOT NULL,
  `gang` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `tikoz_calltaxi`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tikoz_calltaxi`
  MODIFY `id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
COMMIT;

ALTER TABLE `tikoz_stockweapon`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tikoz_stockweapon`
  MODIFY `id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;
