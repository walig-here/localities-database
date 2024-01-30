CALL unassign_permission_from_user(
	'user_2',
	(
		SELECT gp.voivodship_id
		FROM granted_permissions AS gp
		WHERE gp.voivodship_name = 'Dolnośląskie'
		LIMIT 1
	),
	1
);
SELECT * FROM granted_permissions;