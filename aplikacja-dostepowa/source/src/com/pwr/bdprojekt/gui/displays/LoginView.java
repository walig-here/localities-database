package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommandGenerator;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;

/**
 * Widok logowania i rejestracji. Dane dla metody refresh(): brak.
 * */
public class LoginView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel z elementami służącymi do logowania i rejestracji użytkowników
	 * */
	private PanelWithHeader login_panel;

	/**
	 * Pole tekstowe do wprowadzenia loginu
	 * */
	private TextField login;

	/**
	 * Pole tekstowe do wprowadzania hasła
	 * */
	private TextField password;

	/**
	 * Panel przycisków
	 * */
	private HorizontalComponentsStrip button_panel;

	/**
	 * Przycisk logowania
	 * */
	private Button login_button;

	/**
	 * Przycisk rejestracji
	 * */
	private Button register_button;

//======================================================================================================================
// METODY

	/**
	 * Inicjalizacja widoku logowania i rejestracji
	 * */
	public LoginView(JFrame parent, EventHandler event_handler) {
		super(parent, true, null);

		// Panel logowania
		login_panel = new PanelWithHeader(main_panel, "Logowanie i rejestracja");

		// Pole do wprowadzania loginu
		login = new TextField(main_panel, "Login", "", 1);
		login_panel.insertComponent(login);

		// Pole do wprowadzania hasła
		password = new TextField(login_panel, "Hasło", "", 1);
		login_panel.insertComponent(password);

		// Panel przycisków
		button_panel = new HorizontalComponentsStrip(login_panel);
		login_panel.insertComponent(button_panel);

		// Przycisk logowania
		login_button = new Button(button_panel, "Zaloguj", EventCommandGenerator.loginUser(), event_handler);
		button_panel.insertComponent(login_button);

		// Przycisk rejestracji
		register_button = new Button(button_panel, "Zarejestruj", EventCommandGenerator.registerUser(), event_handler);
		button_panel.insertComponent(register_button);

		// Rozmieszczenie elementów
		redraw();
	}

	public String[] getLoginData() {
		// TODO - implement LoginView.getLoginData
		throw new UnsupportedOperationException();
	}

	@Override
	public void redraw(){
		// Panel przycisków
		button_panel.setSizeOfElement(0, Text.LETTER_HEIGHT);

		// Panel logowania
		login_panel.setPosition(0,0);
		login_panel.setSizeOfElement(main_panel.getWidth(), main_panel.getHeight());
	}

	@Override
	protected void updateData(String[] data) {

	}
}