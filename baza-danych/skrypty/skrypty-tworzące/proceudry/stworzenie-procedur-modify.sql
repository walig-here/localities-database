-- modify_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_locality (
	IN locality_id INT(10),
	IN locality_name VARCHAR(50),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN locality_type INT(10),
	IN municipality_id INT(10),
	IN latititude REAL,
	IN longitude REAL
) BEGIN	
	
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
	
END;
// 
DELIMITER ;

-- modify_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_attraction (
	IN attraction_id INT(10),
	IN attraction_name VARCHAR(50),
	IN attraction_desc VARCHAR(1000)
) BEGIN
	
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
END;
// 
DELIMITER ;

-- modify_user_role
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_user_role (
	IN login VARCHAR(30),
	IN user_role VARCHAR(30)
) BEGIN
	DECLARE prev_role VARCHAR(30);
	
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
	
	-- Pobranie porzedniej roli
	SELECT u.`role`
	INTO prev_role
	FROM users AS u
	WHERE u.login = login;
	
	-- Ustalenie roli w bazie danych
	UPDATE users AS u
	SET u.`role` = user_role
	WHERE u.login = login;
	
	-- Ustalenie roli na serwerze bazodanowym i odebranie poprzedniej roli
	SET @sql = concat("REVOKE ",prev_role," FROM ",`login`);
	PREPARE stmt2 FROM @SQL;
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
	
END;
// 
DELIMITER ;

-- modify_figure_caption
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_figure_caption (
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
) BEGIN
	
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
	
END;
// 
DELIMITER ;