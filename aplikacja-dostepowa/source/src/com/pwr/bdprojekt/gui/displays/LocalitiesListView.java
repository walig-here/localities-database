package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Wyświetla pobrane z bazy dane nt miejscowości. Pozwala użytkownikom na dalsze interakcje z miejscowościami.
 * Dane dla metody refresh():
 * [0] 		login aktualnego użytkownika
 * [1] 		rola aktualnego użytkownika
 * [2] 		lista 2-elementowa z minimalną i maksymalną liczbą atrakcji (oddzielone przecinkami)
 * [3] 		lista 2-elementowa z minimalną i maksymalną populacją (oddzielone przecinkami)
 * [4] 		lista nazw wszystkich dostępnych w bazie typów miejscowości (posorotwana względem id), oddzielana przecinkami
 * [5] 		lista identyfikatorów typów miejscowości, po których odbywa się filtrowanie, oddzielana przecinakami
 * [6] 		lista nazw wszystkich dostępnych w bazie typów atrakcji (posrotowana względem id), oddzielana przecinkami
 * [7] 		lista identyfikatorów typów atrakcji, po których odbywa się filtrowanie, oddzielana przecinkami
 * [8] 		lista nazw wszystkich dostępnych w bazie województw (posortowana względem id), oddzielana przecinkami
 * [9] 		lista numerów porządkowych województw, po których odbywa się filtrowanie, oddzielana przecinkami
 * [10] 	lista nazw wszystkich powiatów podlegających pod wybrane województwa (posortowana względem id), oddzielana przecinkami
 * [11] 	lista numerów porządkowych powiatów, po których odbywa się filtrowanie, oddzielana przecinkami
 * [12] 	lista nazw wszystkich gmin podlegających pod wybrane powiaty (posortowana względem id), oddzielana przecinkami
 * [13] 	lista numerów porządkowych gmin, po których odbywa się filtrowanie, oddzielana przecinkami
 *
 * [14..n] 	lista danych miejscowości, które mają być wypisane na liście. Układ pól danych miejscowości to:
 * 			[id];[nazwa];[typ];[województwo, powiat, gmina];[liczba ludności];[liczba atrakcji];[czy ulubiona]
 * */
public class LocalitiesListView extends View {

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
	 * Przycisk filtrowania
	 * */
	private Button filter_button;

	/**
	 * Przycisk sortowania
	 * */
	private Button sort_button;

	/**
	 * Przycisk dodania miejscowości
	 * */
	private Button add_locality_button;

	/**
	 * Elementy listy miejscowości
	 * */
	private List<LocalityListElement> locality_data_panels = new ArrayList<>();

	/**
	 * Dame nt filtrowania
	 * */
	private String[] filtering_data;

	/**
	 * Odbiorca zdarzeń z widoku
	 * */
	private EventHandler event_handler;

	/**
	 * Czy widok jest w trybie administracyjnym
	 * */
	private boolean administrative_mode;

//======================================================================================================================
// METODY

	public LocalitiesListView(JFrame parent, EventHandler eventHandler, boolean administrative_view) {
		super(parent,false, eventHandler);
		this.event_handler = eventHandler;
		this.administrative_mode = administrative_view;

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Lista miejscowości");
		elements_panel.setScrollableVertically(true);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk filtrowania
		filter_button = new Button(
			buttons_panel,
			"Filtruj",
			EventCommand.openFilterLocalityView,
			eventHandler
		);
		buttons_panel.insertComponent(filter_button);

		// przycisk sortowania
		sort_button = new Button(
			buttons_panel,
			"Sortuj",
			EventCommand.openSortLocalityView,
			eventHandler
		);
		buttons_panel.insertComponent(sort_button);

		if(administrative_view){
			add_locality_button = new Button(
				buttons_panel,
				"Dodaj miejscowość",
				EventCommand.addNewLocality,
				eventHandler
			);
			buttons_panel.insertComponent(add_locality_button);
		}

		// rozrysowanie elementów na oknie
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

		// dane nt. filtrowania
		filtering_data = Arrays.copyOfRange(data, 2, 15);

		// dane nt miejscowości
		locality_data_panels.clear();
		elements_panel.removeAllComponents();
		for(int i = 14; i < data.length; i++){
			String[] locality_data = data[i].split(";");
			LocalityListElement locality_panel = new LocalityListElement(elements_panel, administrative_mode, Integer.parseInt(locality_data[0]), event_handler);

			locality_panel.setLocalityName(locality_data[1]);
			locality_panel.setLocalityType(locality_data[2]);
			locality_panel.setAdministrativeData(locality_data[3]);
			locality_panel.setPopulationData(locality_data[4]);
			locality_panel.setNumberOfAttractions(locality_data[5]);
			locality_panel.setFavouriteIcon(Boolean.parseBoolean(locality_data[6]));

			locality_data_panels.add(locality_panel);
			elements_panel.insertComponent(locality_panel);
		}
	}

	/**
	 * Pobranie danych filtrowania
	 * */
	public String[] getFilteringData(){
		return filtering_data;
	}
}