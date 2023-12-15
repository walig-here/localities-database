-- assign_permission_to_user
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_permission_to_user (
	IN voivodship_id INT(10),
	IN login VARCHAR(30),
	IN permission_id INT(10)
) BEGIN
	IF voivodship_id IS NULL OR login IS NULL OR permission_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac uprawnien: jeden z parametrow jest NULL';
        LEAVE PROCEDURE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE login = login AND is_metrytoryczny_admin = 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie posiada roli administratora metrytorycznego';
        LEAVE PROCEDURE;
    END IF;

    -- Sprawdzenie, czy parametry znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM Voivodships WHERE id = voivodship_id) OR 
       NOT EXISTS (SELECT 1 FROM Permissions WHERE id = permission_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Wojewodztwo lub uprawnienie nie istnieje w bazie danych';
        LEAVE PROCEDURE;
    END IF;

    -- Nadanie uprawnienia
    INSERT INTO Users_Permissions_In_Voivodships (user_login, voivodship_id, permission_id)
    VALUES (login, voivodship_id, permission_id);

    -- Aktualizacja tabeli, jeśli to konieczne
    IF NOT EXISTS (SELECT 1 FROM Voivodships_Administrated_By_Users WHERE user_login = login AND voivodship_id = voivodship_id) THEN
        INSERT INTO Voivodships_Administrated_By_Users (user_login, voivodship_id)
        VALUES (login, voivodship_id);
    END IF;

END;
// 
DELIMITER ;

-- assign_attraction_to_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_attraction_to_locality (
	IN attraction_id INT(10),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN building_number VARCHAR(50),
	IN flat_number VARCHAR(50)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- assign_type_to_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_type_to_attraction (
	IN type_id INT(10),
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- assign_figure_to_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_figure_to_attraction (
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;
