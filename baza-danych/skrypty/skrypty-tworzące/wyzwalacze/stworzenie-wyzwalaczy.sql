-- Wyzwalacz Before_User_Deleted --------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER Before_User_Deleted 
	BEFORE DELETE ON 
	users FOR EACH ROW
BEGIN
		-- Zapobiega usunięciu jedynego konta o roli administratora technicznego
		DECLARE amount_of_tech_admins INT;
		IF OLD.`role` = 'technical_administrator' THEN
			SELECT COUNT(*)
			INTO 	amount_of_tech_admins
			FROM users
			WHERE users.role = 'technical_administrator';
			
			IF amount_of_tech_admins = 1 THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nie można usunąć jedynego konta administratora technicznego!';
			END IF;
		END IF;	
END; //
DELIMITER ;

-- Wyzwalacz After_Delete_On_Locations --------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER After_Delete_On_Locations 
	AFTER DELETE ON locations FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz Afrer_Delete_On_Attractions_Locations ---------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER After_Delete_On_Attractions_Locations 
	AFTER DELETE ON attractions_locations FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz After_Delete_On_Figures_Containing_Attractions ------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER After_Delete_On_Figures_Containing_Attractions
	AFTER DELETE ON figures_containing_attractions FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz Before_Insert_On_Users -------------------------------------------------------------------------------------------------------------------------------------------------
-- Procedura pomocnicza, bo triggery nie pozwalają na dynamiczy sql
DELIMITER //
CREATE OR REPLACE PROCEDURE grant_technical_adm_to_user (
	IN login VARCHAR(30)
)BEGIN
	set @sql = concat("REVOKE technical_administrator FROM '",`login`,"' ");
	PREPARE stmt1 FROM @sql;
	EXECUTE stmt1;
	DEALLOCATE PREPARE stmt1;
	FLUSH PRIVILEGES;
		
	set @sql = concat("GRANT technical_administrator TO '",`login`,"' ");
	PREPARE stmt2 FROM @sql;
	EXECUTE stmt2;
	DEALLOCATE PREPARE stmt2;
	FLUSH PRIVILEGES;
	   
	set @sql = concat("SET DEFAULT ROLE technical_administrator FOR '",`login`,"' ");
	PREPARE stmt2 FROM @sql;
	EXECUTE stmt2;
	DEALLOCATE PREPARE stmt2;
	FLUSH PRIVILEGES;
END; //
DELIMITER ;

-- Właściwy trigger
DELIMITER //
CREATE OR REPLACE TRIGGER Before_Insert_On_Users 
	BEFORE INSERT ON users 
	FOR EACH ROW
BEGIN
		
	-- Pierwsze konto w systemie otrzymuje role administratora merytorycznego
	DECLARE user_amount INT;
	SELECT COUNT(*) INTO user_amount FROM users;
	
	IF user_amount = 0 THEN
		SET NEW.role = 'technical_administrator';
		CALL grant_technical_adm_to_user(NEW.login);
	END IF;
		
END; //
DELIMITER ;

-- Wyzwalacz After_Delete_On_Users_Permissions_In_Voivodships ----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER After_Delete_On_Users_Permissions_In_Voivodships
	AFTER DELETE ON users_permissions_in_voivodships FOR EACH ROW
		-- uzupełnić
	;