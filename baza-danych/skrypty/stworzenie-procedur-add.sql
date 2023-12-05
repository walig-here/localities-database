-- add_new_locality
DELIMITER //
CREATE PROCEDURE add_new_locality (
	IN locality_name VARCHAR(30),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latitude REAL,
	IN longitude REAL
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- add_new_attraction
DELIMITER //
CREATE PROCEDURE add_new_attraction (
	IN attraction_name VARCHAR(30),
	IN attraction_desc VARCHAR(1000),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN buildig_number VARCHAR(30),
	IN flat_number VARCHAR(30)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- add_locality_to_fav_list
DELIMITER //
CREATE PROCEDURE add_locality_to_fav_list (
	IN locality_id INT(10),
	IN adnotation VARCHAR(1000)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- register_user
DELIMITER //
CREATE PROCEDURE register_user (
	IN	user_login  VARCHAR(30),
	IN user_password VARCHAR(48)
) BEGIN
	-- Dodanie nowego konta do serwera bazodanowego
	set @sql = concat("CREATE USER '",`user_login`,"'@'%","' IDENTIFIED BY '",`user_password`,"'");
   PREPARE stmt1 FROM @sql;
   EXECUTE stmt1;
   DEALLOCATE PREPARE stmt1;

   set @sql = concat("GRANT viewer TO '",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
   
   set @sql = concat("SET DEFAULT ROLE viewer FOR '",`user_login`,"' ");
   PREPARE stmt2 FROM @sql;
   EXECUTE stmt2;
   DEALLOCATE PREPARE stmt2;
   FLUSH PRIVILEGES;
	
	-- Dodanie nowego konta do bazy danych
	INSERT INTO users (users.login,users.`password`,users.role) VALUES (user_login, user_password, 'viewer');
END;
// 
DELIMITER ;