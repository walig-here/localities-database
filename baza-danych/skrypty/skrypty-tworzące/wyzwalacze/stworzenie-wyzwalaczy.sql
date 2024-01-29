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

-- Wyzwalacz Afrer_Delete_On_Attractions ---------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Attractions
	AFTER DELETE ON attractions FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich lokalizacji, które nie są przypiane do żandej atrakcji
		DELETE FROM locations
		WHERE location_id NOT IN (
			SELECT DISTINCT al.location_id
			FROM attractions_locations AS al
		);
		
		-- Usunięcie wszystkich ilustracji, które nie są przypisane do żadnej atrakcji
		DELETE FROM figures
		WHERE figure_id NOT IN (
			SELECT DISTINCT figure_id
			FROM figures_containing_attractions
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
		WHERE (voivodship_id, login) NOT IN (
			SELECT DISTINCT voivodship_id, login
			FROM users_permissions_in_voivodships AS upv
		);
		
END; //
DELIMITER ;

-- Wyzwalacz Afrer_Delete_On_Localities ---------------------------------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Localities
	AFTER DELETE ON localities FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich atrakcji, które były zlokalizowane tylko w tej miejscowości
		DELETE FROM attractions
		WHERE attraction_id NOT IN (
			SELECT DISTINCT al.attraction_id
			FROM attractions_locations AS al
		);
		
END; //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE TRIGGER After_Delete_On_Attractions_Locations
	AFTER DELETE ON attractions_locations FOR EACH ROW
BEGIN
		
		-- Usunięcie wszystkich atrakcji, które były zlokalizowane tylko w jednej lokacji
		DELETE FROM attractions
		WHERE attraction_id NOT IN (
			SELECT DISTINCT al.attraction_id
			FROM attractions_locations AS al
		);
		
		-- Usunięcie wszystkich lokalizacji, które były przypisane tylko do jednej atrakcji
		DELETE FROM locations
		WHERE location_id NOT IN (
			SELECT DISTINCT al.location_id
			FROM attractions_locations AS al
		);
		
END; //
DELIMITER ;
