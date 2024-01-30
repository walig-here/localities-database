-- unassign_permission_from_user 
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_permission_from_user (
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
   
END //
DELIMITER ;

-- unassign_figure_from_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_figure_from_attraction (
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
END //
DELIMITER ;

-- unassign_attraction_from_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_attraction_from_locality (
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
END //
DELIMITER ;

-- unassign_type_from_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_type_from_attraction (
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
	 
END //
DELIMITER ;