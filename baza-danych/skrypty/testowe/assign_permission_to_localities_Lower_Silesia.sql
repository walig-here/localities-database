CALL assign_permission_to_user(
	(SELECT au.administrative_unit_id FROM administrative_units AS au WHERE `name` = 'Dolnośląskie' LIMIT 1),
	'user_2',
	1
);
SELECT * FROM granted_permissions;