-- del_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE del_locality (
	IN locality_id INT(10)
) BEGIN
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
END;
// 
DELIMITER ;

-- del_locality_from_fav_list
DELIMITER //
CREATE OR REPLACE PROCEDURE del_locality_from_fav_list (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- del_user
DELIMITER //
CREATE OR REPLACE PROCEDURE del_user (
	IN user_login VARCHAR(30)
) BEGIN
	
	
	-- Jeżeli użytkownik wykonujący komendę nie jest administratorem technicznym, to moze usunąć wyłącznie
	-- swoje konto
	DECLARE caller_role VARCHAR(30);
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
END;
// 
DELIMITER ;

-- del_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE del_attraction (
	IN attraction_id INT(10)
) BEGIN
	    IF attraction_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna usunac atrakcji';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM attractions WHERE id = attraction_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy atrakcja jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM voivodships_administrated_by_users v
        INNER JOIN attractions a ON a.voivodship_id = v.voivodship_id
        WHERE a.id = attraction_id AND v.user_id = CURRENT_USER_ID()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie znajduje sie w wojewodztwie zarzadzanym przez uzytkownika';
    END IF;

    -- Usunięcie atrakcji
    DELETE FROM attractions WHERE id = attraction_id;
END;
// 
DELIMITER ;
