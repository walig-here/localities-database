CALL assign_type_to_attraction(
	(
		SELECT attraction_type_id
		FROM attraction_types
		WHERE `name` = 'zabytek'
	),
	(
		SELECT attraction_id
		FROM locations_of_attractions
		LIMIT 1
	)
);
CALL get_types_assigned_to_attraction(1);
SELECT * FROM return_table;