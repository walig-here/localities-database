package com.pwr.bdprojekt.logic;

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
	public static boolean addLocalityToFavList(Locality locality) {
		// TODO - implement DataBaseApi.addLocalityToFavList
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param attraction
	 */
	public static boolean addNewAttraction(Attraction attraction) {
		// TODO - implement DataBaseApi.addNewAttraction


		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean addNewLocality(Locality locality) {
		// TODO - implement DataBaseApi.addNewLocality
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
	public static boolean assignAttractionToLocality(String attraction_id, String address) {
		// TODO - implement DataBaseApi.assignAttractionToLocality
		throw new UnsupportedOperationException();
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
	 * @param user
	 * @param permission
	 * @param voivodship
	 */
	public static boolean assignPermissionToUser(AdministrativeUnit voivodship, User user, Permission permission) {
		// TODO - implement DataBaseApi.assignPermissionToUser
		try{
			CallableStatement callableStatement = user_connection.prepareCall("assign_permission_to_user(?, ?, ?)");
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
	 * @param attraction
	 * @param type
	 */
	public static boolean assignTypeToAttraction(Attraction attraction, AttractionType type) {
		// TODO - implement DataBaseApi.assignTypeToAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param attraction
	 */
	public static boolean delAttraction(Attraction attraction) {
		// TODO - implement DataBaseApi.delAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean delLocality(Locality locality) {
		// TODO - implement DataBaseApi.delLocality
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static boolean delLocalityFromFavList(Locality locality) {
		// TODO - implement DataBaseApi.delLocalityFromFavList
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param user
	 */
	public static boolean delUser(User user) {
		// TODO - implement DataBaseApi.delUser
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static Attraction[] getAttractionsInLocality(Locality locality) {
		// TODO - implement DataBaseApi.getAttractionsFromLocality
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param voivodeship
	 */
	public static List<AdministrativeUnit> getCountiesFromVoivodship(AdministrativeUnit voivodeship) {
		// TODO - implement DataBaseApi.getCountiesFromVoivodship
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
		// TODO - implement DataBaseApi.getLocalitiesNumberOfAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param locality
	 */
	public static Address[] getLocationsFromLocality(Locality locality) {
		// TODO - implement DataBaseApi.getLocationsFromLocality
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param county
	 */
	public static List<AdministrativeUnit> getMunicipalitiesFromCounty(AdministrativeUnit county) {
		// TODO - implement DataBaseApi.getMunicipalitiesFromCounty

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
	public static AttractionType[] getTypesAssignedToAttraction(Attraction attraction) {
		// TODO - implement DataBaseApi.getTypesAssignedToAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param user
	 * @param voivodship
	 */
	public static Permission[] getUserPermissionsInVoivodship(User user, AdministrativeUnit voivodship) {
		// TODO - implement DataBaseApi.getUserPermissionsInVoivodship
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param user
	 */
	public static AdministrativeUnit[] getVoivodshipsManagedByUser(User user) {
		// TODO - implement DataBaseApi.getVoivodshipsManagedByUser
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param attraction
	 */
	public static boolean modifyAttraction(Attraction attraction) {
		// TODO - implement DataBaseApi.modifyAttraction
		throw new UnsupportedOperationException();
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
		// TODO - implement DataBaseApi.modifyLocality
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param user
	 * @param new_role
	 */
	public static boolean modifyUserRole(User user, UserRole new_role) {
		// TODO - implement DataBaseApi.modifyUserRole
		throw new UnsupportedOperationException();
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
	 * @param attraction
	 * @param locality
	 */
	public static boolean unassignAttractionFromLocality(Attraction attraction, Locality locality) {
		// TODO - implement DataBaseApi.unassignAttractionFromLocality
		throw new UnsupportedOperationException();
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
		// TODO - implement DataBaseApi.unassignPermissionFromUser
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param attraction
	 * @param type
	 */
	public static boolean unassignTypeFromAttraction(Attraction attraction, AttractionType type) {
		// TODO - implement DataBaseApi.unassignTypeFromAttraction
		throw new UnsupportedOperationException();
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
}