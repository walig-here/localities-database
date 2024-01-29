-- Rola przeglądającego
CREATE OR REPLACE ROLE viewer;
	GRANT SELECT ON projekt_bd.full_localities_data TO viewer;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO viewer;
	GRANT SELECT ON projekt_bd.user_permissions TO viewer;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO viewer;
	GRANT SELECT ON projekt_bd.user_account TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO viewer;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO viewer;
	GRANT SELECT ON projekt_bd.administrative_units TO viewer;
	GRANT SELECT ON projekt_bd.permissions TO viewer;
	GRANT SELECT ON projekt_bd.locality_types TO viewer;
	GRANT SELECT ON projekt_bd.figures TO viewer;
	GRANT SELECT ON projekt_bd.attraction_types TO viewer;

	GRANT SELECT ON projekt_bd.return_table TO viewer;
	GRANT FILE ON *.* TO viewer;
FLUSH PRIVILEGES;

-- Rola administratora technicznego
CREATE OR REPLACE ROLE technical_administrator;
	GRANT SELECT ON projekt_bd.registered_users TO technical_administrator;
	GRANT SELECT ON projekt_bd.granted_permissions TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_permission_from_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_permission_to_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_user_role TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_voivodships_managed_by_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_user_permissions_in_voivodship TO technical_administrator;
	
	GRANT SELECT ON projekt_bd.full_localities_data TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_permissions TO technical_administrator;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO technical_administrator;
	GRANT SELECT ON projekt_bd.user_account TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO technical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO technical_administrator;
	GRANT SELECT ON projekt_bd.administrative_units TO technical_administrator;
	GRANT SELECT ON projekt_bd.permissions TO technical_administrator;
	GRANT SELECT ON projekt_bd.locality_types TO technical_administrator;
	GRANT SELECT ON projekt_bd.figures TO technical_administrator;
	GRANT SELECT ON projekt_bd.attraction_types TO technical_administrator;

	GRANT SELECT ON projekt_bd.return_table TO technical_administrator;
	GRANT FILE ON *.* TO technical_administrator;
FLUSH PRIVILEGES;

-- Rola administratora merytorycznego
CREATE OR REPLACE ROLE meritorical_administrator;
	GRANT SELECT ON projekt_bd.managed_localities TO meritorical_administrator;
	GRANT INSERT ON projekt_bd.figures TO meritorical_administrator;
	GRANT DELETE ON projekt_bd.figures TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_new_locality TO meritorical_administrator;
	
	GRANT SELECT ON projekt_bd.managed_attractions TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_figure_from_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_attraction_from_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.unassign_type_from_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_attraction_to_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_figure_to_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.assign_type_to_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.modify_figure_caption TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_new_attraction TO meritorical_administrator;
	
	GRANT SELECT ON projekt_bd.full_localities_data TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.user_favourite_localities TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.user_permissions TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.locations_of_attractions TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.user_account TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_locality_from_fav_list TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.del_user TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.add_locality_to_fav_list TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_localities_number_of_attractions TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_locations_from_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_attractions_in_locality TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_figures_assigned_to_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_types_assigned_to_attraction TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_counties_from_voivodship TO meritorical_administrator;
	GRANT EXECUTE ON PROCEDURE projekt_bd.get_municipalities_from_county TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.administrative_units TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.permissions TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.locality_types TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.figures TO meritorical_administrator;
	GRANT SELECT ON projekt_bd.attraction_types TO meritorical_administrator;

	GRANT SELECT ON projekt_bd.return_table TO meritorical_administrator;
	GRANT FILE ON *.* TO meritorical_administrator;
FLUSH PRIVILEGES;