CALL unassign_permission_from_user(
	'user_2',
	NULL,
	NULL
);
SELECT * FROM granted_permissions;