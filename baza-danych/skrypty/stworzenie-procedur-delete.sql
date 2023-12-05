-- del_locality
DELIMITER //
CREATE PROCEDURE del_locality (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- del_locality_from_fav_list
DELIMITER //
CREATE PROCEDURE del_locality_from_fav_list (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- del_user
DELIMITER //
CREATE PROCEDURE del_user (
	IN user_login VARCHAR(30)
) BEGIN
	-- Usunięcie użytkownika z serwera bazodanowego
	set @sql = concat("DROP USER'",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   
   -- Usunięcie użytkownika z bazy danych
   DELETE FROM projekt_bd.users
   WHERE user_login = Users.login;
END;
// 
DELIMITER ;

-- del_attraction
DELIMITER //
CREATE PROCEDURE del_attraction (
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;