package com.pwr.bdprojekt.logic;

import com.pwr.bdprojekt.gui.Window;
import com.pwr.bdprojekt.gui.displays.ViewType;
import com.pwr.bdprojekt.logic.entities.*;

import java.util.ArrayList;
import java.util.List;


/**
 * Logika aplikacji
 * */
public class Application {

	private static User current_user = null;	// aktualnie zalogowany użytkownik
	private static boolean is_running = false;	// czy aplikacja jest włączona

	public static User getCurrentUser() {
		return current_user;
	}

	public static void register(String login, String password) {
		// TODO - implement Logic.register

		String errorMessage = DataBaseApi.registerUser(login, password);
		if(errorMessage.equals("")){
			Window.showMessageBox("Rejestracja powiodła się");
		}else{
			Window.showMessageBox(errorMessage);
		}
	}

	public static void logiIn(String login, String password) {
		if(!DataBaseApi.connect(login, password)){
			Window.showMessageBox("Logowanie nieudane!");
			return;
		}
		current_user = DataBaseApi.getCurrentUser(login);

		openHomeDisplay();
	}

	public static void logOut() {
		DataBaseApi.closeConnection(current_user.getLogin());
	}

	/**
	 * Przeglądanie listy użytkowników
	 * */
	public static void browseUsersList()
	{
		// pobranie użytkowników z bazy
		List<String> dataForGui = new ArrayList<>();
		List<User> usersFromDatabase = DataBaseApi.selectUsers("");
		if(usersFromDatabase == null){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add("");
		dataForGui.add(String.join(",", new String[]{}));
		dataForGui.add(String.join(",", new String[]{}));

		// ustalenie danych użytkowników
		for (User user : usersFromDatabase) {
			dataForGui.add(user.getLogin() + ";" + user.getRoleName());
		}

		// otworzenie widoku listy miejscowości
		Window.switchToView(ViewType.USERS_LIST, dataForGui.toArray(new String[]{}));
	}

	public static void browseLocalitiesList() {
		// TODO - implement Logic.browseLocalitiesList
		throw new UnsupportedOperationException();
	}

	public static void browseFavouriteList() {
		// TODO - implement Logic.browseFavouriteList
		throw new UnsupportedOperationException();
	}

	public static void examineUserData() {
		// TODO - implement Logic.examineUserData
		throw new UnsupportedOperationException();
	}

	public static void changeUserRole() {
		// TODO - implement Logic.changeUserRole
		throw new UnsupportedOperationException();
	}

	public static void deleteUserAccount() {
		// TODO - implement Logic.deleteUserAccount
		throw new UnsupportedOperationException();
	}

	public static void givePermissionToRegion() {
		// TODO - implement Logic.givePermissionToRegion
		throw new UnsupportedOperationException();
	}

	public static void takeAwayPermissionToRegion() {
		// TODO - implement Logic.takeAwayPermissionToRegion
		throw new UnsupportedOperationException();
	}

	public static void givePermissionInRegion() {
		// TODO - implement Logic.givePermissionInRegion
		throw new UnsupportedOperationException();
	}

	public static void takeAwayPermissionInRegion() {
		// TODO - implement Logic.takeAwayPermissionInRegion
		throw new UnsupportedOperationException();
	}

	public static void addLocalityToFavourites() {
		// TODO - implement Logic.addLocalityToFavourites
		throw new UnsupportedOperationException();
	}

	public static void removeLocalityFromFavourites() {
		// TODO - implement Logic.removeLocalityFromFavourites
		throw new UnsupportedOperationException();
	}

	public static void examineLocalityData() {
		// TODO - implement Logic.examineLocalityData
		throw new UnsupportedOperationException();
	}

	public static void addAddnotation() {
		// TODO - implement Logic.addAddnotation
		throw new UnsupportedOperationException();
	}

	public static void addNewLocality(Locality locality) {
		// TODO - implement Logic.addNewLocality
		if(DataBaseApi.addNewLocality(locality))
			Window.showMessageBox("Nowa miejscowość została dodana!");
		else
			Window.showMessageBox("Dodanie miejscowości nie powiodło się");
	}

	public static void assignAttractionToLocality() {
		// TODO - implement Logic.assignAttractionToLocality
		throw new UnsupportedOperationException();
	}

	public static void editAttraction() {
		// TODO - implement Logic.editAttraction
		throw new UnsupportedOperationException();
	}

	public static void deleteAttractionFromLocality() {
		// TODO - implement Logic.deleteAttractionFromLocality
		throw new UnsupportedOperationException();
	}

	public static void deleteLocality() {
		// TODO - implement Logic.deleteLocality
		throw new UnsupportedOperationException();
	}

	public static void addNewAttraction() {
		// TODO - implement Logic.addNewAttraction
		throw new UnsupportedOperationException();
	}

	public static void editLocality() {
		// TODO - implement Logic.editLocality
		throw new UnsupportedOperationException();
	}

	public static void assignAddressToAttraction() {
		// TODO - implement Logic.assignAddressToAttraction
		throw new UnsupportedOperationException();
	}

	public static void addNewAddress() {
		// TODO - implement Logic.addNewAddress
		throw new UnsupportedOperationException();
	}

	public static void assignFigureToAttraction() {
		// TODO - implement Logic.assignFigureToAttraction
		throw new UnsupportedOperationException();
	}

	public static void addNewFiugre() {
		// TODO - implement Logic.addNewFiugre
		throw new UnsupportedOperationException();
	}

	public static void deleteAttraction(Attraction attraction) {
		if(DataBaseApi.delAttraction(attraction))
			Window.showMessageBox("Miejscowość została usunięta!");
		else
			Window.showMessageBox("Usunięcie miejscowości nie powiodło się");
	}

	public static void open() {
		is_running = true;
		Window.open("Baza danych miejscowości", 975, 800);
		if(!DataBaseApi.connect("root", "admin")){
			Window.showMessageBox("Nie udało się połączyć z bazą danych!\nZamykanie aplikacji...");
			quit();
		}
	}

	public static void quit() {
		is_running = false;
		Window.close();
		DataBaseApi.closeConnection("root");
		if(current_user != null)
			DataBaseApi.closeConnection(current_user.getLogin());
	}

	public static void openHomeDisplay() {
		if(current_user.getRole().equals(UserRole.TECHNICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.HOME_ADMIN_TECH, new String[]{current_user.getLogin(), current_user.getRoleName()});
		else
			Window.switchToView(ViewType.HOME, new String[]{current_user.getLogin(), current_user.getRoleName()});
	}

	public static void openAccountDisplay(String login)
	{
		List<String> dataForGui = new ArrayList<>();
		// dane aktualnego użytkownika
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		// pobranie danych użytkownika, którego konto przeglądamy
		try{
			User user = DataBaseApi.selectUsers("login = '" + login + "'").get(0);
			dataForGui.add(user.getLogin());
			dataForGui.add(user.getRoleName());

			List<AdministrativeUnit> voivodshipsManagedByUser = DataBaseApi.getVoivodshipsManagedByUser(user);
			for (AdministrativeUnit voivodship : voivodshipsManagedByUser) {
				String dataForVoivodship = voivodship.getId() + ";" + voivodship.getName();

				List<Permission> permissionsInVoivodship = DataBaseApi.getUserPermissionsInVoivodship(user, voivodship);
				for (Permission permission : permissionsInVoivodship) {
					dataForVoivodship += ";" + permission.getId();
					dataForVoivodship += ";" + permission.getName();
					dataForVoivodship += ";" + permission.getDesc();
				}
			}
		}
		catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.USER_DATA_ADMIN_TECH, dataForGui.toArray(new String[0]));
	}

	public static void openPreviousDisplay() {
		// TODO - implement Logic.openPreviousDisplay
		throw new UnsupportedOperationException();
	}

	public static void refreshDisplay() {
		// TODO - implement Logic.refreshDisplay
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param attraction_id
	 * @param figure_id
	 * @param caption
	 */
	public static void editCaption(String attraction_id, String figure_id, String caption) {
		// TODO - implement Logic.editCaption
		throw new UnsupportedOperationException();
	}

	private Application(){}

}