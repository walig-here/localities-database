-- --------------------------------------------------------
-- Host:                         10.166.70.10
-- Wersja serwera:               10.11.6-MariaDB - mariadb.org binary distribution
-- Serwer OS:                    Win64
-- HeidiSQL Wersja:              12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Zrzut struktury bazy danych projekt_bd
CREATE DATABASE IF NOT EXISTS `projekt_bd` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `projekt_bd`;

-- Zrzut struktury procedura projekt_bd.add_locality_to_fav_list
DELIMITER //
CREATE PROCEDURE `add_locality_to_fav_list`(
	IN locality_id INT(10),
	IN adnotation VARCHAR(1000)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.add_new_attraction
DELIMITER //
CREATE PROCEDURE `add_new_attraction`(
	IN attraction_name VARCHAR(30),
	IN attraction_desc VARCHAR(1000),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN buildig_number VARCHAR(30),
	IN flat_number VARCHAR(30)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.add_new_locality
DELIMITER //
CREATE PROCEDURE `add_new_locality`(
	IN locality_name VARCHAR(30),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latitude REAL,
	IN longitude REAL
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.administrative_units
CREATE TABLE IF NOT EXISTS `administrative_units` (
  `administrative_unit_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` varchar(30) NOT NULL,
  `superior_administrative_unit` int(10) DEFAULT NULL,
  PRIMARY KEY (`administrative_unit_id`),
  KEY `superior_administrative_unit` (`superior_administrative_unit`),
  CONSTRAINT `FKAdministra497736` FOREIGN KEY (`superior_administrative_unit`) REFERENCES `administrative_units` (`administrative_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury procedura projekt_bd.assign_attraction_to_locality
DELIMITER //
CREATE PROCEDURE `assign_attraction_to_locality`(
	IN attraction_id INT(10),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN building_number VARCHAR(50),
	IN flat_number VARCHAR(50)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.assign_figure_to_attraction
DELIMITER //
CREATE PROCEDURE `assign_figure_to_attraction`(
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.assign_permission_to_user
DELIMITER //
CREATE PROCEDURE `assign_permission_to_user`(
	IN voivodship_id INT(10),
	IN login VARCHAR(30),
	IN permission_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.assign_type_to_attraction
DELIMITER //
CREATE PROCEDURE `assign_type_to_attraction`(
	IN type_id INT(10),
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.attractions
CREATE TABLE IF NOT EXISTS `attractions` (
  `attraction_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`attraction_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.attractions_locations
CREATE TABLE IF NOT EXISTS `attractions_locations` (
  `attraction_id` int(10) NOT NULL,
  `location_id` int(10) NOT NULL,
  PRIMARY KEY (`attraction_id`,`location_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `FKAttraction904049` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`),
  CONSTRAINT `FKAttraction940482` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.attraction_types
CREATE TABLE IF NOT EXISTS `attraction_types` (
  `attraction_type_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`attraction_type_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury procedura projekt_bd.del_attraction
DELIMITER //
CREATE PROCEDURE `del_attraction`(
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_locality
DELIMITER //
CREATE PROCEDURE `del_locality`(
	IN locality_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_locality_from_fav_list
DELIMITER //
CREATE PROCEDURE `del_locality_from_fav_list`(
	IN locality_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_user
DELIMITER //
CREATE PROCEDURE `del_user`(
	IN user_login VARCHAR(30)
)
BEGIN
	-- Usunięcie użytkownika z serwera bazodanowego
	set @sql = concat("DROP USER'",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   
   -- Usunięcie użytkownika z bazy danych
   DELETE FROM projekt_bd.users
   WHERE user_login = Users.login;
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.favourite_localities
CREATE TABLE IF NOT EXISTS `favourite_localities` (
  `locality_id` int(5) NOT NULL,
  `login` varchar(30) NOT NULL,
  `adnotation` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`locality_id`,`login`),
  KEY `login` (`login`),
  CONSTRAINT `FKFavourite_482397` FOREIGN KEY (`login`) REFERENCES `users` (`login`),
  CONSTRAINT `FKFavourite_981560` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`locality_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.figures
CREATE TABLE IF NOT EXISTS `figures` (
  `figure_id` int(10) NOT NULL AUTO_INCREMENT,
  `figure` blob NOT NULL,
  PRIMARY KEY (`figure_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.figures_containing_attractions
CREATE TABLE IF NOT EXISTS `figures_containing_attractions` (
  `figure_id` int(10) NOT NULL,
  `attraction_id` int(10) NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`figure_id`,`attraction_id`),
  KEY `attraction_id` (`attraction_id`),
  CONSTRAINT `FKFigures_Co325289` FOREIGN KEY (`figure_id`) REFERENCES `figures` (`figure_id`),
  CONSTRAINT `FKFigures_Co880499` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury widok projekt_bd.full_localities_data
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `full_localities_data` (
	`locality_id` INT(5) NOT NULL,
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`population` INT(10) UNSIGNED NOT NULL,
	`locality_latitude` DOUBLE NULL,
	`locality_longitude` DOUBLE NULL,
	`locality_type` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury procedura projekt_bd.get_attractions_in_locality
DELIMITER //
CREATE PROCEDURE `get_attractions_in_locality`(
	IN locality_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_counties_from_voivodship
DELIMITER //
CREATE PROCEDURE `get_counties_from_voivodship`(
	IN voivodship_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_figures_assigned_to_attraction
DELIMITER //
CREATE PROCEDURE `get_figures_assigned_to_attraction`(
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_localities_number_of_attractions
DELIMITER //
CREATE PROCEDURE `get_localities_number_of_attractions`(
	IN locality_id INT(10),
	OUT number_of_attraction INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_locations_from_locality
DELIMITER //
CREATE PROCEDURE `get_locations_from_locality`(
	IN locality_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_municipalities_from_county
DELIMITER //
CREATE PROCEDURE `get_municipalities_from_county`(
	IN county_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_types_assigned_to_attraction
DELIMITER //
CREATE PROCEDURE `get_types_assigned_to_attraction`(
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_user_permissions_in_voivodship
DELIMITER //
CREATE PROCEDURE `get_user_permissions_in_voivodship`(
	IN login VARCHAR(30),
	IN voivodship_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_voivodships_managed_by_user
DELIMITER //
CREATE PROCEDURE `get_voivodships_managed_by_user`(
	IN login VARCHAR(30)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury widok projekt_bd.granted_permissions
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `granted_permissions` (
	`permission_id` INT(10) NOT NULL,
	`permission_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`permission_desc` VARCHAR(1000) NOT NULL COLLATE 'utf8mb4_general_ci',
	`user_role` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci',
	`user_login` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_id` INT(10) NOT NULL,
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury tabela projekt_bd.localities
CREATE TABLE IF NOT EXISTS `localities` (
  `locality_id` int(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `DESCRIPTION` varchar(1000) DEFAULT NULL,
  `population` int(10) unsigned NOT NULL,
  `municipality_id` int(10) NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `locality_type_id` int(10) NOT NULL,
  PRIMARY KEY (`locality_id`),
  KEY `name` (`name`),
  KEY `municipality_id` (`municipality_id`),
  KEY `locality_type_id` (`locality_type_id`),
  CONSTRAINT `FKLocalities245678` FOREIGN KEY (`locality_type_id`) REFERENCES `locality_types` (`locality_type_id`),
  CONSTRAINT `FKLocalities574896` FOREIGN KEY (`municipality_id`) REFERENCES `administrative_units` (`administrative_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.locality_types
CREATE TABLE IF NOT EXISTS `locality_types` (
  `locality_type_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`locality_type_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.locations
CREATE TABLE IF NOT EXISTS `locations` (
  `location_id` int(10) NOT NULL AUTO_INCREMENT,
  `locality_id` int(5) NOT NULL,
  `street` varchar(50) DEFAULT NULL,
  `building_number` varchar(10) DEFAULT NULL,
  `flat_number` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  KEY `locality_id` (`locality_id`),
  CONSTRAINT `FKLocations403057` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`locality_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury widok projekt_bd.locations_of_attractions
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `locations_of_attractions` (
	`location_id` INT(10) NOT NULL,
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`street` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`building_number` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`flat_number` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`attraction_id` INT(10) NOT NULL,
	`attraction_name` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_general_ci',
	`attraction_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury widok projekt_bd.managed_attractions
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `managed_attractions` (
	`attraction_id` INT(10) NOT NULL,
	`attraction_name` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_general_ci',
	`attraction_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`street` VARCHAR(50) NULL COLLATE 'utf8mb4_general_ci',
	`building_number` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`flat_number` VARCHAR(10) NULL COLLATE 'utf8mb4_general_ci',
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_na` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury widok projekt_bd.managed_localities
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `managed_localities` (
	`locality_id` INT(5) NOT NULL,
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`population` INT(10) UNSIGNED NOT NULL,
	`locality_latitude` DOUBLE NULL,
	`locality_longitude` DOUBLE NULL,
	`locality_type` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municiaplity_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury procedura projekt_bd.modify_attraction
DELIMITER //
CREATE PROCEDURE `modify_attraction`(
	IN attraction_id INT(10),
	IN attraction_name VARCHAR(50),
	IN attraction_desc VARCHAR(1000)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.modify_figure_caption
DELIMITER //
CREATE PROCEDURE `modify_figure_caption`(
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.modify_locality
DELIMITER //
CREATE PROCEDURE `modify_locality`(
	IN locality_id INT(10),
	IN locality_name VARCHAR(50),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latititude REAL,
	IN longitude REAL
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.modify_user_role
DELIMITER //
CREATE PROCEDURE `modify_user_role`(
	IN login VARCHAR(30),
	IN user_role VARCHAR(30)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.permissions
CREATE TABLE IF NOT EXISTS `permissions` (
  `permission_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(1000) NOT NULL,
  PRIMARY KEY (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury widok projekt_bd.registered_users
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `registered_users` (
	`login` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci',
	`role` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury procedura projekt_bd.register_user
DELIMITER //
CREATE PROCEDURE `register_user`(
	IN	user_login  VARCHAR(30),
	IN user_password VARCHAR(48)
)
BEGIN
	-- Dodanie nowego konta do serwera bazodanowego
	set @sql = concat("CREATE USER '",`user_login`,"'@'%","' IDENTIFIED BY '",`user_password`,"'");
   PREPARE stmt1 FROM @sql;
   EXECUTE stmt1;
   DEALLOCATE PREPARE stmt1;

   set @sql = concat("GRANT viewer TO '",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
   
   set @sql = concat("SET DEFAULT ROLE viewer FOR '",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
	
	-- Dodanie nowego konta do bazy danych
	INSERT INTO users (users.login,users.`password`,users.role) VALUES (user_login, user_password, 'viewer');
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.types_assigned_to_attractions
CREATE TABLE IF NOT EXISTS `types_assigned_to_attractions` (
  `attraction_type_id` int(10) NOT NULL,
  `attraction_id` int(10) NOT NULL,
  PRIMARY KEY (`attraction_type_id`,`attraction_id`),
  KEY `attraction_id` (`attraction_id`),
  CONSTRAINT `FKTypes_Assi239592` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`),
  CONSTRAINT `FKTypes_Assi695374` FOREIGN KEY (`attraction_type_id`) REFERENCES `attraction_types` (`attraction_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury procedura projekt_bd.unassign_attraction_from_locality
DELIMITER //
CREATE PROCEDURE `unassign_attraction_from_locality`(
	IN attraction_id INT(10),
	IN locality_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_figure_from_attraction
DELIMITER //
CREATE PROCEDURE `unassign_figure_from_attraction`(
	IN figure_id INT(10),
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_permission_from_user
DELIMITER //
CREATE PROCEDURE `unassign_permission_from_user`(
	IN login VARCHAR(30),
	IN voivodship_id INT(10),
	IN permission_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_type_from_attraction
DELIMITER //
CREATE PROCEDURE `unassign_type_from_attraction`(
	IN attraction_type_id INT(10),
	IN attraction_id INT(10)
)
BEGIN
	-- uzupełnić
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.users
CREATE TABLE IF NOT EXISTS `users` (
  `login` varchar(30) NOT NULL,
  `password` char(48) NOT NULL,
  `role` varchar(30) NOT NULL,
  PRIMARY KEY (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury tabela projekt_bd.users_permissions_in_voivodships
CREATE TABLE IF NOT EXISTS `users_permissions_in_voivodships` (
  `login` varchar(30) NOT NULL,
  `voivodship_id` int(10) NOT NULL,
  `permission_id` int(10) NOT NULL,
  PRIMARY KEY (`login`,`voivodship_id`,`permission_id`),
  KEY `login` (`login`),
  KEY `FKUsers_Perm443111` (`permission_id`),
  CONSTRAINT `FKUsers_Perm443111` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`),
  CONSTRAINT `FKUsers_Perm990828` FOREIGN KEY (`login`, `voivodship_id`) REFERENCES `voivodships_administrated_by_users` (`login`, `voivodship_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury widok projekt_bd.user_account
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `user_account` (
	`my_login` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci',
	`my_role` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury widok projekt_bd.user_favourite_localities
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `user_favourite_localities` (
	`locality_id` INT(5) NOT NULL,
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`population` INT(10) UNSIGNED NOT NULL,
	`locality_latitude` DOUBLE NULL,
	`locality_longitude` DOUBLE NULL,
	`adnotation` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`locality_type` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury widok projekt_bd.user_permissions
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `user_permissions` (
	`permission_id` INT(10) NOT NULL,
	`permission_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`permission_desc` VARCHAR(1000) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_id` INT(10) NOT NULL,
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury tabela projekt_bd.voivodships_administrated_by_users
CREATE TABLE IF NOT EXISTS `voivodships_administrated_by_users` (
  `login` varchar(30) NOT NULL,
  `voivodship_id` int(10) NOT NULL,
  PRIMARY KEY (`login`,`voivodship_id`),
  KEY `login` (`login`),
  KEY `FKVoivodship87041` (`voivodship_id`),
  CONSTRAINT `FKVoivodship178065` FOREIGN KEY (`login`) REFERENCES `users` (`login`),
  CONSTRAINT `FKVoivodship87041` FOREIGN KEY (`voivodship_id`) REFERENCES `administrative_units` (`administrative_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Eksport danych został odznaczony.

-- Zrzut struktury widok projekt_bd.full_localities_data
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `full_localities_data`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `full_localities_data` AS SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Locality_Types.name AS locality_type,
	Municipality.name AS municipality_name,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Localities INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id ;

-- Zrzut struktury widok projekt_bd.granted_permissions
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `granted_permissions`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `granted_permissions` AS SELECT
	Permissions.permission_id,
	Permissions.name AS permission_name,
	Permissions.description AS permission_desc,
	Users.role AS user_role,
	Users.login AS user_login,
	Voivodship.administrative_unit_id AS voivodship_id,
	Voivodship.name AS voivodship_name
FROM
	Permissions INNER JOIN
	Users_Permissions_In_Voivodships ON Permissions.permission_id = Users_Permissions_In_Voivodships.permission_id INNER JOIN
	Voivodships_Administrated_By_Users ON Users_Permissions_In_Voivodships.voivodship_id = Voivodships_Administrated_By_Users.voivodship_id INNER JOIN
	Users ON Voivodships_Administrated_By_Users.login = Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id ;

-- Zrzut struktury widok projekt_bd.locations_of_attractions
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `locations_of_attractions`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `locations_of_attractions` AS SELECT
	Locations.location_id,
	Voivodship.name AS voivodship_name,
	County.name AS county_name,
	Municipality.name AS municipality_name,
	Localities.name AS locality_name,
	Locations.street,
	Locations.building_number,
	Locations.flat_number,
	Attractions.attraction_id,
	Attractions.name AS attraction_name,
	Attractions.description AS attraction_desc
FROM
	Attractions INNER JOIN
	Attractions_locations ON Attractions.attraction_id = Attractions_locations.attraction_id INNER JOIN
	Locations ON Attractions_locations.location_id = Locations.location_id INNER JOIN
	Localities ON Locations.locality_id = Localities.locality_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id ;

-- Zrzut struktury widok projekt_bd.managed_attractions
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `managed_attractions`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `managed_attractions` AS SELECT
	Attractions.attraction_id,
	Attractions.name AS attraction_name,
	Attractions.description AS attraction_desc,
	Locations.street,
	Locations.building_number,
	Locations.flat_number,
	Localities.name AS locality_name,
	Municipality.name AS municipality_na,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locations ON Localities.locality_id = Locations.locality_id INNER JOIN
	Attractions_locations ON Locations.location_id = Attractions_locations.location_id INNER JOIN
	Attractions ON Attractions_locations.attraction_id = Attractions.attraction_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

-- Zrzut struktury widok projekt_bd.managed_localities
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `managed_localities`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `managed_localities` AS SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Locality_Types.name AS locality_type,
	Municipality.name AS municiaplity_id,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

-- Zrzut struktury widok projekt_bd.registered_users
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `registered_users`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `registered_users` AS SELECT
	Users.login,
	Users.role
FROM
	users ;

-- Zrzut struktury widok projekt_bd.user_account
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `user_account`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `user_account` AS SELECT
	Users.login AS my_login,
	Users.role AS my_role
FROM
	Users
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

-- Zrzut struktury widok projekt_bd.user_favourite_localities
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `user_favourite_localities`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `user_favourite_localities` AS SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Favourite_Localities.adnotation,
	Locality_Types.name AS locality_type,
	Municipality.name AS municipality_name,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Favourite_Localities ON Users.login = Favourite_Localities.login INNER JOIN
	Localities ON Favourite_Localities.locality_id = Localities.locality_id INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

-- Zrzut struktury widok projekt_bd.user_permissions
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `user_permissions`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `user_permissions` AS SELECT
	Permissions.permission_id,
	Permissions.name AS permission_name,
	Permissions.description AS permission_desc,
	Voivodship.administrative_unit_id AS voivodship_id,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Users_Permissions_In_Voivodships ON Voivodships_Administrated_By_Users.voivodship_id = Users_Permissions_In_Voivodships.voivodship_id INNER JOIN
	Permissions ON Users_Permissions_In_Voivodships.permission_id = Permissions.permission_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

-- Rola przeglądającego
DROP ROLE IF EXISTS viewer;
CREATE ROLE viewer;
	GRANT SELECT ON projekt_bd.full_localities_data TO viewer;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO viewer;
	GRANT SELECT ON projekt_bd.user_permissions TO viewer;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO viewer;
	GRANT SELECT ON projekt_bd.user_account TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO viewer;
	GRANT SELECT ON projekt_bd.administrative_units TO viewer;
	GRANT SELECT ON projekt_bd.permissions TO viewer;
	GRANT SELECT ON projekt_bd.locality_types TO viewer;
	GRANT SELECT ON projekt_bd.figures TO viewer;
	GRANT SELECT ON projekt_bd.attraction_types TO viewer;
FLUSH PRIVILEGES;

-- Rola administratora technicznego
DROP ROLE IF EXISTS technical_administrator;
CREATE ROLE technical_administrator;
	GRANT SELECT ON projekt_bd.registered_users TO technical_administrator;
	GRANT SELECT ON projekt_bd.granted_permissions TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_permission_from_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_permission_to_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_user_role TO technical_administrator;
	
	GRANT SELECT ON projekt_bd.full_localities_data TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_permissions TO technical_administrator;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_account TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO technical_administrator;
	GRANT SELECT ON projekt_bd.administrative_units TO technical_administrator;
	GRANT SELECT ON projekt_bd.permissions TO technical_administrator;
	GRANT SELECT ON projekt_bd.locality_types TO technical_administrator;
	GRANT SELECT ON projekt_bd.figures TO technical_administrator;
	GRANT SELECT ON projekt_bd.attraction_types TO technical_administrator;
FLUSH PRIVILEGES;

-- Rola administratora merytorycznego
DROP ROLE IF EXISTS meritorical_admin;
CREATE ROLE meritorical_admin;
	GRANT SELECT ON projekt_bd.managed_localities TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_new_locality TO meritorical_admin;
	
	GRANT SELECT ON projekt_bd.managed_attractions TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_figure_from_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_attraction_from_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_type_from_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_attraction_to_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_figure_to_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_type_to_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_figure_caption TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_new_attraction TO meritorical_admin;
	
	GRANT SELECT ON projekt_bd.full_localities_data TO meritorical_admin;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO meritorical_admin;
	GRANT SELECT ON projekt_bd.user_permissions TO meritorical_admin;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO meritorical_admin;
	GRANT SELECT ON projekt_bd.user_account TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO meritorical_admin;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO meritorical_admin;
	GRANT SELECT ON projekt_bd.administrative_units TO meritorical_admin;
	GRANT SELECT ON projekt_bd.permissions TO meritorical_admin;
	GRANT SELECT ON projekt_bd.locality_types TO meritorical_admin;
	GRANT SELECT ON projekt_bd.figures TO meritorical_admin;
	GRANT SELECT ON projekt_bd.attraction_types TO meritorical_admin;
FLUSH PRIVILEGES;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;