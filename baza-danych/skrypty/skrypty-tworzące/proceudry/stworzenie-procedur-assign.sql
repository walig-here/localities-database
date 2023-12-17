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
	IF attraction_id IS NULL OR locality_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna przypisac atrakcji: attraction_id lub locality_id sa NULL';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM attractions WHERE id = attraction_id) OR 
       NOT EXISTS (SELECT 1 FROM localities WHERE id = locality_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja lub miejscowosc nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy miejscowość należy do województwa zarządzanego przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM voivodships_administrated_by_users v
        INNER JOIN Localities l ON l.voivodship_id = v.voivodship_id
        WHERE l.id = locality_id AND v.user_id = CURRENT_USER_ID()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Miejscowosc nie nalezy do wojewodztwa zarzadzanego przez uzytkownika';
    END IF;

    -- Sprawdzenie, czy lokalizacja istnieje w bazie, jeśli nie, to dodanie jej
    IF NOT EXISTS (
        SELECT 1 
        FROM locations 
        WHERE locality_id = locality_id AND street = street 
            AND building_number = building_number AND flat_number = flat_number
    ) THEN
        INSERT INTO Locations (locality_id, street, building_number, flat_number)
        VALUES (locality_id, street, building_number, flat_number);
    END IF;

    -- Przypisanie atrakcji do lokalizacji
    INSERT INTO Attractions_locations (attraction_id, locality_id, street, building_number, flat_number)
    VALUES (attraction_id, locality_id, street, building_number, flat_number);

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
