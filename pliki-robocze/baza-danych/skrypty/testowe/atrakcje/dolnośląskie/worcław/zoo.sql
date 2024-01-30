CALL add_new_attraction(
	'ZOO Wrocław',
	NULL,
	(
		SELECT fld.locality_id
		FROM full_localities_data AS fld
		WHERE fld.locality_name = 'Wrocław'
	),
	'Wróblewskiego',
	'1-5',
	NULL
);
SELECT * FROM locations_of_attractions;