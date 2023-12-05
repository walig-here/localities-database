-- unassign_permission_from_user 
DELIMITER //
CREATE PROCEDURE unassign_permission_from_user (
	IN login VARCHAR(30),
	IN voivodship_id INT(10),
	IN permission_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- unassign_figure_from_attraction
DELIMITER //
CREATE PROCEDURE unassign_figure_from_attraction (
	IN figure_id INT(10),
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- unassign_attraction_from_locality
DELIMITER //
CREATE PROCEDURE unassign_attraction_from_locality (
	IN attraction_id INT(10),
	IN locality_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- unassign_type_from_attraction
DELIMITER //
CREATE PROCEDURE unassign_type_from_attraction (
	IN attraction_type_id INT(10),
	IN attraction_id INT(10)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;