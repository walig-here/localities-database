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
	IN locality_identifier INT(10)
) BEGIN
	 IF locality_identifier IS NOT NULL THEN
        DELETE FROM favourite_localities 
		  WHERE locality_id = locality_identifier AND SESSION_USER() LIKE CONCAT(login,'@','%');
    END IF;
END;
// 
DELIMITER ;

-- del_user
DELIMITER //
CREATE OR REPLACE PROCEDURE del_user (
	IN user_login VARCHAR(30)
) BEGIN
	
	DECLARE caller_role VARCHAR(30);
	
	-- Jeżeli w parametrze zamiast loginu podano null, to należy przyjąć login wywołującego metodę użytkownika
	IF user_login IS NULL THEN
		SELECT `my_login`
		INTO user_login
		FROM user_account;
	END IF;
	
	-- Jeżeli użytkownik wykonujący komendę nie jest administratorem technicznym, to moze usunąć wyłącznie
	-- swoje konto
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
	IN attr_id INT(10)
) BEGIN
	    IF attr_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nie mozna usunac atrakcji';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM attractions AS a WHERE a.attraction_id = attr_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy atrakcja jest zlokalizowana w województwie zarządzanym przez użytkownika
    IF NOT EXISTS (
        SELECT 1 
        FROM managed_attractions AS ma
		  WHERE ma.attraction_id = attr_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Atrakcja nie znajduje sie w wojewodztwie zarzadzanym przez uzytkownika';
    END IF;

    -- Usunięcie atrakcji
    DELETE FROM attractions WHERE attraction_id = attr_id;
END;
// 
DELIMITER ;
