-- modify_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_locality (
	IN locality_id INT(10),
	IN locality_name VARCHAR(50),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latititude REAL,
	IN longitude REAL
) BEGIN	
	-- Sprawdzenie, czy miejscowość znajdje się w bazie danych
	SELECT *
	FROM localities
	WHERE projekt_bd.localities.locality_id = locality_id;
	IF NOT EXISTS (SELECT * FROM localities WHERE locality_id = locality_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Wskazana miejscowość nie znajduje się w bazie!';
	END IF;
	
	-- Sprawdzenie, czy użytkownik to administrator merytoryczny
	IF NOT EXISTS (SELECT * FROM user_account WHERE my_role = 'meritorical_administrator') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania danych!';
	END IF;
	
	-- Sprawdzenie, czy miejscowość znajduje się w województwie zarządzanym przez użytkownika
	IF NOT EXISTS (SELECT * FROM managed_localities AS ml WHERE ml.locality_id = locality_id) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie posiadasz uprawnień do edytowania w tym województwie!';	
	END IF;
	
	-- Aktualizacja danych miejscowości
    UPDATE Localities
    SET
        name = COALESCE(`name`, Localities.`name`),
        description = COALESCE(`desc`, Localities.`description`),
        population = COALESCE(pop, Localities.population),
        municipality_id = COALESCE(municipality_id, Localities.municipality_id),
        latitude = COALESCE(lat, Localities.latitude),
        longitude = COALESCE(lon, Localities.longitude)
    WHERE locality_id = Localities.locality_id;
    
    -- Aktualizacja typu miejscowości na podstawie populacji
    -- TO DO
	
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
	-- uzupełnić
END;
// 
DELIMITER ;

-- modify_user_role
DELIMITER //
CREATE OR REPLACE PROCEDURE modify_user_role (
	IN login VARCHAR(30),
	IN user_role VARCHAR(30)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- modify_figure_caption
DELIMITER //
CREATE OR REPLACE OR REPLACE PROCEDURE modify_figure_caption (
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;