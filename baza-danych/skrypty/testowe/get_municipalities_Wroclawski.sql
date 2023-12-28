CALL get_municipalities_from_county(
	(
		SELECT au.administrative_unit_id
		FROM administrative_units AS au
		WHERE `name` = 'Wrocławski' AND `type` = 'powiat'
	)
);
SELECT * FROM return_table;