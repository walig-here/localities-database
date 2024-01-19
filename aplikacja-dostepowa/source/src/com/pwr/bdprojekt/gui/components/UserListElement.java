package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;

/**
 * Element listy użytkowników, wyświetlający szczątkowe dane nt użytkownika i pozwalający na zarządzenie jego kontem.
 * */
public class UserListElement extends GuiComponent {

//======================================================================================================================
// POLA

	public final static String USER_ROLE_DATA_HEADER = "Rola:\t";

//======================================================================================================================
// POLA

	/**
	 * Odbiorca zdarzeń z widoku
	 * */
	private EventHandler event_handler;

	/**
	 * Panel elementów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Rola użytkownika
	 * */
	private Text role;

	/**
	 * Przycisk zarządzenia kontem
	 * */
	private Button open_account_button;

//======================================================================================================================
// METODY

	public UserListElement(JPanel parent, EventHandler eventHandler, int user_index) {
		super(parent);
		this.event_handler = eventHandler;

		// panel elementów
		elements_panel = new PanelWithHeader(this, "użytkownik...");
		elements_panel.setScrollableVertically(false);
		elements_panel.setBorderVisibility(true);

		// rola użytkwnika
		role = new Text(elements_panel, USER_ROLE_DATA_HEADER, 1);
		elements_panel.insertComponent(role);

		// przycisk zarządzenia kontem
		open_account_button = new Button(
				elements_panel,
				"Zarządzaj kontem",
				EventCommand.openUserAccountView+" "+user_index,
				eventHandler
		);
		elements_panel.insertComponent(open_account_button);

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		// przycisk
		open_account_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, 0);
		elements_panel.setSizeOfElement(getWidth(), getHeight());

		// rozmiar elementu
		final int HEIGHT = 	40+
							4*VerticalComponentsStrip.SEPARATOR+
							role.getHeight()+
							open_account_button.getHeight();
		setBounds(
				getX(),
				getY(),
				getWidth(),
				HEIGHT
		);
	}

	@Override
	protected void updateData(String[] data) {

	}

	/**
	 * Ustalenie loginu
	 * */
	public void setLogin(String login){
		elements_panel.setHeaderText(login);
	}

	/**
	 * Ustalenie roli
	 * */
	public void setRole(String role){
		this.role.setText(USER_ROLE_DATA_HEADER+role);
	}
}