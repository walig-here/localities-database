-- unassign_permission_from_user 
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_permission_from_user (
    IN user_login VARCHAR(255),
    IN voivodship_id INT,
    IN permission_id INT
)
BEGIN
    DECLARE is_admin INT;
    SELECT COUNT(*) INTO is_admin
    FROM users
    WHERE login = user_login AND role = 'administrator_merytoryczny';

    IF is_admin = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uzytkownik nie jest administratorem merytorycznym';
    ELSE
        IF voivodship_id IS NOT NULL AND permission_id IS NOT NULL THEN
            DELETE FROM users_permissions_in_voivodships
            WHERE user_login = user_login AND voivodship_id = voivodship_id AND permission_id = permission_id;
        
        ELSEIF voivodship_id IS NOT NULL AND permission_id IS NULL THEN
            DELETE FROM users_permissions_in_voivodships
            WHERE user_login = user_login AND voivodship_id = voivodship_id;

        -- wyjątek dla NULL w voivodship_id i NOT NULL w permission_id
        ELSEIF voivodship_id IS NULL AND permission_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nieprawidłowe parametry: voivodship_id nie może być NULL, gdy permission_id jest NOT NULL';
        
        ELSE
            DELETE FROM users_permissions_in_voivodships
            WHERE user_login = user_login;
        END IF;
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
        FROM figures_containing_attractions
        WHERE figure_id = figure_id AND attraction_id = attraction_id;

        IF exists_relation = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie istnieje powiązanie między wskazanymi elementami';
        ELSE
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
    IN attraction_id INT,
    IN locality_id INT
)
BEGIN
    DECLARE exists_relation INT;
    IF attraction_id IS NULL OR locality_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parametry nie mogą być NULL';
    ELSE
        SELECT COUNT(*) INTO exists_relation
        FROM attraction_locations
        WHERE attraction_id = attraction_id AND locality_id = locality_id;

        IF exists_relation = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nie istnieje powiązanie między wskazanymi elementami';
        ELSE
            DELETE FROM attraction_locations
            WHERE attraction_id = attraction_id AND locality_id = locality_id;
        END IF;
    END IF;
END //
DELIMITER ;

-- unassign_type_from_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE unassign_type_from_attraction (
    IN attraction_type_id INT,
    IN attraction_id INT
)
BEGIN
	 DECLARE exists_relation INT;
    IF attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parametr attraction_id nie może być NULL';
    ELSE
        IF attraction_type_id IS NOT NULL THEN
            SELECT COUNT(*) INTO exists_relation
            FROM types_assigned_to_attractions
            WHERE attraction_type_id = attraction_type_id AND attraction_id = attraction_id;

            IF exists_relation = 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Nie istnieje powiązanie między wskazanymi elementami';
            ELSE
                DELETE FROM types_assigned_to_attractions
                WHERE attraction_type_id = attraction_type_id AND attraction_id = attraction_id;
            END IF;
        ELSE
            DELETE FROM types_assigned_to_attractions
            WHERE attraction_id = attraction_id;
        END IF;
    END IF;
END //
DELIMITER ;