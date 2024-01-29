package com.pwr.bdprojekt.logic;

import com.pwr.bdprojekt.gui.Window;
import com.pwr.bdprojekt.logic.entities.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DataBaseApi {

//======================================================================================================================
// POLA

	/**
	 * Połączenie z bazą jako użytkownik root
	 * */
	private static Connection root_connection = null;

	/**
	 * Połączenie z bazą jako właściwy użytkownik Bazy Miejscowości
	 * */
	private static Connection user_connection = null;

//======================================================================================================================
// METODY

	/**
	 * Ustanowienie połączenia z bazą danych.
	 * @param login nazwa użytkownika ustanawiającego połączenie
	 * @param password hasło użytkownika ustanawiającego połączenie
	 * */
	public static boolean connect(String login, String password){
		Connection connection_to_establish;

		String url = "jdbc:mariadb://localhost:3306/projekt_bd?user=" + login + "&password=" + password;
		try {
			connection_to_establish = DriverManager.getConnection(url);
		} catch (SQLException e) {
			System.out.println("Cannot connect to database as " + login);
			return false;
		}

		if(login.equals("root")){
			root_connection = connection_to_establish;
		}
		else if(root_connection != null){
			user_connection = connection_to_establish;
		}
		else {
			// Jeżeli nie ustanowiono połączenia root, to aplikacja nie powinna pozwolić na nawiązania połączenia
			// użytkownika
			return false;
		}

		System.out.println("Connected to database as " + login);
		return true;
	}

	/**
	 * Zamyka połączenie wskazanego użytkownika
	 * @param login nazwa użytkownika, którego połączenie zamykamy
	 * */
	public static boolean closeConnection(String login){
		Connection connection_to_establish;
		if(login.equals("root")){
			connection_to_establish = root_connection;
		}
		else {
			connection_to_establish = user_connection;
		}

		try {
			connection_to_establish.close();
		} catch (SQLException e) {
			System.out.println("Cannot close connection to database as " + login);
			return false;
		}

		System.out.println("Closed connection to database as " + login);
		return true;
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean addLocalityToFavList(Locality locality, String adnotation) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call add_locality_to_fav_list(?, ?)");
			callableStatement.setInt(1, locality.getId());
			callableStatement.setString(2, adnotation);

			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param attraction
	 */
	public static boolean addNewAttraction(Attraction attraction, Address address) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call add_new_attraction(?, ?, ?, ?, ?, ?)");
			callableStatement.setString(1, attraction.getName());
			callableStatement.setString(2, attraction.getDescription());
			callableStatement.setInt(3, address.getLocality().getId());
			callableStatement.setString(4, address.getStreet());
			callableStatement.setString(5, address.getBuilding_number());
			callableStatement.setString(6, address.getFlat_number());
			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
            return false;
        }
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean addNewLocality(Locality locality) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call add_new_locality(?, ?, ?, ?, ?, ?, ?)");
			callableStatement.setString(1, locality.getName());
			callableStatement.setString(2, locality.getDescription());
			callableStatement.setInt(3, locality.getPopulation());
			callableStatement.setInt(4, locality.getMunicipality().getId());
			callableStatement.setDouble(5, locality.getLatitude());
			callableStatement.setDouble(6, locality.getLongitude());
			callableStatement.setInt(7, locality.getType().getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		}catch (SQLException e){
			return false;
		}
	}

	/**
	 * 
	 * @param attraction_id
	 * @param address
	 */
	public static boolean assignAttractionToLocality(int attraction_id, Address address) {
		try{
			CallableStatement callableStatement =  user_connection.prepareCall("call assign_attraction_to_locality(?, ?, ?, ?, ?)");
			callableStatement.setInt(1, attraction_id);
			callableStatement.setInt(2, address.getLocality().getId());
			callableStatement.setString(3, address.getStreet());
			callableStatement.setString(4, address.getBuilding_number());
			callableStatement.setString(5, address.getFlat_number());
			callableStatement.execute();
			callableStatement.close();
			return true;
		}catch(SQLException e){
			return false;
		}
	}

	/**
	 * 
	 * @param figure
	 * @param attraction
	 * @param caption
	 */
	public static boolean assignFigureToAttraction(Figure figure, Address attraction, String caption) {
		// TODO - implement DataBaseApi.assignFigureToAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 *
	 * @param voivodship
	 * @param user
	 * @param permission
	 */
	public static boolean assignPermissionToUser(AdministrativeUnit voivodship, User user, Permission permission) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call assign_permission_to_user(?, ?, ?)");
			callableStatement.setInt(1, voivodship.getId());
			callableStatement.setString(2, user.getLogin());
			callableStatement.setInt(3, permission.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		}catch(SQLException e){
			return false;
		}
	}

	/**
	 * 
	 * @param attraction_id
	 * @param type
	 */
	public static boolean assignTypeToAttraction(int attraction_id, AttractionType type) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call assign_type_to_attraction(?, ?)");
			callableStatement.setInt(1, type.getId());
			callableStatement.setInt(2, attraction_id);
			callableStatement.execute();
			callableStatement.close();
			return true;
		}catch (SQLException e) {
            return false;
        }
    }

	/**
	 * 
	 * @param attraction
	 */
	public static boolean delAttraction(Attraction attraction) {
		Connection connection = user_connection;
		String callProcedureSql = "call del_attraction(?)";

		try {
			CallableStatement callableStatement = connection.prepareCall(callProcedureSql);
			callableStatement.setInt(1, attraction.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean delLocality(Locality locality) {
		Connection connection = user_connection;
		String sql = "call del_locality(?)";

		try  {
			CallableStatement callableStatement = connection.prepareCall(sql);
			callableStatement.setInt(1, locality.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean delLocalityFromFavList(Locality locality) {
		Connection connection = user_connection;
		String sql = "call del_locality_from_fav_list(?)";

		try {
			CallableStatement callableStatement = connection.prepareCall(sql);
			callableStatement.setInt(1, locality.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param user
	 */
	public static boolean delUser(User user) {
		Connection connection = user_connection;
		String sql = "call del_user(?)";

		try {
			CallableStatement callableStatement = connection.prepareCall(sql);
			callableStatement.setString(1, user.getLogin());
			callableStatement.execute();
			callableStatement.close();
			return true;

		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param locality
	 */
	public static List<Attraction> getAttractionsInLocality(Locality locality) {
		List<Attraction> attratcionsInLocality = new ArrayList<>();

		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_attractions_in_locality(?)");
			callableStatement.setInt(1, locality.getId());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				Attraction attraction = new Attraction();
				attraction.setId(resultSet.getInt("attraction_id"));
				attraction.setName(resultSet.getString("attraction_name"));
				attraction.setDescription(resultSet.getString("attraction_desc"));

				Address address = new Address();
				address.setLocality(locality);
				address.setStreet(resultSet.getString("street"));
				address.setBuilding_number(resultSet.getString("building_number"));
				address.setFlat_number(resultSet.getString("flat_number"));
				attraction.setAddress(address);

				attratcionsInLocality.add(attraction);
			}

			preparedStatement.close();
			resultSet.close();
		} catch (SQLException e){
			attratcionsInLocality = null;
		}

		return attratcionsInLocality;
	}

	/**
	 * Pobranie atrakcji  z bazy
	 * */
	public static List<Attraction> selectAttractions(String whereClause){
		List<Attraction> attractions = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM locations_of_attractions" +
							(whereClause.isEmpty() ? "" : " WHERE " + whereClause) +
							";"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				Attraction attraction = new Attraction();
				attraction.setId(resultSet.getInt("attraction_id"));
				attraction.setName(resultSet.getString("attraction_name"));
				attraction.setDescription(resultSet.getString("attraction_desc"));

				Address address = new Address();
				address.setId(resultSet.getInt("location_id"));
				address.setStreet(resultSet.getString("street"));
				address.setBuilding_number(resultSet.getString("building_number"));
				address.setFlat_number(resultSet.getString("flat_number"));
				attraction.setAddress(address);

				attractions.add(attraction);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać atrakcji z bazy!");
			return null;
		}
		return attractions;
	}

	/**
	 * 
	 * @param voivodeship
	 */
	public static List<AdministrativeUnit> getCountiesFromVoivodship(AdministrativeUnit voivodeship) {
		List<AdministrativeUnit> counties = new ArrayList<>();
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_counties_from_voivodship(?)");
			callableStatement.setInt(1, voivodeship.getId());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				AdministrativeUnit county = new AdministrativeUnit();
				county.setId(resultSet.getInt("administrative_unit_id"));
				county.setName(resultSet.getString("name"));
				county.setSuperiorAdministrativeUnit(voivodeship);
				// Dodaj obiekt do listy
				counties.add(county);
			}

			preparedStatement.close();
			resultSet.close();

        }catch (SQLException e){
			counties.clear();
		}
		return counties;
	}

	/**
	 * 
	 * @param attraction
	 */
	public static FigureAssignedToAttraction[] getFiguresAssignedToAttraction(Attraction attraction) {
		// TODO - implement DataBaseApi.getFiguresAssignedToAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static int getLocalitiesNumberOfAttraction(Locality locality) {
		int numberOfAttractions = -1;
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_localities_number_of_attractions(?)");
			callableStatement.setInt(1, locality.getId());
			ResultSet set = callableStatement.executeQuery();

			if (set.next()) {
				numberOfAttractions = set.getInt(1);
			}
			callableStatement.close();
			set.close();

		}catch (SQLException e){
			numberOfAttractions = -1;
		}
		return numberOfAttractions;
	}

	/**
	 * 
	 * @param locality
	 */
	public static List<Address> getLocationsFromLocality(Locality locality) {
		List<Address> addresses = new ArrayList<>();
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_locations_from_locality(?)");
			callableStatement.setInt(1, locality.getId());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				Address address = new Address();
				address.setId(resultSet.getInt("location_id"));
				address.setLocality(locality);
				address.setStreet(resultSet.getString("street"));
				address.setBuilding_number(resultSet.getString("building_number"));
				address.setFlat_number(resultSet.getString("flat_number"));
				// Dodaj obiekt do listy
				addresses.add(address);
			}

			preparedStatement.close();
			resultSet.close();

		}catch (SQLException e){
			addresses.clear();
		}
		return addresses;
	}

	/**
	 * 
	 * @param county
	 */
	public static List<AdministrativeUnit> getMunicipalitiesFromCounty(AdministrativeUnit county) {
		List<AdministrativeUnit> municipalities = new ArrayList<>();
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_municipalities_from_county(?)");
			callableStatement.setInt(1, county.getId());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				AdministrativeUnit municipality = new AdministrativeUnit();
				municipality.setId(resultSet.getInt("administrative_unit_id"));
				municipality.setName(resultSet.getString("name"));
				municipality.setSuperiorAdministrativeUnit(county);
				// Dodaj obiekt do listy
				municipalities.add(municipality);
			}

			preparedStatement.close();
			resultSet.close();

		}catch (SQLException e){
			municipalities.clear();
		}
		return municipalities;
	}

	/**
	 * 
	 * @param attraction
	 */
	public static List<AttractionType> getTypesAssignedToAttraction(Attraction attraction) {
		List<AttractionType> attractionTypes = new ArrayList<>();
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call get_types_assigned_to_attraction(?)");
			callableStatement.setInt(1, attraction.getId());
			callableStatement.execute();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				AttractionType type = new AttractionType();
				type.setId(resultSet.getInt("attraction_type_id"));
				type.setName(resultSet.getString("name"));
				attractionTypes.add(type);
			}
			callableStatement.close();
			preparedStatement.close();
			resultSet.close();

		} catch (SQLException e) {
            attractionTypes = null;
        }
		return attractionTypes;
    }

	/**
	 * 
	 * @param user
	 * @param voivodship
	 */
	public static List<Permission> getUserPermissionsInVoivodship(User user, AdministrativeUnit voivodship) {
		List<Permission> userPermissionsInVoivodships = new ArrayList<>();
		try{
			CallableStatement callableStatement = root_connection.prepareCall("call get_user_permissions_in_voivodship(?, ?)");
			callableStatement.setString(1, user.getLogin());
			callableStatement.setInt(2, voivodship.getId());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				Permission permission = new Permission();
				permission.setId(resultSet.getInt("permission_id"));
				permission.setName(resultSet.getString("permission_name"));
				permission.setDesc(resultSet.getString("permission_desc"));
				// Dodaj obiekt do listy
				userPermissionsInVoivodships.add(permission);
			}

			preparedStatement.close();
			resultSet.close();

		}catch (SQLException e){
			userPermissionsInVoivodships.clear();
		}
		return userPermissionsInVoivodships;
	}

	/**
	 * 
	 * @param user
	 */
	public static List<AdministrativeUnit> getVoivodshipsManagedByUser(User user) {
		List<AdministrativeUnit> voivodshipsManagedByUsers = new ArrayList<>();
		try{
			CallableStatement callableStatement = root_connection.prepareCall("call get_voivodships_managed_by_user(?)");
			callableStatement.setString(1, user.getLogin());
			callableStatement.execute();
			callableStatement.close();

			PreparedStatement preparedStatement = user_connection.prepareStatement("SELECT * FROM return_table");
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()) {
				AdministrativeUnit voivodship = new AdministrativeUnit();
				voivodship.setId(resultSet.getInt("voivodship_id"));
				voivodship.setName(resultSet.getString("voivodship_name"));
				voivodship.setSuperiorAdministrativeUnit(null);
				// Dodaj obiekt do listy
				voivodshipsManagedByUsers.add(voivodship);
			}

			preparedStatement.close();
			resultSet.close();

		}catch (SQLException e){
			voivodshipsManagedByUsers.clear();
		}
		return voivodshipsManagedByUsers;
	}

	/**
	 * 
	 * @param attraction
	 */
	public static boolean modifyAttraction(Attraction attraction) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call modify_attraction(?, ?, ?)");
			callableStatement.setInt(1, attraction.getId());
			callableStatement.setString(2, attraction.getName());
			callableStatement.setString(3, attraction.getDescription());

			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
			return false;
		}
	}

	/**
	 * 
	 * @param new_caption
	 */
	public static boolean modifyFigureCaption(String new_caption) {
		// TODO - implement DataBaseApi.modifyFigureCaption
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean modifyLocality(Locality locality) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call modify_locality(?, ?, ?, ?, ?, ?, ?, ?)");
			callableStatement.setInt(1, locality.getId());
			callableStatement.setString(2, locality.getName());
			callableStatement.setString(3, (locality.getDescription().isEmpty() ? " " : locality.getDescription()));

			if(locality.getPopulation() < 0){
				Window.showMessageBox("Populacja nie może być liczbą ujemną!");
				return false;
			} else callableStatement.setInt(4, locality.getPopulation());

			callableStatement.setInt(5, locality.getType().getId());
			callableStatement.setInt(6, locality.getMunicipality().getId());

			if(locality.getLatitude() > 90){
				Window.showMessageBox("Nieprawidłowa wartość szerokości geograficznej!");
				return false;
			} else callableStatement.setDouble(7, locality.getLatitude());

			if(locality.getLongitude() > 180){
				Window.showMessageBox("Nieprawidłowa wartość długości geograficznej!");
				return false;
			} else callableStatement.setDouble(8, locality.getLongitude());

			callableStatement.execute();
			callableStatement.close();
			return true;

		}catch (SQLException e){
			return false;
		}
	}

	/**
	 * 
	 * @param user
	 * @param new_role
	 */
	public static boolean modifyUserRole(User user, UserRole new_role) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call modify_user_role(?, ?)");
			callableStatement.setString(1, user.getLogin());
			callableStatement.setString(2, new_role.name().toLowerCase());
			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
			return false;
        }
	}

	/**
	 * 
	 * @param login
	 * @param password
	 */
	public static String registerUser(String login, String password) {
		if(login.equals("")){
			return "Login nie może być pusty";
		}
		try{
			CallableStatement callableStatement = root_connection.prepareCall("call register_user(?,?)");
			callableStatement.setString(1, login);
			callableStatement.setString(2, password);
			callableStatement.execute();
			callableStatement.close();
			return "";
		}catch (SQLException e){
			return "Takie konto już istnieje";
		}
	}

	/**
	 * 
	 * @param attraction_id
	 * @param locality
	 */
	public static boolean unassignAttractionFromLocality(int attraction_id, Locality locality) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call unassign_attraction_from_locality(?, ?)");
			callableStatement.setInt(1, attraction_id);
			callableStatement.setInt(2, locality.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
            return false;
        }
    }

	/**
	 * 
	 * @param attraction
	 * @param figure
	 */
	public static boolean unassignFigureFromAttraction(Attraction attraction, Figure figure) {
		// TODO - implement DataBaseApi.unassignFigureFromAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param user
	 * @param voivodship
	 * @param permission
	 */
	public static boolean unassignPermissionFromUser(User user, AdministrativeUnit voivodship, Permission permission) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call unassign_permission_from_user(?, ?, ?)");
			callableStatement.setString(1, user.getLogin());
			callableStatement.setInt(2, voivodship.getId());
			if(permission == null)
				callableStatement.setNull(3, Types.INTEGER);
			else
				callableStatement.setInt(3, permission.getId());
			callableStatement.execute();
			callableStatement.close();
			return true;

		}catch(SQLException e){
			return false;
		}
	}

	/**
	 * 
	 * @param attraction_id
	 * @param type
	 */
	public static boolean unassignTypeFromAttraction(int attraction_id, AttractionType type) {
		try{
			CallableStatement callableStatement = user_connection.prepareCall("call unassign_type_from_attraction(?, ?)");
			callableStatement.setInt(1, type.getId());
			callableStatement.setInt(2, attraction_id);
			callableStatement.execute();
			callableStatement.close();
			return true;
		} catch (SQLException e) {
            return false;
        }
    }

	/**
	 * 
	 * @param figure
	 */
	public static boolean addFigure(Figure figure) {
		// TODO - implement DataBaseApi.addFigure
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param figure
	 */
	public static boolean deleteFigure(Figure figure) {
		// TODO - implement DataBaseApi.deleteFigure
		throw new UnsupportedOperationException();
	}

	public static User getCurrentUser(String login) {
		try{
			PreparedStatement preparedStatement = root_connection.prepareStatement("SELECT role FROM users WHERE login = ?");
			preparedStatement.setString(1, login);
			ResultSet resultSet = preparedStatement.executeQuery();

			if (resultSet.next()) {
				// Jeżeli resultSet zawiera wiersz, to pobierz wartość
				String roleString = resultSet.getString("role").toUpperCase();
				return new User(login, UserRole.valueOf(roleString));
			}

			preparedStatement.close();
			resultSet.close();

		}catch (SQLException e){
			return null;
		}
        return null;
    }

	/**
	 * Pobranie typów atrakcji
	 * */
	public static List<AttractionType> selectAttractionTypes(String whereClause){
		List<AttractionType> attractionTypes = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM attraction_types" +
							(whereClause.isEmpty() ? "" : " WHERE " + whereClause) +
							";"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				AttractionType attractionType = new AttractionType();
				attractionType.setId(resultSet.getInt("attraction_type_id"));
				attractionType.setName(resultSet.getString("name"));

				attractionTypes.add(attractionType);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać typów atrakcji z bazy!");
			return null;
		}
		return attractionTypes;
	}

	/**
	 * Pobranie ulubionych miejscowości z bazy
	 * */
	public static List<Locality> selectFavouriteLocalities(String whereClause){
		List<Locality> localitiesFromDatabase = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM user_favourite_localities" +
							(whereClause.isEmpty() ? "" : " WHERE "+whereClause)
			);
			ResultSet resultSet = preparedStatement.executeQuery();


			while (resultSet.next()){
				Locality localityFromDatabase = new Locality();
				localityFromDatabase.setId(resultSet.getInt("locality_id"));
				localityFromDatabase.setName(resultSet.getString("locality_name"));
				localityFromDatabase.setDescription(resultSet.getString("locality_desc"));
				localityFromDatabase.setPopulation(resultSet.getInt("population"));
				localityFromDatabase.setLatitude(resultSet.getDouble("locality_latitude"));
				localityFromDatabase.setLongitude(resultSet.getDouble("locality_longitude"));

				AdministrativeUnit municipality = new AdministrativeUnit();
				municipality.setName(resultSet.getString("municipality_name"));

				AdministrativeUnit county = new AdministrativeUnit();
				county.setName(resultSet.getString("county_name"));

				AdministrativeUnit voivodship = new AdministrativeUnit();
				voivodship.setName(resultSet.getString("voivodship_name"));

				municipality.setSuperiorAdministrativeUnit(county);
				county.setSuperiorAdministrativeUnit(voivodship);
				voivodship.setSuperiorAdministrativeUnit(null);
				localityFromDatabase.setMunicipality(municipality);

				LocalityType type = DataBaseApi.selectLocalityType("name = '"+resultSet.getString("locality_type")+"'").get(0);
				localityFromDatabase.setType(type);

				localityFromDatabase.setAddnotation(resultSet.getString("adnotation"));

				localitiesFromDatabase.add(localityFromDatabase);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (Exception e) {
			System.out.println("Nie udało się pobrać miejscowości z bazy!");
			return null;
		}
		return localitiesFromDatabase;
	}

	/**
	 * Pobranie danych miejscowości z bazy
	 * */
	public static List<Locality> selectLocalities(String whereClause){
		List<Locality> localitiesFromDatabase = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM full_localities_data" +
					(whereClause.isEmpty() ? "" : " WHERE "+whereClause)
			);
			ResultSet resultSet = preparedStatement.executeQuery();


			while (resultSet.next()){
				Locality localityFromDatabase = new Locality();
				localityFromDatabase.setId(resultSet.getInt("locality_id"));
				localityFromDatabase.setName(resultSet.getString("locality_name"));
				localityFromDatabase.setDescription(resultSet.getString("locality_desc"));
				localityFromDatabase.setPopulation(resultSet.getInt("population"));
				localityFromDatabase.setLatitude(resultSet.getDouble("locality_latitude"));
				localityFromDatabase.setLongitude(resultSet.getDouble("locality_longitude"));

				AdministrativeUnit municipality = new AdministrativeUnit();
				municipality.setId(resultSet.getInt("municipality_id"));
				municipality.setName(resultSet.getString("municipality_name"));

				AdministrativeUnit county = new AdministrativeUnit();
				county.setId(resultSet.getInt("county_id"));
				county.setName(resultSet.getString("county_name"));

				AdministrativeUnit voivodship = new AdministrativeUnit();
				voivodship.setName(resultSet.getString("voivodship_name"));
				voivodship.setId(resultSet.getInt("voivodship_id"));

				municipality.setSuperiorAdministrativeUnit(county);
				county.setSuperiorAdministrativeUnit(voivodship);
				voivodship.setSuperiorAdministrativeUnit(null);
				localityFromDatabase.setMunicipality(municipality);

				LocalityType type = DataBaseApi.selectLocalityType("name = '"+resultSet.getString("locality_type")+"'").get(0);
				localityFromDatabase.setType(type);

				localitiesFromDatabase.add(localityFromDatabase);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (Exception e) {
			System.out.println("Nie udało się pobrać miejscowości z bazy!");
			return null;
		}
		return localitiesFromDatabase;
	}

	/**
	 * Pobranie użytkowników z bazy
	 * */
	public static List<User> selectUsers(String whereClause){
		List<User> usersFromDatabase = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM registered_users" +
						(whereClause.isEmpty() ? "" : " WHERE " + whereClause) +
						";"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				User userFromDatabase = new User(
						resultSet.getString("login"),
						UserRole.valueOf(resultSet.getString("role").toUpperCase())
				);

				usersFromDatabase.add(userFromDatabase);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać użytkowników z bazy!");
			return null;
		}
		return usersFromDatabase;
	}

	/**
	 * Pobranie województw z bazy
	 * */
	public static List<AdministrativeUnit> selectVoivodships(String whereClause){
		List<AdministrativeUnit> voivodships = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM administrative_units WHERE type = 'województwo'" +
					(whereClause.isEmpty() ? "" : " AND " + whereClause) +
					" ORDER BY name;"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				AdministrativeUnit voivodship = new AdministrativeUnit();
				voivodship.setId(resultSet.getInt("administrative_unit_id"));
				voivodship.setName(resultSet.getString("name"));
				voivodship.setSuperiorAdministrativeUnit(null);
				voivodships.add(voivodship);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać województw z bazy!");
			return null;
		}
		return voivodships;
	}

	public static List<AdministrativeUnit> selectMunicipalities(String whereClause){
		List<AdministrativeUnit> municipalities = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM administrative_units WHERE type = 'gmina'" +
							(whereClause.isEmpty() ? "" : " and " + whereClause) +
							"ORDER BY name;"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				AdministrativeUnit municipality = new AdministrativeUnit();
				municipality.setId(resultSet.getInt("administrative_unit_id"));
				municipality.setName(resultSet.getString("name"));
				municipality.setSuperiorAdministrativeUnit(null);
				municipalities.add(municipality);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać gmin z bazy!");
			return null;
		}
		return municipalities;
	}

	/**
	 * Pobranie typów uprawnień z bazy danych
	 * */
	public static List<Permission> selectPermissions(){
		List<Permission> permissions = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM permissions;"
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				Permission permission = new Permission();
				permission.setId(resultSet.getInt("permission_id"));
				permission.setName(resultSet.getString("name"));
				permission.setDesc(resultSet.getString("description"));
				permissions.add(permission);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać uprawnień z bazy!");
			return null;
		}
		return permissions;
	}

	public static List<LocalityType> selectLocalityType(String whereClause){
		List<LocalityType> localityTypes = new ArrayList<>();
		try {
			PreparedStatement preparedStatement = user_connection.prepareStatement(
					"SELECT * FROM locality_types" +
					(whereClause.isEmpty() ? "" : " WHERE "+whereClause)
			);
			ResultSet resultSet = preparedStatement.executeQuery();

			while (resultSet.next()){
				LocalityType localityType = new LocalityType();
				localityType.setId(resultSet.getInt("locality_type_id"));
				localityType.setName(resultSet.getString("name"));
				localityTypes.add(localityType);
			}

			resultSet.close();
			preparedStatement.close();
		} catch (SQLException e) {
			System.out.println("Nie udało się pobrać typów miejscowości z bazy!");
			return null;
		}
		return localityTypes;
	}
}