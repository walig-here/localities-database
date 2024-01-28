package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozwalający na przypisanie jednej z dostępnych w bazie atrakcji do miejscowości. Dane dla refresh():
 * [0] login aktualnego uzytkownika
 * [1] rola aktualnego użytkownika
 * [2] identyfikator miejscowości, do której przypisywane są atrakcje
 * [3] nazwa miejscowości, do której przypisywane są atrakcje
 * [4] lista nazw atrakcji (posortowana wg id) oddzielana średnikami
 * [5] lista opisw atrakcji (posortowana wg id) oddzielana średnikami
 * */
public class AssignAttractionView extends View {

//======================================================================================================================
// STAŁE

	private final static String HEADER = "Przypisanie atrakcji do miejscowości \"";

//======================================================================================================================
// POLA

	/**
	 * Panel z elementami
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Przycisk powrotu do widoku danych miejscowości
	 * */
	private Button back_button;

	/**
	 * Odbiorca zdarzeń
	 * */
	private EventHandler event_handler;

	/**
	 * Przycisk dodawania nowej atrakcji
	 * */
	private Button add_attraction_button;

	/**
	 * Atrakcje
	 * */
	private List<AttractionDataPanel> attraction_data_panels = new ArrayList<>();

	/**
	 * Identyfikator miejscowości, do której przypisane zostana atrakcje
	 * */
	private String locality_id;

//======================================================================================================================
// METODY

	public AssignAttractionView(JFrame frame, EventHandler eventHandler) {
		super(frame, false, eventHandler);
		event_handler = eventHandler;

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, HEADER);
		elements_panel.setScrollableVertically(true);

		// przycisk powrotu
		back_button = new Button(
				main_panel,
				"Wróć",
				EventCommand.openPreviousView,
				eventHandler
		);

		// przycisk dodania atrakcji
		add_attraction_button = new Button(
				elements_panel,
				"Przypisz nową atrakcje",
				EventCommand.openAttractionEditor,
				eventHandler
		);
		elements_panel.insertComponent(add_attraction_button);

		// rozmieszczenie elementów
		redraw();
	}

	@Override
	protected void redraw() {
		// przycisk nowej atrakcji
		add_attraction_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-Text.LETTER_HEIGHT-PanelWithHeader.S
		);

		// pwrzycisk powrotu
		back_button.setPosition(main_panel.getWidth()/2-50, elements_panel.getBottomY());
		back_button.setSizeOfElement(
				100,
				Text.LETTER_HEIGHT
		);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// dane miejscowości
		locality_id = data[2];
		elements_panel.setHeaderText(HEADER+data[3]+"\"");

		// dane atrackji
		elements_panel.removeAllComponents();
		elements_panel.insertComponent(add_attraction_button);
		attraction_data_panels.clear();
		String[] attraction_names = data[4].split(";");
		if(attraction_names[0].isEmpty())
			return;
		String[] attraction_descs = data[5].split(";");
		for(int i = 0; i < attraction_names.length; i++){
			AttractionDataPanel attraction_panel = new AttractionDataPanel(elements_panel, event_handler, i);
			attraction_panel.setAttractionName(attraction_names[i]);
			attraction_panel.setAttractionDescription(attraction_descs[i]);
			elements_panel.insertComponent(attraction_panel);
		}
	}

	/**
	 * Pobranie idnetyfikatora miejscowości
	 * */
	public int getLocalityId(){
		return Integer.parseInt(locality_id);
	}
}