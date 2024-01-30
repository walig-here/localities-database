CALL assign_permission_to_user(
	(SELECT au.administrative_unit_id FROM administrative_units AS au WHERE `name` = 'Pomorskie' LIMIT 1),
	'user_3',
	1
);
SELECT * FROM granted_permissions;