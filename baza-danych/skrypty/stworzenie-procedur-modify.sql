-- modify_locality
DELIMITER //
CREATE PROCEDURE modify_locality (
	IN locality_id INT(10),
	IN locality_name VARCHAR(50),
	IN locality_desc VARCHAR(1000),
	IN pop INT(10),
	IN municipality_id INT(10),
	IN latititude REAL,
	IN longitude REAL
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- modify_attraction
DELIMITER //
CREATE PROCEDURE modify_attraction (
	IN attraction_id INT(10),
	IN attraction_name VARCHAR(50),
	IN attraction_desc VARCHAR(1000)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- modify_user_role
DELIMITER //
CREATE PROCEDURE modify_user_role (
	IN login VARCHAR(30),
	IN user_role VARCHAR(30)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;

-- modify_figure_caption
DELIMITER //
CREATE PROCEDURE modify_figure_caption (
	IN figure_id INT(10),
	IN attraction_id INT(10),
	IN caption VARCHAR(255)
) BEGIN
	-- uzupełnić
END;
// 
DELIMITER ;