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

-- Wyzwalacz Before_User_Upadted --------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER Before_User_Upadted 
	BEFORE UPDATE ON 
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
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Locations 
	AFTER DELETE ON locations 
	FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich atrakcji, dla których była to jedyna lokalizacja
		DELETE FROM attractions
		WHERE 0 = (
			SELECT COUNT(*)
			FROM locations_of_attractions AS loa
			WHERE loa.attraction_id = attraction_id
		);
		
END; //
DELIMITER ;

-- Wyzwalacz Afrer_Delete_On_Attractions_Locations ---------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Attractions_Locations 
	AFTER DELETE ON attractions_locations FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich lokalizacji, które nie są przypiane do żandej atrakcji
		DELETE FROM locations
		WHERE 0 = (
			SELECT COUNT(*)
			FROM locations_of_attractions AS loa
			WHERE loa.location_id = location_id
		);
		
		-- Usunięcie wszystkich atrakcji, które nie są przypisane do żadnej lokalizacji
		DELETE FROM attractions
		WHERE 0 = (
			SELECT COUNT(*)
			FROM locations_of_attractions AS loa
			WHERE loa.attraction_id = attraction_id
		);
		
END; //
DELIMITER ;


-- Wyzwalacz After_Delete_On_Figures_Containing_Attractions ------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Figures_Containing_Attractions
	AFTER DELETE ON figures_containing_attractions FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich ilustracji, które nie są przypisane do żadnej atrakcji
		DELETE FROM figures
		WHERE 0 = (
			SELECT COUNT(*)
			FROM figures_containing_attractions AS fca
			WHERE fca.figure_id = figure_id
		);
		
END; //
DELIMITER ;

-- Wyzwalacz After_Delete_On_Users_Permissions_In_Voivodships ----------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Users_Permissions_In_Voivodships
	AFTER DELETE ON users_permissions_in_voivodships FOR EACH ROW
BEGIN
		
		-- Usunięcie użytkownikom uprawnień do zarządzenai wszystkimi województtwami, w których nie mają przypisanych uprawnień
		DELETE FROM voivodships_administrated_by_users
		WHERE 0 = (
			SELECT COUNT(*)
			FROM users_permissions_in_voivodships AS upv
			WHERE upv.voivodship_id = voivodship_id AND upv.login = login
		);
		
END; //
DELIMITER ;