CALL add_new_attraction(
	'Ratusz',
	NULL,
	(
		SELECT fld.locality_id
		FROM full_localities_data AS fld
		WHERE fld.locality_name = 'Wrocław'
	),
	'Sukiennice',
	'14',
	'15'
);
SELECT * FROM locations_of_attractions;