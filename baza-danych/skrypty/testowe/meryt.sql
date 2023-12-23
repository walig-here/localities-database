CALL get_counties_from_voivodship(20000)
SELECT * FROM return_table;
CALL get_municipalities_from_county((
	SELECT administrative_unit_id
	FROM return_table
	WHERE `name` LIKE 'Wrocław (miasto)'
));
SELECT * FROM return_table;