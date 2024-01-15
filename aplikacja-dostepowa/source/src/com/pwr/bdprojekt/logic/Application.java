package com.pwr.bdprojekt.logic;

import com.pwr.bdprojekt.gui.Window;
import com.pwr.bdprojekt.logic.entities.*;

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
		// TODO - implement Logic.logiIn

		if(!DataBaseApi.connect(login, password)){
			Window.showMessageBox("Nie udało się zalogować!");
		}else{
			Window.showMessageBox("Zalogowano!");
		}
	}

	public static void logOut(String login) {
		// TODO - implement Logic.logOut

		if(!DataBaseApi.closeConnection(login)){
			Window.showMessageBox("Nie udało się wylogować!");
		}else{
			Window.showMessageBox("Wylogowano!");
		}
	}

	public static void browseUsersList() {
		// TODO - implement Logic.browseUsersList
		throw new UnsupportedOperationException();
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

	public static void addNewLocality() {
		// TODO - implement Logic.addNewLocality
		throw new UnsupportedOperationException();
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

	public static void deleteAttraction() {
		// TODO - implement Logic.deleteAttraction
		throw new UnsupportedOperationException();
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
		// TODO - implement Logic.openHomeDisplay
		throw new UnsupportedOperationException();
	}

	public static void openAccountDisplay() {
		// TODO - implement Logic.openAccountDisplay
		throw new UnsupportedOperationException();
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