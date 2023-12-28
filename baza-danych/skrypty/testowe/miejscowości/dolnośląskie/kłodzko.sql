CALL add_new_locality(
	'Kłodzko',
	NULL,
	NULL,
	(
		SELECT administrative_unit_id
		FROM administrative_units
		WHERE `type` = 'gmina' AND `name` = 'Kłodzko (miasto)'
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