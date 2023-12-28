CALL assign_attraction_to_locality(
	(
		SELECT loa.attraction_id
		FROM locations_of_attractions AS loa
		WHERE 
			loa.attraction_name LIKE '%kolej wąstkotorowa' AND 
			loa.voivodship_name = 'Dolnośląskie'
	),
	5,
	NULL,
	NULL,
	NULL
);
SELECT * FROM locations_of_attractions;