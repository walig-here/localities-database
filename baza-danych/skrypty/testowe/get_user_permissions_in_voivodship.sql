CALL get_user_permissions_in_voivodship(
	'user_2',
	(
		SELECT voivodship_id
		FROM granted_permissions
		WHERE user_login = 'user_2'
		LIMIT 1
	)
);
SELECT * FROM return_table;

