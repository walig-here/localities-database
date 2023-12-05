-- Wyzwalacz Before_User_Deleted --------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER Before_User_Deleted 
	BEFORE DELETE ON users FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz After_Delete_On_Locations --------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER After_Delete_On_Locations 
	AFTER DELETE ON locations FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz Afrer_Delete_On_Attractions_Locations ---------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER After_Delete_On_Attractions_Locations 
	AFTER DELETE ON attractions_locations FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz After_Delete_On_Figures_Containing_Attractions ------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER After_Delete_On_Figures_Containing_Attractions
	AFTER DELETE ON figures_containing_attractions FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz After_Insert_On_Users -------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER After_Insert_On_Users
	AFTER INSERT ON users FOR EACH ROW
		-- uzupełnić
	;

-- Wyzwalacz After_Delete_On_Users_Permissions_In_Voivodships ----------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER After_Delete_On_Users_Permissions_In_Voivodships
	AFTER DELETE ON users_permissions_in_voivodships FOR EACH ROW
		-- uzupełnić
	;