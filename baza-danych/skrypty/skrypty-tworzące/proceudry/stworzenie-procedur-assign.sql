-- assign_permission_to_user
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_permission_to_user (
	IN voivodship_id INT(10),
	IN login VARCHAR(30),
	IN permission_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- assign_attraction_to_locality
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_attraction_to_locality (
	IN attraction_id INT(10),
	IN locality_id INT(10),
	IN street VARCHAR(50),
	IN building_number VARCHAR(50),
	IN flat_number VARCHAR(50)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- assign_type_to_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_type_to_attraction (
	IN type_id INT(10),
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- assign_figure_to_attraction
DELIMITER //
CREATE OR REPLACE PROCEDURE assign_figure_to_attraction (
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;