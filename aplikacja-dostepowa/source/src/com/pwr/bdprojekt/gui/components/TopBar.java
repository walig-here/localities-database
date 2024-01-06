package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommandGenerator;
import com.pwr.bdprojekt.gui.events.EventHandler;
import com.pwr.bdprojekt.logic.Application;
import com.pwr.bdprojekt.logic.entities.User;

import javax.swing.*;
import java.awt.*;

/**
 * Belka zlokalizowana na szczycie ekranu. Zawiera: dane o aktualnie zalogowanym użytkowniku, przyciski do nawigowania
 * między kluczowymi ekranami aplikacji, przyciski wylogowania i odświeżenia. Dane dla refresh:
 * 0. login użytkownika
 * 1. rola użytkownika
 * */
public class TopBar extends GuiComponent {

//======================================================================================================================

	/**
	 * Panel z elementami
	 * */
	private HorizontalComponentsStrip elements_panel;

	/**
	 * Panel z danymi użytkownika
	 * */
	private HorizontalComponentsStrip user_data_panel;

	/**
	 * Login aktualnie zalogowanego użytkownika
	 * */
	private Text login;

	/**
	 * Rola aktualnie zalowogwanego użytkownika
	 * */
	private Text role;

	/**
	 * Panel z przyciskami nawigacyjnymi
	 * */
	private HorizontalComponentsStrip navigation_panel;

	/**
	 * Przycisk przejścia do profilu użytkownika
	 * */
	private Button user_profile_button;

	/**
	 * Przycisk powrotu do poprzedniego widoku
	 * */
	private Button previous_view_button;

	/**
	 * Przycisk przejście do widoku domowego
	 * */
	private Button home_view_button;

	/**
	 * Przycisk odświeżenia
	 * */
	private Button refresh_button;

	/**
	 * Przycisk wylogowania
	 * */
	private Button log_out_button;

//======================================================================================================================

	public TopBar(JPanel parent, EventHandler event_handler) {
		super(parent);
		setBackground(Color.WHITE);

		// Panel elementów
		elements_panel = new HorizontalComponentsStrip(this);

		// Panel danych użytkownika
		user_data_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(user_data_panel);

		// Login
		login = new Text(elements_panel, "login");
		user_data_panel.insertComponent(login);

		// rola
		role = new Text(elements_panel, "rola");
		user_data_panel.insertComponent(role);

		// panel nawigacyjny
		navigation_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(navigation_panel);

		// przycisk profilu
		user_profile_button = new Button(
				navigation_panel,
				"Mój profil",
				EventCommandGenerator.openCurrentUserAccount(),
				event_handler
		);
		navigation_panel.insertComponent(user_profile_button);

		// przycisk powrotu do poprzedniego widoku
		previous_view_button = new Button(
				navigation_panel,
				"Wstecz",
				EventCommandGenerator.openPreviousView(),
				event_handler
		);
		navigation_panel.insertComponent(previous_view_button);

		// Przycisk przejścia do ekranu domowego
		home_view_button = new Button(
				navigation_panel,
				"Główna",
				EventCommandGenerator.openHomeView(),
				event_handler
		);
		navigation_panel.insertComponent(home_view_button);

		// Przycisk odświeżenia
		refresh_button = new Button(
				navigation_panel,
				"Odśwież",
				EventCommandGenerator.refreshView(),
				event_handler
		);
		navigation_panel.insertComponent(refresh_button);

		// Przycisk wylogowania
		log_out_button = new Button(
			navigation_panel,
			"Wyloguj",
			EventCommandGenerator.logOutCurrentUser(),
			event_handler
		);
		navigation_panel.insertComponent(log_out_button);

		// Rozłożenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		// Panel elementów
		elements_panel.setSizeOfElement(getWidth(), getHeight());
	}

	@Override
	protected void updateData(String[] data) {
		// Dane użytkownika
		login.setText(data[0]);
		role.setText("("+data[1]+")");
	}
}