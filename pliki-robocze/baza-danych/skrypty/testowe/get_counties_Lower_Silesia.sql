CALL get_counties_from_voivodship(
	(
		SELECT administrative_unit_id
		FROM administrative_units
		WHERE `name` = 'Dolnośląskie' AND `type` = 'województwo'
	)
);
SELECT * FROM return_table;