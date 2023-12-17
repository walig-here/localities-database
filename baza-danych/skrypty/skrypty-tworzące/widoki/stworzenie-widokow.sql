-- Widok Managed_Attractions -----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Managed_Attractions AS
SELECT
	Attractions.attraction_id,
	Attractions.name AS attraction_name,
	Attractions.description AS attraction_desc,
	Locations.street,
	Locations.building_number,
	Locations.flat_number,
	Localities.name AS locality_name,
	Municipality.name AS municipality_na,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	users_permissions_in_voivodships AS upv ON upv.voivodship_id = voivodships_administrated_by_users.voivodship_id INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locations ON Localities.locality_id = Locations.locality_id INNER JOIN
	Attractions_locations ON Locations.location_id = Attractions_locations.location_id INNER JOIN
	Attractions ON Attractions_locations.attraction_id = Attractions.attraction_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') AND upv.permission_id = 2;

-- Widok Managed_Localities -----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Managed_Localities AS
SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Locality_Types.name AS locality_type,
	Municipality.name AS municiaplity_id,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	users_permissions_in_voivodships AS upv ON upv.voivodship_id = voivodships_administrated_by_users.voivodship_id INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Voivodship.administrative_unit_id = County.superior_administrative_unit INNER JOIN
	Administrative_units AS Municipality ON County.administrative_unit_id = Municipality.superior_administrative_unit INNER JOIN
	Localities ON Municipality.administrative_unit_id = Localities.municipality_id INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%') AND upv.permission_id = 1;

-- Widok User_Favourite_Localities ---------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW User_Favourite_Localities AS
SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Favourite_Localities.adnotation,
	Locality_Types.name AS locality_type,
	Municipality.name AS municipality_name,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Favourite_Localities ON Users.login = Favourite_Localities.login INNER JOIN
	Localities ON Favourite_Localities.locality_id = Localities.locality_id INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%');

-- Widok User_Permissions -----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW User_Permissions AS
SELECT
	Permissions.permission_id,
	Permissions.name AS permission_name,
	Permissions.description AS permission_desc,
	Voivodship.administrative_unit_id AS voivodship_id,
	Voivodship.name AS voivodship_name
FROM
	Users INNER JOIN
	Voivodships_Administrated_By_Users ON Users.login = Voivodships_Administrated_By_Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id INNER JOIN
	Users_Permissions_In_Voivodships ON Voivodships_Administrated_By_Users.voivodship_id = Users_Permissions_In_Voivodships.voivodship_id INNER JOIN
	Permissions ON Users_Permissions_In_Voivodships.permission_id = Permissions.permission_id
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%');

-- Widok Full_Localities_Data -------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Full_Localities_Data AS
SELECT
	Localities.locality_id,
	Localities.name AS locality_name,
	Localities.description AS locality_desc,
	Localities.population,
	Localities.latitude AS locality_latitude,
	Localities.longitude AS locality_longitude,
	Locality_Types.name AS locality_type,
	Municipality.name AS municipality_name,
	County.name AS county_name,
	Voivodship.name AS voivodship_name
FROM
	Localities INNER JOIN
	Locality_Types ON Localities.locality_type_id = Locality_Types.locality_type_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id;

-- Widok Locations_of_Attractions ---------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Locations_of_Attractions AS
SELECT
	Locations.location_id,
	Voivodship.name AS voivodship_name,
	County.name AS county_name,
	Municipality.name AS municipality_name,
	Localities.name AS locality_name,
	Localities.locality_id AS locality_id,
	Locations.street,
	Locations.building_number,
	Locations.flat_number,
	Attractions.attraction_id,
	Attractions.name AS attraction_name,
	Attractions.description AS attraction_desc
FROM
	Attractions INNER JOIN
	Attractions_locations ON Attractions.attraction_id = Attractions_locations.attraction_id INNER JOIN
	Locations ON Attractions_locations.location_id = Locations.location_id INNER JOIN
	Localities ON Locations.locality_id = Localities.locality_id INNER JOIN
	Administrative_units AS Municipality ON Localities.municipality_id = Municipality.administrative_unit_id INNER JOIN
	Administrative_units AS County ON Municipality.superior_administrative_unit = County.administrative_unit_id INNER JOIN
	Administrative_units AS Voivodship ON County.superior_administrative_unit = Voivodship.administrative_unit_id;

-- Widok Registered_Users -----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Registered_Users AS
SELECT
	Users.login,
	Users.role
FROM
	users;

-- Widok User_Account ----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW User_Account AS
SELECT
	Users.login AS my_login,
	Users.role AS my_role
FROM
	Users
WHERE
	SESSION_USER() LIKE CONCAT(users.login,'@','%');

-- Widok Granted_permissions ---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW Granted_permissions AS
SELECT
	Permissions.permission_id,
	Permissions.name AS permission_name,
	Permissions.description AS permission_desc,
	Users.role AS user_role,
	Users.login AS user_login,
	Voivodship.administrative_unit_id AS voivodship_id,
	Voivodship.name AS voivodship_name
FROM
	Permissions INNER JOIN
	Users_Permissions_In_Voivodships ON Permissions.permission_id = Users_Permissions_In_Voivodships.permission_id INNER JOIN
	Voivodships_Administrated_By_Users ON Users_Permissions_In_Voivodships.voivodship_id = Voivodships_Administrated_By_Users.voivodship_id INNER JOIN
	Users ON Voivodships_Administrated_By_Users.login = Users.login INNER JOIN
	Administrative_units AS Voivodship ON Voivodships_Administrated_By_Users.voivodship_id = Voivodship.administrative_unit_id;