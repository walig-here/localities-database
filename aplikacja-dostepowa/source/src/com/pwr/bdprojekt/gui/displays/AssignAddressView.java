package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Adres pozwalakący przypisać atrakcji adres z jednej z miejscowości. Dane dla metody refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] identyfikator miejscowości, z której pochodzą adresy
 * [3] nazwa miejscowości, z której pochodzą adresy
 * [4] identyfikator atrakcji, do której przypisany ma zostać adres
 * [5] nazwa atrakcji, do której przypisany ma zostać adres
 * [6] lista adresów z miejscowości z puntku [2] (posortowana względem id), oddzielona średnikami
 * */
public class AssignAddressView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel elementów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Przycisk powrotu do ekranu atrakcji
	 * */
	private Button back_button;

	/**
	 * Przycisk przypisania nowego adresu
	 * */
	private Button new_address_button;

	/**
	 * Identyfikator miejsocowści, z której pochodzą adresy
	 * */
	private String locality_id;

	/**
	 * Idektyfikator atrakcji, do której przypisany ma być adres
	 * */
	private String attraction_id;

	/**
	 * Adresy
	 * */
	private List<AddressBar> address_data_panels = new ArrayList<>();

	/**
	 * Odbiorca zdarzeń
	 * */
	private EventHandler eventHandler;

//======================================================================================================================
// METODY

	public AssignAddressView(JFrame frame, EventHandler eventHandler) {
		super(frame, false, eventHandler);
		this.eventHandler = eventHandler;

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, getHeader("xxx", "xxx"));
		elements_panel.setScrollableVertically(true);

		// przycisk powrotu
		back_button = new Button(
				main_panel,
				"Wróć",
				EventCommand.openAttractionEditor,
				eventHandler
		);

		// przycisk nowego adresu
		new_address_button = new Button(
				elements_panel,
				"Przypisz nowy adres",
				EventCommand.openAddressEditorView,
				eventHandler
		);
		elements_panel.insertComponent(new_address_button);

		// rozmieszczenie elementów
		redraw();
	}

	/**
	 * Wygenerowanie nagłówka
	 * */
	private static String getHeader(String locality_name, String attraction_name){
		return "Przypisanie adresu do atrakcji \"" + attraction_name + "\" w miejscowości \""+ locality_name + "\"";
	}

	@Override
	protected void redraw() {
		// przycisk nowego adresu
		new_address_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-PanelWithHeader.S-Text.LETTER_HEIGHT
		);

		// przycisk powrotu
		back_button.setPosition(main_panel.getWidth()/2-50, elements_panel.getBottomY());
		back_button.setSizeOfElement(
				100,
				Text.LETTER_HEIGHT
		);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// dane miejscowości i atrakcji
		locality_id = data[2];
		attraction_id = data[4];
		elements_panel.setHeaderText(getHeader(data[3], data[5]));

		// adresy
		elements_panel.removeAllComponents();
		elements_panel.insertComponent(new_address_button);
		address_data_panels.clear();
		String[] addresses = data[6].split(";");
		for(int i = 0; i < addresses.length; i++){
			AddressBar address_data_panel = new AddressBar(
					elements_panel,
					eventHandler,
					"Przypisz",
					EventCommand.assignAddressToAttraction+i
			);
			address_data_panel.setAddressData(addresses[i]);
			elements_panel.insertComponent(address_data_panel);
		}
	}
}