package com.pwr.bdprojekt.gui.events;

public class EventCommandGenerator {

	/**
	 * 
	 * @param address_id
	 * @param attraction_id
	 */
	public static String assignAddressToAttraction(String address_id, String attraction_id) {
		// TODO - implement EventCommandGenerator.assignAddressToAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * Otworzenie edytora adresu w miejscowoœci
	 * @param locality_id
	 * @param attraction_id
	 */
	public static String openAddressEditor(String locality_id, String attraction_id) {
		// TODO - implement EventCommandGenerator.openAddressEditor
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param login
	 */
	public static String viewAccount(String login) {
		// TODO - implement EventCommandGenerator.viewAccount
		throw new UnsupportedOperationException();
	}

	public static String openHomeView() {
		// TODO - implement EventCommandGenerator.openHomeView
		throw new UnsupportedOperationException();
	}

	public static String openPreviousView() {
		// TODO - implement EventCommandGenerator.openPreviousView
		throw new UnsupportedOperationException();
	}

	public static String refreshView() {
		// TODO - implement EventCommandGenerator.refreshView
		throw new UnsupportedOperationException();
	}

	public static void logOut() {
		// TODO - implement EventCommandGenerator.logOut
		throw new UnsupportedOperationException();
	}

	/**
	 * Otwiera ekran filtrowania listy u¿ytkowników
	 */
	public static String openUserFilters() {
		// TODO - implement EventCommandGenerator.openUserFilters
		throw new UnsupportedOperationException();
	}

	/**
	 * otworzenie okna sortowania u¿ytkowników
	 */
	public static String openUserSort() {
		// TODO - implement EventCommandGenerator.openUserSort
		throw new UnsupportedOperationException();
	}

	/**
	 * otwiera listê miejscowoœci
	 */
	public static String openLocalityList() {
		// TODO - implement EventCommandGenerator.openLocalityList
		throw new UnsupportedOperationException();
	}

	/**
	 * otwiera listê ulubionych miejscowoœci
	 */
	public static String openFavouriteList() {
		// TODO - implement EventCommandGenerator.openFavouriteList
		throw new UnsupportedOperationException();
	}

	/**
	 * otwiera listê u¿ytkowników
	 */
	public static String openUserList() {
		// TODO - implement EventCommandGenerator.openUserList
		throw new UnsupportedOperationException();
	}

	/**
	 * Dodaje nowy adres do bazy danych i przypisuje do niego atrakcje
	 * @param attraction_id
	 * @param locality_id
	 * @param address
	 */
	public static String addNewAddress(String attraction_id, String locality_id, String[] address) {
		// TODO - implement EventCommandGenerator.addNewAddress
		throw new UnsupportedOperationException();
	}

	/**
	 * Otworzenie widoku przypisania atrakcji adresu z miejscowoœci
	 * @param locality_id
	 * @param attraction_id
	 */
	public static String assignAttractionToLocality(String locality_id, String attraction_id) {
		// TODO - implement EventCommandGenerator.assignAttractionToLocality
		throw new UnsupportedOperationException();
	}

	/**
	 * modyfikacja podstawowych danych atrakcji
	 * @param attraction_id
	 */
	public static String updateAttraction(String attraction_id) {
		// TODO - implement EventCommandGenerator.updateAttraction
		throw new UnsupportedOperationException();
	}

	/**
	 * usuniêcie przypisania obrazka do atrakcji
	 * @param figure_id
	 * @param attraction_id
	 */
	public static String unassignFigure(String figure_id, String attraction_id) {
		// TODO - implement EventCommandGenerator.unassignFigure
		throw new UnsupportedOperationException();
	}

	/**
	 * modyfikacja podpisu obrazka
	 * @param attraction_id
	 * @param figure_index
	 */
	public static String modifyCaption(String attraction_id, String figure_index) {
		// TODO - implement EventCommandGenerator.modifyCaption
		throw new UnsupportedOperationException();
	}

	/**
	 * otwiera listê obrazków zawartych w bazie
	 */
	public static String openFiguresList() {
		// TODO - implement EventCommandGenerator.openFiguresList
		throw new UnsupportedOperationException();
	}

}