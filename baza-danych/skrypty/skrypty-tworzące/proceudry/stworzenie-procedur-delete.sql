-- del_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE del_locality (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
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
	-- uzupełnić
END;
// 
DELIMITER ;