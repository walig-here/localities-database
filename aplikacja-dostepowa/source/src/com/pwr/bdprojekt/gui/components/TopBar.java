package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;
import org.w3c.dom.events.Event;

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
	 * Logik i rola aktualnie zalogowanego użytkownika
	 * */
	private Text loginAndRole;

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

		// Login
		loginAndRole = new Text(elements_panel, "login i rola", 2);
		elements_panel.insertComponent(loginAndRole);

		// panel nawigacyjny
		navigation_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(navigation_panel);

		// przycisk profilu
		user_profile_button = new Button(
				navigation_panel,
				"Mój profil",
				EventCommand.openCurrentUserAccount,
				event_handler
		);
		navigation_panel.insertComponent(user_profile_button);

		// przycisk powrotu do poprzedniego widoku
		previous_view_button = new Button(
				navigation_panel,
				"Wstecz",
				EventCommand.openPreviousView,
				event_handler
		);
		navigation_panel.insertComponent(previous_view_button);

		// Przycisk przejścia do ekranu domowego
		home_view_button = new Button(
				navigation_panel,
				"Główna",
				EventCommand.openHomeView,
				event_handler
		);
		navigation_panel.insertComponent(home_view_button);

		// Przycisk odświeżenia
		refresh_button = new Button(
				navigation_panel,
				"Odśwież",
				EventCommand.refreshView,
				event_handler
		);
		navigation_panel.insertComponent(refresh_button);

		// Przycisk wylogowania
		log_out_button = new Button(
			navigation_panel,
			"Wyloguj",
				EventCommand.logOutCurrentUser,
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
		loginAndRole.setText(data[0]+" ("+data[1]+")");
	}
}