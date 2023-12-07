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
			
			IF amount_of_tech_admins = 1 AND (SESSION_USER() NOT LIKE 'root@%') THEN
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

-- Wyzwalacz After_Delete_On_Users_Permissions_In_Voivodships ----------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER After_Delete_On_Users_Permissions_In_Voivodships
	AFTER DELETE ON users_permissions_in_voivodships FOR EACH ROW
		-- uzupełnić
	;