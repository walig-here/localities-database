-- --------------------------------------------------------
-- Host:                         127.0.0.1
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

	-- Sprawdzenie, czy miejscowość znajduje się w bazie danych
	IF NOT EXISTS (
		SELECT 1
		FROM localities AS l
		WHERE l.locality_id = locality_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Ta miejscowośc nie istnieje!';
	END IF;
	
	-- Dodanie miejscowości do listy ulubionych
	INSERT INTO favourite_localities (
		locality_id,
		login,
		adnotation
	)
	VALUES (
		locality_id,
		(SELECT my_login FROM user_account),
		adnotation
	);

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
	
	DECLARE location_id INT(10);
	DECLARE attraction_id INT(10);
	
	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT 1 FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;
	
	-- Sprawdzedznie czy podano nazwę atrakcji
	IF attraction_name = NULL OR attraction_name = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Nazwa atrakcji nie może być pusta!';
	END IF; 
	
	-- Sprawdzenie czy podana miejscowość istnieje
	IF NOT EXISTS (SELECT * FROM localities AS l WHERE l.locality_id = locality_id) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Podana miejscowość nie znajduje się w bazie danych!';
	END IF;
	
	-- Sprawdzenie, czy użytkownik ma uprawnienie do dodawania atrakcji do wskazanej miejscowości
	IF NOT EXISTS (
		SELECT 1
		FROM full_localities_data AS fld
		JOIN user_permissions AS up ON up.voivodship_id = fld.voivodship_id
		WHERE fld.locality_id = locality_id AND up.permission_id = 2
	) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Nie masz uprawnień do dodawania atrakcji w tym województwie!';
	END IF;
	
	-- Dodanie atrakcji
	INSERT INTO attractions (
		`name`,
		`description`
	) 
	VALUES (
		attraction_name,
		attraction_desc
	);
	SET attraction_id = LAST_INSERT_ID();
	
	-- Sprawdzenie czy adres jaki ma zostać przypisany do atrakcji już istnieje w bazie
	-- Jeżeli nie to należy go stworzyć, w przeciwnym wypadku można po prostu przypisać atrakcję do 
	-- istniejącego adresu
	IF NOT EXISTS (
		SELECT loa.location_id
		FROM locations_of_attractions AS loa
		WHERE 
			loa.locality_id = locality_id AND 
			(loa.street = street OR (loa.street IS NULL AND street IS NULL)) AND 
			(loa.building_number = buildig_number OR (loa.building_number IS NULL AND buildig_number IS NULL)) AND
			(loa.flat_number = flat_number OR (loa.flat_number IS NULL AND flat_number IS NULL))
		LIMIT 1
	) THEN
		INSERT INTO locations (
			locality_id,
			street,
			building_number,
			flat_number
		)
		VALUES (
			locality_id,
			street,
			buildig_number,
			flat_number
		);
		
		SET location_id = LAST_INSERT_ID();
	ELSE 
		SELECT loa.location_id
		INTO location_id
		FROM locations_of_attractions AS loa
		WHERE 
			loa.locality_id = locality_id AND 
			(loa.street = street OR (loa.street IS NULL AND street IS NULL)) AND 
			(loa.building_number = buildig_number OR (loa.building_number IS NULL AND buildig_number IS NULL)) AND
			(loa.flat_number = flat_number OR (loa.flat_number IS NULL AND flat_number IS NULL))
			LIMIT 1;
	END IF;
	
	-- Przypisanie atrakcji do adresu
	INSERT INTO attractions_locations(
		attraction_id,
		location_id
	)
	VALUES (
		attraction_id,
		location_id
	);
	
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
	IN longitude REAL,
	IN locality_type_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;

	-- Sprawdzedznie czy podano nazwę miejscowości
	IF locality_name = NULL OR locality_name = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Nazwa miejscowosci nie może być pusta!';
	END IF;
	
	-- Sprawdzenie czy podana gmina istnieje
	IF NOT EXISTS (
		SELECT * 
		FROM administrative_units AS au 
		WHERE au.administrative_unit_id = municipality_id AND au.`type` = 'gmina'
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Podana gmina nie istnieje!';
	END IF;
	
	-- Sprawdzenie, czy dana miejscowość znajduje się w województwie zarządzanym przez użytkownika
	IF NOT EXISTS (
		SELECT *
		FROM user_permissions AS up
		JOIN administrative_units AS v ON v.administrative_unit_id = up.voivodship_id
		JOIN administrative_units AS c ON c.superior_administrative_unit = v.administrative_unit_id
		JOIN administrative_units AS m ON m.superior_administrative_unit = c.administrative_unit_id
		WHERE m.administrative_unit_id = municipality_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Brak uprawnień do dodawania miejscowości w tej gminie!';
	END IF;
	
	-- Sprawdzenie czy podany typ miejscowości istnieje
	IF NOT EXISTS (
		SELECT *
		FROM locality_types AS lt
		WHERE lt.locality_type_id = locality_type_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Podany typ miejscowości nie istnieje!';
	END IF;
	
	-- Dodanie miejscowości
	INSERT INTO localities (
		`name`,
		`DESCRIPTION`,
		population,
		municipality_id,
		latitude,
		longitude,
		locality_type_id
	) 
	VALUES (
		locality_name,
		locality_desc,
		pop,
		municipality_id,
		latitude,
		longitude,
		locality_type_id
	);

END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.administrative_units
CREATE TABLE IF NOT EXISTS `administrative_units` (
  `administrative_unit_id` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `type` varchar(30) NOT NULL,
  `superior_administrative_unit` int(10) DEFAULT NULL,
  PRIMARY KEY (`administrative_unit_id`),
  KEY `superior_administrative_unit` (`superior_administrative_unit`),
  CONSTRAINT `FKAdministra497736` FOREIGN KEY (`superior_administrative_unit`) REFERENCES `administrative_units` (`administrative_unit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.administrative_units: ~2 873 rows (około)
INSERT INTO `administrative_units` (`administrative_unit_id`, `name`, `type`, `superior_administrative_unit`) VALUES
	(20000, 'Dolnośląskie', 'województwo', NULL),
	(20100, 'Bolesławiecki', 'powiat', 20000),
	(20101, 'Bolesławiec (miasto)', 'gmina', 20100),
	(20102, 'Bolesławiec', 'gmina', 20100),
	(20103, 'Gromadka', 'gmina', 20100),
	(20104, 'Nowogrodziec', 'gmina', 20100),
	(20105, 'Osiecznica', 'gmina', 20100),
	(20106, 'Warta Bolesławiecka', 'gmina', 20100),
	(20200, 'Dzierżoniowski', 'powiat', 20000),
	(20201, 'Bielawa (miasto)', 'gmina', 20200),
	(20202, 'Dzierżoniów (miasto)', 'gmina', 20200),
	(20203, 'Pieszyce', 'gmina', 20200),
	(20204, 'Piława Górna (miasto)', 'gmina', 20200),
	(20205, 'Dzierżoniów', 'gmina', 20200),
	(20206, 'Łagiewniki', 'gmina', 20200),
	(20207, 'Niemcza', 'gmina', 20200),
	(20300, 'Głogowski', 'powiat', 20000),
	(20301, 'Głogów (miasto)', 'gmina', 20300),
	(20302, 'Głogów', 'gmina', 20300),
	(20303, 'Jerzmanowa', 'gmina', 20300),
	(20304, 'Kotla', 'gmina', 20300),
	(20305, 'Pęcław', 'gmina', 20300),
	(20306, 'Żukowice', 'gmina', 20300),
	(20400, 'Górowski', 'powiat', 20000),
	(20401, 'Góra', 'gmina', 20400),
	(20402, 'Jemielno', 'gmina', 20400),
	(20403, 'Niechlów', 'gmina', 20400),
	(20404, 'Wąsosz', 'gmina', 20400),
	(20500, 'Jaworski', 'powiat', 20000),
	(20501, 'Jawor (miasto)', 'gmina', 20500),
	(20502, 'Bolków', 'gmina', 20500),
	(20503, 'Męcinka', 'gmina', 20500),
	(20504, 'Mściwojów', 'gmina', 20500),
	(20505, 'Paszowice', 'gmina', 20500),
	(20506, 'Wądroże Wielkie', 'gmina', 20500),
	(20600, 'Karkonoski', 'powiat', 20000),
	(20601, 'Karpacz (miasto)', 'gmina', 20600),
	(20602, 'Kowary (miasto)', 'gmina', 20600),
	(20603, 'Piechowice (miasto)', 'gmina', 20600),
	(20604, 'Szklarska Poręba (miasto)', 'gmina', 20600),
	(20605, 'Janowice Wielkie', 'gmina', 20600),
	(20606, 'Jeżów Sudecki', 'gmina', 20600),
	(20607, 'Mysłakowice', 'gmina', 20600),
	(20608, 'Podgórzyn', 'gmina', 20600),
	(20609, 'Stara Kamienica', 'gmina', 20600),
	(20700, 'Kamiennogórski', 'powiat', 20000),
	(20701, 'Kamienna Góra (miasto)', 'gmina', 20700),
	(20702, 'Kamienna Góra', 'gmina', 20700),
	(20703, 'Lubawka', 'gmina', 20700),
	(20704, 'Marciszów', 'gmina', 20700),
	(20800, 'Kłodzki', 'powiat', 20000),
	(20801, 'Duszniki-Zdrój (miasto)', 'gmina', 20800),
	(20802, 'Kłodzko (miasto)', 'gmina', 20800),
	(20803, 'Kudowa-Zdrój (miasto)', 'gmina', 20800),
	(20804, 'Nowa Ruda (miasto)', 'gmina', 20800),
	(20805, 'Polanica-Zdrój (miasto)', 'gmina', 20800),
	(20806, 'Bystrzyca Kłodzka', 'gmina', 20800),
	(20807, 'Kłodzko', 'gmina', 20800),
	(20808, 'Lądek-Zdrój', 'gmina', 20800),
	(20809, 'Lewin Kłodzki', 'gmina', 20800),
	(20810, 'Międzylesie', 'gmina', 20800),
	(20811, 'Nowa Ruda', 'gmina', 20800),
	(20812, 'Radków', 'gmina', 20800),
	(20813, 'Stronie Śląskie', 'gmina', 20800),
	(20814, 'Szczytna', 'gmina', 20800),
	(20900, 'Legnicki', 'powiat', 20000),
	(20901, 'Chojnów (miasto)', 'gmina', 20900),
	(20902, 'Chojnów', 'gmina', 20900),
	(20903, 'Krotoszyce', 'gmina', 20900),
	(20904, 'Kunice', 'gmina', 20900),
	(20905, 'Legnickie Pole', 'gmina', 20900),
	(20906, 'Miłkowice', 'gmina', 20900),
	(20907, 'Prochowice', 'gmina', 20900),
	(20908, 'Ruja', 'gmina', 20900),
	(21000, 'Lubański', 'powiat', 20000),
	(21001, 'Lubań (miasto)', 'gmina', 21000),
	(21002, 'Świeradów-Zdrój (miasto)', 'gmina', 21000),
	(21003, 'Leśna', 'gmina', 21000),
	(21004, 'Lubań', 'gmina', 21000),
	(21005, 'Olszyna', 'gmina', 21000),
	(21006, 'Platerówka', 'gmina', 21000),
	(21007, 'Siekierczyn', 'gmina', 21000),
	(21100, 'Lubiński', 'powiat', 20000),
	(21101, 'Lubin (miasto)', 'gmina', 21100),
	(21102, 'Lubin', 'gmina', 21100),
	(21103, 'Rudna', 'gmina', 21100),
	(21104, 'Ścinawa', 'gmina', 21100),
	(21200, 'Lwówecki', 'powiat', 20000),
	(21201, 'Gryfów Śląski', 'gmina', 21200),
	(21202, 'Lubomierz', 'gmina', 21200),
	(21203, 'Lwówek Śląski', 'gmina', 21200),
	(21204, 'Mirsk', 'gmina', 21200),
	(21205, 'Wleń', 'gmina', 21200),
	(21300, 'Milicki', 'powiat', 20000),
	(21301, 'Cieszków', 'gmina', 21300),
	(21302, 'Krośnice', 'gmina', 21300),
	(21303, 'Milicz', 'gmina', 21300),
	(21400, 'Oleśnicki', 'powiat', 20000),
	(21401, 'Oleśnica (miasto)', 'gmina', 21400),
	(21402, 'Bierutów', 'gmina', 21400),
	(21403, 'Dobroszyce', 'gmina', 21400),
	(21404, 'Dziadowa Kłoda', 'gmina', 21400),
	(21405, 'Międzybórz', 'gmina', 21400),
	(21406, 'Oleśnica', 'gmina', 21400),
	(21407, 'Syców', 'gmina', 21400),
	(21408, 'Twardogóra', 'gmina', 21400),
	(21500, 'Oławski', 'powiat', 20000),
	(21501, 'Oława (miasto)', 'gmina', 21500),
	(21502, 'Domaniów', 'gmina', 21500),
	(21503, 'Jelcz-Laskowice', 'gmina', 21500),
	(21504, 'Oława', 'gmina', 21500),
	(21600, 'Polkowicki', 'powiat', 20000),
	(21601, 'Chocianów', 'gmina', 21600),
	(21602, 'Gaworzyce', 'gmina', 21600),
	(21603, 'Grębocice', 'gmina', 21600),
	(21604, 'Polkowice', 'gmina', 21600),
	(21605, 'Przemków', 'gmina', 21600),
	(21606, 'Radwanice', 'gmina', 21600),
	(21700, 'Strzeliński', 'powiat', 20000),
	(21701, 'Borów', 'gmina', 21700),
	(21702, 'Kondratowice', 'gmina', 21700),
	(21703, 'Przeworno', 'gmina', 21700),
	(21704, 'Strzelin', 'gmina', 21700),
	(21705, 'Wiązów', 'gmina', 21700),
	(21800, 'Średzki', 'powiat', 20000),
	(21801, 'Kostomłoty', 'gmina', 21800),
	(21802, 'Malczyce', 'gmina', 21800),
	(21803, 'Miękinia', 'gmina', 21800),
	(21804, 'Środa Śląska', 'gmina', 21800),
	(21805, 'Udanin', 'gmina', 21800),
	(21900, 'Świdnicki', 'powiat', 20000),
	(21901, 'Świdnica (miasto)', 'gmina', 21900),
	(21902, 'Świebodzice (miasto)', 'gmina', 21900),
	(21903, 'Dobromierz', 'gmina', 21900),
	(21904, 'Jaworzyna Śląska', 'gmina', 21900),
	(21905, 'Marcinowice', 'gmina', 21900),
	(21906, 'Strzegom', 'gmina', 21900),
	(21907, 'Świdnica', 'gmina', 21900),
	(21908, 'Żarów', 'gmina', 21900),
	(22000, 'Trzebnicki', 'powiat', 20000),
	(22001, 'Oborniki Śląskie', 'gmina', 22000),
	(22002, 'Prusice', 'gmina', 22000),
	(22003, 'Trzebnica', 'gmina', 22000),
	(22004, 'Wisznia Mała', 'gmina', 22000),
	(22005, 'Zawonia', 'gmina', 22000),
	(22006, 'Żmigród', 'gmina', 22000),
	(22100, 'Wałbrzyski', 'powiat', 20000),
	(22101, 'Boguszów-Gorce (miasto)', 'gmina', 22100),
	(22102, 'Jedlina-Zdrój (miasto)', 'gmina', 22100),
	(22103, 'Szczawno-Zdrój (miasto)', 'gmina', 22100),
	(22104, 'Czarny Bór', 'gmina', 22100),
	(22105, 'Głuszyca', 'gmina', 22100),
	(22106, 'Mieroszów', 'gmina', 22100),
	(22107, 'Stare Bogaczowice', 'gmina', 22100),
	(22108, 'Walim', 'gmina', 22100),
	(22200, 'Wołowski', 'powiat', 20000),
	(22201, 'Brzeg Dolny', 'gmina', 22200),
	(22202, 'Wińsko', 'gmina', 22200),
	(22203, 'Wołów', 'gmina', 22200),
	(22300, 'Wrocławski', 'powiat', 20000),
	(22301, 'Czernica', 'gmina', 22300),
	(22302, 'Długołęka', 'gmina', 22300),
	(22303, 'Jordanów Śląski', 'gmina', 22300),
	(22304, 'Kąty Wrocławskie', 'gmina', 22300),
	(22305, 'Kobierzyce', 'gmina', 22300),
	(22306, 'Mietków', 'gmina', 22300),
	(22307, 'Sobótka', 'gmina', 22300),
	(22308, 'Siechnice', 'gmina', 22300),
	(22309, 'Żórawina', 'gmina', 22300),
	(22400, 'Ząbkowicki', 'powiat', 20000),
	(22401, 'Bardo', 'gmina', 22400),
	(22402, 'Ciepłowody', 'gmina', 22400),
	(22403, 'Kamieniec Ząbkowicki', 'gmina', 22400),
	(22404, 'Stoszowice', 'gmina', 22400),
	(22405, 'Ząbkowice Śląskie', 'gmina', 22400),
	(22406, 'Ziębice', 'gmina', 22400),
	(22407, 'Złoty Stok', 'gmina', 22400),
	(22500, 'Zgorzelecki', 'powiat', 20000),
	(22501, 'Zawidów (miasto)', 'gmina', 22500),
	(22502, 'Zgorzelec (miasto)', 'gmina', 22500),
	(22503, 'Bogatynia', 'gmina', 22500),
	(22504, 'Pieńsk', 'gmina', 22500),
	(22505, 'Sulików', 'gmina', 22500),
	(22506, 'Węgliniec', 'gmina', 22500),
	(22507, 'Zgorzelec', 'gmina', 22500),
	(22600, 'Złotoryjski', 'powiat', 20000),
	(22601, 'Wojcieszów (miasto)', 'gmina', 22600),
	(22602, 'Złotoryja (miasto)', 'gmina', 22600),
	(22603, 'Pielgrzymka', 'gmina', 22600),
	(22604, 'Świerzawa', 'gmina', 22600),
	(22605, 'Zagrodno', 'gmina', 22600),
	(22606, 'Złotoryja', 'gmina', 22600),
	(26100, 'Jelenia Góra (miasto)', 'powiat', 20000),
	(26101, 'Jelenia Góra (miasto)', 'gmina', 26100),
	(26200, 'Legnica (miasto)', 'powiat', 20000),
	(26201, 'Legnica (miasto)', 'gmina', 26200),
	(26400, 'Wrocław (miasto)', 'powiat', 20000),
	(26401, 'Wrocław (miasto)', 'gmina', 26400),
	(26500, 'Wałbrzych (miasto)', 'powiat', 20000),
	(26501, 'Wałbrzych (miasto)', 'gmina', 26500),
	(40000, 'Kujawsko-Pomorskie', 'województwo', NULL),
	(40100, 'Aleksandrowski', 'powiat', 40000),
	(40101, 'Aleksandrów Kujawski (miasto)', 'gmina', 40100),
	(40102, 'Ciechocinek (miasto)', 'gmina', 40100),
	(40103, 'Nieszawa (miasto)', 'gmina', 40100),
	(40104, 'Aleksandrów Kujawski', 'gmina', 40100),
	(40105, 'Bądkowo', 'gmina', 40100),
	(40106, 'Koneck', 'gmina', 40100),
	(40107, 'Raciążek', 'gmina', 40100),
	(40108, 'Waganiec', 'gmina', 40100),
	(40109, 'Zakrzewo', 'gmina', 40100),
	(40200, 'Brodnicki', 'powiat', 40000),
	(40201, 'Brodnica (miasto)', 'gmina', 40200),
	(40202, 'Bobrowo', 'gmina', 40200),
	(40203, 'Brodnica', 'gmina', 40200),
	(40204, 'Brzozie', 'gmina', 40200),
	(40205, 'Górzno', 'gmina', 40200),
	(40206, 'Bartniczka', 'gmina', 40200),
	(40207, 'Jabłonowo Pomorskie', 'gmina', 40200),
	(40208, 'Osiek', 'gmina', 40200),
	(40209, 'Świedziebnia', 'gmina', 40200),
	(40210, 'Zbiczno', 'gmina', 40200),
	(40300, 'Bydgoski', 'powiat', 40000),
	(40301, 'Białe Błota', 'gmina', 40300),
	(40302, 'Dąbrowa Chełmińska', 'gmina', 40300),
	(40303, 'Dobrcz', 'gmina', 40300),
	(40304, 'Koronowo', 'gmina', 40300),
	(40305, 'Nowa Wieś Wielka', 'gmina', 40300),
	(40306, 'Osielsko', 'gmina', 40300),
	(40307, 'Sicienko', 'gmina', 40300),
	(40308, 'Solec Kujawski', 'gmina', 40300),
	(40400, 'Chełmiński', 'powiat', 40000),
	(40401, 'Chełmno (miasto)', 'gmina', 40400),
	(40402, 'Chełmno', 'gmina', 40400),
	(40403, 'Kijewo Królewskie', 'gmina', 40400),
	(40404, 'Lisewo', 'gmina', 40400),
	(40405, 'Papowo Biskupie', 'gmina', 40400),
	(40406, 'Stolno', 'gmina', 40400),
	(40407, 'Unisław', 'gmina', 40400),
	(40500, 'Golubsko-Dobrzyński', 'powiat', 40000),
	(40501, 'Golub-Dobrzyń (miasto)', 'gmina', 40500),
	(40502, 'Ciechocin', 'gmina', 40500),
	(40503, 'Golub-Dobrzyń', 'gmina', 40500),
	(40504, 'Kowalewo Pomorskie', 'gmina', 40500),
	(40505, 'Radomin', 'gmina', 40500),
	(40506, 'Zbójno', 'gmina', 40500),
	(40600, 'Grudziądzki', 'powiat', 40000),
	(40601, 'Grudziądz', 'gmina', 40600),
	(40602, 'Gruta', 'gmina', 40600),
	(40603, 'Łasin', 'gmina', 40600),
	(40604, 'Radzyń Chełmiński', 'gmina', 40600),
	(40605, 'Rogóźno', 'gmina', 40600),
	(40606, 'Świecie Nad Osą', 'gmina', 40600),
	(40700, 'Inowrocławski', 'powiat', 40000),
	(40701, 'Inowrocław (miasto)', 'gmina', 40700),
	(40702, 'Dąbrowa Biskupia', 'gmina', 40700),
	(40703, 'Gniewkowo', 'gmina', 40700),
	(40704, 'Inowrocław', 'gmina', 40700),
	(40705, 'Janikowo', 'gmina', 40700),
	(40706, 'Kruszwica', 'gmina', 40700),
	(40707, 'Pakość', 'gmina', 40700),
	(40708, 'Rojewo', 'gmina', 40700),
	(40709, 'Złotniki Kujawskie', 'gmina', 40700),
	(40800, 'Lipnowski', 'powiat', 40000),
	(40801, 'Lipno (miasto)', 'gmina', 40800),
	(40802, 'Bobrowniki', 'gmina', 40800),
	(40803, 'Chrostkowo', 'gmina', 40800),
	(40804, 'Dobrzyń Nad Wisłą', 'gmina', 40800),
	(40805, 'Kikół', 'gmina', 40800),
	(40806, 'Lipno', 'gmina', 40800),
	(40807, 'Skępe', 'gmina', 40800),
	(40808, 'Tłuchowo', 'gmina', 40800),
	(40809, 'Wielgie', 'gmina', 40800),
	(40900, 'Mogileński', 'powiat', 40000),
	(40901, 'Dąbrowa', 'gmina', 40900),
	(40902, 'Jeziora Wielkie', 'gmina', 40900),
	(40903, 'Mogilno', 'gmina', 40900),
	(40904, 'Strzelno', 'gmina', 40900),
	(41000, 'Nakielski', 'powiat', 40000),
	(41001, 'Kcynia', 'gmina', 41000),
	(41002, 'Mrocza', 'gmina', 41000),
	(41003, 'Nakło Nad Notecią', 'gmina', 41000),
	(41004, 'Sadki', 'gmina', 41000),
	(41005, 'Szubin', 'gmina', 41000),
	(41100, 'Radziejowski', 'powiat', 40000),
	(41101, 'Radziejów (miasto)', 'gmina', 41100),
	(41102, 'Bytoń', 'gmina', 41100),
	(41103, 'Dobre', 'gmina', 41100),
	(41104, 'Osięciny', 'gmina', 41100),
	(41105, 'Piotrków Kujawski', 'gmina', 41100),
	(41106, 'Radziejów', 'gmina', 41100),
	(41107, 'Topólka', 'gmina', 41100),
	(41200, 'Rypiński', 'powiat', 40000),
	(41201, 'Rypin (miasto)', 'gmina', 41200),
	(41202, 'Brzuze', 'gmina', 41200),
	(41203, 'Rogowo', 'gmina', 41200),
	(41204, 'Rypin', 'gmina', 41200),
	(41205, 'Skrwilno', 'gmina', 41200),
	(41206, 'Wąpielsk', 'gmina', 41200),
	(41300, 'Sępoleński', 'powiat', 40000),
	(41301, 'Kamień Krajeński', 'gmina', 41300),
	(41302, 'Sępólno Krajeńskie', 'gmina', 41300),
	(41303, 'Sośno', 'gmina', 41300),
	(41304, 'Więcbork', 'gmina', 41300),
	(41400, 'Świecki', 'powiat', 40000),
	(41401, 'Bukowiec', 'gmina', 41400),
	(41402, 'Dragacz', 'gmina', 41400),
	(41403, 'Drzycim', 'gmina', 41400),
	(41404, 'Jeżewo', 'gmina', 41400),
	(41405, 'Lniano', 'gmina', 41400),
	(41406, 'Nowe', 'gmina', 41400),
	(41407, 'Osie', 'gmina', 41400),
	(41408, 'Pruszcz', 'gmina', 41400),
	(41409, 'Świecie', 'gmina', 41400),
	(41410, 'Świekatowo', 'gmina', 41400),
	(41411, 'Warlubie', 'gmina', 41400),
	(41500, 'Toruński', 'powiat', 40000),
	(41501, 'Chełmża (miasto)', 'gmina', 41500),
	(41502, 'Chełmża', 'gmina', 41500),
	(41503, 'Czernikowo', 'gmina', 41500),
	(41504, 'Lubicz', 'gmina', 41500),
	(41505, 'Łubianka', 'gmina', 41500),
	(41506, 'Łysomice', 'gmina', 41500),
	(41507, 'Obrowo', 'gmina', 41500),
	(41508, 'Wielka Nieszawka', 'gmina', 41500),
	(41509, 'Zławieś Wielka', 'gmina', 41500),
	(41600, 'Tucholski', 'powiat', 40000),
	(41601, 'Cekcyn', 'gmina', 41600),
	(41602, 'Gostycyn', 'gmina', 41600),
	(41603, 'Kęsowo', 'gmina', 41600),
	(41604, 'Lubiewo', 'gmina', 41600),
	(41605, 'Śliwice', 'gmina', 41600),
	(41606, 'Tuchola', 'gmina', 41600),
	(41700, 'Wąbrzeski', 'powiat', 40000),
	(41701, 'Wąbrzeźno (miasto)', 'gmina', 41700),
	(41702, 'Dębowa Łąka', 'gmina', 41700),
	(41703, 'Książki', 'gmina', 41700),
	(41704, 'Płużnica', 'gmina', 41700),
	(41705, 'Ryńsk', 'gmina', 41700),
	(41800, 'Włocławski', 'powiat', 40000),
	(41801, 'Kowal (miasto)', 'gmina', 41800),
	(41802, 'Baruchowo', 'gmina', 41800),
	(41803, 'Boniewo', 'gmina', 41800),
	(41804, 'Brześć Kujawski', 'gmina', 41800),
	(41805, 'Choceń', 'gmina', 41800),
	(41806, 'Chodecz', 'gmina', 41800),
	(41807, 'Fabianki', 'gmina', 41800),
	(41808, 'Izbica Kujawska', 'gmina', 41800),
	(41809, 'Kowal', 'gmina', 41800),
	(41810, 'Lubanie', 'gmina', 41800),
	(41811, 'Lubień Kujawski', 'gmina', 41800),
	(41812, 'Lubraniec', 'gmina', 41800),
	(41813, 'Włocławek', 'gmina', 41800),
	(41900, 'Żniński', 'powiat', 40000),
	(41901, 'Barcin', 'gmina', 41900),
	(41902, 'Gąsawa', 'gmina', 41900),
	(41903, 'Janowiec Wielkopolski', 'gmina', 41900),
	(41904, 'Łabiszyn', 'gmina', 41900),
	(41905, 'Rogowo', 'gmina', 41900),
	(41906, 'Żnin', 'gmina', 41900),
	(46100, 'Bydgoszcz (miasto)', 'powiat', 40000),
	(46101, 'Bydgoszcz (miasto)', 'gmina', 46100),
	(46200, 'Grudziądz (miasto)', 'powiat', 40000),
	(46201, 'Grudziądz (miasto)', 'gmina', 46200),
	(46300, 'Toruń (miasto)', 'powiat', 40000),
	(46301, 'Toruń (miasto)', 'gmina', 46300),
	(46400, 'Włocławek (miasto)', 'powiat', 40000),
	(46401, 'Włocławek (miasto)', 'gmina', 46400),
	(60000, 'Lubelskie', 'województwo', NULL),
	(60100, 'Bialski', 'powiat', 60000),
	(60101, 'Międzyrzec Podlaski (miasto)', 'gmina', 60100),
	(60102, 'Terespol (miasto)', 'gmina', 60100),
	(60103, 'Biała Podlaska', 'gmina', 60100),
	(60104, 'Drelów', 'gmina', 60100),
	(60105, 'Janów Podlaski', 'gmina', 60100),
	(60106, 'Kodeń', 'gmina', 60100),
	(60107, 'Konstantynów', 'gmina', 60100),
	(60108, 'Leśna Podlaska', 'gmina', 60100),
	(60109, 'Łomazy', 'gmina', 60100),
	(60110, 'Międzyrzec Podlaski', 'gmina', 60100),
	(60111, 'Piszczac', 'gmina', 60100),
	(60112, 'Rokitno', 'gmina', 60100),
	(60113, 'Rossosz', 'gmina', 60100),
	(60114, 'Sławatycze', 'gmina', 60100),
	(60115, 'Sosnówka', 'gmina', 60100),
	(60116, 'Terespol', 'gmina', 60100),
	(60117, 'Tuczna', 'gmina', 60100),
	(60118, 'Wisznice', 'gmina', 60100),
	(60119, 'Zalesie', 'gmina', 60100),
	(60200, 'Biłgorajski', 'powiat', 60000),
	(60201, 'Biłgoraj (miasto)', 'gmina', 60200),
	(60202, 'Aleksandrów', 'gmina', 60200),
	(60203, 'Biłgoraj', 'gmina', 60200),
	(60204, 'Biszcza', 'gmina', 60200),
	(60205, 'Frampol', 'gmina', 60200),
	(60206, 'Goraj', 'gmina', 60200),
	(60207, 'Józefów', 'gmina', 60200),
	(60208, 'Księżpol', 'gmina', 60200),
	(60209, 'Łukowa', 'gmina', 60200),
	(60210, 'Obsza', 'gmina', 60200),
	(60211, 'Potok Górny', 'gmina', 60200),
	(60212, 'Tarnogród', 'gmina', 60200),
	(60213, 'Tereszpol', 'gmina', 60200),
	(60214, 'Turobin', 'gmina', 60200),
	(60300, 'Chełmski', 'powiat', 60000),
	(60301, 'Rejowiec Fabryczny (miasto)', 'gmina', 60300),
	(60302, 'Białopole', 'gmina', 60300),
	(60303, 'Chełm', 'gmina', 60300),
	(60304, 'Dorohusk', 'gmina', 60300),
	(60305, 'Dubienka', 'gmina', 60300),
	(60306, 'Kamień', 'gmina', 60300),
	(60307, 'Leśniowice', 'gmina', 60300),
	(60308, 'Rejowiec Fabryczny', 'gmina', 60300),
	(60309, 'Ruda-Huta', 'gmina', 60300),
	(60310, 'Sawin', 'gmina', 60300),
	(60311, 'Siedliszcze', 'gmina', 60300),
	(60312, 'Wierzbica', 'gmina', 60300),
	(60313, 'Wojsławice', 'gmina', 60300),
	(60314, 'Żmudź', 'gmina', 60300),
	(60315, 'Rejowiec', 'gmina', 60300),
	(60400, 'Hrubieszowski', 'powiat', 60000),
	(60401, 'Hrubieszów (miasto)', 'gmina', 60400),
	(60402, 'Dołhobyczów', 'gmina', 60400),
	(60403, 'Horodło', 'gmina', 60400),
	(60404, 'Hrubieszów', 'gmina', 60400),
	(60405, 'Mircze', 'gmina', 60400),
	(60406, 'Trzeszczany', 'gmina', 60400),
	(60407, 'Uchanie', 'gmina', 60400),
	(60408, 'Werbkowice', 'gmina', 60400),
	(60500, 'Janowski', 'powiat', 60000),
	(60501, 'Batorz', 'gmina', 60500),
	(60502, 'Chrzanów', 'gmina', 60500),
	(60503, 'Dzwola', 'gmina', 60500),
	(60504, 'Godziszów', 'gmina', 60500),
	(60505, 'Janów Lubelski', 'gmina', 60500),
	(60506, 'Modliborzyce', 'gmina', 60500),
	(60507, 'Potok Wielki', 'gmina', 60500),
	(60600, 'Krasnostawski', 'powiat', 60000),
	(60601, 'Krasnystaw (miasto)', 'gmina', 60600),
	(60602, 'Fajsławice', 'gmina', 60600),
	(60603, 'Gorzków', 'gmina', 60600),
	(60604, 'Izbica', 'gmina', 60600),
	(60605, 'Krasnystaw', 'gmina', 60600),
	(60606, 'Kraśniczyn', 'gmina', 60600),
	(60607, 'Łopiennik Górny', 'gmina', 60600),
	(60609, 'Rudnik', 'gmina', 60600),
	(60610, 'Siennica Różana', 'gmina', 60600),
	(60611, 'Żółkiewka', 'gmina', 60600),
	(60700, 'Kraśnicki', 'powiat', 60000),
	(60701, 'Kraśnik (miasto)', 'gmina', 60700),
	(60702, 'Annopol', 'gmina', 60700),
	(60703, 'Dzierzkowice', 'gmina', 60700),
	(60704, 'Gościeradów', 'gmina', 60700),
	(60705, 'Kraśnik', 'gmina', 60700),
	(60706, 'Szastarka', 'gmina', 60700),
	(60707, 'Trzydnik Duży', 'gmina', 60700),
	(60708, 'Urzędów', 'gmina', 60700),
	(60709, 'Wilkołaz', 'gmina', 60700),
	(60710, 'Zakrzówek', 'gmina', 60700),
	(60800, 'Lubartowski', 'powiat', 60000),
	(60801, 'Lubartów (miasto)', 'gmina', 60800),
	(60802, 'Abramów', 'gmina', 60800),
	(60803, 'Firlej', 'gmina', 60800),
	(60804, 'Jeziorzany', 'gmina', 60800),
	(60805, 'Kamionka', 'gmina', 60800),
	(60806, 'Kock', 'gmina', 60800),
	(60807, 'Lubartów', 'gmina', 60800),
	(60808, 'Michów', 'gmina', 60800),
	(60809, 'Niedźwiada', 'gmina', 60800),
	(60810, 'Ostrów Lubelski', 'gmina', 60800),
	(60811, 'Ostrówek', 'gmina', 60800),
	(60812, 'Serniki', 'gmina', 60800),
	(60813, 'Uścimów', 'gmina', 60800),
	(60900, 'Lubelski', 'powiat', 60000),
	(60901, 'Bełżyce', 'gmina', 60900),
	(60902, 'Borzechów', 'gmina', 60900),
	(60903, 'Bychawa', 'gmina', 60900),
	(60904, 'Garbów', 'gmina', 60900),
	(60905, 'Głusk', 'gmina', 60900),
	(60906, 'Jabłonna', 'gmina', 60900),
	(60907, 'Jastków', 'gmina', 60900),
	(60908, 'Konopnica', 'gmina', 60900),
	(60909, 'Krzczonów', 'gmina', 60900),
	(60910, 'Niedrzwica Duża', 'gmina', 60900),
	(60911, 'Niemce', 'gmina', 60900),
	(60912, 'Strzyżewice', 'gmina', 60900),
	(60913, 'Wojciechów', 'gmina', 60900),
	(60914, 'Wólka', 'gmina', 60900),
	(60915, 'Wysokie', 'gmina', 60900),
	(60916, 'Zakrzew', 'gmina', 60900),
	(61000, 'Łęczyński', 'powiat', 60000),
	(61001, 'Cyców', 'gmina', 61000),
	(61002, 'Ludwin', 'gmina', 61000),
	(61003, 'Łęczna', 'gmina', 61000),
	(61004, 'Milejów', 'gmina', 61000),
	(61005, 'Puchaczów', 'gmina', 61000),
	(61006, 'Spiczyn', 'gmina', 61000),
	(61100, 'Łukowski', 'powiat', 60000),
	(61101, 'Łuków (miasto)', 'gmina', 61100),
	(61102, 'Stoczek Łukowski (miasto)', 'gmina', 61100),
	(61103, 'Adamów', 'gmina', 61100),
	(61104, 'Krzywda', 'gmina', 61100),
	(61105, 'Łuków', 'gmina', 61100),
	(61106, 'Serokomla', 'gmina', 61100),
	(61107, 'Stanin', 'gmina', 61100),
	(61108, 'Stoczek Łukowski', 'gmina', 61100),
	(61109, 'Trzebieszów', 'gmina', 61100),
	(61110, 'Wojcieszków', 'gmina', 61100),
	(61111, 'Wola Mysłowska', 'gmina', 61100),
	(61200, 'Opolski', 'powiat', 60000),
	(61201, 'Chodel', 'gmina', 61200),
	(61202, 'Józefów Nad Wisłą', 'gmina', 61200),
	(61203, 'Karczmiska', 'gmina', 61200),
	(61204, 'Łaziska', 'gmina', 61200),
	(61205, 'Opole Lubelskie', 'gmina', 61200),
	(61206, 'Poniatowa', 'gmina', 61200),
	(61207, 'Wilków', 'gmina', 61200),
	(61300, 'Parczewski', 'powiat', 60000),
	(61301, 'Dębowa Kłoda', 'gmina', 61300),
	(61302, 'Jabłoń', 'gmina', 61300),
	(61303, 'Milanów', 'gmina', 61300),
	(61304, 'Parczew', 'gmina', 61300),
	(61305, 'Podedwórze', 'gmina', 61300),
	(61306, 'Siemień', 'gmina', 61300),
	(61307, 'Sosnowica', 'gmina', 61300),
	(61400, 'Puławski', 'powiat', 60000),
	(61401, 'Puławy (miasto)', 'gmina', 61400),
	(61402, 'Baranów', 'gmina', 61400),
	(61403, 'Janowiec', 'gmina', 61400),
	(61404, 'Kazimierz Dolny', 'gmina', 61400),
	(61405, 'Końskowola', 'gmina', 61400),
	(61406, 'Kurów', 'gmina', 61400),
	(61407, 'Markuszów', 'gmina', 61400),
	(61408, 'Nałęczów', 'gmina', 61400),
	(61409, 'Puławy', 'gmina', 61400),
	(61410, 'Wąwolnica', 'gmina', 61400),
	(61411, 'Żyrzyn', 'gmina', 61400),
	(61500, 'Radzyński', 'powiat', 60000),
	(61501, 'Radzyń Podlaski (miasto)', 'gmina', 61500),
	(61502, 'Borki', 'gmina', 61500),
	(61503, 'Czemierniki', 'gmina', 61500),
	(61504, 'Kąkolewnica', 'gmina', 61500),
	(61505, 'Komarówka Podlaska', 'gmina', 61500),
	(61506, 'Radzyń Podlaski', 'gmina', 61500),
	(61507, 'Ulan-Majorat', 'gmina', 61500),
	(61508, 'Wohyń', 'gmina', 61500),
	(61600, 'Rycki', 'powiat', 60000),
	(61601, 'Dęblin (miasto)', 'gmina', 61600),
	(61602, 'Kłoczew', 'gmina', 61600),
	(61603, 'Nowodwór', 'gmina', 61600),
	(61604, 'Ryki', 'gmina', 61600),
	(61605, 'Stężyca', 'gmina', 61600),
	(61606, 'Ułęż', 'gmina', 61600),
	(61700, 'Świdnicki', 'powiat', 60000),
	(61701, 'Świdnik (miasto)', 'gmina', 61700),
	(61702, 'Mełgiew', 'gmina', 61700),
	(61703, 'Piaski', 'gmina', 61700),
	(61704, 'Rybczewice', 'gmina', 61700),
	(61705, 'Trawniki', 'gmina', 61700),
	(61800, 'Tomaszowski', 'powiat', 60000),
	(61801, 'Tomaszów Lubelski (miasto)', 'gmina', 61800),
	(61802, 'Bełżec', 'gmina', 61800),
	(61803, 'Jarczów', 'gmina', 61800),
	(61804, 'Krynice', 'gmina', 61800),
	(61805, 'Lubycza Królewska', 'gmina', 61800),
	(61806, 'Łaszczów', 'gmina', 61800),
	(61807, 'Rachanie', 'gmina', 61800),
	(61808, 'Susiec', 'gmina', 61800),
	(61809, 'Tarnawatka', 'gmina', 61800),
	(61810, 'Telatyn', 'gmina', 61800),
	(61811, 'Tomaszów Lubelski', 'gmina', 61800),
	(61812, 'Tyszowce', 'gmina', 61800),
	(61813, 'Ulhówek', 'gmina', 61800),
	(61900, 'Włodawski', 'powiat', 60000),
	(61901, 'Włodawa (miasto)', 'gmina', 61900),
	(61902, 'Hanna', 'gmina', 61900),
	(61903, 'Hańsk', 'gmina', 61900),
	(61904, 'Stary Brus', 'gmina', 61900),
	(61905, 'Urszulin', 'gmina', 61900),
	(61906, 'Włodawa', 'gmina', 61900),
	(61907, 'Wola Uhruska', 'gmina', 61900),
	(61908, 'Wyryki', 'gmina', 61900),
	(62000, 'Zamojski', 'powiat', 60000),
	(62001, 'Adamów', 'gmina', 62000),
	(62002, 'Grabowiec', 'gmina', 62000),
	(62003, 'Komarów-Osada', 'gmina', 62000),
	(62004, 'Krasnobród', 'gmina', 62000),
	(62005, 'Łabunie', 'gmina', 62000),
	(62006, 'Miączyn', 'gmina', 62000),
	(62007, 'Nielisz', 'gmina', 62000),
	(62008, 'Radecznica', 'gmina', 62000),
	(62009, 'Sitno', 'gmina', 62000),
	(62010, 'Skierbieszów', 'gmina', 62000),
	(62011, 'Stary Zamość', 'gmina', 62000),
	(62012, 'Sułów', 'gmina', 62000),
	(62013, 'Szczebrzeszyn', 'gmina', 62000),
	(62014, 'Zamość', 'gmina', 62000),
	(62015, 'Zwierzyniec', 'gmina', 62000),
	(66100, 'Biała Podlaska (miasto)', 'powiat', 60000),
	(66101, 'Biała Podlaska (miasto)', 'gmina', 66100),
	(66200, 'Chełm (miasto)', 'powiat', 60000),
	(66201, 'Chełm (miasto)', 'gmina', 66200),
	(66300, 'Lublin (miasto)', 'powiat', 60000),
	(66301, 'Lublin (miasto)', 'gmina', 66300),
	(66400, 'Zamość (miasto)', 'powiat', 60000),
	(66401, 'Zamość (miasto)', 'gmina', 66400),
	(80000, 'Lubuskie', 'województwo', NULL),
	(80100, 'Gorzowski', 'powiat', 80000),
	(80101, 'Kostrzyn Nad Odrą (miasto)', 'gmina', 80100),
	(80102, 'Bogdaniec', 'gmina', 80100),
	(80103, 'Deszczno', 'gmina', 80100),
	(80104, 'Kłodawa', 'gmina', 80100),
	(80105, 'Lubiszyn', 'gmina', 80100),
	(80106, 'Santok', 'gmina', 80100),
	(80107, 'Witnica', 'gmina', 80100),
	(80200, 'Krośnieński', 'powiat', 80000),
	(80201, 'Gubin (miasto)', 'gmina', 80200),
	(80202, 'Bobrowice', 'gmina', 80200),
	(80203, 'Bytnica', 'gmina', 80200),
	(80204, 'Dąbie', 'gmina', 80200),
	(80205, 'Gubin', 'gmina', 80200),
	(80206, 'Krosno Odrzańskie', 'gmina', 80200),
	(80207, 'Maszewo', 'gmina', 80200),
	(80300, 'Międzyrzecki', 'powiat', 80000),
	(80301, 'Bledzew', 'gmina', 80300),
	(80302, 'Międzyrzecz', 'gmina', 80300),
	(80303, 'Przytoczna', 'gmina', 80300),
	(80304, 'Pszczew', 'gmina', 80300),
	(80305, 'Skwierzyna', 'gmina', 80300),
	(80306, 'Trzciel', 'gmina', 80300),
	(80400, 'Nowosolski', 'powiat', 80000),
	(80401, 'Nowa Sól (miasto)', 'gmina', 80400),
	(80402, 'Bytom Odrzański', 'gmina', 80400),
	(80403, 'Kolsko', 'gmina', 80400),
	(80404, 'Kożuchów', 'gmina', 80400),
	(80405, 'Nowa Sól', 'gmina', 80400),
	(80406, 'Nowe Miasteczko', 'gmina', 80400),
	(80407, 'Otyń', 'gmina', 80400),
	(80408, 'Siedlisko', 'gmina', 80400),
	(80500, 'Słubicki', 'powiat', 80000),
	(80501, 'Cybinka', 'gmina', 80500),
	(80502, 'Górzyca', 'gmina', 80500),
	(80503, 'Ośno Lubuskie', 'gmina', 80500),
	(80504, 'Rzepin', 'gmina', 80500),
	(80505, 'Słubice', 'gmina', 80500),
	(80600, 'Strzelecko-Drezdenecki', 'powiat', 80000),
	(80601, 'Dobiegniew', 'gmina', 80600),
	(80602, 'Drezdenko', 'gmina', 80600),
	(80603, 'Stare Kurowo', 'gmina', 80600),
	(80604, 'Strzelce Krajeńskie', 'gmina', 80600),
	(80605, 'Zwierzyn', 'gmina', 80600),
	(80700, 'Sulęciński', 'powiat', 80000),
	(80701, 'Krzeszyce', 'gmina', 80700),
	(80702, 'Lubniewice', 'gmina', 80700),
	(80703, 'Słońsk', 'gmina', 80700),
	(80704, 'Sulęcin', 'gmina', 80700),
	(80705, 'Torzym', 'gmina', 80700),
	(80800, 'Świebodziński', 'powiat', 80000),
	(80801, 'Lubrza', 'gmina', 80800),
	(80802, 'Łagów', 'gmina', 80800),
	(80803, 'Skąpe', 'gmina', 80800),
	(80804, 'Szczaniec', 'gmina', 80800),
	(80805, 'Świebodzin', 'gmina', 80800),
	(80806, 'Zbąszynek', 'gmina', 80800),
	(80900, 'Zielonogórski', 'powiat', 80000),
	(80901, 'Babimost', 'gmina', 80900),
	(80902, 'Bojadła', 'gmina', 80900),
	(80903, 'Czerwieńsk', 'gmina', 80900),
	(80904, 'Kargowa', 'gmina', 80900),
	(80905, 'Nowogród Bobrzański', 'gmina', 80900),
	(80906, 'Sulechów', 'gmina', 80900),
	(80907, 'Świdnica', 'gmina', 80900),
	(80908, 'Trzebiechów', 'gmina', 80900),
	(80909, 'Zabór', 'gmina', 80900),
	(81000, 'Żagański', 'powiat', 80000),
	(81001, 'Gozdnica (miasto)', 'gmina', 81000),
	(81002, 'Żagań (miasto)', 'gmina', 81000),
	(81003, 'Brzeźnica', 'gmina', 81000),
	(81004, 'Iłowa', 'gmina', 81000),
	(81005, 'Małomice', 'gmina', 81000),
	(81006, 'Niegosławice', 'gmina', 81000),
	(81007, 'Szprotawa', 'gmina', 81000),
	(81008, 'Wymiarki', 'gmina', 81000),
	(81009, 'Żagań', 'gmina', 81000),
	(81100, 'Żarski', 'powiat', 80000),
	(81101, 'Łęknica (miasto)', 'gmina', 81100),
	(81102, 'Żary (miasto)', 'gmina', 81100),
	(81103, 'Brody', 'gmina', 81100),
	(81104, 'Jasień', 'gmina', 81100),
	(81105, 'Lipinki Łużyckie', 'gmina', 81100),
	(81106, 'Lubsko', 'gmina', 81100),
	(81107, 'Przewóz', 'gmina', 81100),
	(81108, 'Trzebiel', 'gmina', 81100),
	(81109, 'Tuplice', 'gmina', 81100),
	(81110, 'Żary', 'gmina', 81100),
	(81200, 'Wschowski', 'powiat', 80000),
	(81201, 'Sława', 'gmina', 81200),
	(81202, 'Szlichtyngowa', 'gmina', 81200),
	(81203, 'Wschowa', 'gmina', 81200),
	(86100, 'Gorzów Wielkopolski (miasto)', 'powiat', 80000),
	(86101, 'Gorzów Wielkopolski (miasto)', 'gmina', 86100),
	(86200, 'Zielona Góra (miasto)', 'powiat', 80000),
	(86201, 'Zielona Góra (miasto)', 'gmina', 86200),
	(100000, 'Łódzkie', 'województwo', NULL),
	(100100, 'Bełchatowski', 'powiat', 100000),
	(100101, 'Bełchatów (miasto)', 'gmina', 100100),
	(100102, 'Bełchatów', 'gmina', 100100),
	(100103, 'Drużbice', 'gmina', 100100),
	(100104, 'Kleszczów', 'gmina', 100100),
	(100105, 'Kluki', 'gmina', 100100),
	(100106, 'Rusiec', 'gmina', 100100),
	(100107, 'Szczerców', 'gmina', 100100),
	(100108, 'Zelów', 'gmina', 100100),
	(100200, 'Kutnowski', 'powiat', 100000),
	(100201, 'Kutno (miasto)', 'gmina', 100200),
	(100202, 'Bedlno', 'gmina', 100200),
	(100203, 'Dąbrowice', 'gmina', 100200),
	(100204, 'Krośniewice', 'gmina', 100200),
	(100205, 'Krzyżanów', 'gmina', 100200),
	(100206, 'Kutno', 'gmina', 100200),
	(100207, 'Łanięta', 'gmina', 100200),
	(100208, 'Nowe Ostrowy', 'gmina', 100200),
	(100209, 'Oporów', 'gmina', 100200),
	(100210, 'Strzelce', 'gmina', 100200),
	(100211, 'Żychlin', 'gmina', 100200),
	(100300, 'Łaski', 'powiat', 100000),
	(100301, 'Buczek', 'gmina', 100300),
	(100302, 'Łask', 'gmina', 100300),
	(100303, 'Sędziejowice', 'gmina', 100300),
	(100304, 'Widawa', 'gmina', 100300),
	(100305, 'Wodzierady', 'gmina', 100300),
	(100400, 'Łęczycki', 'powiat', 100000),
	(100401, 'Łęczyca (miasto)', 'gmina', 100400),
	(100402, 'Daszyna', 'gmina', 100400),
	(100403, 'Góra Świętej Małgorzaty', 'gmina', 100400),
	(100404, 'Grabów', 'gmina', 100400),
	(100405, 'Łęczyca', 'gmina', 100400),
	(100406, 'Piątek', 'gmina', 100400),
	(100407, 'Świnice Warckie', 'gmina', 100400),
	(100408, 'Witonia', 'gmina', 100400),
	(100500, 'Łowicki', 'powiat', 100000),
	(100501, 'Łowicz (miasto)', 'gmina', 100500),
	(100502, 'Bielawy', 'gmina', 100500),
	(100503, 'Chąśno', 'gmina', 100500),
	(100504, 'Domaniewice', 'gmina', 100500),
	(100505, 'Kiernozia', 'gmina', 100500),
	(100506, 'Kocierzew Południowy', 'gmina', 100500),
	(100507, 'Łowicz', 'gmina', 100500),
	(100508, 'Łyszkowice', 'gmina', 100500),
	(100509, 'Nieborów', 'gmina', 100500),
	(100510, 'Zduny', 'gmina', 100500),
	(100600, 'Łódzki Wschodni', 'powiat', 100000),
	(100602, 'Andrespol', 'gmina', 100600),
	(100603, 'Brójce', 'gmina', 100600),
	(100607, 'Koluszki', 'gmina', 100600),
	(100608, 'Nowosolna', 'gmina', 100600),
	(100610, 'Rzgów', 'gmina', 100600),
	(100611, 'Tuszyn', 'gmina', 100600),
	(100700, 'Opoczyński', 'powiat', 100000),
	(100701, 'Białaczów', 'gmina', 100700),
	(100702, 'Drzewica', 'gmina', 100700),
	(100703, 'Mniszków', 'gmina', 100700),
	(100704, 'Opoczno', 'gmina', 100700),
	(100705, 'Paradyż', 'gmina', 100700),
	(100706, 'Poświętne', 'gmina', 100700),
	(100707, 'Sławno', 'gmina', 100700),
	(100708, 'Żarnów', 'gmina', 100700),
	(100800, 'Pabianicki', 'powiat', 100000),
	(100801, 'Konstantynów Łódzki (miasto)', 'gmina', 100800),
	(100802, 'Pabianice (miasto)', 'gmina', 100800),
	(100803, 'Dłutów', 'gmina', 100800),
	(100804, 'Dobroń', 'gmina', 100800),
	(100805, 'Ksawerów', 'gmina', 100800),
	(100806, 'Lutomiersk', 'gmina', 100800),
	(100807, 'Pabianice', 'gmina', 100800),
	(100900, 'Pajęczański', 'powiat', 100000),
	(100901, 'Działoszyn', 'gmina', 100900),
	(100902, 'Kiełczygłów', 'gmina', 100900),
	(100903, 'Nowa Brzeźnica', 'gmina', 100900),
	(100904, 'Pajęczno', 'gmina', 100900),
	(100905, 'Rząśnia', 'gmina', 100900),
	(100906, 'Siemkowice', 'gmina', 100900),
	(100907, 'Strzelce Wielkie', 'gmina', 100900),
	(100908, 'Sulmierzyce', 'gmina', 100900),
	(101000, 'Piotrkowski', 'powiat', 100000),
	(101001, 'Aleksandrów', 'gmina', 101000),
	(101002, 'Czarnocin', 'gmina', 101000),
	(101003, 'Gorzkowice', 'gmina', 101000),
	(101004, 'Grabica', 'gmina', 101000),
	(101005, 'Łęki Szlacheckie', 'gmina', 101000),
	(101006, 'Moszczenica', 'gmina', 101000),
	(101007, 'Ręczno', 'gmina', 101000),
	(101008, 'Rozprza', 'gmina', 101000),
	(101009, 'Sulejów', 'gmina', 101000),
	(101010, 'Wola Krzysztoporska', 'gmina', 101000),
	(101011, 'Wolbórz', 'gmina', 101000),
	(101100, 'Poddębicki', 'powiat', 100000),
	(101101, 'Dalików', 'gmina', 101100),
	(101102, 'Pęczniew', 'gmina', 101100),
	(101103, 'Poddębice', 'gmina', 101100),
	(101104, 'Uniejów', 'gmina', 101100),
	(101105, 'Wartkowice', 'gmina', 101100),
	(101106, 'Zadzim', 'gmina', 101100),
	(101200, 'Radomszczański', 'powiat', 100000),
	(101201, 'Radomsko (miasto)', 'gmina', 101200),
	(101202, 'Dobryszyce', 'gmina', 101200),
	(101203, 'Gidle', 'gmina', 101200),
	(101204, 'Gomunice', 'gmina', 101200),
	(101205, 'Kamieńsk', 'gmina', 101200),
	(101206, 'Kobiele Wielkie', 'gmina', 101200),
	(101207, 'Kodrąb', 'gmina', 101200),
	(101208, 'Lgota Wielka', 'gmina', 101200),
	(101209, 'Ładzice', 'gmina', 101200),
	(101210, 'Masłowice', 'gmina', 101200),
	(101211, 'Przedbórz', 'gmina', 101200),
	(101212, 'Radomsko', 'gmina', 101200),
	(101213, 'Wielgomłyny', 'gmina', 101200),
	(101214, 'Żytno', 'gmina', 101200),
	(101300, 'Rawski', 'powiat', 100000),
	(101301, 'Rawa Mazowiecka (miasto)', 'gmina', 101300),
	(101302, 'Biała Rawska', 'gmina', 101300),
	(101303, 'Cielądz', 'gmina', 101300),
	(101304, 'Rawa Mazowiecka', 'gmina', 101300),
	(101305, 'Regnów', 'gmina', 101300),
	(101306, 'Sadkowice', 'gmina', 101300),
	(101400, 'Sieradzki', 'powiat', 100000),
	(101401, 'Sieradz (miasto)', 'gmina', 101400),
	(101402, 'Błaszki', 'gmina', 101400),
	(101403, 'Brąszewice', 'gmina', 101400),
	(101404, 'Brzeźnio', 'gmina', 101400),
	(101405, 'Burzenin', 'gmina', 101400),
	(101406, 'Goszczanów', 'gmina', 101400),
	(101407, 'Klonowa', 'gmina', 101400),
	(101408, 'Sieradz', 'gmina', 101400),
	(101409, 'Warta', 'gmina', 101400),
	(101410, 'Wróblew', 'gmina', 101400),
	(101411, 'Złoczew', 'gmina', 101400),
	(101500, 'Skierniewicki', 'powiat', 100000),
	(101501, 'Bolimów', 'gmina', 101500),
	(101502, 'Głuchów', 'gmina', 101500),
	(101503, 'Godzianów', 'gmina', 101500),
	(101504, 'Kowiesy', 'gmina', 101500),
	(101505, 'Lipce Reymontowskie', 'gmina', 101500),
	(101506, 'Maków', 'gmina', 101500),
	(101507, 'Nowy Kawęczyn', 'gmina', 101500),
	(101508, 'Skierniewice', 'gmina', 101500),
	(101509, 'Słupia', 'gmina', 101500),
	(101600, 'Tomaszowski', 'powiat', 100000),
	(101601, 'Tomaszów Mazowiecki (miasto)', 'gmina', 101600),
	(101602, 'Będków', 'gmina', 101600),
	(101603, 'Budziszewice', 'gmina', 101600),
	(101604, 'Czerniewice', 'gmina', 101600),
	(101605, 'Inowłódz', 'gmina', 101600),
	(101606, 'Lubochnia', 'gmina', 101600),
	(101607, 'Rokiciny', 'gmina', 101600),
	(101608, 'Rzeczyca', 'gmina', 101600),
	(101609, 'Tomaszów Mazowiecki', 'gmina', 101600),
	(101610, 'Ujazd', 'gmina', 101600),
	(101611, 'Żelechlinek', 'gmina', 101600),
	(101700, 'Wieluński', 'powiat', 100000),
	(101701, 'Biała', 'gmina', 101700),
	(101702, 'Czarnożyły', 'gmina', 101700),
	(101703, 'Konopnica', 'gmina', 101700),
	(101704, 'Mokrsko', 'gmina', 101700),
	(101705, 'Osjaków', 'gmina', 101700),
	(101706, 'Ostrówek', 'gmina', 101700),
	(101707, 'Pątnów', 'gmina', 101700),
	(101708, 'Skomlin', 'gmina', 101700),
	(101709, 'Wieluń', 'gmina', 101700),
	(101710, 'Wierzchlas', 'gmina', 101700),
	(101800, 'Wieruszowski', 'powiat', 100000),
	(101801, 'Bolesławiec', 'gmina', 101800),
	(101802, 'Czastary', 'gmina', 101800),
	(101803, 'Galewice', 'gmina', 101800),
	(101804, 'Lututów', 'gmina', 101800),
	(101805, 'Łubnice', 'gmina', 101800),
	(101806, 'Sokolniki', 'gmina', 101800),
	(101807, 'Wieruszów', 'gmina', 101800),
	(101900, 'Zduńskowolski', 'powiat', 100000),
	(101901, 'Zduńska Wola (miasto)', 'gmina', 101900),
	(101902, 'Szadek', 'gmina', 101900),
	(101903, 'Zapolice', 'gmina', 101900),
	(101904, 'Zduńska Wola', 'gmina', 101900),
	(102000, 'Zgierski', 'powiat', 100000),
	(102001, 'Głowno (miasto)', 'gmina', 102000),
	(102002, 'Ozorków (miasto)', 'gmina', 102000),
	(102003, 'Zgierz (miasto)', 'gmina', 102000),
	(102004, 'Aleksandrów Łódzki', 'gmina', 102000),
	(102005, 'Głowno', 'gmina', 102000),
	(102006, 'Ozorków', 'gmina', 102000),
	(102007, 'Parzęczew', 'gmina', 102000),
	(102008, 'Stryków', 'gmina', 102000),
	(102009, 'Zgierz', 'gmina', 102000),
	(102100, 'Brzeziński', 'powiat', 100000),
	(102101, 'Brzeziny (miasto)', 'gmina', 102100),
	(102102, 'Brzeziny', 'gmina', 102100),
	(102103, 'Dmosin', 'gmina', 102100),
	(102104, 'Jeżów', 'gmina', 102100),
	(102105, 'Rogów', 'gmina', 102100),
	(106100, 'Łódź (miasto)', 'powiat', 100000),
	(106101, 'Łódź (miasto)', 'gmina', 106100),
	(106200, 'Piotrków Trybunalski (miasto)', 'powiat', 100000),
	(106201, 'Piotrków Trybunalski (miasto)', 'gmina', 106200),
	(106300, 'Skierniewice (miasto)', 'powiat', 100000),
	(106301, 'Skierniewice (miasto)', 'gmina', 106300),
	(120000, 'Małopolskie', 'województwo', NULL),
	(120100, 'Bocheński', 'powiat', 120000),
	(120101, 'Bochnia (miasto)', 'gmina', 120100),
	(120102, 'Bochnia', 'gmina', 120100),
	(120103, 'Drwinia', 'gmina', 120100),
	(120104, 'Lipnica Murowana', 'gmina', 120100),
	(120105, 'Łapanów', 'gmina', 120100),
	(120106, 'Nowy Wiśnicz', 'gmina', 120100),
	(120107, 'Rzezawa', 'gmina', 120100),
	(120108, 'Trzciana', 'gmina', 120100),
	(120109, 'Żegocina', 'gmina', 120100),
	(120200, 'Brzeski', 'powiat', 120000),
	(120201, 'Borzęcin', 'gmina', 120200),
	(120202, 'Brzesko', 'gmina', 120200),
	(120203, 'Czchów', 'gmina', 120200),
	(120204, 'Dębno', 'gmina', 120200),
	(120205, 'Gnojnik', 'gmina', 120200),
	(120206, 'Iwkowa', 'gmina', 120200),
	(120207, 'Szczurowa', 'gmina', 120200),
	(120300, 'Chrzanowski', 'powiat', 120000),
	(120301, 'Alwernia', 'gmina', 120300),
	(120302, 'Babice', 'gmina', 120300),
	(120303, 'Chrzanów', 'gmina', 120300),
	(120304, 'Libiąż', 'gmina', 120300),
	(120305, 'Trzebinia', 'gmina', 120300),
	(120400, 'Dąbrowski', 'powiat', 120000),
	(120401, 'Bolesław', 'gmina', 120400),
	(120402, 'Dąbrowa Tarnowska', 'gmina', 120400),
	(120403, 'Gręboszów', 'gmina', 120400),
	(120404, 'Mędrzechów', 'gmina', 120400),
	(120405, 'Olesno', 'gmina', 120400),
	(120406, 'Radgoszcz', 'gmina', 120400),
	(120407, 'Szczucin', 'gmina', 120400),
	(120500, 'Gorlicki', 'powiat', 120000),
	(120501, 'Gorlice (miasto)', 'gmina', 120500),
	(120502, 'Biecz', 'gmina', 120500),
	(120503, 'Bobowa', 'gmina', 120500),
	(120504, 'Gorlice', 'gmina', 120500),
	(120505, 'Lipinki', 'gmina', 120500),
	(120506, 'Łużna', 'gmina', 120500),
	(120507, 'Moszczenica', 'gmina', 120500),
	(120508, 'Ropa', 'gmina', 120500),
	(120509, 'Sękowa', 'gmina', 120500),
	(120510, 'Uście Gorlickie', 'gmina', 120500),
	(120600, 'Krakowski', 'powiat', 120000),
	(120601, 'Czernichów', 'gmina', 120600),
	(120602, 'Igołomia-Wawrzeńczyce', 'gmina', 120600),
	(120603, 'Iwanowice', 'gmina', 120600),
	(120604, 'Jerzmanowice-Przeginia', 'gmina', 120600),
	(120605, 'Kocmyrzów-Luborzyca', 'gmina', 120600),
	(120606, 'Krzeszowice', 'gmina', 120600),
	(120607, 'Liszki', 'gmina', 120600),
	(120608, 'Michałowice', 'gmina', 120600),
	(120609, 'Mogilany', 'gmina', 120600),
	(120610, 'Skała', 'gmina', 120600),
	(120611, 'Skawina', 'gmina', 120600),
	(120612, 'Słomniki', 'gmina', 120600),
	(120613, 'Sułoszowa', 'gmina', 120600),
	(120614, 'Świątniki Górne', 'gmina', 120600),
	(120615, 'Wielka Wieś', 'gmina', 120600),
	(120616, 'Zabierzów', 'gmina', 120600),
	(120617, 'Zielonki', 'gmina', 120600),
	(120700, 'Limanowski', 'powiat', 120000),
	(120701, 'Limanowa (miasto)', 'gmina', 120700),
	(120702, 'Mszana Dolna (miasto)', 'gmina', 120700),
	(120703, 'Dobra', 'gmina', 120700),
	(120704, 'Jodłownik', 'gmina', 120700),
	(120705, 'Kamienica', 'gmina', 120700),
	(120706, 'Laskowa', 'gmina', 120700),
	(120707, 'Limanowa', 'gmina', 120700),
	(120708, 'Łukowica', 'gmina', 120700),
	(120709, 'Mszana Dolna', 'gmina', 120700),
	(120710, 'Niedźwiedź', 'gmina', 120700),
	(120711, 'Słopnice', 'gmina', 120700),
	(120712, 'Tymbark', 'gmina', 120700),
	(120800, 'Miechowski', 'powiat', 120000),
	(120801, 'Charsznica', 'gmina', 120800),
	(120802, 'Gołcza', 'gmina', 120800),
	(120803, 'Kozłów', 'gmina', 120800),
	(120804, 'Książ Wielki', 'gmina', 120800),
	(120805, 'Miechów', 'gmina', 120800),
	(120806, 'Racławice', 'gmina', 120800),
	(120807, 'Słaboszów', 'gmina', 120800),
	(120900, 'Myślenicki', 'powiat', 120000),
	(120901, 'Dobczyce', 'gmina', 120900),
	(120902, 'Lubień', 'gmina', 120900),
	(120903, 'Myślenice', 'gmina', 120900),
	(120904, 'Pcim', 'gmina', 120900),
	(120905, 'Raciechowice', 'gmina', 120900),
	(120906, 'Siepraw', 'gmina', 120900),
	(120907, 'Sułkowice', 'gmina', 120900),
	(120908, 'Tokarnia', 'gmina', 120900),
	(120909, 'Wiśniowa', 'gmina', 120900),
	(121000, 'Nowosądecki', 'powiat', 120000),
	(121001, 'Grybów (miasto)', 'gmina', 121000),
	(121002, 'Chełmiec', 'gmina', 121000),
	(121003, 'Gródek Nad Dunajcem', 'gmina', 121000),
	(121004, 'Grybów', 'gmina', 121000),
	(121005, 'Kamionka Wielka', 'gmina', 121000),
	(121006, 'Korzenna', 'gmina', 121000),
	(121007, 'Krynica-Zdrój', 'gmina', 121000),
	(121008, 'Łabowa', 'gmina', 121000),
	(121009, 'Łącko', 'gmina', 121000),
	(121010, 'Łososina Dolna', 'gmina', 121000),
	(121011, 'Muszyna', 'gmina', 121000),
	(121012, 'Nawojowa', 'gmina', 121000),
	(121013, 'Piwniczna-Zdrój', 'gmina', 121000),
	(121014, 'Podegrodzie', 'gmina', 121000),
	(121015, 'Rytro', 'gmina', 121000),
	(121016, 'Stary Sącz', 'gmina', 121000),
	(121100, 'Nowotarski', 'powiat', 120000),
	(121101, 'Nowy Targ (miasto)', 'gmina', 121100),
	(121102, 'Szczawnica', 'gmina', 121100),
	(121103, 'Czarny Dunajec', 'gmina', 121100),
	(121104, 'Czorsztyn', 'gmina', 121100),
	(121105, 'Jabłonka', 'gmina', 121100),
	(121106, 'Krościenko Nad Dunajcem', 'gmina', 121100),
	(121107, 'Lipnica Wielka', 'gmina', 121100),
	(121108, 'Łapsze Niżne', 'gmina', 121100),
	(121109, 'Nowy Targ', 'gmina', 121100),
	(121110, 'Ochotnica Dolna', 'gmina', 121100),
	(121111, 'Raba Wyżna', 'gmina', 121100),
	(121112, 'Rabka-Zdrój', 'gmina', 121100),
	(121113, 'Spytkowice', 'gmina', 121100),
	(121114, 'Szaflary', 'gmina', 121100),
	(121200, 'Olkuski', 'powiat', 120000),
	(121201, 'Bukowno (miasto)', 'gmina', 121200),
	(121203, 'Bolesław', 'gmina', 121200),
	(121204, 'Klucze', 'gmina', 121200),
	(121205, 'Olkusz', 'gmina', 121200),
	(121206, 'Trzyciąż', 'gmina', 121200),
	(121207, 'Wolbrom', 'gmina', 121200),
	(121300, 'Oświęcimski', 'powiat', 120000),
	(121301, 'Oświęcim (miasto)', 'gmina', 121300),
	(121302, 'Brzeszcze', 'gmina', 121300),
	(121303, 'Chełmek', 'gmina', 121300),
	(121304, 'Kęty', 'gmina', 121300),
	(121305, 'Osiek', 'gmina', 121300),
	(121306, 'Oświęcim', 'gmina', 121300),
	(121307, 'Polanka Wielka', 'gmina', 121300),
	(121308, 'Przeciszów', 'gmina', 121300),
	(121309, 'Zator', 'gmina', 121300),
	(121400, 'Proszowicki', 'powiat', 120000),
	(121401, 'Koniusza', 'gmina', 121400),
	(121402, 'Koszyce', 'gmina', 121400),
	(121403, 'Nowe Brzesko', 'gmina', 121400),
	(121404, 'Pałecznica', 'gmina', 121400),
	(121405, 'Proszowice', 'gmina', 121400),
	(121406, 'Radziemice', 'gmina', 121400),
	(121500, 'Suski', 'powiat', 120000),
	(121501, 'Jordanów (miasto)', 'gmina', 121500),
	(121502, 'Sucha Beskidzka (miasto)', 'gmina', 121500),
	(121503, 'Budzów', 'gmina', 121500),
	(121504, 'Bystra-Sidzina', 'gmina', 121500),
	(121505, 'Jordanów', 'gmina', 121500),
	(121506, 'Maków Podhalański', 'gmina', 121500),
	(121507, 'Stryszawa', 'gmina', 121500),
	(121508, 'Zawoja', 'gmina', 121500),
	(121509, 'Zembrzyce', 'gmina', 121500),
	(121600, 'Tarnowski', 'powiat', 120000),
	(121601, 'Ciężkowice', 'gmina', 121600),
	(121602, 'Gromnik', 'gmina', 121600),
	(121603, 'Lisia Góra', 'gmina', 121600),
	(121604, 'Pleśna', 'gmina', 121600),
	(121605, 'Radłów', 'gmina', 121600),
	(121606, 'Ryglice', 'gmina', 121600),
	(121607, 'Rzepiennik Strzyżewski', 'gmina', 121600),
	(121608, 'Skrzyszów', 'gmina', 121600),
	(121609, 'Tarnów', 'gmina', 121600),
	(121610, 'Tuchów', 'gmina', 121600),
	(121611, 'Wierzchosławice', 'gmina', 121600),
	(121612, 'Wietrzychowice', 'gmina', 121600),
	(121613, 'Wojnicz', 'gmina', 121600),
	(121614, 'Zakliczyn', 'gmina', 121600),
	(121615, 'Żabno', 'gmina', 121600),
	(121616, 'Szerzyny', 'gmina', 121600),
	(121700, 'Tatrzański', 'powiat', 120000),
	(121701, 'Zakopane (miasto)', 'gmina', 121700),
	(121702, 'Biały Dunajec', 'gmina', 121700),
	(121703, 'Bukowina Tatrzańska', 'gmina', 121700),
	(121704, 'Kościelisko', 'gmina', 121700),
	(121705, 'Poronin', 'gmina', 121700),
	(121800, 'Wadowicki', 'powiat', 120000),
	(121801, 'Andrychów', 'gmina', 121800),
	(121802, 'Brzeźnica', 'gmina', 121800),
	(121803, 'Kalwaria Zebrzydowska', 'gmina', 121800),
	(121804, 'Lanckorona', 'gmina', 121800),
	(121805, 'Mucharz', 'gmina', 121800),
	(121806, 'Spytkowice', 'gmina', 121800),
	(121807, 'Stryszów', 'gmina', 121800),
	(121808, 'Tomice', 'gmina', 121800),
	(121809, 'Wadowice', 'gmina', 121800),
	(121810, 'Wieprz', 'gmina', 121800),
	(121900, 'Wielicki', 'powiat', 120000),
	(121901, 'Biskupice', 'gmina', 121900),
	(121902, 'Gdów', 'gmina', 121900),
	(121903, 'Kłaj', 'gmina', 121900),
	(121904, 'Niepołomice', 'gmina', 121900),
	(121905, 'Wieliczka', 'gmina', 121900),
	(126100, 'Kraków (miasto)', 'powiat', 120000),
	(126101, 'Kraków (miasto)', 'gmina', 126100),
	(126200, 'Nowy Sącz (miasto)', 'powiat', 120000),
	(126201, 'Nowy Sącz (miasto)', 'gmina', 126200),
	(126300, 'Tarnów (miasto)', 'powiat', 120000),
	(126301, 'Tarnów (miasto)', 'gmina', 126300),
	(140000, 'Mazowieckie', 'województwo', NULL),
	(140100, 'Białobrzeski', 'powiat', 140000),
	(140101, 'Białobrzegi', 'gmina', 140100),
	(140102, 'Promna', 'gmina', 140100),
	(140103, 'Radzanów', 'gmina', 140100),
	(140104, 'Stara Błotnica', 'gmina', 140100),
	(140105, 'Stromiec', 'gmina', 140100),
	(140106, 'Wyśmierzyce', 'gmina', 140100),
	(140200, 'Ciechanowski', 'powiat', 140000),
	(140201, 'Ciechanów (miasto)', 'gmina', 140200),
	(140202, 'Ciechanów', 'gmina', 140200),
	(140203, 'Glinojeck', 'gmina', 140200),
	(140204, 'Gołymin-Ośrodek', 'gmina', 140200),
	(140205, 'Grudusk', 'gmina', 140200),
	(140206, 'Ojrzeń', 'gmina', 140200),
	(140207, 'Opinogóra Górna', 'gmina', 140200),
	(140208, 'Regimin', 'gmina', 140200),
	(140209, 'Sońsk', 'gmina', 140200),
	(140300, 'Garwoliński', 'powiat', 140000),
	(140301, 'Garwolin (miasto)', 'gmina', 140300),
	(140302, 'Łaskarzew (miasto)', 'gmina', 140300),
	(140303, 'Borowie', 'gmina', 140300),
	(140304, 'Garwolin', 'gmina', 140300),
	(140305, 'Górzno', 'gmina', 140300),
	(140306, 'Łaskarzew', 'gmina', 140300),
	(140307, 'Maciejowice', 'gmina', 140300),
	(140308, 'Miastków Kościelny', 'gmina', 140300),
	(140309, 'Parysów', 'gmina', 140300),
	(140310, 'Pilawa', 'gmina', 140300),
	(140311, 'Sobolew', 'gmina', 140300),
	(140312, 'Trojanów', 'gmina', 140300),
	(140313, 'Wilga', 'gmina', 140300),
	(140314, 'Żelechów', 'gmina', 140300),
	(140400, 'Gostyniński', 'powiat', 140000),
	(140401, 'Gostynin (miasto)', 'gmina', 140400),
	(140402, 'Gostynin', 'gmina', 140400),
	(140403, 'Pacyna', 'gmina', 140400),
	(140404, 'Sanniki', 'gmina', 140400),
	(140405, 'Szczawin Kościelny', 'gmina', 140400),
	(140500, 'Grodziski', 'powiat', 140000),
	(140501, 'Milanówek (miasto)', 'gmina', 140500),
	(140502, 'Podkowa Leśna (miasto)', 'gmina', 140500),
	(140503, 'Baranów', 'gmina', 140500),
	(140504, 'Grodzisk Mazowiecki', 'gmina', 140500),
	(140505, 'Jaktorów', 'gmina', 140500),
	(140506, 'Żabia Wola', 'gmina', 140500),
	(140600, 'Grójecki', 'powiat', 140000),
	(140601, 'Belsk Duży', 'gmina', 140600),
	(140602, 'Błędów', 'gmina', 140600),
	(140603, 'Chynów', 'gmina', 140600),
	(140604, 'Goszczyn', 'gmina', 140600),
	(140605, 'Grójec', 'gmina', 140600),
	(140606, 'Jasieniec', 'gmina', 140600),
	(140607, 'Mogielnica', 'gmina', 140600),
	(140608, 'Nowe Miasto Nad Pilicą', 'gmina', 140600),
	(140609, 'Pniewy', 'gmina', 140600),
	(140611, 'Warka', 'gmina', 140600),
	(140700, 'Kozienicki', 'powiat', 140000),
	(140701, 'Garbatka-Letnisko', 'gmina', 140700),
	(140702, 'Głowaczów', 'gmina', 140700),
	(140703, 'Gniewoszów', 'gmina', 140700),
	(140704, 'Grabów Nad Pilicą', 'gmina', 140700),
	(140705, 'Kozienice', 'gmina', 140700),
	(140706, 'Magnuszew', 'gmina', 140700),
	(140707, 'Sieciechów', 'gmina', 140700),
	(140800, 'Legionowski', 'powiat', 140000),
	(140801, 'Legionowo (miasto)', 'gmina', 140800),
	(140802, 'Jabłonna', 'gmina', 140800),
	(140803, 'Nieporęt', 'gmina', 140800),
	(140804, 'Serock', 'gmina', 140800),
	(140805, 'Wieliszew', 'gmina', 140800),
	(140900, 'Lipski', 'powiat', 140000),
	(140901, 'Chotcza', 'gmina', 140900),
	(140902, 'Ciepielów', 'gmina', 140900),
	(140903, 'Lipsko', 'gmina', 140900),
	(140904, 'Rzeczniów', 'gmina', 140900),
	(140905, 'Sienno', 'gmina', 140900),
	(140906, 'Solec Nad Wisłą', 'gmina', 140900),
	(141000, 'Łosicki', 'powiat', 140000),
	(141001, 'Huszlew', 'gmina', 141000),
	(141002, 'Łosice', 'gmina', 141000),
	(141003, 'Olszanka', 'gmina', 141000),
	(141004, 'Platerów', 'gmina', 141000),
	(141005, 'Sarnaki', 'gmina', 141000),
	(141006, 'Stara Kornica', 'gmina', 141000),
	(141100, 'Makowski', 'powiat', 140000),
	(141101, 'Maków Mazowiecki (miasto)', 'gmina', 141100),
	(141102, 'Czerwonka', 'gmina', 141100),
	(141103, 'Karniewo', 'gmina', 141100),
	(141104, 'Krasnosielc', 'gmina', 141100),
	(141105, 'Młynarze', 'gmina', 141100),
	(141106, 'Płoniawy-Bramura', 'gmina', 141100),
	(141107, 'Różan', 'gmina', 141100),
	(141108, 'Rzewnie', 'gmina', 141100),
	(141109, 'Sypniewo', 'gmina', 141100),
	(141110, 'Szelków', 'gmina', 141100),
	(141200, 'Miński', 'powiat', 140000),
	(141201, 'Mińsk Mazowiecki (miasto)', 'gmina', 141200),
	(141204, 'Cegłów', 'gmina', 141200),
	(141205, 'Dębe Wielkie', 'gmina', 141200),
	(141206, 'Dobre', 'gmina', 141200),
	(141207, 'Halinów', 'gmina', 141200),
	(141208, 'Jakubów', 'gmina', 141200),
	(141209, 'Kałuszyn', 'gmina', 141200),
	(141210, 'Latowicz', 'gmina', 141200),
	(141211, 'Mińsk Mazowiecki', 'gmina', 141200),
	(141212, 'Mrozy', 'gmina', 141200),
	(141213, 'Siennica', 'gmina', 141200),
	(141214, 'Stanisławów', 'gmina', 141200),
	(141215, 'Sulejówek (miasto)', 'gmina', 141200),
	(141300, 'Mławski', 'powiat', 140000),
	(141301, 'Mława (miasto)', 'gmina', 141300),
	(141302, 'Dzierzgowo', 'gmina', 141300),
	(141303, 'Lipowiec Kościelny', 'gmina', 141300),
	(141304, 'Radzanów', 'gmina', 141300),
	(141305, 'Strzegowo', 'gmina', 141300),
	(141306, 'Stupsk', 'gmina', 141300),
	(141307, 'Szreńsk', 'gmina', 141300),
	(141308, 'Szydłowo', 'gmina', 141300),
	(141309, 'Wieczfnia Kościelna', 'gmina', 141300),
	(141310, 'Wiśniewo', 'gmina', 141300),
	(141400, 'Nowodworski', 'powiat', 140000),
	(141401, 'Nowy Dwór Mazowiecki (miasto)', 'gmina', 141400),
	(141402, 'Czosnów', 'gmina', 141400),
	(141403, 'Leoncin', 'gmina', 141400),
	(141404, 'Nasielsk', 'gmina', 141400),
	(141405, 'Pomiechówek', 'gmina', 141400),
	(141406, 'Zakroczym', 'gmina', 141400),
	(141500, 'Ostrołęcki', 'powiat', 140000),
	(141501, 'Baranowo', 'gmina', 141500),
	(141502, 'Czarnia', 'gmina', 141500),
	(141503, 'Czerwin', 'gmina', 141500),
	(141504, 'Goworowo', 'gmina', 141500),
	(141505, 'Kadzidło', 'gmina', 141500),
	(141506, 'Lelis', 'gmina', 141500),
	(141507, 'Łyse', 'gmina', 141500),
	(141508, 'Myszyniec', 'gmina', 141500),
	(141509, 'Olszewo-Borki', 'gmina', 141500),
	(141510, 'Rzekuń', 'gmina', 141500),
	(141511, 'Troszyn', 'gmina', 141500),
	(141600, 'Ostrowski', 'powiat', 140000),
	(141601, 'Ostrów Mazowiecka (miasto)', 'gmina', 141600),
	(141602, 'Andrzejewo', 'gmina', 141600),
	(141603, 'Boguty-Pianki', 'gmina', 141600),
	(141604, 'Brok', 'gmina', 141600),
	(141605, 'Małkinia Górna', 'gmina', 141600),
	(141606, 'Nur', 'gmina', 141600),
	(141607, 'Ostrów Mazowiecka', 'gmina', 141600),
	(141608, 'Stary Lubotyń', 'gmina', 141600),
	(141609, 'Szulborze Wielkie', 'gmina', 141600),
	(141610, 'Wąsewo', 'gmina', 141600),
	(141611, 'Zaręby Kościelne', 'gmina', 141600),
	(141700, 'Otwocki', 'powiat', 140000),
	(141701, 'Józefów (miasto)', 'gmina', 141700),
	(141702, 'Otwock (miasto)', 'gmina', 141700),
	(141703, 'Celestynów', 'gmina', 141700),
	(141704, 'Karczew', 'gmina', 141700),
	(141705, 'Kołbiel', 'gmina', 141700),
	(141706, 'Osieck', 'gmina', 141700),
	(141707, 'Sobienie-Jeziory', 'gmina', 141700),
	(141708, 'Wiązowna', 'gmina', 141700),
	(141800, 'Piaseczyński', 'powiat', 140000),
	(141801, 'Góra Kalwaria', 'gmina', 141800),
	(141802, 'Konstancin-Jeziorna', 'gmina', 141800),
	(141803, 'Lesznowola', 'gmina', 141800),
	(141804, 'Piaseczno', 'gmina', 141800),
	(141805, 'Prażmów', 'gmina', 141800),
	(141806, 'Tarczyn', 'gmina', 141800),
	(141900, 'Płocki', 'powiat', 140000),
	(141901, 'Bielsk', 'gmina', 141900),
	(141902, 'Bodzanów', 'gmina', 141900),
	(141903, 'Brudzeń Duży', 'gmina', 141900),
	(141904, 'Bulkowo', 'gmina', 141900),
	(141905, 'Drobin', 'gmina', 141900),
	(141906, 'Gąbin', 'gmina', 141900),
	(141907, 'Łąck', 'gmina', 141900),
	(141908, 'Mała Wieś', 'gmina', 141900),
	(141909, 'Nowy Duninów', 'gmina', 141900),
	(141910, 'Radzanowo', 'gmina', 141900),
	(141911, 'Słubice', 'gmina', 141900),
	(141912, 'Słupno', 'gmina', 141900),
	(141913, 'Stara Biała', 'gmina', 141900),
	(141914, 'Staroźreby', 'gmina', 141900),
	(141915, 'Wyszogród', 'gmina', 141900),
	(142000, 'Płoński', 'powiat', 140000),
	(142001, 'Płońsk (miasto)', 'gmina', 142000),
	(142002, 'Raciąż (miasto)', 'gmina', 142000),
	(142003, 'Baboszewo', 'gmina', 142000),
	(142004, 'Czerwińsk Nad Wisłą', 'gmina', 142000),
	(142005, 'Dzierzążnia', 'gmina', 142000),
	(142006, 'Joniec', 'gmina', 142000),
	(142007, 'Naruszewo', 'gmina', 142000),
	(142008, 'Nowe Miasto', 'gmina', 142000),
	(142009, 'Płońsk', 'gmina', 142000),
	(142010, 'Raciąż', 'gmina', 142000),
	(142011, 'Sochocin', 'gmina', 142000),
	(142012, 'Załuski', 'gmina', 142000),
	(142100, 'Pruszkowski', 'powiat', 140000),
	(142101, 'Piastów (miasto)', 'gmina', 142100),
	(142102, 'Pruszków (miasto)', 'gmina', 142100),
	(142103, 'Brwinów', 'gmina', 142100),
	(142104, 'Michałowice', 'gmina', 142100),
	(142105, 'Nadarzyn', 'gmina', 142100),
	(142106, 'Raszyn', 'gmina', 142100),
	(142200, 'Przasnyski', 'powiat', 140000),
	(142201, 'Przasnysz (miasto)', 'gmina', 142200),
	(142202, 'Chorzele', 'gmina', 142200),
	(142203, 'Czernice Borowe', 'gmina', 142200),
	(142204, 'Jednorożec', 'gmina', 142200),
	(142205, 'Krasne', 'gmina', 142200),
	(142206, 'Krzynowłoga Mała', 'gmina', 142200),
	(142207, 'Przasnysz', 'gmina', 142200),
	(142300, 'Przysuski', 'powiat', 140000),
	(142301, 'Borkowice', 'gmina', 142300),
	(142302, 'Gielniów', 'gmina', 142300),
	(142303, 'Klwów', 'gmina', 142300),
	(142304, 'Odrzywół', 'gmina', 142300),
	(142305, 'Potworów', 'gmina', 142300),
	(142306, 'Przysucha', 'gmina', 142300),
	(142307, 'Rusinów', 'gmina', 142300),
	(142308, 'Wieniawa', 'gmina', 142300),
	(142400, 'Pułtuski', 'powiat', 140000),
	(142401, 'Gzy', 'gmina', 142400),
	(142402, 'Obryte', 'gmina', 142400),
	(142403, 'Pokrzywnica', 'gmina', 142400),
	(142404, 'Pułtusk', 'gmina', 142400),
	(142405, 'Świercze', 'gmina', 142400),
	(142406, 'Winnica', 'gmina', 142400),
	(142407, 'Zatory', 'gmina', 142400),
	(142500, 'Radomski', 'powiat', 140000),
	(142501, 'Pionki (miasto)', 'gmina', 142500),
	(142502, 'Gózd', 'gmina', 142500),
	(142503, 'Iłża', 'gmina', 142500),
	(142504, 'Jastrzębia', 'gmina', 142500),
	(142505, 'Jedlińsk', 'gmina', 142500),
	(142506, 'Jedlnia-Letnisko', 'gmina', 142500),
	(142507, 'Kowala', 'gmina', 142500),
	(142508, 'Pionki', 'gmina', 142500),
	(142509, 'Przytyk', 'gmina', 142500),
	(142510, 'Skaryszew', 'gmina', 142500),
	(142511, 'Wierzbica', 'gmina', 142500),
	(142512, 'Wolanów', 'gmina', 142500),
	(142513, 'Zakrzew', 'gmina', 142500),
	(142600, 'Siedlecki', 'powiat', 140000),
	(142601, 'Domanice', 'gmina', 142600),
	(142602, 'Korczew', 'gmina', 142600),
	(142603, 'Kotuń', 'gmina', 142600),
	(142604, 'Mokobody', 'gmina', 142600),
	(142605, 'Mordy', 'gmina', 142600),
	(142606, 'Paprotnia', 'gmina', 142600),
	(142607, 'Przesmyki', 'gmina', 142600),
	(142608, 'Siedlce', 'gmina', 142600),
	(142609, 'Skórzec', 'gmina', 142600),
	(142610, 'Suchożebry', 'gmina', 142600),
	(142611, 'Wiśniew', 'gmina', 142600),
	(142612, 'Wodynie', 'gmina', 142600),
	(142613, 'Zbuczyn', 'gmina', 142600),
	(142700, 'Sierpecki', 'powiat', 140000),
	(142701, 'Sierpc (miasto)', 'gmina', 142700),
	(142702, 'Gozdowo', 'gmina', 142700),
	(142703, 'Mochowo', 'gmina', 142700),
	(142704, 'Rościszewo', 'gmina', 142700),
	(142705, 'Sierpc', 'gmina', 142700),
	(142706, 'Szczutowo', 'gmina', 142700),
	(142707, 'Zawidz', 'gmina', 142700),
	(142800, 'Sochaczewski', 'powiat', 140000),
	(142801, 'Sochaczew (miasto)', 'gmina', 142800),
	(142802, 'Brochów', 'gmina', 142800),
	(142803, 'Iłów', 'gmina', 142800),
	(142804, 'Młodzieszyn', 'gmina', 142800),
	(142805, 'Nowa Sucha', 'gmina', 142800),
	(142806, 'Rybno', 'gmina', 142800),
	(142807, 'Sochaczew', 'gmina', 142800),
	(142808, 'Teresin', 'gmina', 142800),
	(142900, 'Sokołowski', 'powiat', 140000),
	(142901, 'Sokołów Podlaski (miasto)', 'gmina', 142900),
	(142902, 'Bielany', 'gmina', 142900),
	(142903, 'Ceranów', 'gmina', 142900),
	(142904, 'Jabłonna Lacka', 'gmina', 142900),
	(142905, 'Kosów Lacki', 'gmina', 142900),
	(142906, 'Repki', 'gmina', 142900),
	(142907, 'Sabnie', 'gmina', 142900),
	(142908, 'Sokołów Podlaski', 'gmina', 142900),
	(142909, 'Sterdyń', 'gmina', 142900),
	(143000, 'Szydłowiecki', 'powiat', 140000),
	(143001, 'Chlewiska', 'gmina', 143000),
	(143002, 'Jastrząb', 'gmina', 143000),
	(143003, 'Mirów', 'gmina', 143000),
	(143004, 'Orońsko', 'gmina', 143000),
	(143005, 'Szydłowiec', 'gmina', 143000),
	(143200, 'Warszawski Zachodni', 'powiat', 140000),
	(143201, 'Błonie', 'gmina', 143200),
	(143202, 'Izabelin', 'gmina', 143200),
	(143203, 'Kampinos', 'gmina', 143200),
	(143204, 'Leszno', 'gmina', 143200),
	(143205, 'Łomianki', 'gmina', 143200),
	(143206, 'Ożarów Mazowiecki', 'gmina', 143200),
	(143207, 'Stare Babice', 'gmina', 143200),
	(143300, 'Węgrowski', 'powiat', 140000),
	(143301, 'Węgrów (miasto)', 'gmina', 143300),
	(143302, 'Grębków', 'gmina', 143300),
	(143303, 'Korytnica', 'gmina', 143300),
	(143304, 'Liw', 'gmina', 143300),
	(143305, 'Łochów', 'gmina', 143300),
	(143306, 'Miedzna', 'gmina', 143300),
	(143307, 'Sadowne', 'gmina', 143300),
	(143308, 'Stoczek', 'gmina', 143300),
	(143309, 'Wierzbno', 'gmina', 143300),
	(143400, 'Wołomiński', 'powiat', 140000),
	(143401, 'Kobyłka (miasto)', 'gmina', 143400),
	(143402, 'Marki (miasto)', 'gmina', 143400),
	(143403, 'Ząbki (miasto)', 'gmina', 143400),
	(143404, 'Zielonka (miasto)', 'gmina', 143400),
	(143405, 'Dąbrówka', 'gmina', 143400),
	(143406, 'Jadów', 'gmina', 143400),
	(143407, 'Klembów', 'gmina', 143400),
	(143408, 'Poświętne', 'gmina', 143400),
	(143409, 'Radzymin', 'gmina', 143400),
	(143410, 'Strachówka', 'gmina', 143400),
	(143411, 'Tłuszcz', 'gmina', 143400),
	(143412, 'Wołomin', 'gmina', 143400),
	(143500, 'Wyszkowski', 'powiat', 140000),
	(143501, 'Brańszczyk', 'gmina', 143500),
	(143502, 'Długosiodło', 'gmina', 143500),
	(143503, 'Rząśnik', 'gmina', 143500),
	(143504, 'Somianka', 'gmina', 143500),
	(143505, 'Wyszków', 'gmina', 143500),
	(143506, 'Zabrodzie', 'gmina', 143500),
	(143600, 'Zwoleński', 'powiat', 140000),
	(143601, 'Kazanów', 'gmina', 143600),
	(143602, 'Policzna', 'gmina', 143600),
	(143603, 'Przyłęk', 'gmina', 143600),
	(143604, 'Tczów', 'gmina', 143600),
	(143605, 'Zwoleń', 'gmina', 143600),
	(143700, 'Żuromiński', 'powiat', 140000),
	(143701, 'Bieżuń', 'gmina', 143700),
	(143702, 'Kuczbork-Osada', 'gmina', 143700),
	(143703, 'Lubowidz', 'gmina', 143700),
	(143704, 'Lutocin', 'gmina', 143700),
	(143705, 'Siemiątkowo', 'gmina', 143700),
	(143706, 'Żuromin', 'gmina', 143700),
	(143800, 'Żyrardowski', 'powiat', 140000),
	(143801, 'Żyrardów (miasto)', 'gmina', 143800),
	(143802, 'Mszczonów', 'gmina', 143800),
	(143803, 'Puszcza Mariańska', 'gmina', 143800),
	(143804, 'Radziejowice', 'gmina', 143800),
	(143805, 'Wiskitki', 'gmina', 143800),
	(146100, 'Ostrołęka (miasto)', 'powiat', 140000),
	(146101, 'Ostrołęka (miasto)', 'gmina', 146100),
	(146200, 'Płock (miasto)', 'powiat', 140000),
	(146201, 'Płock (miasto)', 'gmina', 146200),
	(146300, 'Radom (miasto)', 'powiat', 140000),
	(146301, 'Radom (miasto)', 'gmina', 146300),
	(146400, 'Siedlce (miasto)', 'powiat', 140000),
	(146401, 'Siedlce (miasto)', 'gmina', 146400),
	(146500, 'Warszawa', 'powiat', 140000),
	(146501, 'Warszawa', 'gmina', 146500),
	(160000, 'Opolskie', 'województwo', NULL),
	(160100, 'Brzeski', 'powiat', 160000),
	(160101, 'Brzeg (miasto)', 'gmina', 160100),
	(160102, 'Skarbimierz', 'gmina', 160100),
	(160103, 'Grodków', 'gmina', 160100),
	(160104, 'Lewin Brzeski', 'gmina', 160100),
	(160105, 'Lubsza', 'gmina', 160100),
	(160106, 'Olszanka', 'gmina', 160100),
	(160200, 'Głubczycki', 'powiat', 160000),
	(160201, 'Baborów', 'gmina', 160200),
	(160202, 'Branice', 'gmina', 160200),
	(160203, 'Głubczyce', 'gmina', 160200),
	(160204, 'Kietrz', 'gmina', 160200),
	(160300, 'Kędzierzyńsko-Kozielski', 'powiat', 160000),
	(160301, 'Kędzierzyn-Koźle (miasto)', 'gmina', 160300),
	(160302, 'Bierawa', 'gmina', 160300),
	(160303, 'Cisek', 'gmina', 160300),
	(160304, 'Pawłowiczki', 'gmina', 160300),
	(160305, 'Polska Cerekiew', 'gmina', 160300),
	(160306, 'Reńska Wieś', 'gmina', 160300),
	(160400, 'Kluczborski', 'powiat', 160000),
	(160401, 'Byczyna', 'gmina', 160400),
	(160402, 'Kluczbork', 'gmina', 160400),
	(160403, 'Lasowice Wielkie', 'gmina', 160400),
	(160404, 'Wołczyn', 'gmina', 160400),
	(160500, 'Krapkowicki', 'powiat', 160000),
	(160501, 'Gogolin', 'gmina', 160500),
	(160502, 'Krapkowice', 'gmina', 160500),
	(160503, 'Strzeleczki', 'gmina', 160500),
	(160504, 'Walce', 'gmina', 160500),
	(160505, 'Zdzieszowice', 'gmina', 160500),
	(160600, 'Namysłowski', 'powiat', 160000),
	(160601, 'Domaszowice', 'gmina', 160600),
	(160602, 'Namysłów', 'gmina', 160600),
	(160603, 'Pokój', 'gmina', 160600),
	(160604, 'Świerczów', 'gmina', 160600),
	(160605, 'Wilków', 'gmina', 160600),
	(160700, 'Nyski', 'powiat', 160000),
	(160701, 'Głuchołazy', 'gmina', 160700),
	(160702, 'Kamiennik', 'gmina', 160700),
	(160703, 'Korfantów', 'gmina', 160700),
	(160704, 'Łambinowice', 'gmina', 160700),
	(160705, 'Nysa', 'gmina', 160700),
	(160706, 'Otmuchów', 'gmina', 160700),
	(160707, 'Paczków', 'gmina', 160700),
	(160708, 'Pakosławice', 'gmina', 160700),
	(160709, 'Skoroszyce', 'gmina', 160700),
	(160800, 'Oleski', 'powiat', 160000),
	(160801, 'Dobrodzień', 'gmina', 160800),
	(160802, 'Gorzów Śląski', 'gmina', 160800),
	(160803, 'Olesno', 'gmina', 160800),
	(160804, 'Praszka', 'gmina', 160800),
	(160805, 'Radłów', 'gmina', 160800),
	(160806, 'Rudniki', 'gmina', 160800),
	(160807, 'Zębowice', 'gmina', 160800),
	(160900, 'Opolski', 'powiat', 160000),
	(160901, 'Chrząstowice', 'gmina', 160900),
	(160902, 'Dąbrowa', 'gmina', 160900),
	(160903, 'Dobrzeń Wielki', 'gmina', 160900),
	(160904, 'Komprachcice', 'gmina', 160900),
	(160905, 'Łubniany', 'gmina', 160900),
	(160906, 'Murów', 'gmina', 160900),
	(160907, 'Niemodlin', 'gmina', 160900),
	(160908, 'Ozimek', 'gmina', 160900),
	(160909, 'Popielów', 'gmina', 160900),
	(160910, 'Prószków', 'gmina', 160900),
	(160911, 'Tarnów Opolski', 'gmina', 160900),
	(160912, 'Tułowice', 'gmina', 160900),
	(160913, 'Turawa', 'gmina', 160900),
	(161000, 'Prudnicki', 'powiat', 160000),
	(161001, 'Biała', 'gmina', 161000),
	(161002, 'Głogówek', 'gmina', 161000),
	(161003, 'Lubrza', 'gmina', 161000),
	(161004, 'Prudnik', 'gmina', 161000),
	(161100, 'Strzelecki', 'powiat', 160000),
	(161101, 'Izbicko', 'gmina', 161100),
	(161102, 'Jemielnica', 'gmina', 161100),
	(161103, 'Kolonowskie', 'gmina', 161100),
	(161104, 'Leśnica', 'gmina', 161100),
	(161105, 'Strzelce Opolskie', 'gmina', 161100),
	(161106, 'Ujazd', 'gmina', 161100),
	(161107, 'Zawadzkie', 'gmina', 161100),
	(166100, 'Opole (miasto)', 'powiat', 160000),
	(166101, 'Opole (miasto)', 'gmina', 166100),
	(180000, 'Podkarpackie', 'województwo', NULL),
	(180100, 'Bieszczadzki', 'powiat', 180000),
	(180103, 'Czarna', 'gmina', 180100),
	(180105, 'Lutowiska', 'gmina', 180100),
	(180108, 'Ustrzyki Dolne', 'gmina', 180100),
	(180200, 'Brzozowski', 'powiat', 180000),
	(180201, 'Brzozów', 'gmina', 180200),
	(180202, 'Domaradz', 'gmina', 180200),
	(180203, 'Dydnia', 'gmina', 180200),
	(180204, 'Haczów', 'gmina', 180200),
	(180205, 'Jasienica Rosielna', 'gmina', 180200),
	(180206, 'Nozdrzec', 'gmina', 180200),
	(180300, 'Dębicki', 'powiat', 180000),
	(180301, 'Dębica (miasto)', 'gmina', 180300),
	(180302, 'Brzostek', 'gmina', 180300),
	(180303, 'Czarna', 'gmina', 180300),
	(180304, 'Dębica', 'gmina', 180300),
	(180305, 'Jodłowa', 'gmina', 180300),
	(180306, 'Pilzno', 'gmina', 180300),
	(180307, 'Żyraków', 'gmina', 180300),
	(180400, 'Jarosławski', 'powiat', 180000),
	(180401, 'Jarosław (miasto)', 'gmina', 180400),
	(180402, 'Radymno (miasto)', 'gmina', 180400),
	(180403, 'Chłopice', 'gmina', 180400),
	(180404, 'Jarosław', 'gmina', 180400),
	(180405, 'Laszki', 'gmina', 180400),
	(180406, 'Pawłosiów', 'gmina', 180400),
	(180407, 'Pruchnik', 'gmina', 180400),
	(180408, 'Radymno', 'gmina', 180400),
	(180409, 'Rokietnica', 'gmina', 180400),
	(180410, 'Roźwienica', 'gmina', 180400),
	(180411, 'Wiązownica', 'gmina', 180400),
	(180500, 'Jasielski', 'powiat', 180000),
	(180501, 'Jasło (miasto)', 'gmina', 180500),
	(180502, 'Brzyska', 'gmina', 180500),
	(180503, 'Dębowiec', 'gmina', 180500),
	(180504, 'Jasło', 'gmina', 180500),
	(180505, 'Kołaczyce', 'gmina', 180500),
	(180506, 'Krempna', 'gmina', 180500),
	(180507, 'Nowy Żmigród', 'gmina', 180500),
	(180508, 'Osiek Jasielski', 'gmina', 180500),
	(180509, 'Skołyszyn', 'gmina', 180500),
	(180511, 'Tarnowiec', 'gmina', 180500),
	(180600, 'Kolbuszowski', 'powiat', 180000),
	(180601, 'Cmolas', 'gmina', 180600),
	(180602, 'Kolbuszowa', 'gmina', 180600),
	(180603, 'Majdan Królewski', 'gmina', 180600),
	(180604, 'Niwiska', 'gmina', 180600),
	(180605, 'Raniżów', 'gmina', 180600),
	(180606, 'Dzikowiec', 'gmina', 180600),
	(180700, 'Krośnieński', 'powiat', 180000),
	(180701, 'Chorkówka', 'gmina', 180700),
	(180702, 'Dukla', 'gmina', 180700),
	(180703, 'Iwonicz-Zdrój', 'gmina', 180700),
	(180704, 'Jedlicze', 'gmina', 180700),
	(180705, 'Korczyna', 'gmina', 180700),
	(180706, 'Krościenko Wyżne', 'gmina', 180700),
	(180707, 'Miejsce Piastowe', 'gmina', 180700),
	(180708, 'Rymanów', 'gmina', 180700),
	(180709, 'Wojaszówka', 'gmina', 180700),
	(180710, 'Jaśliska', 'gmina', 180700),
	(180800, 'Leżajski', 'powiat', 180000),
	(180801, 'Leżajsk (miasto)', 'gmina', 180800),
	(180802, 'Grodzisko Dolne', 'gmina', 180800),
	(180803, 'Kuryłówka', 'gmina', 180800),
	(180804, 'Leżajsk', 'gmina', 180800),
	(180805, 'Nowa Sarzyna', 'gmina', 180800),
	(180900, 'Lubaczowski', 'powiat', 180000),
	(180901, 'Lubaczów (miasto)', 'gmina', 180900),
	(180902, 'Cieszanów', 'gmina', 180900),
	(180903, 'Horyniec-Zdrój', 'gmina', 180900),
	(180904, 'Lubaczów', 'gmina', 180900),
	(180905, 'Narol', 'gmina', 180900),
	(180906, 'Oleszyce', 'gmina', 180900),
	(180907, 'Stary Dzików', 'gmina', 180900),
	(180908, 'Wielkie Oczy', 'gmina', 180900),
	(181000, 'Łańcucki', 'powiat', 180000),
	(181001, 'Łańcut (miasto)', 'gmina', 181000),
	(181002, 'Białobrzegi', 'gmina', 181000),
	(181003, 'Czarna', 'gmina', 181000),
	(181004, 'Łańcut', 'gmina', 181000),
	(181005, 'Markowa', 'gmina', 181000),
	(181006, 'Rakszawa', 'gmina', 181000),
	(181007, 'Żołynia', 'gmina', 181000),
	(181100, 'Mielecki', 'powiat', 180000),
	(181101, 'Mielec (miasto)', 'gmina', 181100),
	(181102, 'Borowa', 'gmina', 181100),
	(181103, 'Czermin', 'gmina', 181100),
	(181104, 'Gawłuszowice', 'gmina', 181100),
	(181105, 'Mielec', 'gmina', 181100),
	(181106, 'Padew Narodowa', 'gmina', 181100),
	(181107, 'Przecław', 'gmina', 181100),
	(181108, 'Radomyśl Wielki', 'gmina', 181100),
	(181109, 'Tuszów Narodowy', 'gmina', 181100),
	(181110, 'Wadowice Górne', 'gmina', 181100),
	(181200, 'Niżański', 'powiat', 180000),
	(181201, 'Harasiuki', 'gmina', 181200),
	(181202, 'Jarocin', 'gmina', 181200),
	(181203, 'Jeżowe', 'gmina', 181200),
	(181204, 'Krzeszów', 'gmina', 181200),
	(181205, 'Nisko', 'gmina', 181200),
	(181206, 'Rudnik Nad Sanem', 'gmina', 181200),
	(181207, 'Ulanów', 'gmina', 181200),
	(181300, 'Przemyski', 'powiat', 180000),
	(181301, 'Bircza', 'gmina', 181300),
	(181302, 'Dubiecko', 'gmina', 181300),
	(181303, 'Fredropol', 'gmina', 181300),
	(181304, 'Krasiczyn', 'gmina', 181300),
	(181305, 'Krzywcza', 'gmina', 181300),
	(181306, 'Medyka', 'gmina', 181300),
	(181307, 'Orły', 'gmina', 181300),
	(181308, 'Przemyśl', 'gmina', 181300),
	(181309, 'Stubno', 'gmina', 181300),
	(181310, 'Żurawica', 'gmina', 181300),
	(181400, 'Przeworski', 'powiat', 180000),
	(181401, 'Przeworsk (miasto)', 'gmina', 181400),
	(181402, 'Adamówka', 'gmina', 181400),
	(181403, 'Gać', 'gmina', 181400),
	(181404, 'Jawornik Polski', 'gmina', 181400),
	(181405, 'Kańczuga', 'gmina', 181400),
	(181406, 'Przeworsk', 'gmina', 181400),
	(181407, 'Sieniawa', 'gmina', 181400),
	(181408, 'Tryńcza', 'gmina', 181400),
	(181409, 'Zarzecze', 'gmina', 181400),
	(181500, 'Ropczycko-Sędziszowski', 'powiat', 180000),
	(181501, 'Iwierzyce', 'gmina', 181500),
	(181502, 'Ostrów', 'gmina', 181500),
	(181503, 'Ropczyce', 'gmina', 181500),
	(181504, 'Sędziszów Małopolski', 'gmina', 181500),
	(181505, 'Wielopole Skrzyńskie', 'gmina', 181500),
	(181600, 'Rzeszowski', 'powiat', 180000),
	(181601, 'Dynów (miasto)', 'gmina', 181600),
	(181602, 'Błażowa', 'gmina', 181600),
	(181603, 'Boguchwała', 'gmina', 181600),
	(181604, 'Chmielnik', 'gmina', 181600),
	(181605, 'Dynów', 'gmina', 181600),
	(181606, 'Głogów Małopolski', 'gmina', 181600),
	(181607, 'Hyżne', 'gmina', 181600),
	(181608, 'Kamień', 'gmina', 181600),
	(181609, 'Krasne', 'gmina', 181600),
	(181610, 'Lubenia', 'gmina', 181600),
	(181611, 'Sokołów Małopolski', 'gmina', 181600),
	(181612, 'Świlcza', 'gmina', 181600),
	(181613, 'Trzebownisko', 'gmina', 181600),
	(181614, 'Tyczyn', 'gmina', 181600),
	(181700, 'Sanocki', 'powiat', 180000),
	(181701, 'Sanok (miasto)', 'gmina', 181700),
	(181702, 'Besko', 'gmina', 181700),
	(181703, 'Bukowsko', 'gmina', 181700),
	(181704, 'Komańcza', 'gmina', 181700),
	(181705, 'Sanok', 'gmina', 181700),
	(181706, 'Tyrawa Wołoska', 'gmina', 181700),
	(181707, 'Zagórz', 'gmina', 181700),
	(181708, 'Zarszyn', 'gmina', 181700),
	(181800, 'Stalowowolski', 'powiat', 180000),
	(181801, 'Stalowa Wola (miasto)', 'gmina', 181800),
	(181802, 'Bojanów', 'gmina', 181800),
	(181803, 'Pysznica', 'gmina', 181800),
	(181804, 'Radomyśl Nad Sanem', 'gmina', 181800),
	(181805, 'Zaklików', 'gmina', 181800),
	(181806, 'Zaleszany', 'gmina', 181800),
	(181900, 'Strzyżowski', 'powiat', 180000),
	(181901, 'Czudec', 'gmina', 181900),
	(181902, 'Frysztak', 'gmina', 181900),
	(181903, 'Niebylec', 'gmina', 181900),
	(181904, 'Strzyżów', 'gmina', 181900),
	(181905, 'Wiśniowa', 'gmina', 181900),
	(182000, 'Tarnobrzeski', 'powiat', 180000),
	(182001, 'Baranów Sandomierski', 'gmina', 182000),
	(182002, 'Gorzyce', 'gmina', 182000),
	(182003, 'Grębów', 'gmina', 182000),
	(182004, 'Nowa Dęba', 'gmina', 182000),
	(182100, 'Leski', 'powiat', 180000),
	(182101, 'Baligród', 'gmina', 182100),
	(182102, 'Cisna', 'gmina', 182100),
	(182103, 'Lesko', 'gmina', 182100),
	(182104, 'Olszanica', 'gmina', 182100),
	(182105, 'Solina', 'gmina', 182100),
	(186100, 'Krosno (miasto)', 'powiat', 180000),
	(186101, 'Krosno (miasto)', 'gmina', 186100),
	(186200, 'Przemyśl (miasto)', 'powiat', 180000),
	(186201, 'Przemyśl (miasto)', 'gmina', 186200),
	(186300, 'Rzeszów (miasto)', 'powiat', 180000),
	(186301, 'Rzeszów (miasto)', 'gmina', 186300),
	(186400, 'Tarnobrzeg (miasto)', 'powiat', 180000),
	(186401, 'Tarnobrzeg (miasto)', 'gmina', 186400),
	(200000, 'Podlaskie', 'województwo', NULL),
	(200100, 'Augustowski', 'powiat', 200000),
	(200101, 'Augustów (miasto)', 'gmina', 200100),
	(200102, 'Augustów', 'gmina', 200100),
	(200103, 'Bargłów Kościelny', 'gmina', 200100),
	(200104, 'Lipsk', 'gmina', 200100),
	(200105, 'Nowinka', 'gmina', 200100),
	(200106, 'Płaska', 'gmina', 200100),
	(200107, 'Sztabin', 'gmina', 200100),
	(200200, 'Białostocki', 'powiat', 200000),
	(200201, 'Choroszcz', 'gmina', 200200),
	(200202, 'Czarna Białostocka', 'gmina', 200200),
	(200203, 'Dobrzyniewo Duże', 'gmina', 200200),
	(200204, 'Gródek', 'gmina', 200200),
	(200205, 'Juchnowiec Kościelny', 'gmina', 200200),
	(200206, 'Łapy', 'gmina', 200200),
	(200207, 'Michałowo', 'gmina', 200200),
	(200208, 'Poświętne', 'gmina', 200200),
	(200209, 'Supraśl', 'gmina', 200200),
	(200210, 'Suraż', 'gmina', 200200),
	(200211, 'Turośń Kościelna', 'gmina', 200200),
	(200212, 'Tykocin', 'gmina', 200200),
	(200213, 'Wasilków', 'gmina', 200200),
	(200214, 'Zabłudów', 'gmina', 200200),
	(200215, 'Zawady', 'gmina', 200200),
	(200300, 'Bielski', 'powiat', 200000),
	(200301, 'Bielsk Podlaski (miasto)', 'gmina', 200300),
	(200302, 'Brańsk (miasto)', 'gmina', 200300),
	(200303, 'Bielsk Podlaski', 'gmina', 200300),
	(200304, 'Boćki', 'gmina', 200300),
	(200305, 'Brańsk', 'gmina', 200300),
	(200306, 'Orla', 'gmina', 200300),
	(200307, 'Rudka', 'gmina', 200300),
	(200308, 'Wyszki', 'gmina', 200300),
	(200400, 'Grajewski', 'powiat', 200000),
	(200401, 'Grajewo (miasto)', 'gmina', 200400),
	(200402, 'Grajewo', 'gmina', 200400),
	(200403, 'Radziłów', 'gmina', 200400),
	(200404, 'Rajgród', 'gmina', 200400),
	(200405, 'Szczuczyn', 'gmina', 200400),
	(200406, 'Wąsosz', 'gmina', 200400),
	(200500, 'Hajnowski', 'powiat', 200000),
	(200501, 'Hajnówka (miasto)', 'gmina', 200500),
	(200502, 'Białowieża', 'gmina', 200500),
	(200503, 'Czeremcha', 'gmina', 200500),
	(200504, 'Czyże', 'gmina', 200500),
	(200505, 'Dubicze Cerkiewne', 'gmina', 200500),
	(200506, 'Hajnówka', 'gmina', 200500),
	(200507, 'Kleszczele', 'gmina', 200500),
	(200508, 'Narew', 'gmina', 200500),
	(200509, 'Narewka', 'gmina', 200500),
	(200600, 'Kolneński', 'powiat', 200000),
	(200601, 'Kolno (miasto)', 'gmina', 200600),
	(200602, 'Grabowo', 'gmina', 200600),
	(200603, 'Kolno', 'gmina', 200600),
	(200604, 'Mały Płock', 'gmina', 200600),
	(200605, 'Stawiski', 'gmina', 200600),
	(200606, 'Turośl', 'gmina', 200600),
	(200700, 'Łomżyński', 'powiat', 200000),
	(200701, 'Jedwabne', 'gmina', 200700),
	(200702, 'Łomża', 'gmina', 200700),
	(200703, 'Miastkowo', 'gmina', 200700),
	(200704, 'Nowogród', 'gmina', 200700),
	(200705, 'Piątnica', 'gmina', 200700),
	(200706, 'Przytuły', 'gmina', 200700),
	(200707, 'Śniadowo', 'gmina', 200700),
	(200708, 'Wizna', 'gmina', 200700),
	(200709, 'Zbójna', 'gmina', 200700),
	(200800, 'Moniecki', 'powiat', 200000),
	(200801, 'Goniądz', 'gmina', 200800),
	(200802, 'Jasionówka', 'gmina', 200800),
	(200803, 'Jaświły', 'gmina', 200800),
	(200804, 'Knyszyn', 'gmina', 200800),
	(200805, 'Krypno', 'gmina', 200800),
	(200806, 'Mońki', 'gmina', 200800),
	(200807, 'Trzcianne', 'gmina', 200800),
	(200900, 'Sejneński', 'powiat', 200000),
	(200901, 'Sejny (miasto)', 'gmina', 200900),
	(200902, 'Giby', 'gmina', 200900),
	(200903, 'Krasnopol', 'gmina', 200900),
	(200904, 'Puńsk', 'gmina', 200900),
	(200905, 'Sejny', 'gmina', 200900),
	(201000, 'Siemiatycki', 'powiat', 200000),
	(201001, 'Siemiatycze (miasto)', 'gmina', 201000),
	(201002, 'Drohiczyn', 'gmina', 201000),
	(201003, 'Dziadkowice', 'gmina', 201000),
	(201004, 'Grodzisk', 'gmina', 201000),
	(201005, 'Mielnik', 'gmina', 201000),
	(201006, 'Milejczyce', 'gmina', 201000),
	(201007, 'Nurzec-Stacja', 'gmina', 201000),
	(201008, 'Perlejewo', 'gmina', 201000),
	(201009, 'Siemiatycze', 'gmina', 201000),
	(201100, 'Sokólski', 'powiat', 200000),
	(201101, 'Dąbrowa Białostocka', 'gmina', 201100),
	(201102, 'Janów', 'gmina', 201100),
	(201103, 'Korycin', 'gmina', 201100),
	(201104, 'Krynki', 'gmina', 201100),
	(201105, 'Kuźnica', 'gmina', 201100),
	(201106, 'Nowy Dwór', 'gmina', 201100),
	(201107, 'Sidra', 'gmina', 201100),
	(201108, 'Sokółka', 'gmina', 201100),
	(201109, 'Suchowola', 'gmina', 201100),
	(201110, 'Szudziałowo', 'gmina', 201100),
	(201200, 'Suwalski', 'powiat', 200000),
	(201201, 'Bakałarzewo', 'gmina', 201200),
	(201202, 'Filipów', 'gmina', 201200),
	(201203, 'Jeleniewo', 'gmina', 201200),
	(201204, 'Przerośl', 'gmina', 201200),
	(201205, 'Raczki', 'gmina', 201200),
	(201206, 'Rutka-Tartak', 'gmina', 201200),
	(201207, 'Suwałki', 'gmina', 201200),
	(201208, 'Szypliszki', 'gmina', 201200),
	(201209, 'Wiżajny', 'gmina', 201200),
	(201300, 'Wysokomazowiecki', 'powiat', 200000),
	(201301, 'Wysokie Mazowieckie (miasto)', 'gmina', 201300),
	(201302, 'Ciechanowiec', 'gmina', 201300),
	(201303, 'Czyżew', 'gmina', 201300),
	(201304, 'Klukowo', 'gmina', 201300),
	(201305, 'Kobylin-Borzymy', 'gmina', 201300),
	(201306, 'Kulesze Kościelne', 'gmina', 201300),
	(201307, 'Nowe Piekuty', 'gmina', 201300),
	(201308, 'Sokoły', 'gmina', 201300),
	(201309, 'Szepietowo', 'gmina', 201300),
	(201310, 'Wysokie Mazowieckie', 'gmina', 201300),
	(201400, 'Zambrowski', 'powiat', 200000),
	(201401, 'Zambrów (miasto)', 'gmina', 201400),
	(201402, 'Kołaki Kościelne', 'gmina', 201400),
	(201403, 'Rutki', 'gmina', 201400),
	(201404, 'Szumowo', 'gmina', 201400),
	(201405, 'Zambrów', 'gmina', 201400),
	(206100, 'Białystok (miasto)', 'powiat', 200000),
	(206101, 'Białystok (miasto)', 'gmina', 206100),
	(206200, 'Łomża (miasto)', 'powiat', 200000),
	(206201, 'Łomża (miasto)', 'gmina', 206200),
	(206300, 'Suwałki (miasto)', 'powiat', 200000),
	(206301, 'Suwałki (miasto)', 'gmina', 206300),
	(220000, 'Pomorskie', 'województwo', NULL),
	(220100, 'Bytowski', 'powiat', 220000),
	(220101, 'Borzytuchom', 'gmina', 220100),
	(220102, 'Bytów', 'gmina', 220100),
	(220103, 'Czarna Dąbrówka', 'gmina', 220100),
	(220104, 'Kołczygłowy', 'gmina', 220100),
	(220105, 'Lipnica', 'gmina', 220100),
	(220106, 'Miastko', 'gmina', 220100),
	(220107, 'Parchowo', 'gmina', 220100),
	(220108, 'Studzienice', 'gmina', 220100),
	(220109, 'Trzebielino', 'gmina', 220100),
	(220110, 'Tuchomie', 'gmina', 220100),
	(220200, 'Chojnicki', 'powiat', 220000),
	(220201, 'Chojnice (miasto)', 'gmina', 220200),
	(220202, 'Brusy', 'gmina', 220200),
	(220203, 'Chojnice', 'gmina', 220200),
	(220204, 'Czersk', 'gmina', 220200),
	(220205, 'Konarzyny', 'gmina', 220200),
	(220300, 'Człuchowski', 'powiat', 220000),
	(220301, 'Człuchów (miasto)', 'gmina', 220300),
	(220302, 'Czarne', 'gmina', 220300),
	(220303, 'Człuchów', 'gmina', 220300),
	(220304, 'Debrzno', 'gmina', 220300),
	(220305, 'Koczała', 'gmina', 220300),
	(220306, 'Przechlewo', 'gmina', 220300),
	(220307, 'Rzeczenica', 'gmina', 220300),
	(220400, 'Gdański', 'powiat', 220000),
	(220401, 'Pruszcz Gdański (miasto)', 'gmina', 220400),
	(220402, 'Cedry Wielkie', 'gmina', 220400),
	(220403, 'Kolbudy', 'gmina', 220400),
	(220404, 'Pruszcz Gdański', 'gmina', 220400),
	(220405, 'Przywidz', 'gmina', 220400),
	(220406, 'Pszczółki', 'gmina', 220400),
	(220407, 'Suchy Dąb', 'gmina', 220400),
	(220408, 'Trąbki Wielkie', 'gmina', 220400),
	(220500, 'Kartuski', 'powiat', 220000),
	(220501, 'Chmielno', 'gmina', 220500),
	(220502, 'Kartuzy', 'gmina', 220500),
	(220503, 'Przodkowo', 'gmina', 220500),
	(220504, 'Sierakowice', 'gmina', 220500),
	(220505, 'Somonino', 'gmina', 220500),
	(220506, 'Stężyca', 'gmina', 220500),
	(220507, 'Sulęczyno', 'gmina', 220500),
	(220508, 'Żukowo', 'gmina', 220500),
	(220600, 'Kościerski', 'powiat', 220000),
	(220601, 'Kościerzyna (miasto)', 'gmina', 220600),
	(220602, 'Dziemiany', 'gmina', 220600),
	(220603, 'Karsin', 'gmina', 220600),
	(220604, 'Kościerzyna', 'gmina', 220600),
	(220605, 'Liniewo', 'gmina', 220600),
	(220606, 'Lipusz', 'gmina', 220600),
	(220607, 'Nowa Karczma', 'gmina', 220600),
	(220608, 'Stara Kiszewa', 'gmina', 220600),
	(220700, 'Kwidzyński', 'powiat', 220000),
	(220701, 'Kwidzyn (miasto)', 'gmina', 220700),
	(220702, 'Gardeja', 'gmina', 220700),
	(220703, 'Kwidzyn', 'gmina', 220700),
	(220704, 'Prabuty', 'gmina', 220700),
	(220705, 'Ryjewo', 'gmina', 220700),
	(220706, 'Sadlinki', 'gmina', 220700),
	(220800, 'Lęborski', 'powiat', 220000),
	(220801, 'Lębork (miasto)', 'gmina', 220800),
	(220802, 'Łeba (miasto)', 'gmina', 220800),
	(220803, 'Cewice', 'gmina', 220800),
	(220804, 'Nowa Wieś Lęborska', 'gmina', 220800),
	(220805, 'Wicko', 'gmina', 220800),
	(220900, 'Malborski', 'powiat', 220000),
	(220901, 'Malbork (miasto)', 'gmina', 220900),
	(220903, 'Lichnowy', 'gmina', 220900),
	(220904, 'Malbork', 'gmina', 220900),
	(220906, 'Miłoradz', 'gmina', 220900),
	(220907, 'Nowy Staw', 'gmina', 220900),
	(220908, 'Stare Pole', 'gmina', 220900),
	(221000, 'Nowodworski', 'powiat', 220000),
	(221001, 'Krynica Morska (miasto)', 'gmina', 221000),
	(221002, 'Nowy Dwór Gdański', 'gmina', 221000),
	(221003, 'Ostaszewo', 'gmina', 221000),
	(221004, 'Stegna', 'gmina', 221000),
	(221005, 'Sztutowo', 'gmina', 221000),
	(221100, 'Pucki', 'powiat', 220000),
	(221101, 'Hel (miasto)', 'gmina', 221100),
	(221102, 'Jastarnia', 'gmina', 221100),
	(221103, 'Puck (miasto)', 'gmina', 221100),
	(221104, 'Władysławowo', 'gmina', 221100),
	(221105, 'Kosakowo', 'gmina', 221100),
	(221106, 'Krokowa', 'gmina', 221100),
	(221107, 'Puck', 'gmina', 221100),
	(221200, 'Słupski', 'powiat', 220000),
	(221201, 'Ustka (miasto)', 'gmina', 221200),
	(221202, 'Damnica', 'gmina', 221200),
	(221203, 'Dębnica Kaszubska', 'gmina', 221200),
	(221204, 'Główczyce', 'gmina', 221200),
	(221205, 'Kępice', 'gmina', 221200),
	(221206, 'Kobylnica', 'gmina', 221200),
	(221207, 'Potęgowo', 'gmina', 221200),
	(221208, 'Słupsk', 'gmina', 221200),
	(221209, 'Smołdzino', 'gmina', 221200),
	(221210, 'Ustka', 'gmina', 221200),
	(221300, 'Starogardzki', 'powiat', 220000),
	(221301, 'Czarna Woda', 'gmina', 221300),
	(221302, 'Skórcz (miasto)', 'gmina', 221300),
	(221303, 'Starogard Gdański (miasto)', 'gmina', 221300),
	(221304, 'Bobowo', 'gmina', 221300),
	(221305, 'Kaliska', 'gmina', 221300),
	(221306, 'Lubichowo', 'gmina', 221300),
	(221307, 'Osieczna', 'gmina', 221300),
	(221308, 'Osiek', 'gmina', 221300),
	(221309, 'Skarszewy', 'gmina', 221300),
	(221310, 'Skórcz', 'gmina', 221300),
	(221311, 'Smętowo Graniczne', 'gmina', 221300),
	(221312, 'Starogard Gdański', 'gmina', 221300),
	(221313, 'Zblewo', 'gmina', 221300),
	(221400, 'Tczewski', 'powiat', 220000),
	(221401, 'Tczew (miasto)', 'gmina', 221400),
	(221402, 'Gniew', 'gmina', 221400),
	(221403, 'Morzeszczyn', 'gmina', 221400),
	(221404, 'Pelplin', 'gmina', 221400),
	(221405, 'Subkowy', 'gmina', 221400),
	(221406, 'Tczew', 'gmina', 221400),
	(221500, 'Wejherowski', 'powiat', 220000),
	(221501, 'Reda (miasto)', 'gmina', 221500),
	(221502, 'Rumia (miasto)', 'gmina', 221500),
	(221503, 'Wejherowo (miasto)', 'gmina', 221500),
	(221504, 'Choczewo', 'gmina', 221500),
	(221505, 'Gniewino', 'gmina', 221500),
	(221506, 'Linia', 'gmina', 221500),
	(221507, 'Luzino', 'gmina', 221500),
	(221508, 'Łęczyce', 'gmina', 221500),
	(221509, 'Szemud', 'gmina', 221500),
	(221510, 'Wejherowo', 'gmina', 221500),
	(221600, 'Sztumski', 'powiat', 220000),
	(221601, 'Dzierzgoń', 'gmina', 221600),
	(221602, 'Mikołajki Pomorskie', 'gmina', 221600),
	(221603, 'Stary Dzierzgoń', 'gmina', 221600),
	(221604, 'Stary Targ', 'gmina', 221600),
	(221605, 'Sztum', 'gmina', 221600),
	(226100, 'Gdańsk (miasto)', 'powiat', 220000),
	(226101, 'Gdańsk (miasto)', 'gmina', 226100),
	(226200, 'Gdynia (miasto)', 'powiat', 220000),
	(226201, 'Gdynia (miasto)', 'gmina', 226200),
	(226300, 'Słupsk (miasto)', 'powiat', 220000),
	(226301, 'Słupsk (miasto)', 'gmina', 226300),
	(226400, 'Sopot (miasto)', 'powiat', 220000),
	(226401, 'Sopot (miasto)', 'gmina', 226400),
	(240000, 'Śląskie', 'województwo', NULL),
	(240100, 'Będziński', 'powiat', 240000),
	(240101, 'Będzin (miasto)', 'gmina', 240100),
	(240102, 'Czeladź (miasto)', 'gmina', 240100),
	(240103, 'Wojkowice (miasto)', 'gmina', 240100),
	(240104, 'Bobrowniki', 'gmina', 240100),
	(240105, 'Mierzęcice', 'gmina', 240100),
	(240106, 'Psary', 'gmina', 240100),
	(240107, 'Siewierz', 'gmina', 240100),
	(240108, 'Sławków (miasto)', 'gmina', 240100),
	(240200, 'Bielski', 'powiat', 240000),
	(240201, 'Szczyrk (miasto)', 'gmina', 240200),
	(240202, 'Bestwina', 'gmina', 240200),
	(240203, 'Buczkowice', 'gmina', 240200),
	(240204, 'Czechowice-Dziedzice', 'gmina', 240200),
	(240205, 'Jasienica', 'gmina', 240200),
	(240206, 'Jaworze', 'gmina', 240200),
	(240207, 'Kozy', 'gmina', 240200),
	(240208, 'Porąbka', 'gmina', 240200),
	(240209, 'Wilamowice', 'gmina', 240200),
	(240210, 'Wilkowice', 'gmina', 240200),
	(240300, 'Cieszyński', 'powiat', 240000),
	(240301, 'Cieszyn (miasto)', 'gmina', 240300),
	(240302, 'Ustroń (miasto)', 'gmina', 240300),
	(240303, 'Wisła (miasto)', 'gmina', 240300),
	(240304, 'Brenna', 'gmina', 240300),
	(240305, 'Chybie', 'gmina', 240300),
	(240306, 'Dębowiec', 'gmina', 240300),
	(240307, 'Goleszów', 'gmina', 240300),
	(240308, 'Hażlach', 'gmina', 240300),
	(240309, 'Istebna', 'gmina', 240300),
	(240310, 'Skoczów', 'gmina', 240300),
	(240311, 'Strumień', 'gmina', 240300),
	(240312, 'Zebrzydowice', 'gmina', 240300),
	(240400, 'Częstochowski', 'powiat', 240000),
	(240401, 'Blachownia', 'gmina', 240400),
	(240402, 'Dąbrowa Zielona', 'gmina', 240400),
	(240403, 'Janów', 'gmina', 240400),
	(240404, 'Kamienica Polska', 'gmina', 240400),
	(240405, 'Kłomnice', 'gmina', 240400),
	(240406, 'Koniecpol', 'gmina', 240400),
	(240407, 'Konopiska', 'gmina', 240400),
	(240408, 'Kruszyna', 'gmina', 240400),
	(240409, 'Lelów', 'gmina', 240400),
	(240410, 'Mstów', 'gmina', 240400),
	(240411, 'Mykanów', 'gmina', 240400),
	(240412, 'Olsztyn', 'gmina', 240400),
	(240413, 'Poczesna', 'gmina', 240400),
	(240414, 'Przyrów', 'gmina', 240400),
	(240415, 'Rędziny', 'gmina', 240400),
	(240416, 'Starcza', 'gmina', 240400),
	(240500, 'Gliwicki', 'powiat', 240000),
	(240501, 'Knurów (miasto)', 'gmina', 240500),
	(240502, 'Pyskowice (miasto)', 'gmina', 240500),
	(240503, 'Gierałtowice', 'gmina', 240500),
	(240504, 'Pilchowice', 'gmina', 240500),
	(240505, 'Rudziniec', 'gmina', 240500),
	(240506, 'Sośnicowice', 'gmina', 240500),
	(240507, 'Toszek', 'gmina', 240500),
	(240508, 'Wielowieś', 'gmina', 240500),
	(240600, 'Kłobucki', 'powiat', 240000),
	(240601, 'Kłobuck', 'gmina', 240600),
	(240602, 'Krzepice', 'gmina', 240600),
	(240603, 'Lipie', 'gmina', 240600),
	(240604, 'Miedźno', 'gmina', 240600),
	(240605, 'Opatów', 'gmina', 240600),
	(240606, 'Panki', 'gmina', 240600),
	(240607, 'Popów', 'gmina', 240600),
	(240608, 'Przystajń', 'gmina', 240600),
	(240609, 'Wręczyca Wielka', 'gmina', 240600),
	(240700, 'Lubliniecki', 'powiat', 240000),
	(240701, 'Lubliniec (miasto)', 'gmina', 240700),
	(240702, 'Boronów', 'gmina', 240700),
	(240703, 'Ciasna', 'gmina', 240700),
	(240704, 'Herby', 'gmina', 240700),
	(240705, 'Kochanowice', 'gmina', 240700),
	(240706, 'Koszęcin', 'gmina', 240700),
	(240707, 'Pawonków', 'gmina', 240700),
	(240708, 'Woźniki', 'gmina', 240700),
	(240800, 'Mikołowski', 'powiat', 240000),
	(240801, 'Łaziska Górne (miasto)', 'gmina', 240800),
	(240802, 'Mikołów (miasto)', 'gmina', 240800),
	(240803, 'Orzesze (miasto)', 'gmina', 240800),
	(240804, 'Ornontowice', 'gmina', 240800),
	(240805, 'Wyry', 'gmina', 240800),
	(240900, 'Myszkowski', 'powiat', 240000),
	(240901, 'Myszków (miasto)', 'gmina', 240900),
	(240902, 'Koziegłowy', 'gmina', 240900),
	(240903, 'Niegowa', 'gmina', 240900),
	(240904, 'Poraj', 'gmina', 240900),
	(240905, 'Żarki', 'gmina', 240900),
	(241000, 'Pszczyński', 'powiat', 240000),
	(241001, 'Goczałkowice-Zdrój', 'gmina', 241000),
	(241002, 'Kobiór', 'gmina', 241000),
	(241003, 'Miedźna', 'gmina', 241000),
	(241004, 'Pawłowice', 'gmina', 241000),
	(241005, 'Pszczyna', 'gmina', 241000),
	(241006, 'Suszec', 'gmina', 241000),
	(241100, 'Raciborski', 'powiat', 240000),
	(241101, 'Racibórz (miasto)', 'gmina', 241100),
	(241102, 'Kornowac', 'gmina', 241100),
	(241103, 'Krzanowice', 'gmina', 241100),
	(241104, 'Krzyżanowice', 'gmina', 241100),
	(241105, 'Kuźnia Raciborska', 'gmina', 241100),
	(241106, 'Nędza', 'gmina', 241100),
	(241107, 'Pietrowice Wielkie', 'gmina', 241100),
	(241108, 'Rudnik', 'gmina', 241100),
	(241200, 'Rybnicki', 'powiat', 240000),
	(241201, 'Czerwionka-Leszczyny', 'gmina', 241200),
	(241202, 'Gaszowice', 'gmina', 241200),
	(241203, 'Jejkowice', 'gmina', 241200),
	(241204, 'Lyski', 'gmina', 241200),
	(241205, 'Świerklany', 'gmina', 241200),
	(241300, 'Tarnogórski', 'powiat', 240000),
	(241301, 'Kalety (miasto)', 'gmina', 241300),
	(241302, 'Miasteczko Śląskie (miasto)', 'gmina', 241300),
	(241303, 'Radzionków (miasto)', 'gmina', 241300),
	(241304, 'Tarnowskie Góry (miasto)', 'gmina', 241300),
	(241305, 'Krupski Młyn', 'gmina', 241300),
	(241306, 'Ożarowice', 'gmina', 241300),
	(241307, 'Świerklaniec', 'gmina', 241300),
	(241308, 'Tworóg', 'gmina', 241300),
	(241309, 'Zbrosławice', 'gmina', 241300),
	(241400, 'Bieruńsko-Lędziński', 'powiat', 240000),
	(241401, 'Bieruń (miasto)', 'gmina', 241400),
	(241402, 'Imielin (miasto)', 'gmina', 241400),
	(241403, 'Lędziny (miasto)', 'gmina', 241400),
	(241404, 'Bojszowy', 'gmina', 241400),
	(241405, 'Chełm Śląski', 'gmina', 241400),
	(241500, 'Wodzisławski', 'powiat', 240000),
	(241501, 'Pszów (miasto)', 'gmina', 241500),
	(241502, 'Radlin (miasto)', 'gmina', 241500),
	(241503, 'Rydułtowy (miasto)', 'gmina', 241500),
	(241504, 'Wodzisław Śląski (miasto)', 'gmina', 241500),
	(241505, 'Godów', 'gmina', 241500),
	(241506, 'Gorzyce', 'gmina', 241500),
	(241507, 'Lubomia', 'gmina', 241500),
	(241508, 'Marklowice', 'gmina', 241500),
	(241509, 'Mszana', 'gmina', 241500),
	(241600, 'Zawierciański', 'powiat', 240000),
	(241601, 'Poręba (miasto)', 'gmina', 241600),
	(241602, 'Zawiercie (miasto)', 'gmina', 241600),
	(241603, 'Irządze', 'gmina', 241600),
	(241604, 'Kroczyce', 'gmina', 241600),
	(241605, 'Łazy', 'gmina', 241600),
	(241606, 'Ogrodzieniec', 'gmina', 241600),
	(241607, 'Pilica', 'gmina', 241600),
	(241608, 'Szczekociny', 'gmina', 241600),
	(241609, 'Włodowice', 'gmina', 241600),
	(241610, 'Żarnowiec', 'gmina', 241600),
	(241700, 'Żywiecki', 'powiat', 240000),
	(241701, 'Żywiec (miasto)', 'gmina', 241700),
	(241702, 'Czernichów', 'gmina', 241700),
	(241703, 'Gilowice', 'gmina', 241700),
	(241704, 'Jeleśnia', 'gmina', 241700),
	(241705, 'Koszarawa', 'gmina', 241700),
	(241706, 'Lipowa', 'gmina', 241700),
	(241707, 'Łękawica', 'gmina', 241700),
	(241708, 'Łodygowice', 'gmina', 241700),
	(241709, 'Milówka', 'gmina', 241700),
	(241710, 'Radziechowy-Wieprz', 'gmina', 241700),
	(241711, 'Rajcza', 'gmina', 241700),
	(241712, 'Ślemień', 'gmina', 241700),
	(241713, 'Świnna', 'gmina', 241700),
	(241714, 'Ujsoły', 'gmina', 241700),
	(241715, 'Węgierska Górka', 'gmina', 241700),
	(246100, 'Bielsko-Biała (miasto)', 'powiat', 240000),
	(246101, 'Bielsko-Biała (miasto)', 'gmina', 246100),
	(246200, 'Bytom (miasto)', 'powiat', 240000),
	(246201, 'Bytom (miasto)', 'gmina', 246200),
	(246300, 'Chorzów (miasto)', 'powiat', 240000),
	(246301, 'Chorzów (miasto)', 'gmina', 246300),
	(246400, 'Częstochowa (miasto)', 'powiat', 240000),
	(246401, 'Częstochowa (miasto)', 'gmina', 246400),
	(246500, 'Dąbrowa Górnicza (miasto)', 'powiat', 240000),
	(246501, 'Dąbrowa Górnicza (miasto)', 'gmina', 246500),
	(246600, 'Gliwice (miasto)', 'powiat', 240000),
	(246601, 'Gliwice (miasto)', 'gmina', 246600),
	(246700, 'Jastrzębie-Zdrój (miasto)', 'powiat', 240000),
	(246701, 'Jastrzębie-Zdrój (miasto)', 'gmina', 246700),
	(246800, 'Jaworzno (miasto)', 'powiat', 240000),
	(246801, 'Jaworzno (miasto)', 'gmina', 246800),
	(246900, 'Katowice (miasto)', 'powiat', 240000),
	(246901, 'Katowice (miasto)', 'gmina', 246900),
	(247000, 'Mysłowice (miasto)', 'powiat', 240000),
	(247001, 'Mysłowice (miasto)', 'gmina', 247000),
	(247100, 'Piekary Śląskie (miasto)', 'powiat', 240000),
	(247101, 'Piekary Śląskie (miasto)', 'gmina', 247100),
	(247200, 'Ruda Śląska (miasto)', 'powiat', 240000),
	(247201, 'Ruda Śląska (miasto)', 'gmina', 247200),
	(247300, 'Rybnik (miasto)', 'powiat', 240000),
	(247301, 'Rybnik (miasto)', 'gmina', 247300),
	(247400, 'Siemianowice Śląskie (miasto)', 'powiat', 240000),
	(247401, 'Siemianowice Śląskie (miasto)', 'gmina', 247400),
	(247500, 'Sosnowiec (miasto)', 'powiat', 240000),
	(247501, 'Sosnowiec (miasto)', 'gmina', 247500),
	(247600, 'Świętochłowice (miasto)', 'powiat', 240000),
	(247601, 'Świętochłowice (miasto)', 'gmina', 247600),
	(247700, 'Tychy (miasto)', 'powiat', 240000),
	(247701, 'Tychy (miasto)', 'gmina', 247700),
	(247800, 'Zabrze (miasto)', 'powiat', 240000),
	(247801, 'Zabrze (miasto)', 'gmina', 247800),
	(247900, 'Żory (miasto)', 'powiat', 240000),
	(247901, 'Żory (miasto)', 'gmina', 247900),
	(260000, 'Świętokrzyskie', 'województwo', NULL),
	(260100, 'Buski', 'powiat', 260000),
	(260101, 'Busko-Zdrój', 'gmina', 260100),
	(260102, 'Gnojno', 'gmina', 260100),
	(260103, 'Nowy Korczyn', 'gmina', 260100),
	(260104, 'Pacanów', 'gmina', 260100),
	(260105, 'Solec-Zdrój', 'gmina', 260100),
	(260106, 'Stopnica', 'gmina', 260100),
	(260107, 'Tuczępy', 'gmina', 260100),
	(260108, 'Wiślica', 'gmina', 260100),
	(260200, 'Jędrzejowski', 'powiat', 260000),
	(260201, 'Imielno', 'gmina', 260200),
	(260202, 'Jędrzejów', 'gmina', 260200),
	(260203, 'Małogoszcz', 'gmina', 260200),
	(260204, 'Nagłowice', 'gmina', 260200),
	(260205, 'Oksa', 'gmina', 260200),
	(260206, 'Sędziszów', 'gmina', 260200),
	(260207, 'Słupia', 'gmina', 260200),
	(260208, 'Sobków', 'gmina', 260200),
	(260209, 'Wodzisław', 'gmina', 260200),
	(260300, 'Kazimierski', 'powiat', 260000),
	(260301, 'Bejsce', 'gmina', 260300),
	(260302, 'Czarnocin', 'gmina', 260300),
	(260303, 'Kazimierza Wielka', 'gmina', 260300),
	(260304, 'Opatowiec', 'gmina', 260300),
	(260305, 'Skalbmierz', 'gmina', 260300),
	(260400, 'Kielecki', 'powiat', 260000),
	(260401, 'Bieliny', 'gmina', 260400),
	(260402, 'Bodzentyn', 'gmina', 260400),
	(260403, 'Chęciny', 'gmina', 260400),
	(260404, 'Chmielnik', 'gmina', 260400),
	(260405, 'Daleszyce', 'gmina', 260400),
	(260406, 'Górno', 'gmina', 260400),
	(260407, 'Łagów', 'gmina', 260400),
	(260408, 'Łopuszno', 'gmina', 260400),
	(260409, 'Masłów', 'gmina', 260400),
	(260410, 'Miedziana Góra', 'gmina', 260400),
	(260411, 'Mniów', 'gmina', 260400),
	(260412, 'Morawica', 'gmina', 260400),
	(260413, 'Nowa Słupia', 'gmina', 260400),
	(260414, 'Piekoszów', 'gmina', 260400),
	(260415, 'Pierzchnica', 'gmina', 260400),
	(260416, 'Raków', 'gmina', 260400),
	(260417, 'Nowiny', 'gmina', 260400),
	(260418, 'Strawczyn', 'gmina', 260400),
	(260419, 'Zagnańsk', 'gmina', 260400),
	(260500, 'Konecki', 'powiat', 260000),
	(260501, 'Fałków', 'gmina', 260500),
	(260502, 'Gowarczów', 'gmina', 260500),
	(260503, 'Końskie', 'gmina', 260500),
	(260504, 'Radoszyce', 'gmina', 260500),
	(260505, 'Ruda Maleniecka', 'gmina', 260500),
	(260506, 'Słupia Konecka', 'gmina', 260500),
	(260507, 'Smyków', 'gmina', 260500),
	(260508, 'Stąporków', 'gmina', 260500),
	(260600, 'Opatowski', 'powiat', 260000),
	(260601, 'Baćkowice', 'gmina', 260600),
	(260602, 'Iwaniska', 'gmina', 260600),
	(260603, 'Lipnik', 'gmina', 260600),
	(260604, 'Opatów', 'gmina', 260600),
	(260605, 'Ożarów', 'gmina', 260600),
	(260606, 'Sadowie', 'gmina', 260600),
	(260607, 'Tarłów', 'gmina', 260600),
	(260608, 'Wojciechowice', 'gmina', 260600),
	(260700, 'Ostrowiecki', 'powiat', 260000),
	(260701, 'Ostrowiec Świętokrzyski (miasto)', 'gmina', 260700),
	(260702, 'Bałtów', 'gmina', 260700),
	(260703, 'Bodzechów', 'gmina', 260700),
	(260704, 'Ćmielów', 'gmina', 260700),
	(260705, 'Kunów', 'gmina', 260700),
	(260706, 'Waśniów', 'gmina', 260700),
	(260800, 'Pińczowski', 'powiat', 260000),
	(260801, 'Działoszyce', 'gmina', 260800),
	(260802, 'Kije', 'gmina', 260800),
	(260803, 'Michałów', 'gmina', 260800),
	(260804, 'Pińczów', 'gmina', 260800),
	(260805, 'Złota', 'gmina', 260800),
	(260900, 'Sandomierski', 'powiat', 260000),
	(260901, 'Sandomierz (miasto)', 'gmina', 260900),
	(260902, 'Dwikozy', 'gmina', 260900),
	(260903, 'Klimontów', 'gmina', 260900),
	(260904, 'Koprzywnica', 'gmina', 260900),
	(260905, 'Łoniów', 'gmina', 260900),
	(260906, 'Obrazów', 'gmina', 260900),
	(260907, 'Samborzec', 'gmina', 260900),
	(260908, 'Wilczyce', 'gmina', 260900),
	(260909, 'Zawichost', 'gmina', 260900),
	(261000, 'Skarżyski', 'powiat', 260000),
	(261001, 'Skarżysko-Kamienna (miasto)', 'gmina', 261000),
	(261002, 'Bliżyn', 'gmina', 261000),
	(261003, 'Łączna', 'gmina', 261000),
	(261004, 'Skarżysko Kościelne', 'gmina', 261000),
	(261005, 'Suchedniów', 'gmina', 261000),
	(261100, 'Starachowicki', 'powiat', 260000),
	(261101, 'Starachowice (miasto)', 'gmina', 261100),
	(261102, 'Brody', 'gmina', 261100),
	(261103, 'Mirzec', 'gmina', 261100),
	(261104, 'Pawłów', 'gmina', 261100),
	(261105, 'Wąchock', 'gmina', 261100),
	(261200, 'Staszowski', 'powiat', 260000),
	(261201, 'Bogoria', 'gmina', 261200),
	(261202, 'Łubnice', 'gmina', 261200),
	(261203, 'Oleśnica', 'gmina', 261200),
	(261204, 'Osiek', 'gmina', 261200),
	(261205, 'Połaniec', 'gmina', 261200),
	(261206, 'Rytwiany', 'gmina', 261200),
	(261207, 'Staszów', 'gmina', 261200),
	(261208, 'Szydłów', 'gmina', 261200),
	(261300, 'Włoszczowski', 'powiat', 260000),
	(261301, 'Kluczewsko', 'gmina', 261300),
	(261302, 'Krasocin', 'gmina', 261300),
	(261303, 'Moskorzew', 'gmina', 261300),
	(261304, 'Radków', 'gmina', 261300),
	(261305, 'Secemin', 'gmina', 261300),
	(261306, 'Włoszczowa', 'gmina', 261300),
	(266100, 'Kielce (miasto)', 'powiat', 260000),
	(266101, 'Kielce (miasto)', 'gmina', 266100),
	(280000, 'Warmińsko-Mazurskie', 'województwo', NULL),
	(280100, 'Bartoszycki', 'powiat', 280000),
	(280101, 'Bartoszyce (miasto)', 'gmina', 280100),
	(280102, 'Górowo Iławeckie (miasto)', 'gmina', 280100),
	(280103, 'Bartoszyce', 'gmina', 280100),
	(280104, 'Bisztynek', 'gmina', 280100),
	(280105, 'Górowo Iławeckie', 'gmina', 280100),
	(280106, 'Sępopol', 'gmina', 280100),
	(280200, 'Braniewski', 'powiat', 280000),
	(280201, 'Braniewo (miasto)', 'gmina', 280200),
	(280202, 'Braniewo', 'gmina', 280200),
	(280203, 'Frombork', 'gmina', 280200),
	(280204, 'Lelkowo', 'gmina', 280200),
	(280205, 'Pieniężno', 'gmina', 280200),
	(280206, 'Płoskinia', 'gmina', 280200),
	(280207, 'Wilczęta', 'gmina', 280200),
	(280300, 'Działdowski', 'powiat', 280000),
	(280301, 'Działdowo (miasto)', 'gmina', 280300),
	(280302, 'Działdowo', 'gmina', 280300),
	(280303, 'Iłowo-Osada', 'gmina', 280300),
	(280304, 'Lidzbark', 'gmina', 280300),
	(280305, 'Płośnica', 'gmina', 280300),
	(280306, 'Rybno', 'gmina', 280300),
	(280400, 'Elbląski', 'powiat', 280000),
	(280401, 'Elbląg', 'gmina', 280400),
	(280402, 'Godkowo', 'gmina', 280400),
	(280403, 'Gronowo Elbląskie', 'gmina', 280400),
	(280404, 'Markusy', 'gmina', 280400),
	(280405, 'Milejewo', 'gmina', 280400),
	(280406, 'Młynary', 'gmina', 280400),
	(280407, 'Pasłęk', 'gmina', 280400),
	(280408, 'Rychliki', 'gmina', 280400),
	(280409, 'Tolkmicko', 'gmina', 280400),
	(280500, 'Ełcki', 'powiat', 280000),
	(280501, 'Ełk (miasto)', 'gmina', 280500),
	(280502, 'Ełk', 'gmina', 280500),
	(280503, 'Kalinowo', 'gmina', 280500),
	(280504, 'Prostki', 'gmina', 280500),
	(280505, 'Stare Juchy', 'gmina', 280500),
	(280600, 'Giżycki', 'powiat', 280000),
	(280601, 'Giżycko (miasto)', 'gmina', 280600),
	(280604, 'Giżycko', 'gmina', 280600),
	(280605, 'Kruklanki', 'gmina', 280600),
	(280606, 'Miłki', 'gmina', 280600),
	(280608, 'Ryn', 'gmina', 280600),
	(280610, 'Wydminy', 'gmina', 280600),
	(280700, 'Iławski', 'powiat', 280000),
	(280701, 'Iława (miasto)', 'gmina', 280700),
	(280702, 'Lubawa (miasto)', 'gmina', 280700),
	(280703, 'Iława', 'gmina', 280700),
	(280704, 'Kisielice', 'gmina', 280700),
	(280705, 'Lubawa', 'gmina', 280700),
	(280706, 'Susz', 'gmina', 280700),
	(280707, 'Zalewo', 'gmina', 280700),
	(280800, 'Kętrzyński', 'powiat', 280000),
	(280801, 'Kętrzyn (miasto)', 'gmina', 280800),
	(280802, 'Barciany', 'gmina', 280800),
	(280803, 'Kętrzyn', 'gmina', 280800),
	(280804, 'Korsze', 'gmina', 280800),
	(280805, 'Reszel', 'gmina', 280800),
	(280806, 'Srokowo', 'gmina', 280800),
	(280900, 'Lidzbarski', 'powiat', 280000),
	(280901, 'Lidzbark Warmiński (miasto)', 'gmina', 280900),
	(280902, 'Kiwity', 'gmina', 280900),
	(280903, 'Lidzbark Warmiński', 'gmina', 280900),
	(280904, 'Lubomino', 'gmina', 280900),
	(280905, 'Orneta', 'gmina', 280900),
	(281000, 'Mrągowski', 'powiat', 280000),
	(281001, 'Mrągowo (miasto)', 'gmina', 281000),
	(281002, 'Mikołajki', 'gmina', 281000),
	(281003, 'Mrągowo', 'gmina', 281000),
	(281004, 'Piecki', 'gmina', 281000),
	(281005, 'Sorkwity', 'gmina', 281000),
	(281100, 'Nidzicki', 'powiat', 280000),
	(281101, 'Janowiec Kościelny', 'gmina', 281100),
	(281102, 'Janowo', 'gmina', 281100),
	(281103, 'Kozłowo', 'gmina', 281100),
	(281104, 'Nidzica', 'gmina', 281100),
	(281200, 'Nowomiejski', 'powiat', 280000),
	(281201, 'Nowe Miasto Lubawskie (miasto)', 'gmina', 281200),
	(281202, 'Biskupiec', 'gmina', 281200),
	(281203, 'Grodziczno', 'gmina', 281200),
	(281204, 'Kurzętnik', 'gmina', 281200),
	(281205, 'Nowe Miasto Lubawskie', 'gmina', 281200),
	(281300, 'Olecki', 'powiat', 280000),
	(281303, 'Kowale Oleckie', 'gmina', 281300),
	(281304, 'Olecko', 'gmina', 281300),
	(281305, 'Świętajno', 'gmina', 281300),
	(281306, 'Wieliczki', 'gmina', 281300),
	(281400, 'Olsztyński', 'powiat', 280000),
	(281401, 'Barczewo', 'gmina', 281400),
	(281402, 'Biskupiec', 'gmina', 281400),
	(281403, 'Dobre Miasto', 'gmina', 281400),
	(281404, 'Dywity', 'gmina', 281400),
	(281405, 'Gietrzwałd', 'gmina', 281400),
	(281406, 'Jeziorany', 'gmina', 281400),
	(281407, 'Jonkowo', 'gmina', 281400),
	(281408, 'Kolno', 'gmina', 281400),
	(281409, 'Olsztynek', 'gmina', 281400),
	(281410, 'Purda', 'gmina', 281400),
	(281411, 'Stawiguda', 'gmina', 281400),
	(281412, 'Świątki', 'gmina', 281400),
	(281500, 'Ostródzki', 'powiat', 280000),
	(281501, 'Ostróda (miasto)', 'gmina', 281500),
	(281502, 'Dąbrówno', 'gmina', 281500),
	(281503, 'Grunwald', 'gmina', 281500),
	(281504, 'Łukta', 'gmina', 281500),
	(281505, 'Małdyty', 'gmina', 281500),
	(281506, 'Miłakowo', 'gmina', 281500),
	(281507, 'Miłomłyn', 'gmina', 281500),
	(281508, 'Morąg', 'gmina', 281500),
	(281509, 'Ostróda', 'gmina', 281500),
	(281600, 'Piski', 'powiat', 280000),
	(281601, 'Biała Piska', 'gmina', 281600),
	(281602, 'Orzysz', 'gmina', 281600),
	(281603, 'Pisz', 'gmina', 281600),
	(281604, 'Ruciane-Nida', 'gmina', 281600),
	(281700, 'Szczycieński', 'powiat', 280000),
	(281701, 'Szczytno (miasto)', 'gmina', 281700),
	(281702, 'Dźwierzuty', 'gmina', 281700),
	(281703, 'Jedwabno', 'gmina', 281700),
	(281704, 'Pasym', 'gmina', 281700),
	(281705, 'Rozogi', 'gmina', 281700),
	(281706, 'Szczytno', 'gmina', 281700),
	(281707, 'Świętajno', 'gmina', 281700),
	(281708, 'Wielbark', 'gmina', 281700),
	(281800, 'Gołdapski', 'powiat', 280000),
	(281801, 'Banie Mazurskie', 'gmina', 281800),
	(281802, 'Dubeninki', 'gmina', 281800),
	(281803, 'Gołdap', 'gmina', 281800),
	(281900, 'Węgorzewski', 'powiat', 280000),
	(281901, 'Budry', 'gmina', 281900),
	(281902, 'Pozezdrze', 'gmina', 281900),
	(281903, 'Węgorzewo', 'gmina', 281900),
	(286100, 'Elbląg (miasto)', 'powiat', 280000),
	(286101, 'Elbląg (miasto)', 'gmina', 286100),
	(286200, 'Olsztyn (miasto)', 'powiat', 280000),
	(286201, 'Olsztyn (miasto)', 'gmina', 286200),
	(300000, 'Wielkopolskie', 'województwo', NULL),
	(300100, 'Chodzieski', 'powiat', 300000),
	(300101, 'Chodzież (miasto)', 'gmina', 300100),
	(300102, 'Budzyń', 'gmina', 300100),
	(300103, 'Chodzież', 'gmina', 300100),
	(300104, 'Margonin', 'gmina', 300100),
	(300105, 'Szamocin', 'gmina', 300100),
	(300200, 'Czarnkowsko-Trzcianecki', 'powiat', 300000),
	(300201, 'Czarnków (miasto)', 'gmina', 300200),
	(300202, 'Czarnków', 'gmina', 300200),
	(300203, 'Drawsko', 'gmina', 300200),
	(300204, 'Krzyż Wielkopolski', 'gmina', 300200),
	(300205, 'Lubasz', 'gmina', 300200),
	(300206, 'Połajewo', 'gmina', 300200),
	(300207, 'Trzcianka', 'gmina', 300200),
	(300208, 'Wieleń', 'gmina', 300200),
	(300300, 'Gnieźnieński', 'powiat', 300000),
	(300301, 'Gniezno (miasto)', 'gmina', 300300),
	(300302, 'Czerniejewo', 'gmina', 300300),
	(300303, 'Gniezno', 'gmina', 300300),
	(300304, 'Kiszkowo', 'gmina', 300300),
	(300305, 'Kłecko', 'gmina', 300300),
	(300306, 'Łubowo', 'gmina', 300300),
	(300307, 'Mieleszyn', 'gmina', 300300),
	(300308, 'Niechanowo', 'gmina', 300300),
	(300309, 'Trzemeszno', 'gmina', 300300),
	(300310, 'Witkowo', 'gmina', 300300),
	(300400, 'Gostyński', 'powiat', 300000),
	(300401, 'Borek Wielkopolski', 'gmina', 300400),
	(300402, 'Gostyń', 'gmina', 300400),
	(300403, 'Krobia', 'gmina', 300400),
	(300404, 'Pępowo', 'gmina', 300400),
	(300405, 'Piaski', 'gmina', 300400),
	(300406, 'Pogorzela', 'gmina', 300400),
	(300407, 'Poniec', 'gmina', 300400),
	(300500, 'Grodziski', 'powiat', 300000),
	(300501, 'Granowo', 'gmina', 300500),
	(300502, 'Grodzisk Wielkopolski', 'gmina', 300500),
	(300503, 'Kamieniec', 'gmina', 300500),
	(300504, 'Rakoniewice', 'gmina', 300500),
	(300505, 'Wielichowo', 'gmina', 300500),
	(300600, 'Jarociński', 'powiat', 300000),
	(300601, 'Jaraczewo', 'gmina', 300600),
	(300602, 'Jarocin', 'gmina', 300600),
	(300603, 'Kotlin', 'gmina', 300600),
	(300604, 'Żerków', 'gmina', 300600),
	(300700, 'Kaliski', 'powiat', 300000),
	(300701, 'Blizanów', 'gmina', 300700),
	(300702, 'Brzeziny', 'gmina', 300700),
	(300703, 'Ceków-Kolonia', 'gmina', 300700),
	(300704, 'Godziesze Wielkie', 'gmina', 300700),
	(300705, 'Koźminek', 'gmina', 300700),
	(300706, 'Lisków', 'gmina', 300700),
	(300707, 'Mycielin', 'gmina', 300700),
	(300708, 'Opatówek', 'gmina', 300700),
	(300709, 'Stawiszyn', 'gmina', 300700),
	(300710, 'Szczytniki', 'gmina', 300700),
	(300711, 'Żelazków', 'gmina', 300700),
	(300800, 'Kępiński', 'powiat', 300000),
	(300801, 'Baranów', 'gmina', 300800),
	(300802, 'Bralin', 'gmina', 300800),
	(300803, 'Kępno', 'gmina', 300800),
	(300804, 'Łęka Opatowska', 'gmina', 300800),
	(300805, 'Perzów', 'gmina', 300800),
	(300806, 'Rychtal', 'gmina', 300800),
	(300807, 'Trzcinica', 'gmina', 300800),
	(300900, 'Kolski', 'powiat', 300000),
	(300901, 'Koło (miasto)', 'gmina', 300900),
	(300902, 'Babiak', 'gmina', 300900),
	(300903, 'Chodów', 'gmina', 300900),
	(300904, 'Dąbie', 'gmina', 300900),
	(300905, 'Grzegorzew', 'gmina', 300900),
	(300906, 'Kłodawa', 'gmina', 300900),
	(300907, 'Koło', 'gmina', 300900),
	(300908, 'Kościelec', 'gmina', 300900),
	(300909, 'Olszówka', 'gmina', 300900),
	(300910, 'Osiek Mały', 'gmina', 300900),
	(300911, 'Przedecz', 'gmina', 300900),
	(301000, 'Koniński', 'powiat', 300000),
	(301001, 'Golina', 'gmina', 301000),
	(301002, 'Grodziec', 'gmina', 301000),
	(301003, 'Kazimierz Biskupi', 'gmina', 301000),
	(301004, 'Kleczew', 'gmina', 301000),
	(301005, 'Kramsk', 'gmina', 301000),
	(301006, 'Krzymów', 'gmina', 301000),
	(301007, 'Rychwał', 'gmina', 301000),
	(301008, 'Rzgów', 'gmina', 301000),
	(301009, 'Skulsk', 'gmina', 301000),
	(301010, 'Sompolno', 'gmina', 301000),
	(301011, 'Stare Miasto', 'gmina', 301000),
	(301012, 'Ślesin', 'gmina', 301000),
	(301013, 'Wierzbinek', 'gmina', 301000),
	(301014, 'Wilczyn', 'gmina', 301000),
	(301100, 'Kościański', 'powiat', 300000),
	(301101, 'Kościan (miasto)', 'gmina', 301100),
	(301102, 'Czempiń', 'gmina', 301100),
	(301103, 'Kościan', 'gmina', 301100),
	(301104, 'Krzywiń', 'gmina', 301100),
	(301105, 'Śmigiel', 'gmina', 301100),
	(301200, 'Krotoszyński', 'powiat', 300000),
	(301201, 'Sulmierzyce (miasto)', 'gmina', 301200),
	(301202, 'Kobylin', 'gmina', 301200),
	(301203, 'Koźmin Wielkopolski', 'gmina', 301200),
	(301204, 'Krotoszyn', 'gmina', 301200),
	(301205, 'Rozdrażew', 'gmina', 301200),
	(301206, 'Zduny', 'gmina', 301200),
	(301300, 'Leszczyński', 'powiat', 300000),
	(301301, 'Krzemieniewo', 'gmina', 301300),
	(301302, 'Lipno', 'gmina', 301300),
	(301303, 'Osieczna', 'gmina', 301300),
	(301304, 'Rydzyna', 'gmina', 301300),
	(301305, 'Święciechowa', 'gmina', 301300),
	(301306, 'Wijewo', 'gmina', 301300),
	(301307, 'Włoszakowice', 'gmina', 301300),
	(301400, 'Międzychodzki', 'powiat', 300000),
	(301401, 'Chrzypsko Wielkie', 'gmina', 301400),
	(301402, 'Kwilcz', 'gmina', 301400),
	(301403, 'Międzychód', 'gmina', 301400),
	(301404, 'Sieraków', 'gmina', 301400),
	(301500, 'Nowotomyski', 'powiat', 300000),
	(301501, 'Kuślin', 'gmina', 301500),
	(301502, 'Lwówek', 'gmina', 301500),
	(301503, 'Miedzichowo', 'gmina', 301500),
	(301504, 'Nowy Tomyśl', 'gmina', 301500),
	(301505, 'Opalenica', 'gmina', 301500),
	(301506, 'Zbąszyń', 'gmina', 301500),
	(301600, 'Obornicki', 'powiat', 300000),
	(301601, 'Oborniki', 'gmina', 301600),
	(301602, 'Rogoźno', 'gmina', 301600),
	(301603, 'Ryczywół', 'gmina', 301600),
	(301700, 'Ostrowski', 'powiat', 300000),
	(301701, 'Ostrów Wielkopolski (miasto)', 'gmina', 301700),
	(301702, 'Nowe Skalmierzyce', 'gmina', 301700),
	(301703, 'Odolanów', 'gmina', 301700),
	(301704, 'Ostrów Wielkopolski', 'gmina', 301700),
	(301705, 'Przygodzice', 'gmina', 301700),
	(301706, 'Raszków', 'gmina', 301700),
	(301707, 'Sieroszewice', 'gmina', 301700),
	(301708, 'Sośnie', 'gmina', 301700),
	(301800, 'Ostrzeszowski', 'powiat', 300000),
	(301801, 'Czajków', 'gmina', 301800),
	(301802, 'Doruchów', 'gmina', 301800),
	(301803, 'Grabów Nad Prosną', 'gmina', 301800),
	(301804, 'Kobyla Góra', 'gmina', 301800),
	(301805, 'Kraszewice', 'gmina', 301800),
	(301806, 'Mikstat', 'gmina', 301800),
	(301807, 'Ostrzeszów', 'gmina', 301800),
	(301900, 'Pilski', 'powiat', 300000),
	(301901, 'Piła (miasto)', 'gmina', 301900),
	(301902, 'Białośliwie', 'gmina', 301900),
	(301903, 'Kaczory', 'gmina', 301900),
	(301904, 'Łobżenica', 'gmina', 301900),
	(301905, 'Miasteczko Krajeńskie', 'gmina', 301900),
	(301906, 'Szydłowo', 'gmina', 301900),
	(301907, 'Ujście', 'gmina', 301900),
	(301908, 'Wyrzysk', 'gmina', 301900),
	(301909, 'Wysoka', 'gmina', 301900),
	(302000, 'Pleszewski', 'powiat', 300000),
	(302001, 'Chocz', 'gmina', 302000),
	(302002, 'Czermin', 'gmina', 302000),
	(302003, 'Dobrzyca', 'gmina', 302000),
	(302004, 'Gizałki', 'gmina', 302000),
	(302005, 'Gołuchów', 'gmina', 302000),
	(302006, 'Pleszew', 'gmina', 302000),
	(302100, 'Poznański', 'powiat', 300000),
	(302101, 'Luboń (miasto)', 'gmina', 302100),
	(302102, 'Puszczykowo (miasto)', 'gmina', 302100),
	(302103, 'Buk', 'gmina', 302100),
	(302104, 'Czerwonak', 'gmina', 302100),
	(302105, 'Dopiewo', 'gmina', 302100),
	(302106, 'Kleszczewo', 'gmina', 302100),
	(302107, 'Komorniki', 'gmina', 302100),
	(302108, 'Kostrzyn', 'gmina', 302100),
	(302109, 'Kórnik', 'gmina', 302100),
	(302110, 'Mosina', 'gmina', 302100),
	(302111, 'Murowana Goślina', 'gmina', 302100),
	(302112, 'Pobiedziska', 'gmina', 302100),
	(302113, 'Rokietnica', 'gmina', 302100),
	(302114, 'Stęszew', 'gmina', 302100),
	(302115, 'Suchy Las', 'gmina', 302100),
	(302116, 'Swarzędz', 'gmina', 302100),
	(302117, 'Tarnowo Podgórne', 'gmina', 302100),
	(302200, 'Rawicki', 'powiat', 300000),
	(302201, 'Bojanowo', 'gmina', 302200),
	(302202, 'Jutrosin', 'gmina', 302200),
	(302203, 'Miejska Górka', 'gmina', 302200),
	(302204, 'Pakosław', 'gmina', 302200),
	(302205, 'Rawicz', 'gmina', 302200),
	(302300, 'Słupecki', 'powiat', 300000),
	(302301, 'Słupca (miasto)', 'gmina', 302300),
	(302302, 'Lądek', 'gmina', 302300),
	(302303, 'Orchowo', 'gmina', 302300),
	(302304, 'Ostrowite', 'gmina', 302300),
	(302305, 'Powidz', 'gmina', 302300),
	(302306, 'Słupca', 'gmina', 302300),
	(302307, 'Strzałkowo', 'gmina', 302300),
	(302308, 'Zagórów', 'gmina', 302300),
	(302400, 'Szamotulski', 'powiat', 300000),
	(302401, 'Obrzycko (miasto)', 'gmina', 302400),
	(302402, 'Duszniki', 'gmina', 302400),
	(302403, 'Kaźmierz', 'gmina', 302400),
	(302404, 'Obrzycko', 'gmina', 302400),
	(302405, 'Ostroróg', 'gmina', 302400),
	(302406, 'Pniewy', 'gmina', 302400),
	(302407, 'Szamotuły', 'gmina', 302400),
	(302408, 'Wronki', 'gmina', 302400),
	(302500, 'Średzki', 'powiat', 300000),
	(302501, 'Dominowo', 'gmina', 302500),
	(302502, 'Krzykosy', 'gmina', 302500),
	(302503, 'Nowe Miasto Nad Wartą', 'gmina', 302500),
	(302504, 'Środa Wielkopolska', 'gmina', 302500),
	(302505, 'Zaniemyśl', 'gmina', 302500),
	(302600, 'Śremski', 'powiat', 300000),
	(302601, 'Brodnica', 'gmina', 302600),
	(302602, 'Dolsk', 'gmina', 302600),
	(302603, 'Książ Wielkopolski', 'gmina', 302600),
	(302604, 'Śrem', 'gmina', 302600),
	(302700, 'Turecki', 'powiat', 300000),
	(302701, 'Turek (miasto)', 'gmina', 302700),
	(302702, 'Brudzew', 'gmina', 302700),
	(302703, 'Dobra', 'gmina', 302700),
	(302704, 'Kawęczyn', 'gmina', 302700),
	(302705, 'Malanów', 'gmina', 302700),
	(302706, 'Przykona', 'gmina', 302700),
	(302707, 'Tuliszków', 'gmina', 302700),
	(302708, 'Turek', 'gmina', 302700),
	(302709, 'Władysławów', 'gmina', 302700),
	(302800, 'Wągrowiecki', 'powiat', 300000),
	(302801, 'Wągrowiec (miasto)', 'gmina', 302800),
	(302802, 'Damasławek', 'gmina', 302800),
	(302803, 'Gołańcz', 'gmina', 302800),
	(302804, 'Mieścisko', 'gmina', 302800),
	(302805, 'Skoki', 'gmina', 302800),
	(302806, 'Wapno', 'gmina', 302800),
	(302807, 'Wągrowiec', 'gmina', 302800),
	(302900, 'Wolsztyński', 'powiat', 300000),
	(302901, 'Przemęt', 'gmina', 302900),
	(302902, 'Siedlec', 'gmina', 302900),
	(302903, 'Wolsztyn', 'gmina', 302900),
	(303000, 'Wrzesiński', 'powiat', 300000),
	(303001, 'Kołaczkowo', 'gmina', 303000),
	(303002, 'Miłosław', 'gmina', 303000),
	(303003, 'Nekla', 'gmina', 303000),
	(303004, 'Pyzdry', 'gmina', 303000),
	(303005, 'Września', 'gmina', 303000),
	(303100, 'Złotowski', 'powiat', 300000),
	(303101, 'Złotów (miasto)', 'gmina', 303100),
	(303102, 'Jastrowie', 'gmina', 303100),
	(303103, 'Krajenka', 'gmina', 303100),
	(303104, 'Lipka', 'gmina', 303100),
	(303105, 'Okonek', 'gmina', 303100),
	(303106, 'Tarnówka', 'gmina', 303100),
	(303107, 'Zakrzewo', 'gmina', 303100),
	(303108, 'Złotów', 'gmina', 303100),
	(306100, 'Kalisz (miasto)', 'powiat', 300000),
	(306101, 'Kalisz (miasto)', 'gmina', 306100),
	(306200, 'Konin (miasto)', 'powiat', 300000),
	(306201, 'Konin (miasto)', 'gmina', 306200),
	(306300, 'Leszno (miasto)', 'powiat', 300000),
	(306301, 'Leszno (miasto)', 'gmina', 306300),
	(306400, 'Poznań (miasto)', 'powiat', 300000),
	(306401, 'Poznań (miasto)', 'gmina', 306400),
	(320000, 'Zachodniopomorskie', 'województwo', NULL),
	(320100, 'Białogardzki', 'powiat', 320000),
	(320101, 'Białogard (miasto)', 'gmina', 320100),
	(320102, 'Białogard', 'gmina', 320100),
	(320103, 'Karlino', 'gmina', 320100),
	(320104, 'Tychowo', 'gmina', 320100),
	(320200, 'Choszczeński', 'powiat', 320000),
	(320201, 'Bierzwnik', 'gmina', 320200),
	(320202, 'Choszczno', 'gmina', 320200),
	(320203, 'Drawno', 'gmina', 320200),
	(320204, 'Krzęcin', 'gmina', 320200),
	(320205, 'Pełczyce', 'gmina', 320200),
	(320206, 'Recz', 'gmina', 320200),
	(320300, 'Drawski', 'powiat', 320000),
	(320301, 'Czaplinek', 'gmina', 320300),
	(320302, 'Drawsko Pomorskie', 'gmina', 320300),
	(320303, 'Kalisz Pomorski', 'gmina', 320300),
	(320305, 'Wierzchowo', 'gmina', 320300),
	(320306, 'Złocieniec', 'gmina', 320300),
	(320400, 'Goleniowski', 'powiat', 320000),
	(320402, 'Goleniów', 'gmina', 320400),
	(320403, 'Maszewo', 'gmina', 320400),
	(320404, 'Nowogard', 'gmina', 320400),
	(320405, 'Osina', 'gmina', 320400),
	(320406, 'Przybiernów', 'gmina', 320400),
	(320407, 'Stepnica', 'gmina', 320400),
	(320500, 'Gryficki', 'powiat', 320000),
	(320501, 'Brojce', 'gmina', 320500),
	(320502, 'Gryfice', 'gmina', 320500),
	(320503, 'Karnice', 'gmina', 320500),
	(320504, 'Płoty', 'gmina', 320500),
	(320507, 'Rewal', 'gmina', 320500),
	(320508, 'Trzebiatów', 'gmina', 320500),
	(320600, 'Gryfiński', 'powiat', 320000),
	(320601, 'Banie', 'gmina', 320600),
	(320602, 'Cedynia', 'gmina', 320600),
	(320603, 'Chojna', 'gmina', 320600),
	(320604, 'Gryfino', 'gmina', 320600),
	(320605, 'Mieszkowice', 'gmina', 320600),
	(320606, 'Moryń', 'gmina', 320600),
	(320607, 'Stare Czarnowo', 'gmina', 320600),
	(320608, 'Trzcińsko-Zdrój', 'gmina', 320600),
	(320609, 'Widuchowa', 'gmina', 320600),
	(320700, 'Kamieński', 'powiat', 320000),
	(320701, 'Dziwnów', 'gmina', 320700),
	(320702, 'Golczewo', 'gmina', 320700),
	(320703, 'Kamień Pomorski', 'gmina', 320700),
	(320704, 'Międzyzdroje', 'gmina', 320700),
	(320705, 'Świerzno', 'gmina', 320700),
	(320706, 'Wolin', 'gmina', 320700),
	(320800, 'Kołobrzeski', 'powiat', 320000),
	(320801, 'Kołobrzeg (miasto)', 'gmina', 320800),
	(320802, 'Dygowo', 'gmina', 320800),
	(320803, 'Gościno', 'gmina', 320800),
	(320804, 'Kołobrzeg', 'gmina', 320800),
	(320805, 'Rymań', 'gmina', 320800),
	(320806, 'Siemyśl', 'gmina', 320800),
	(320807, 'Ustronie Morskie', 'gmina', 320800),
	(320900, 'Koszaliński', 'powiat', 320000),
	(320901, 'Będzino', 'gmina', 320900),
	(320902, 'Biesiekierz', 'gmina', 320900),
	(320903, 'Bobolice', 'gmina', 320900),
	(320904, 'Manowo', 'gmina', 320900),
	(320905, 'Mielno', 'gmina', 320900),
	(320906, 'Polanów', 'gmina', 320900),
	(320907, 'Sianów', 'gmina', 320900),
	(320908, 'Świeszyno', 'gmina', 320900),
	(321000, 'Myśliborski', 'powiat', 320000),
	(321001, 'Barlinek', 'gmina', 321000),
	(321002, 'Boleszkowice', 'gmina', 321000),
	(321003, 'Dębno', 'gmina', 321000),
	(321004, 'Myślibórz', 'gmina', 321000),
	(321005, 'Nowogródek Pomorski', 'gmina', 321000),
	(321100, 'Policki', 'powiat', 320000),
	(321101, 'Dobra (Szczecińska)', 'gmina', 321100),
	(321102, 'Kołbaskowo', 'gmina', 321100),
	(321103, 'Nowe Warpno', 'gmina', 321100),
	(321104, 'Police', 'gmina', 321100),
	(321200, 'Pyrzycki', 'powiat', 320000),
	(321201, 'Bielice', 'gmina', 321200),
	(321202, 'Kozielice', 'gmina', 321200),
	(321203, 'Lipiany', 'gmina', 321200),
	(321204, 'Przelewice', 'gmina', 321200),
	(321205, 'Pyrzyce', 'gmina', 321200),
	(321206, 'Warnice', 'gmina', 321200),
	(321300, 'Sławieński', 'powiat', 320000),
	(321301, 'Darłowo (miasto)', 'gmina', 321300),
	(321302, 'Sławno (miasto)', 'gmina', 321300),
	(321303, 'Darłowo', 'gmina', 321300),
	(321304, 'Malechowo', 'gmina', 321300),
	(321305, 'Postomino', 'gmina', 321300),
	(321306, 'Sławno', 'gmina', 321300),
	(321400, 'Stargardzki', 'powiat', 320000),
	(321401, 'Stargard (miasto)', 'gmina', 321400),
	(321402, 'Chociwel', 'gmina', 321400),
	(321403, 'Dobrzany', 'gmina', 321400),
	(321404, 'Dolice', 'gmina', 321400),
	(321405, 'Ińsko', 'gmina', 321400),
	(321406, 'Kobylanka', 'gmina', 321400),
	(321408, 'Marianowo', 'gmina', 321400),
	(321409, 'Stara Dąbrowa', 'gmina', 321400),
	(321410, 'Stargard', 'gmina', 321400),
	(321411, 'Suchań', 'gmina', 321400),
	(321500, 'Szczecinecki', 'powiat', 320000),
	(321501, 'Szczecinek (miasto)', 'gmina', 321500),
	(321502, 'Barwice', 'gmina', 321500),
	(321503, 'Biały Bór', 'gmina', 321500),
	(321504, 'Borne Sulinowo', 'gmina', 321500),
	(321505, 'Grzmiąca', 'gmina', 321500),
	(321506, 'Szczecinek', 'gmina', 321500),
	(321600, 'Świdwiński', 'powiat', 320000),
	(321601, 'Świdwin (miasto)', 'gmina', 321600),
	(321602, 'Brzeżno', 'gmina', 321600),
	(321603, 'Połczyn-Zdrój', 'gmina', 321600),
	(321604, 'Rąbino', 'gmina', 321600),
	(321605, 'Sławoborze', 'gmina', 321600),
	(321606, 'Świdwin', 'gmina', 321600),
	(321700, 'Wałecki', 'powiat', 320000),
	(321701, 'Wałcz (miasto)', 'gmina', 321700),
	(321702, 'Człopa', 'gmina', 321700),
	(321703, 'Mirosławiec', 'gmina', 321700),
	(321704, 'Tuczno', 'gmina', 321700),
	(321705, 'Wałcz', 'gmina', 321700),
	(321800, 'Łobeski', 'powiat', 320000),
	(321801, 'Dobra', 'gmina', 321800),
	(321802, 'Łobez', 'gmina', 321800),
	(321803, 'Radowo Małe', 'gmina', 321800),
	(321804, 'Resko', 'gmina', 321800),
	(321805, 'Węgorzyno', 'gmina', 321800),
	(326100, 'Koszalin (miasto)', 'powiat', 320000),
	(326101, 'Koszalin (miasto)', 'gmina', 326100),
	(326200, 'Szczecin (miasto)', 'powiat', 320000),
	(326201, 'Szczecin (miasto)', 'gmina', 326200),
	(326300, 'Świnoujście (miasto)', 'powiat', 320000),
	(326301, 'Świnoujście (miasto)', 'gmina', 326300);

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
	DECLARE location_id INT(10);

	IF NOT EXISTS (SELECT 1 FROM user_account AS ua WHERE ua.my_role = 'meritorical_administrator') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie posiada roli administratora metrytorycznego';
    END IF;

	IF attraction_id IS NULL OR locality_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac atrakcji: attraction_id lub locality_id sa NULL';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM attractions AS a WHERE a.attraction_id = attraction_id) OR 
       NOT EXISTS (SELECT 1 FROM localities AS l WHERE l.locality_id = locality_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja lub miejscowosc nie istnieje w bazie danych';
    END IF;
    
    -- Sprawdzenie, czy użytkownik ma uprawnienie do dodawania atrakcji do wskazanej miejscowości
	IF NOT EXISTS (
		SELECT 1
		FROM managed_attractions AS ma
		WHERE ma.attraction_id = attraction_id
	) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Nie masz uprawnień do dodawania atrakcji w tym województwie!';
	END IF;

    -- Sprawdzenie czy adres jaki ma zostać przypisany do atrakcji już istnieje w bazie
	-- Jeżeli nie to należy go stworzyć, w przeciwnym wypadku można po prostu przypisać atrakcję do 
	-- istniejącego adresu
	IF NOT EXISTS (
		SELECT loa.location_id
		FROM locations_of_attractions AS loa
		WHERE 
			loa.locality_id = locality_id AND 
			(loa.street = street OR (loa.street IS NULL AND street IS NULL)) AND 
			(loa.building_number = building_number OR (loa.building_number IS NULL AND building_number IS NULL)) AND
			(loa.flat_number = flat_number OR (loa.flat_number IS NULL AND flat_number IS NULL))
		LIMIT 1
	) THEN
		INSERT INTO locations (
			locality_id,
			street,
			building_number,
			flat_number
		)
		VALUES (
			locality_id,
			street,
			building_number,
			flat_number
		);
		
		SET location_id = LAST_INSERT_ID();
	ELSE 
		SELECT loa.location_id
		INTO location_id
		FROM locations_of_attractions AS loa
		WHERE 
			loa.locality_id = locality_id AND 
			(loa.street = street OR (loa.street IS NULL AND street IS NULL)) AND 
			(loa.building_number = building_number OR (loa.building_number IS NULL AND building_number IS NULL)) AND
			(loa.flat_number = flat_number OR (loa.flat_number IS NULL AND flat_number IS NULL))
			LIMIT 1;
	END IF;
	
	-- Przypisanie atrakcji do adresu
	INSERT INTO attractions_locations(
		attraction_id,
		location_id
	)
	VALUES (
		attraction_id,
		location_id
	);

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
	IF figure_id IS NULL OR attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac ilustracji: figure_id lub attraction_id są NULL';
    END IF;

    -- Sprawdzenie, czy figure_id i attraction_id znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM figures AS f WHERE f.figure_id = figure_id) OR 
       NOT EXISTS (SELECT 1 FROM attractions AS a WHERE a.attraction_id = attraction_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ilustracja lub atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy atrakcja jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM managed_attractions AS ma
        WHERE ma.attraction_id = attraction_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie znajduje się w województwie zarządzanym przez użytkownika';
    END IF;

    -- Przypisanie ilustracji do atrakcji
    INSERT INTO figures_containing_attractions (figure_id, attraction_id, caption)
    VALUES (figure_id, attraction_id, caption);
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
	IF voivodship_id IS NULL OR login IS NULL OR permission_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac uprawnien: jeden z parametrow jest NULL';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM users WHERE users.login = login AND `role` = 'meritorical_administrator') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie posiada roli administratora metrytorycznego';
    END IF;

    -- Sprawdzenie, czy parametry znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM administrative_units WHERE administrative_unit_id = voivodship_id) OR 
       NOT EXISTS (SELECT 1 FROM permissions WHERE permission_id = permission_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Wojewodztwo lub uprawnienie nie istnieje w bazie danych';
    END IF;
    
   -- Aktualizacja tabeli, jeśli to konieczne
   IF NOT EXISTS (
	 	SELECT 1 
		FROM voivodships_administrated_by_users AS vau 
		WHERE vau.login = login AND vau.voivodship_id = voivodship_id
	) THEN
        INSERT INTO Voivodships_Administrated_By_Users (login, voivodship_id)
        VALUES (login, voivodship_id);
    END IF;

    -- Nadanie uprawnienia
    INSERT INTO users_permissions_in_voivodships (login, voivodship_id, permission_id)
    VALUES (login, voivodship_id, permission_id);

END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.assign_type_to_attraction
DELIMITER //
CREATE PROCEDURE `assign_type_to_attraction`(
	IN type_id INT(10),
	IN attraction_id INT(10)
)
BEGIN
    IF type_id IS NULL OR attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac typu: type_id lub attraction_id sa NULL';
    END IF;

    -- Sprawdzenie, czy type_id i attraction_id znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM attraction_types WHERE attraction_type_id = type_id) OR 
       NOT EXISTS (SELECT 1 FROM attractions AS a WHERE a.attraction_id = attraction_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Typ atrakcji lub atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie czy atrakcja jest zlokalizowana w województwie zarządzanym przez administratora i czy ma on uprawnienia
    IF NOT EXISTS (
        SELECT 1 
        FROM managed_attractions ma
        WHERE ma.attraction_id = attraction_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie ma uprawnien do zarzadzania atrakcjami w wojewodztwie, w którym znajduje sie atrakcja';
    END IF;

    -- Przypisanie typu atrakcji do atrakcji
    INSERT INTO types_assigned_to_attractions (attraction_type_id, attraction_id)
    VALUES (type_id, attraction_id);
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

-- Zrzucanie danych dla tabeli projekt_bd.attractions: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.attractions_locations
CREATE TABLE IF NOT EXISTS `attractions_locations` (
  `attraction_id` int(10) NOT NULL,
  `location_id` int(10) NOT NULL,
  PRIMARY KEY (`attraction_id`,`location_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `FKAttraction904049` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`) ON DELETE CASCADE,
  CONSTRAINT `FKAttraction940482` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.attractions_locations: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.attraction_types
CREATE TABLE IF NOT EXISTS `attraction_types` (
  `attraction_type_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`attraction_type_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.attraction_types: ~61 rows (około)
INSERT INTO `attraction_types` (`attraction_type_id`, `name`) VALUES
	(45, 'agroturystyka'),
	(55, 'akwen'),
	(47, 'bar'),
	(40, 'centrum edukacyjne'),
	(21, 'centrum handlowe'),
	(60, 'galeria sztuki'),
	(56, 'gastronomia'),
	(2, 'góra'),
	(51, 'historia'),
	(42, 'hotel'),
	(11, 'jaskinia'),
	(6, 'jezioro'),
	(34, 'kolejki'),
	(49, 'kościół'),
	(54, 'las'),
	(31, 'mauzoleum'),
	(4, 'muzeum'),
	(53, 'na zewnątrz'),
	(30, 'nekropolia'),
	(12, 'ogród botaniczny'),
	(25, 'park'),
	(23, 'park dinozaurów'),
	(15, 'park linowy'),
	(5, 'park narodowy'),
	(10, 'park rozrywki'),
	(41, 'pałac'),
	(3, 'plaża'),
	(37, 'pole golfowe'),
	(14, 'pomnik'),
	(28, 'port'),
	(48, 'przyroda'),
	(19, 'przystań'),
	(38, 'pub'),
	(46, 'punkt widokowy'),
	(13, 'restauracja'),
	(29, 'sanktuarium'),
	(8, 'skansen'),
	(59, 'sklep'),
	(20, 'skocznia narciarska'),
	(33, 'skwer miejski'),
	(35, 'spa'),
	(61, 'sport'),
	(18, 'stadion'),
	(39, 'stadnina koni'),
	(58, 'starówka'),
	(32, 'szlak kajakowy'),
	(50, 'sztuka'),
	(26, 'teatr'),
	(27, 'termy'),
	(36, 'tor go-kartowy'),
	(17, 'trasa narciarska'),
	(7, 'trasa rowerowa'),
	(57, 'uzdrowisko'),
	(52, 'w środku'),
	(9, 'wieżowiec'),
	(16, 'wodospad'),
	(22, 'zabytek'),
	(43, 'zajazd'),
	(44, 'zakwaterowanie'),
	(1, 'zamek'),
	(24, 'zoo');

-- Zrzut struktury procedura projekt_bd.del_attraction
DELIMITER //
CREATE PROCEDURE `del_attraction`(
	IN attr_id INT(10)
)
BEGIN
	    IF attr_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna usunac atrakcji';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM attractions AS a WHERE a.attraction_id = attr_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy atrakcja jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM managed_attractions AS ma
		  WHERE ma.attraction_id = attr_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie znajduje sie w wojewodztwie zarzadzanym przez uzytkownika';
    END IF;

    -- Usunięcie atrakcji
    DELETE FROM attractions WHERE attraction_id = attr_id;
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_locality
DELIMITER //
CREATE PROCEDURE `del_locality`(
	IN locality_id INT(10)
)
BEGIN
	    IF locality_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna usunac miejscowosci: locality_id jest NULL';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM localities AS l WHERE l.locality_id = locality_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Miejscowosc nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy miejscowość jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1  
        FROM managed_localities AS ml
        WHERE ml.locality_id = locality_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Miejscowosc nie znajduje sie w wojewodztwie zarzadzanym przez uzytkownika';
    END IF;

    -- Usunięcie miejscowości
    DELETE FROM localities WHERE localities.locality_id = locality_id;
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_locality_from_fav_list
DELIMITER //
CREATE PROCEDURE `del_locality_from_fav_list`(
	IN locality_identifier INT(10)
)
BEGIN
	 IF locality_identifier IS NOT NULL THEN
        DELETE FROM favourite_localities 
		  WHERE locality_id = locality_identifier AND SESSION_USER() LIKE CONCAT(login,'@','%');
    END IF;
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.del_user
DELIMITER //
CREATE PROCEDURE `del_user`(
	IN user_login VARCHAR(30)
)
BEGIN
	
	DECLARE caller_role VARCHAR(30);
	
	-- Jeżeli w parametrze zamiast loginu podano null, to należy przyjąć login wywołującego metodę użytkownika
	IF user_login IS NULL THEN
		SELECT `my_login`
		INTO user_login
		FROM user_account;
	END IF;
	
	-- Jeżeli użytkownik wykonujący komendę nie jest administratorem technicznym, to moze usunąć wyłącznie
	-- swoje konto
	SELECT `role` 
	INTO caller_role 
	FROM users
	WHERE SESSION_USER() LIKE CONCAT(users.login,'@','%');
	
	IF SESSION_USER() LIKE 'root@%' THEN
		SELECT 'Wymuszono usunięcie nieswojego konta' AS Message;
	ELSEIF caller_role != 'technical_administrator' AND (SESSION_USER() NOT LIKE CONCAT(user_login,'@','%')) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie masz uprawnień do usunięcia tego konta!';
	END IF;

   -- Usunięcie użytkownika z bazy danych
   DELETE FROM projekt_bd.users
   WHERE user_login = Users.login;
   
	-- Usunięcie użytkownika z serwera bazodanowego
	set @sql = concat("DROP USER'",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.favourite_localities
CREATE TABLE IF NOT EXISTS `favourite_localities` (
  `locality_id` int(5) NOT NULL,
  `login` varchar(30) NOT NULL,
  `adnotation` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`locality_id`,`login`),
  KEY `login` (`login`),
  CONSTRAINT `FKFavourite_482397` FOREIGN KEY (`login`) REFERENCES `users` (`login`) ON DELETE CASCADE,
  CONSTRAINT `FKFavourite_981560` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`locality_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.favourite_localities: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.figures
CREATE TABLE IF NOT EXISTS `figures` (
  `figure_id` int(10) NOT NULL AUTO_INCREMENT,
  `figure` blob NOT NULL,
  PRIMARY KEY (`figure_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.figures: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.figures_containing_attractions
CREATE TABLE IF NOT EXISTS `figures_containing_attractions` (
  `figure_id` int(10) NOT NULL,
  `attraction_id` int(10) NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`figure_id`,`attraction_id`),
  KEY `attraction_id` (`attraction_id`),
  CONSTRAINT `FKFigures_Co325289` FOREIGN KEY (`figure_id`) REFERENCES `figures` (`figure_id`) ON DELETE CASCADE,
  CONSTRAINT `FKFigures_Co880499` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.figures_containing_attractions: ~0 rows (około)

-- Zrzut struktury widok projekt_bd.full_localities_data
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `full_localities_data` (
	`locality_id` INT(5) NOT NULL,
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_desc` VARCHAR(1000) NULL COLLATE 'utf8mb4_general_ci',
	`population` INT(10) UNSIGNED NULL,
	`locality_latitude` DOUBLE NULL,
	`locality_longitude` DOUBLE NULL,
	`locality_type` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_id` INT(10) NOT NULL,
	`municipality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_id` INT(10) NOT NULL,
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`voivodship_id` INT(10) NOT NULL,
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Zrzut struktury procedura projekt_bd.get_attractions_in_locality
DELIMITER //
CREATE PROCEDURE `get_attractions_in_locality`(
	IN locality_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy miejscowość istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM localities AS l
		WHERE l.locality_id = locality_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazana miejscowość nie istnieje!';
	END IF;
	
	-- Pobranie wszystkich atrakcji w danej miejscowości
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 
			loa.attraction_id,
			loa.attraction_name,
			loa.attraction_desc,
			loa.street,
			loa.building_number,
			loa.flat_number
		FROM locations_of_attractions AS loa
		WHERE loa.locality_id = locality_id;

END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_counties_from_voivodship
DELIMITER //
CREATE PROCEDURE `get_counties_from_voivodship`(
	IN voivodship_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy wskazane województwo istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM administrative_units AS au
		WHERE au.`type` = 'województwo' AND au.administrative_unit_id = voivodship_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazane wojwewództwo nie istnieje!';
	END IF;
	
	-- Pobranie powiatów z województwa
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 
			au.administrative_unit_id,
			au.`name`
		FROM administrative_units AS au
		WHERE `type` = 'powiat' AND superior_administrative_unit = voivodship_id;
	
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_figures_assigned_to_attraction
DELIMITER //
CREATE PROCEDURE `get_figures_assigned_to_attraction`(
	IN attraction_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy atrakcja istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM attractions AS a
		WHERE a.attraction_id = attraction_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazana atrakcja nie istnieje!';
	END IF;
	
	-- Pobranie przypisanych do atrakcji obrazków
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 
			f.figure_id,
			f.figure,
			fca.caption
		FROM figures_containing_attractions AS fca
		JOIN figures AS f ON fca.figure_id = f.figure_id
		WHERE fca.attraction_id = attraction_id;
		
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_localities_number_of_attractions
DELIMITER //
CREATE PROCEDURE `get_localities_number_of_attractions`(
	IN locality_id INT(10)
)
BEGIN
	DECLARE header VARCHAR(50);
	
	-- Jeżeli miejscowość nie istnieje, to zwracana jest wartość -1
	IF NOT EXISTS (
		SELECT *
		FROM localities AS l
		WHERE l.locality_id = locality_id
	) THEN
		SELECT -1 AS Message;
	END IF;
	
	-- Zliczenie liczby atrakcji
	SELECT l.`name` 
	INTO header
	FROM localities AS l 
	WHERE l.locality_id = locality_id;
	
	SET header = CONCAT('Liczba atrakcji w ', header);
	
	SELECT COUNT(*) AS `header`
	FROM locations_of_attractions AS loa
	WHERE loa.location_id = locality_id;

END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_locations_from_locality
DELIMITER //
CREATE PROCEDURE `get_locations_from_locality`(
	IN locality_id INT(10)
)
BEGIN
	
	-- Sprawdzenie, czy miejscowość nie istnieje
	IF NOT EXISTS (
		SELECT *
		FROM localities AS l
		WHERE l.locality_id = locality_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Miejscowosc nie istnieje w bazie danych';
	END IF;
	
	-- Pobranie lokacji znajdujących się w miejscowości
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 
			loa.location_id,
			loa.voivodship_name,
			loa.county_name,
			loa.municipality_name,
			loa.locality_id,
			loa.locality_name,
			loa.street,
			loa.building_number,
			loa.flat_number
		FROM locations_of_attractions AS loa
		WHERE loa.locality_id = locality_id;
	
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_municipalities_from_county
DELIMITER //
CREATE PROCEDURE `get_municipalities_from_county`(
	IN county_id INT(10)
)
BEGIN
	
	-- Sprawdzenie, czy wskazane powiat istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM administrative_units AS au
		WHERE au.`type` = 'powiat' AND au.administrative_unit_id = county_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazany powiat nie istnieje!';
	END IF;
	
	-- Pobranie gmin z powiatu
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 
			au.administrative_unit_id,
			au.`name`
		FROM administrative_units AS au
		WHERE `type` = 'gmina' AND superior_administrative_unit = county_id;
	
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_types_assigned_to_attraction
DELIMITER //
CREATE PROCEDURE `get_types_assigned_to_attraction`(
	IN attraction_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy atrakcja istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM attractions AS a
		WHERE a.attraction_id = attraction_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazana atrakcja nie istnieje!';
	END IF;
	
	-- Pobranie typów przypisanych do atrakcji
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT `at`.*
		FROM types_assigned_to_attractions AS tata
		JOIN attraction_types AS `at` ON tata.attraction_type_id = `at`.attraction_type_id
		WHERE tata.attraction_id = attraction_id;

END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_user_permissions_in_voivodship
DELIMITER //
CREATE PROCEDURE `get_user_permissions_in_voivodship`(
	IN login VARCHAR(30),
	IN voivodship_id INT(10)
)
BEGIN

	-- Sprawdzenie, czy taki użytkownik jest zarejestrowany
	IF NOT EXISTS (
		SELECT 1
		FROM registered_users AS ru
		WHERE ru.login = login
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazane konto użytkownika nie istnieje!';
	END IF;
	
	-- Sprawdzenie, czy wskazane województwo istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM administrative_units AS au
		WHERE au.`type` = 'województwo' AND au.administrative_unit_id = voivodship_id
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazane wojwewództwo nie istnieje!';
	END IF;	
	
	-- Pobranie upranień użytkownika w województwie
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 	
			gp.permission_name,
			gp.permission_desc
		FROM granted_permissions AS gp
		WHERE gp.user_login = login AND gp.voivodship_id = voivodship_id;

END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.get_voivodships_managed_by_user
DELIMITER //
CREATE PROCEDURE `get_voivodships_managed_by_user`(
	IN login VARCHAR(30)
)
BEGIN
	
	-- Sprawdzenie, czy taki użytkownik jest zarejestrowany
	IF NOT EXISTS (
		SELECT 1
		FROM registered_users AS ru
		WHERE ru.login = login
	) THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Wskazane konto użytkownika nie istnieje!';
	END IF;
	
	-- Pobranie województw zarządzanych przez użytkownika
	DROP TABLE IF EXISTS return_table;
	CREATE TABLE return_table AS
		SELECT 	
			gp.voivodship_id,
			gp.voivodship_name
		FROM granted_permissions AS gp
		WHERE gp.user_login = login;
	
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
  `population` int(10) unsigned DEFAULT NULL,
  `municipality_id` int(10) NOT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `locality_type_id` int(10) NOT NULL,
  PRIMARY KEY (`locality_id`),
  KEY `name` (`name`),
  KEY `municipality_id` (`municipality_id`),
  KEY `locality_type_id` (`locality_type_id`),
  CONSTRAINT `FKLocalities245678` FOREIGN KEY (`locality_type_id`) REFERENCES `locality_types` (`locality_type_id`) ON DELETE CASCADE,
  CONSTRAINT `FKLocalities574896` FOREIGN KEY (`municipality_id`) REFERENCES `administrative_units` (`administrative_unit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.localities: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.locality_types
CREATE TABLE IF NOT EXISTS `locality_types` (
  `locality_type_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`locality_type_id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.locality_types: ~7 rows (około)
INSERT INTO `locality_types` (`locality_type_id`, `name`) VALUES
	(2, 'Kolonia'),
	(7, 'Miasto'),
	(3, 'Osada'),
	(4, 'Osada leśna'),
	(5, 'Osiedla'),
	(6, 'Schronisko turystyczne'),
	(1, 'Wieś');

-- Zrzut struktury tabela projekt_bd.locations
CREATE TABLE IF NOT EXISTS `locations` (
  `location_id` int(10) NOT NULL AUTO_INCREMENT,
  `locality_id` int(5) NOT NULL,
  `street` varchar(50) DEFAULT NULL,
  `building_number` varchar(10) DEFAULT NULL,
  `flat_number` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  KEY `locality_id` (`locality_id`),
  CONSTRAINT `FKLocations403057` FOREIGN KEY (`locality_id`) REFERENCES `localities` (`locality_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.locations: ~0 rows (około)

-- Zrzut struktury widok projekt_bd.locations_of_attractions
-- Tworzenie tymczasowej tabeli, aby przezwyciężyć błędy z zależnościami w WIDOKU
CREATE TABLE `locations_of_attractions` (
	`location_id` INT(10) NOT NULL,
	`voivodship_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`county_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`municipality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locality_id` INT(5) NOT NULL,
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
	`population` INT(10) UNSIGNED NULL,
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
	
	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;
	
	-- Sprawdzenie, czy atrakcja znajdje się w bazie danych
	IF NOT EXISTS (SELECT * FROM attractions AS a WHERE a.attraction_id = attraction_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wskazana atrakcja nie znajduje się w bazie!';
	END IF;
	
	-- Sprawdzenie, czy atrakcja znajduje się w województwie zarządzanym przez użytkownika
	IF NOT EXISTS (SELECT * FROM managed_attractions AS ma WHERE ma.attraction_id = attraction_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania w tym województwie!';	
	END IF;
	
	-- Sprawdzenie, czy nadana nazwa jest poprawna
	IF attraction_name = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Nazwa atrakcji jest niepoprawna!';
	END IF;
	
	-- Aktualizacja danych miejscowości
    UPDATE attractions AS a
    SET
        name = COALESCE(attraction_name, a.`name`),
        description = COALESCE(attraction_desc, a.`description`)
    WHERE attraction_id = a.attraction_id;
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
	
	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;
	
	-- Sprawdzenie czy istnieje powiązanie między wskazaną atrakcją a wskazanym obrazkiem
	IF NOT EXISTS (SELECT * FROM figures_containing_attractions fca WHERE fca.figure_id = figure_id AND fca.attraction_id = attraction_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wskazany obrazek nie jest przypisany do wskazanej atrakcji!';
	END IF;
	
	-- Sprawdzenie czy atrakcja, którą opisuje ten obrazek może być zarządzana przez użytkownika wywołującego procedurę
	IF NOT EXISTS (SELECT * FROM managed_attractions AS ma WHERE ma.attraction_id = attraction_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania tej atrakcji!';
	END IF;
	
	-- Wprowadzenie zmian
	UPDATE figures_containing_attractions AS fca
	SET fca.caption = COALESCE(caption, fca.caption)
	WHERE fca.figure_id = figure_id AND fca.attraction_id = attraction_id;
	
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.modify_locality
DELIMITER //
CREATE PROCEDURE `modify_locality`(
	IN locality_id INT(10),
	IN locality_name VARCHAR(50),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN locality_type INT(10),
	IN municipality_id INT(10),
	IN latititude REAL,
	IN longitude REAL
)
BEGIN	
	
	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;
	
	-- Sprawdzenie, czy miejscowość znajdje się w bazie danych
	IF NOT EXISTS (SELECT * FROM localities WHERE localities.locality_id = locality_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wskazana miejscowość nie znajduje się w bazie!';
	END IF;
	
	-- Sprawdzenie, czy miejscowość znajduje się w województwie zarządzanym przez użytkownika
	IF NOT EXISTS (SELECT * FROM managed_localities AS ml WHERE ml.locality_id = locality_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania w tym województwie!';	
	END IF;
	
	-- Sprawdzenie, czy gmina podana przez użytkownika istnieje
	IF municipality_id IS NOT NULL AND NOT EXISTS (SELECT * FROM administrative_units AS au WHERE au.administrative_unit_id = municipality_id AND au.`type` = 'gmina') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Podana gmina nie istnieje!';	
	END IF;
	
	-- Sprawdzenie, czy typ miejscowości podany przez użytkownika istnieje
	IF locality_type IS NOT NULL AND NOT EXISTS (SELECT * FROM locality_types AS lt WHERE lt.locality_type_id = locality_type) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Podany typ miejscowości nie istnieje!';	
	END IF;
	
	-- Sprawdzenie, czy nazwa miejscowości nie jest pusta
	IF locality_name = '' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Nazwa miejscowości jest niepoprawna!';
	END if;
	
	-- Aktualizacja danych miejscowości
    UPDATE Localities
    SET
        `name` = COALESCE(`locality_name`, Localities.`name`),
        `description` = COALESCE(`locality_desc`, Localities.`description`),
        population = COALESCE(pop, Localities.population),
        municipality_id = COALESCE(municipality_id, Localities.municipality_id),
        latitude = COALESCE(latititude, Localities.latitude),
        longitude = COALESCE(longitude, Localities.longitude),
        locality_type_id = COALESCE(locality_type, localities.locality_type_id)
    WHERE locality_id = Localities.locality_id;
	
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.modify_user_role
DELIMITER //
CREATE PROCEDURE `modify_user_role`(
	IN login VARCHAR(30),
	IN user_role VARCHAR(30)
)
BEGIN
	
	-- Sprawdzenie czy użytkownik jest administratorem merytorycznym lub użytkownikiem root
	IF SESSION_USER() LIKE 'root@%' THEN
		SELECT 'Wymuszono zmianę roli użytkownika' AS Message;
	ELSEIF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'technical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie masz uprawnień do zmiany ról użytkowników!';		
	END IF;
	
	-- Sprawdzenie, czy w bazie znajduje się użytkownik o podanym loginie
	IF NOT EXISTS (SELECT * FROM users AS u WHERE u.login = login) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wskazany użytkownik nie znajduje się w bazie danych!';			
	END IF;
	
	-- Sprawdzenie czy zadana rola nie przyjęła jedną z 3 dozwolonych wartości
	IF user_role != 'viewer' AND user_role != 'technical_administrator' AND user_role != 'meritorical_administrator' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Podana rola jest niepoprawna!';
	END IF;
	
	-- Ustalenie roli na serwerze bazodanowym i odebranie poprzedniej roli
	SET @sql = concat("REVOKE ",(SELECT `role` FROM users AS u WHERE u.login = login)," FROM ",`login`);
	PREPARE stmt2 FROM @sql;
	EXECUTE stmt2;
	DEALLOCATE PREPARE stmt2;
	
	SET @sql = concat("GRANT ",`user_role`," TO ",`login`);
	PREPARE stmt2 FROM @sql;
	EXECUTE stmt2;
	DEALLOCATE PREPARE stmt2;
	
	SET @sql = concat("SET DEFAULT ROLE ",`user_role`," FOR ",`login`);
	PREPARE stmt2 FROM @SQL;
	EXECUTE stmt2;
	DEALLOCATE PREPARE stmt2;
	FLUSH PRIVILEGES;
	
	-- Ustalenie roli w bazie danych
	UPDATE users AS u
	SET u.`role` = user_role
	WHERE u.login = login;
	
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.permissions
CREATE TABLE IF NOT EXISTS `permissions` (
  `permission_id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(1000) NOT NULL,
  PRIMARY KEY (`permission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.permissions: ~2 rows (około)
INSERT INTO `permissions` (`permission_id`, `name`, `description`) VALUES
	(1, 'Edytor miejscowości', 'Prawo do dodawania, usuwania oraz modyfikowania miejscowości w zarządzanych województwach.'),
	(2, 'Edytor atrakcji', 'Prawo do dodawania, usuwania oraz modyfikowania atrakcji, które zlokalizowane są w miejscowściach przynależnych do zarządzanych województw.');

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
	
	-- Pierwsze konto w systemie otrzymuje role administratora merytorycznego
	DECLARE user_amount INT;
	DECLARE user_role VARCHAR(30);
	SELECT COUNT(*) INTO user_amount FROM users;
	
	-- Dodanie nowego konta do serwera bazodanowego
	set @sql = concat("CREATE USER '",`user_login`,"'@'%","' IDENTIFIED BY '",`user_password`,"'");
   PREPARE stmt1 FROM @sql;
   EXECUTE stmt1;
   DEALLOCATE PREPARE stmt1;

	-- Ustalenie roli użytkownika
	IF user_amount = 0 THEN
		SET user_role = 'technical_administrator';
	ELSE
		SET user_role = 'viewer';
	END IF;
	
	set @sql = concat("GRANT ",`user_role`," TO ",`user_login`);
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
   
   set @sql = concat("SET DEFAULT ROLE ",`user_role`," FOR ",`user_login`);
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
	
	-- Dodanie nowego konta do bazy danych
	INSERT INTO users (users.login,users.`password`,users.role) VALUES (user_login, user_password, user_role);
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.return_table
CREATE TABLE IF NOT EXISTS `return_table` (
  `Message` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.return_table: ~1 rows (około)
INSERT INTO `return_table` (`Message`) VALUES
	(1);

-- Zrzut struktury tabela projekt_bd.types_assigned_to_attractions
CREATE TABLE IF NOT EXISTS `types_assigned_to_attractions` (
  `attraction_type_id` int(10) NOT NULL,
  `attraction_id` int(10) NOT NULL,
  PRIMARY KEY (`attraction_type_id`,`attraction_id`),
  KEY `attraction_id` (`attraction_id`),
  CONSTRAINT `FKTypes_Assi239592` FOREIGN KEY (`attraction_id`) REFERENCES `attractions` (`attraction_id`) ON DELETE CASCADE,
  CONSTRAINT `FKTypes_Assi695374` FOREIGN KEY (`attraction_type_id`) REFERENCES `attraction_types` (`attraction_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.types_assigned_to_attractions: ~0 rows (około)

-- Zrzut struktury procedura projekt_bd.unassign_attraction_from_locality
DELIMITER //
CREATE PROCEDURE `unassign_attraction_from_locality`(
    IN attr_id INT,
    IN loc_id INT
)
BEGIN
    DECLARE exists_relation INT;
    DECLARE lct_id INT;
    IF attr_id IS NULL OR loc_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parametry nie mogą być NULL';
    ELSE
        SELECT COUNT(*) INTO exists_relation
        FROM locations_of_attractions AS al
        WHERE al.attraction_id = attr_id AND al.locality_id = loc_id;

        IF exists_relation = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie istnieje powiązanie między wskazanymi elementami';
        ELSE
        		-- Sprawdzenie czy użytkownik może edytować tę miejscowość
        		IF NOT EXISTS (
				  SELECT 1
				  FROM managed_attractions AS ma
				  WHERE ma.attraction_id = attr_id
				) THEN
					SIGNAL SQLSTATE '45000'
            	SET MESSAGE_TEXT = 'Nie masz uprawnień do edycji atrakcji w tym województwie';
				END IF;
        
        		SELECT loa.location_id
        		INTO lct_id
        		FROM locations_of_attractions AS loa
        		WHERE loa.locality_id = loc_id AND attr_id = loa.attraction_id;
        
            DELETE FROM attractions_locations
            WHERE attraction_id = attr_id AND location_id = lct_id;
        END IF;
    END IF;
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_figure_from_attraction
DELIMITER //
CREATE PROCEDURE `unassign_figure_from_attraction`(
    IN figure_id INT,
    IN attraction_id INT
)
BEGIN
    DECLARE exists_relation INT;
        
    IF figure_id IS NULL OR attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parametry nie mogą być NULL';
    ELSE
        SELECT COUNT(*) INTO exists_relation
        FROM figures_containing_attractions AS fca
        WHERE fca.figure_id = figure_id AND fca.attraction_id = attraction_id;

        IF exists_relation = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie istnieje powiązanie między wskazanymi elementami';
        ELSE
        		-- Sprawdzenie, czy atrakcja jest zarządzana przez użytkownika
        		IF NOT EXISTS (
        			SELECT 1
        			FROM managed_attractions AS ma
        			WHERE ma.attraction_id = attraction_id
				) THEN
					SIGNAL SQLSTATE '45000'
            	SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania atrakcji w tym województwie!';
				END IF;
        	
            -- Usunięcie powiązania
            DELETE FROM figures_containing_attractions
            WHERE figure_id = figure_id AND attraction_id = attraction_id;
        END IF;
    END IF;
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_permission_from_user
DELIMITER //
CREATE PROCEDURE `unassign_permission_from_user`(
    IN user_login VARCHAR(255),
    IN voivod_id INT,
    IN perm_id INT
)
BEGIN

	-- Sprawdzenie, czy wskazany użytkownik istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM registered_users AS ru
		WHERE ru.login = user_login
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Wskazany użytkownik nie istnieje!';
	END IF;
   
	-- Usunięcie pojedynczego uprawnienia w regionie
	IF (voivod_id IS NOT NULL) AND (perm_id IS NOT NULL) THEN
		DELETE FROM users_permissions_in_voivodships
		WHERE login = user_login AND 
				voivod_id = voivodship_id AND 
				perm_id = permission_id;
	-- Usunięcie użytkownikowi wszyskich uprawnień w regionie
	ELSEIF (voivod_id IS NOT NULL) AND (perm_id IS NULL) THEN
		DELETE FROM users_permissions_in_voivodships
		WHERE login = user_login AND
				voivod_id = voivodship_id;
	ELSEIF (voivod_id IS NULL) AND (perm_id IS NULL) THEN
		DELETE FROM users_permissions_in_voivodships
		WHERE login  = user_login;
	ELSE
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Podano niepoprawne parametry!';
	END IF;
   
END//
DELIMITER ;

-- Zrzut struktury procedura projekt_bd.unassign_type_from_attraction
DELIMITER //
CREATE PROCEDURE `unassign_type_from_attraction`(
    IN type_id INT,
    IN attr_id INT
)
BEGIN

	-- Sprawdzenie, czy atrakcja istnieje
	IF NOT EXISTS (
		SELECT 1
		FROM attractions AS a
		WHERE a.attraction_id = attr_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Wskazana atrakcja nie istnieje!';
	END IF;
	
	-- Sprawdzenie, czy użytkownik ma uprawnienia do zarządzania tą atrakcją
	IF NOT EXISTS (
		SELECT 1 
		FROM managed_attractions AS ma
		WHERE ma.attraction_id = attr_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Nie masz uprawnień do edycji atrakcji w tym województwie!';
	END IF;
	 
	-- Usunięcie wskazanego typu atrakcji z listy typów przypisanych do atrakcji
	IF type_id IS NOT NULL THEN
		-- Sprawdzenie, czy typ atrakcji istnieje
		IF NOT EXISTS (
			SELECT 1
			FROM attraction_types AS t
			WHERE t.attraction_type_id = type_id
		) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Wskazany typ atrakcji nie istnieje!';
		END IF;
		
		-- Usunięcie przypisania
		DELETE FROM types_assigned_to_attractions 
		WHERE attraction_type_id = type_id AND attraction_id = attr_id;

	-- Usunięcie wszystkich typów przypisanych do atrakcji
	ELSE
		-- Usunięcie przypisań
		DELETE FROM types_assigned_to_attractions 
		WHERE attraction_id = attr_id; 
	END IF;
	 
END//
DELIMITER ;

-- Zrzut struktury tabela projekt_bd.users
CREATE TABLE IF NOT EXISTS `users` (
  `login` varchar(30) NOT NULL,
  `password` char(48) NOT NULL,
  `role` varchar(30) NOT NULL,
  PRIMARY KEY (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.users: ~0 rows (około)

-- Zrzut struktury tabela projekt_bd.users_permissions_in_voivodships
CREATE TABLE IF NOT EXISTS `users_permissions_in_voivodships` (
  `login` varchar(30) NOT NULL,
  `voivodship_id` int(10) NOT NULL,
  `permission_id` int(10) NOT NULL,
  PRIMARY KEY (`login`,`voivodship_id`,`permission_id`),
  KEY `login` (`login`),
  KEY `FKUsers_Perm443111` (`permission_id`),
  CONSTRAINT `FKUsers_Perm443111` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`) ON DELETE CASCADE,
  CONSTRAINT `FKUsers_Perm990828` FOREIGN KEY (`login`, `voivodship_id`) REFERENCES `voivodships_administrated_by_users` (`login`, `voivodship_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.users_permissions_in_voivodships: ~0 rows (około)

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
	`population` INT(10) UNSIGNED NULL,
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
  CONSTRAINT `FKVoivodship178065` FOREIGN KEY (`login`) REFERENCES `users` (`login`) ON DELETE CASCADE,
  CONSTRAINT `FKVoivodship87041` FOREIGN KEY (`voivodship_id`) REFERENCES `administrative_units` (`administrative_unit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Zrzucanie danych dla tabeli projekt_bd.voivodships_administrated_by_users: ~0 rows (około)

-- Zrzut struktury wyzwalacz projekt_bd.After_Delete_On_Attractions
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER After_Delete_On_Attractions
	AFTER DELETE ON attractions FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich lokalizacji, które nie są przypiane do żandej atrakcji
		DELETE FROM locations
		WHERE location_id NOT IN (
			SELECT DISTINCT al.location_id
			FROM attractions_locations AS al
		);
		
		-- Usunięcie wszystkich ilustracji, które nie są przypisane do żadnej atrakcji
		DELETE FROM figures
		WHERE figure_id NOT IN (
			SELECT DISTINCT figure_id
			FROM figures_containing_attractions
		);
		
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Zrzut struktury wyzwalacz projekt_bd.After_Delete_On_Localities
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER After_Delete_On_Localities
	AFTER DELETE ON localities FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich atrakcji, które były zlokalizowane tylko w tej miejscowości
		DELETE FROM attractions
		WHERE attraction_id NOT IN (
			SELECT DISTINCT al.attraction_id
			FROM attractions_locations AS al
		);
		
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Zrzut struktury wyzwalacz projekt_bd.After_Delete_On_Users_Permissions_In_Voivodships
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER After_Delete_On_Users_Permissions_In_Voivodships
	AFTER DELETE ON users_permissions_in_voivodships FOR EACH ROW
BEGIN
		
		-- Usunięcie użytkownikom uprawnień do zarządzenai wszystkimi województtwami, w których nie mają przypisanych uprawnień
		DELETE FROM voivodships_administrated_by_users
		WHERE (voivodship_id, login) NOT IN (
			SELECT DISTINCT voivodship_id, login
			FROM users_permissions_in_voivodships AS upv
		);
		
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Zrzut struktury wyzwalacz projekt_bd.Before_User_Deleted
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER Before_User_Deleted 
	BEFORE DELETE ON 
	users FOR EACH ROW
BEGIN
		-- Zapobiega usunięciu jedynego konta o roli administratora technicznego
		DECLARE amount_of_tech_admins INT;
		IF OLD.`role` = 'technical_administrator' THEN
			SELECT COUNT(*)
			INTO 	amount_of_tech_admins
			FROM users
			WHERE users.role = 'technical_administrator';
			
			IF amount_of_tech_admins = 1 AND (SESSION_USER() NOT LIKE 'root@%') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie można usunąć jedynego konta administratora technicznego!';
			END IF;
		END IF;	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Zrzut struktury wyzwalacz projekt_bd.Before_User_Upadted
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER Before_User_Upadted 
	BEFORE UPDATE ON 
	users FOR EACH ROW
BEGIN
		-- Zapobiega usunięciu jedynego konta o roli administratora technicznego
		DECLARE amount_of_tech_admins INT;
		IF OLD.`role` = 'technical_administrator' THEN
			SELECT COUNT(*)
			INTO 	amount_of_tech_admins
			FROM users
			WHERE users.role = 'technical_administrator';
			
			IF amount_of_tech_admins = 1 AND (SESSION_USER() NOT LIKE 'root@%') THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie można usunąć jedynego konta administratora technicznego!';
			END IF;
		END IF;	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

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
	Municipality.administrative_unit_id AS municipality_id,
	Municipality.name AS municipality_name,
	County.administrative_unit_id AS county_id,
	County.name AS county_name,
	Voivodship.administrative_unit_id AS voivodship_id,
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
	users_permissions_in_voivodships AS upv ON Permissions.permission_id = upv.permission_id INNER JOIN
	voivodships_administrated_by_users AS vau ON upv.voivodship_id = vau.voivodship_id AND upv.login = vau.login INNER JOIN
	Users ON vau.login = Users.login INNER JOIN
	Administrative_units AS Voivodship ON vau.voivodship_id = Voivodship.administrative_unit_id ;

-- Zrzut struktury widok projekt_bd.locations_of_attractions
-- Usuwanie tabeli tymczasowej i tworzenie ostatecznej struktury WIDOKU
DROP TABLE IF EXISTS `locations_of_attractions`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `locations_of_attractions` AS SELECT
	Locations.location_id,
	Voivodship.name AS voivodship_name,
	County.name AS county_name,
	Municipality.name AS municipality_name,
	Localities.name AS locality_name,
	Localities.locality_id AS locality_id,
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
	users_permissions_in_voivodships AS upv ON upv.voivodship_id = voivodships_administrated_by_users.voivodship_id INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locations ON Localities.locality_id = Locations.locality_id INNER JOIN
	Attractions_locations ON Locations.location_id = Attractions_locations.location_id INNER JOIN
	Attractions ON Attractions_locations.attraction_id = Attractions.attraction_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') AND upv.permission_id = 2 ;

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
	users_permissions_in_voivodships AS upv ON upv.voivodship_id = voivodships_administrated_by_users.voivodship_id INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') AND upv.permission_id = 1 ;

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
	Voivodships_Administrated_By_Users AS vau ON Users.login = vau.login INNER JOIN
	Administrative_units AS Voivodship ON vau.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Users_Permissions_In_Voivodships AS upv ON vau.voivodship_id = upv.voivodship_id AND vau.login = upv.login INNER JOIN
	Permissions ON upv.permission_id = Permissions.permission_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
