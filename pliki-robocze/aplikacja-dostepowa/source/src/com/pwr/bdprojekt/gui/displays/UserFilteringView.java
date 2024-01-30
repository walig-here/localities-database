package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok pozwalający na filtrowanie listy użytkowników. Dane dla metody refresh():
 * [0] - login aktualnego uzytkownika
 * [1] - rola aktualnego użytkownika
 * [2] - login, po którym aktualnego odbywa się filtrowanie
 * [3] - lista nazw wszystkich ról dostepnych w bazie (posortowana względem id), oddzielana przecinkami
 * [4]  - lista identyfikatorów wybrany do filtrowania ról, oddzielana przecinkami
 * */
public class UserFilteringView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel elementów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Panel przycisków
	 * */
	private HorizontalComponentsStrip buttons_panel;

	/**
	 * Przycisk zastosowania filtrów
	 * */
	private Button apply_filters_button;

	/**
	 * Przycisk zresetowania filtrów
	 * */
	private Button reset_filters_button;

	/**
	 * Login
	 * */
	private TextField login;

	/**
	 * Rola
	 * */
	private MultiChoiceList user_roles;

//======================================================================================================================
// METODY

	/**
	 * Stworzenie nowego, pustego widoku.
	 *
	 * @param parent        okno, w którym wyświetlony ma zostać widok
	 * @param event_handler odbiorca zdarzeń z widoku
	 */
	public UserFilteringView(JFrame parent, EventHandler event_handler) {
		super(parent, false, event_handler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Kryteria filtrowania użytkowników");
		elements_panel.setScrollableVertically(true);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk zatwierdzenia
		apply_filters_button = new Button(
				buttons_panel,
				"Zastosuj filtry",
				EventCommand.applyFiltersForUsers,
				event_handler
		);
		buttons_panel.insertComponent(apply_filters_button);

		// przycisk zresetowania filtrów
		reset_filters_button = new Button(
				buttons_panel,
				"Resetuj filtry",
				a -> resetAll()
		);
		buttons_panel.insertComponent(reset_filters_button);

		// login
		login = new TextField(elements_panel, "Login", "", 1);
		login.setResetable(true);
		elements_panel.insertComponent(login);

		// rola
		user_roles = new MultiChoiceList(elements_panel, "Rola", new int[0], 3);
		user_roles.setResetable(true);
		elements_panel.insertComponent(user_roles);

		// rozmieszczenie elementów
		redraw();
	}

	private void resetAll(){
		login.reset();
		user_roles.reset();
	}

	@Override
	protected void redraw() {
		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
			main_panel.getWidth(),
			main_panel.getHeight()-topbar.getHeight()-Text.LETTER_HEIGHT-PanelWithHeader.S
		);

		// panel przycisków
		buttons_panel.setPosition(0, elements_panel.getBottomY());
		buttons_panel.setSizeOfElement(
				main_panel.getWidth(),
				Text.LETTER_HEIGHT
		);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// login
		login.setText(data[2]);

		// rola
		String[] available_roles = data[3].split(",");
		String[] selected_roles = data[4].split(",");
		user_roles.setElements(available_roles);
		user_roles.setSelectedElements(selected_roles);
	}

}