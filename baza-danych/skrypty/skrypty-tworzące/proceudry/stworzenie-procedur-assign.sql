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
    IF NOT EXISTS (SELECT 1 FROM voivodships_administrated_by_users AS vau WHERE vau.login = login AND vau.voivodship_id = voivodship_id) THEN
        INSERT INTO Voivodships_Administrated_By_Users (login, voivodship_id)
        VALUES (login, voivodship_id);
    END IF;

    -- Nadanie uprawnienia
    INSERT INTO users_permissions_in_voivodships (login, voivodship_id, permission_id)
    VALUES (login, voivodship_id, permission_id);

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
		FROM full_localities_data AS fld
		JOIN user_permissions AS up ON up.voivodship_id = fld.voivodship_id
		WHERE fld.locality_id = locality_id AND up.permission_id = 2
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

END;
// 
DELIMITER ;

-- assign_type_to_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_type_to_attraction (
	IN type_id INT(10),
	IN attraction_id INT(10)
) BEGIN
    IF type_id IS NULL OR attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac typu: type_id lub attraction_id sa NULL';
    END IF;

    -- Sprawdzenie, czy type_id i attraction_id znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM types WHERE id = type_id) OR 
       NOT EXISTS (SELECT 1 FROM attractions WHERE id = attraction_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Typ atrakcji lub atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie czy atrakcja jest zlokalizowana w województwie zarządzanym przez administratora i czy ma on uprawnienia
    IF NOT EXISTS (
        SELECT 1 
        FROM voivodships_administrated_by_users v
        INNER JOIN attractions a ON a.voivodship_id = v.voivodship_id
        WHERE a.id = attraction_id AND v.user_id = CURRENT_USER_ID() AND v.has_attraction_management_permission = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie ma uprawnien do zarzadzania atrakcjami w wojewodztwie, w którym znajduje sie atrakcja';
    END IF;

    -- Przypisanie typu atrakcji do atrakcji
    INSERT INTO types_assigned_to_attractions (type_id, attraction_id)
    VALUES (type_id, attraction_id);
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
	IF figure_id IS NULL OR attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac ilustracji: figure_id lub attraction_id są NULL';
    END IF;

    -- Sprawdzenie, czy figure_id i attraction_id znajdują się w bazie danych
    IF NOT EXISTS (SELECT 1 FROM figures WHERE id = figure_id) OR 
       NOT EXISTS (SELECT 1 FROM attractions WHERE id = attraction_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ilustracja lub atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy atrakcja jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM voivodships_administrated_by_users v
        INNER JOIN attractions a ON a.voivodship_id = v.voivodship_id
        WHERE a.id = attraction_id AND v.user_id = CURRENT_USER_ID()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie znajduje się w województwie zarządzanym przez użytkownika';
    END IF;

    -- Przypisanie ilustracji do atrakcji
    INSERT INTO figures_containing_attractions (figure_id, attraction_id, caption)
    VALUES (figure_id, attraction_id, caption);
END;
// 
DELIMITER ;
