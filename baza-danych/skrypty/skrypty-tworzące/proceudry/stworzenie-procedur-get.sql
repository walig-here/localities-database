-- get_localities_number_of_attractions 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_localities_number_of_attractions (
	IN locality_id INT(10)
) BEGIN
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

END;
// 
DELIMITER ;

-- get_locations_from_locality 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_locations_from_locality (
	IN locality_id INT(10)
) BEGIN
	
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
	
END;
// 
DELIMITER ;

-- get_voivodships_managed_by_user 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_voivodships_managed_by_user (
	IN login VARCHAR(30)
) BEGIN
	
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
	
END;
// 
DELIMITER ;

-- get_user_permissions_in_voivodship 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_user_permissions_in_voivodship (
	IN login VARCHAR(30),
	IN voivodship_id INT(10)
) BEGIN

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

END;
// 
DELIMITER ;

-- get_attractions_in_locality 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_attractions_in_locality (
	IN locality_id INT(10)
) BEGIN

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

END;
// 
DELIMITER ;

-- get_figures_assigned_to_attraction 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_figures_assigned_to_attraction (
	IN attraction_id INT(10)
) BEGIN

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
		
END;
// 
DELIMITER ;

-- get_types_assigned_to_attraction 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_types_assigned_to_attraction (
	IN attraction_id INT(10)
) BEGIN

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

END;
// 
DELIMITER ;

-- get_counties_from_voivodship 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_counties_from_voivodship (
	IN voivodship_id INT(10)
) BEGIN

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
	
END;
// 
DELIMITER ;

-- get_municipalities_from_county 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_municipalities_from_county (
	IN county_id INT(10)
) BEGIN
	
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
	
END;
// 
DELIMITER ;