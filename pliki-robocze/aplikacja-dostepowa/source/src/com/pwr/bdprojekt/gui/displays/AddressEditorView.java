package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.components.Button;
import com.pwr.bdprojekt.gui.components.TextField;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok edytora adresu. Dane dla metody refresh():
 * [0] login użytkownika
 * [1] rola użytkownika
 * [2] nazwa miejscowości
 * [3] id miejscowości
 * [4] id atrakcji
 * */
public class AddressEditorView extends View {

//======================================================================================================================
// STAŁE

	private final String HEADER_BASE = "Edytor adresu w miejscowości";

//======================================================================================================================
// POLA

	/**
	 * Panel zawierający elementy edytora
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Pole z nazwą ulicy
	 * */
	private TextField street_name;

	/**
	 * Pole z numerem budynku
	 * */
	private TextField building_number;

	/**
	 * Pole z numerem lokalu
	 * */
	private TextField flat_number;

	/**
	 * Panel przycisków
	 * */
	private HorizontalComponentsStrip buttons_panel;

	/**
	 * Przycisk zatwierdzenia
	 * */
	private Button confirm_button;

	/**
	 * Przycisk anulowania
	 * */
	private Button cancel_button;

	/**
	 * Identyfikator miejscowości, w której znajduje się edytowany adres
	 * */
	private String locality_id;

	/**
	 * Identyfikator atrakcji, która jest przypisana do edytowanego adresu
	 * */
	private String attraction_id;

//======================================================================================================================
// METODY

	/**
	 * Tworzy widok edytora adresu.
	 * @param parent okno, w którym widoczny jest widok
	 * @param event_handler obiekt zbierający zdarzenia wywołane w widoku
	 */
	public AddressEditorView(JFrame parent, EventHandler event_handler) {
		super(parent, false, event_handler);

		// Panel elementów
		elements_panel = new PanelWithHeader(main_panel, HEADER_BASE);
		elements_panel.setScrollableVertically(true);

		// Nazwa ulicy
		street_name = new TextField(main_panel, "Nazwa ulicy", "", 1);
		elements_panel.insertComponent(street_name);

		// Nazwa budynku
		building_number = new TextField(main_panel, "Numer budynku", "", 1);
		elements_panel.insertComponent(building_number);

		// Nazwa lokalu
		flat_number = new TextField(main_panel, "Numer lokalu", "", 1);
		elements_panel.insertComponent(flat_number);

		// Panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk zatwierdzenia
		confirm_button = new Button(
				main_panel,
				"Zatwierdź",
				EventCommand.addAddressToLocalityAndAssignAttractionToIt,
				event_handler
		);
		buttons_panel.insertComponent(confirm_button);

		// przycisk anulownia
		cancel_button = new Button(
			main_panel,
			"Anuluj",
			EventCommand.openAssignAttractionToAddressFromLocalityView,
			event_handler
		);
		buttons_panel.insertComponent(cancel_button);

		// rozmieszczenie elementów
		redraw();
	}

	@Override
	protected void redraw() {
		// panel przycisków
		buttons_panel.setPosition(
				VerticalComponentsStrip.SEPARATOR,
				main_panel.getHeight()-2*VerticalComponentsStrip.SEPARATOR-Text.LETTER_HEIGHT
		);
		buttons_panel.setSizeOfElement(
				main_panel.getWidth()-2*VerticalComponentsStrip.SEPARATOR,
				Text.LETTER_HEIGHT
		);

		// panel z elementami
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-buttons_panel.getHeight()-VerticalComponentsStrip.SEPARATOR
		);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));
		elements_panel.setHeaderText(HEADER_BASE + " " + data[2]);
		locality_id = data[3];
		attraction_id = data[4];
	}

	/**
	 * Pobranie nazwy ulicy
	 * */
	public String getStreetName(){
		return street_name.getText();
	}

	/**
	 * Pobranie numery budynku
	 * */
	public String getBuildingNumber(){
		return building_number.getText();
	}

	/**
	 * Pobranie numeru lokalu
	 * */
	public String getFlatNumber(){
		return flat_number.getText();
	}

	/**
	 * Pobranie id miejscowości
	 * */
	public int getLocalityId(){
		return Integer.parseInt(locality_id);
	}

	/**
	 * Pobranie id atrakcji
	 * */
	public int getAttractionId(){
		return Integer.parseInt(attraction_id);
	}
}