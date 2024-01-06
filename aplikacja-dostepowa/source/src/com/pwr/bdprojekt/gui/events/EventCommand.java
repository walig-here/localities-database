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
}