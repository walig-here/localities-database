CALL add_new_locality(
	'Warszawa',
	NULL,
	NULL,
	(
		SELECT administrative_unit_id
		FROM administrative_units
		WHERE `type` = 'gmina' AND `name` = 'Warszawa'
	),
	NULL,
	NULL,
	(
		SELECT locality_type_id
		FROM locality_types
		WHERE `name` = 'Miasto'
	)
);
SELECT * FROM full_localities_data;