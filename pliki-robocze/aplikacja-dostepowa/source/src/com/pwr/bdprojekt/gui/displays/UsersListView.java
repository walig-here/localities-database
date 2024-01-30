package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozwalający przeglądać szczątkowe dane nt. wszystkich użytkowników w bazie. Dane dla metody refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] - login, po którym aktualnego odbywa się filtrowanie
 * [3] - lista nazw wszystkich ról dostepnych w bazie (posortowana względem id), oddzielana przecinkami
 * [4]  - lista identyfikatorów wybrany do filtrowania ról, oddzielana przecinkami
 * [5..n] - dane użytkowników podane w formie listy:
 * 				[login];[rola]
 * */
public class UsersListView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel elemenmtów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Panel przycisków
	 * */
	private HorizontalComponentsStrip buttons_panel;

	/**
	 * Przycisk filtrowania
	 * */
	private Button filter_button;

	/**
	 * Przycisk sortowania
	 * */
	private Button sort_button;

	/**
	 * Panele z danymi użytkowników
	 * */
	private List<UserListElement> user_data_panels = new ArrayList<>();

	/**
	 * Dane nt filtrowania
	 * */
	private String[] filtering_data;

	/**
	 * Odbiorca zdarzeń z widoku
	 * */
	private EventHandler event_handler;

//======================================================================================================================
// POLA

	public UsersListView(JFrame frame, EventHandler eventHandler) {
		super(frame, false, eventHandler);
		this.event_handler = eventHandler;

		// panel elemenów
		elements_panel = new PanelWithHeader(main_panel, "Lista użytkowników");
		elements_panel.setScrollableVertically(true);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk filtrowania
		//filter_button = new Button(
		//		buttons_panel,
		//		"Filtruj",
		//		EventCommand.openFilterUsersView,
		//		eventHandler
		//);
		//buttons_panel.insertComponent(filter_button);

		// przycisk sortowania
		//sort_button = new Button(
		//		buttons_panel,
		//		"Sortuj",
		//		EventCommand.openSortUsersView,
		//		eventHandler
		//);
		//buttons_panel.insertComponent(sort_button);

		// rozrysowanie gui
		redraw();
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

		// dane nt filtrowanie
		filtering_data = Arrays.copyOfRange(data, 2, 5);

		// dane nt użytkowników
		elements_panel.removeAllComponents();
		user_data_panels.clear();
		for(int i = 5; i < data.length; i++){
			String[] user_data = data[i].split(";");
			UserListElement user_data_panel = new UserListElement(elements_panel, event_handler, user_data[0]);
			user_data_panel.setLogin(user_data[0]);
			user_data_panel.setRole(user_data[1]);
			elements_panel.insertComponent(user_data_panel);
		}
	}

	/**
	 * Pobranie danych filtrowania
	 * */
	public String[] getFilteringData(){
		return filtering_data;
	}
}