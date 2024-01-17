package com.pwr.bdprojekt.gui.events;

public interface EventCommand {

	/**
	 * Logowanie użytkownika
	 * */
	String loginUser = "login";


	/**
	 * Rejestracja użytkownika
	 * */
	String registerUser = "register";

	/**
	 * Otworzenie widoku konta zalogowanego użytkownika
	 * */
	String openCurrentUserAccount = "my account";

	/**
	 * Powrót do poprzedniego ekranu
	 * */
	String openPreviousView = "back";

	/**
	 * Otworzenie widoku domowego
	 * */
	String openHomeView = "home";

	/**
	 * Odświeżenie widoku
	 * */
	String refreshView = "refresh";

	/**
	 * Wylogowanie aktualnego użytkownika
	 * */
	String logOutCurrentUser = "log out";

	/**
	 * Otwarcie widoku listy miejscowości
	 * */
	String openLocalityList = "locality list";

	/**
	 * Otwarcie widoku listy ulubionych miejscowości
	 * */
	String openFavouriteList = "favourite list";

	/**
	 * Otwarcie widoku listy użytkowników
	 * */
	String openUserList = "user list";

	/**
	 * Dodanie nowego adresu do miejscowości i przypisanie do niego atrakcji
	 * */
	String addAddressToLocalityAndAssignAttractionToIt = "new address";

	/**
	 * Otwarcie widoku przypisania atrakcji do adresu z miejscowości
	 * */
	String openAssignAttractionToAddressFromLocalityView = "locality addresses";

	/**
	 * Otwarcie widoku danych atrakcji
	 * */
	String openAttractionView = "attraction";

	/**
	 * Modifykacja danych bazowych atrakcji
	 * */
	String modifyBaseAttractionData = "update attraction";

	/**
	 * Usunięcie przypisania adresu
	 * */
	String unassignAddressFromAttraction = "unassign address ";

	/**
	 * Modyfikacja podpisu ilustacji przypisanej do atrakcji
	 * */
	String modifyCaptionOfFigureAssignToAttraction = "modify caption ";

	/**
	 * Usunięcie przypisania ilustracji do atrakcji
	 * */
	String unassignFigureFromAttraction = "unassign figure ";

	/**
	 * Otworzenie widoku przypisania atrakcji do ilustracji
	 * */
	String openAssignAttractionToFigure = "figures";

	/**
	 * Otworzenie widoku danych miejscowości
	 * */
	String openLocalityView = "locality ";

	/**
	 * Modyfikacja danych miejscowości
	 * */
	String modifyLocalityData = "modify locality";

	/**
	 * Otworzenie widoku konta użytkownika
	 * */
	String openUserAccountView = "user";

	/**
	 * Otworzenie widoku nadaniwa uprawnienia w regionie
	 * */
	String openAssignPermissionToRegionView = "permissions";

	/**
	 * Przypisanie użytkownikowi uprawnienia w regionie
	 * */
	String assignPermissionInRegionToUser = "assign permission";

	/**
	 * Zastosowanie filtrowania miejscowości
	 * */
	String applyFiltersForLocalities = "filter localities";

	/**
	 * Zastosowanie filtrowania użytkowników
	 * */
	String applyFiltersForUsers = "filter users";

	/**
	 * Zmiana filtra województw
	 * */
	String localityVoivodshipFilterChanged = "voivodship filter change";

	/**
	 * Zmiana filtra powiatów
	 * */
	String localityCountyFilterChanged = "county filter change";

	/**
	 * Włączenie widoku filtrowania miejscowości
	 * */
	String openFilterLocalityView = "locality filters";

	/**
	 * Włączenie widoku sortowania miejscowości
	 * */
	String openSortLocalityView = "locality sorting";

	/**
	 * Dodanie nowej miejscowości
	 * */
	String addNewLocality = "new locality";

	/**
	 * Otworzenie eytora miejscowości
	 * */
	String openLocalityEditor = "edit locality ";

	/**
	 * Usunięcie miejscowości
	 * */
	String deleteLocality = "delete locality ";

	/**
	 * Włączenie widoku sortowania użytkowników
	 * */
	String openSortUsersView = "user sorting";

	/**
	 * Włączenie widoku filtrowania użytkowników
	 * */
	String openFilterUsersView = "user filters";
}