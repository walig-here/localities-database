package com.pwr.bdprojekt.gui.displays;

/**
 * Typy widoków dostępnych w aplikacji.
 * */
public enum ViewType {
	/**
	 * Widok domowy administratora technicznego
	 * */
	HOME_ADMIN_TECH,

	/**
	 * Widok domowy użytkowników innych niż administrator techniczny
	 * */
	HOME,

	/**
	 * Widok edycji adresu atrakcji w miejscowości
	 * */
	ADDRESS_EDITOR,

	/**
	 * Widok edycji atrakcji
	 * */
	ATTRACTION_EDITOR,

	/**
	 * Widok edycji miejscowości
	 * */
	LOCALITY_EDITOR,

	/**
	 * Widok edycji uprawnienia w regionie
	 * */
	PERMISSION_EDITOR,

	/**
	 * Widok edycji uprawnienia do regionu
	 * */
	PERMISSION_TO_REGION_EDITOR,

	/**
	 * Widok filtrowania miejscowości
	 * */
	LOCALITY_FILTER,

	/**
	 * Widok filtrowania użytkowników
	 * */
	USERS_FILTER,

	/**
	 * Widok listy miejscowości (perspektywa administratora merytorycznego)
	 * */
	LOCALITY_LIST_ADMIN_MERIT,

	/**
	 * Widok listy miejscowości
	 * */
	LOCALITY_LIST,

	/**
	 * Widok listy użytkowników
	 * */
	USERS_LIST,

	/**
	 * Widok logowania i rejestracji
	 * */
	LOGIN,

	/**
	 * Widok przypisania atrakcji adresu z miejscowości
	 * */
	ASSIGN_ATTRACTION,

	/**
	 * Widok przypisania atrakcji nowego adresu, który zlokalizowany jest we wskazanej miejscowości
	 * */
	ASSIGN_ADDRESS,

	/**
	 * Widok przypisania obrazka do atrakcji
	 * */
	ASSIGN_FIGURE,

	/**
	 * Widok sortowania miejscowości
	 * */
	LOCALITY_SORT,

	/**
	 * Widok sortowania użytkowników
	 * */
	USERS_SORT,

	/**
	 * Widok danych miejscowości
	 * */
	LOCALITY_DATA,

	/**
	 * Widok danych miejscowości (perspektywa administratora merytorycznego)
	 * */
	LOCALITY_DATA_ADMIN_MERIT,

	/**
	 * Widok danych użytkownika (perspektywa administratora technicznego)
	 * */
	USER_DATA_ADMIN_TECH,

	/**
	 * Widok danych użytkownika
	 * */
	USER_DATA,

	/**
	 * Pusty widok (aplikacja nieaktywna)
	 * */
	EMPTY
}