CALL add_new_locality(
	'Wierzchowice',
	NULL,
	NULL,
	(
		SELECT administrative_unit_id
		FROM administrative_units
		WHERE `type` = 'gmina' AND `name` = 'Krośnice'
	),
	NULL,
	NULL,
	(
		SELECT locality_type_id
		FROM locality_types
		WHERE `name` = 'Wieś'
	)
);
SELECT * FROM full_localities_data;