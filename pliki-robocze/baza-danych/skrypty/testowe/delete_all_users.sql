delimiter //
CREATE PROCEDURE del_all_users ()
BEGIN
	DECLARE r_user ROW TYPE OF registered_users;
	DECLARE done INT DEFAULT FALSE;
	DECLARE c_registered_user CURSOR FOR
		SELECT * FROM registered_users;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
		
	OPEN c_registered_user;
	read_loop : LOOP
		FETCH c_registered_user INTO r_user;
		IF done THEN
			LEAVE read_loop;
		END IF;
		CALL del_user(r_user.login);
	END LOOP;
END //
delimiter ;

CALL del_all_users();

DROP PROCEDURE del_all_users;

SELECT * FROM registered_users;