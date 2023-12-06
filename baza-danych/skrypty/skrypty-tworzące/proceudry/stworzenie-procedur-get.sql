-- get_localities_number_of_attractions 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_localities_number_of_attractions (
	IN locality_id INT(10),
	OUT number_of_attraction INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_locations_from_locality 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_locations_from_locality (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_voivodships_managed_by_user 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_voivodships_managed_by_user (
	IN login VARCHAR(30)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_user_permissions_in_voivodship 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_user_permissions_in_voivodship (
	IN login VARCHAR(30),
	IN voivodship_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_attractions_in_locality 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_attractions_in_locality (
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_figures_assigned_to_attraction 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_figures_assigned_to_attraction (
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_types_assigned_to_attraction 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_types_assigned_to_attraction (
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_counties_from_voivodship 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_counties_from_voivodship (
	IN voivodship_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- get_municipalities_from_county 
DELIMITER //
CREATE OR REPLACE PROCEDURE get_municipalities_from_county (
	IN county_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;