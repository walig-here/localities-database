CALL add_locality_to_fav_list(
	(
		SELECT locality_id 
		FROM full_localities_data
		LIMIT 1
	),
	'Ulubiona miejscowość użytkownika user_2'
);
SELECT * FROM user_favourite_localities;