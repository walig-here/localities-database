-- add_new_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE add_new_locality (
	IN locality_name VARCHAR(30),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latitude REAL,
	IN longitude REAL,
	IN locality_type_id INT(10)
) BEGIN

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

END;
// 
DELIMITER ;

-- add_new_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE add_new_attraction (
	IN attraction_name VARCHAR(30),
	IN attraction_desc VARCHAR(1000),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN buildig_number VARCHAR(30),
	IN flat_number VARCHAR(30)
) BEGIN
	
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
	
END;
// 
DELIMITER ;

-- add_locality_to_fav_list
DELIMITER //
CREATE OR REPLACE PROCEDURE add_locality_to_fav_list (
	IN locality_id INT(10),
	IN adnotation VARCHAR(1000)
) BEGIN

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

END;
// 
DELIMITER ;

-- register_user
DELIMITER //
CREATE OR REPLACE PROCEDURE register_user (
	IN	user_login  VARCHAR(30),
	IN user_password VARCHAR(48)
) BEGIN
	
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
END;
// 
DELIMITER ;