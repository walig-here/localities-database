package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;

/**
 * Element listy miejscowości. Przedstawia podstawowe dane nt miejscowości i pozwala użytkownikowi na dalsze
 * interakcje z miejscowością.
 * */
public class LocalityListElement extends GuiComponent {

//======================================================================================================================
// STAŁE

	public static final String LOCALITY_TYPE_DATA_HEADER = "Typ miejscowości:\t";
	public static final String ADMINSTRATIVE_DATA_HEADER = "Przydział administracyjny:\t";
	public static final String POPULATION_DATA_HEADER = "Liczba ludności:\t";
	public static final String NUMER_OF_ATTRACTION_DATA_HEADER = "Liczba atrakcji:\t\t";

//======================================================================================================================
// POLA

	/**
	 * Panel z elementami
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Ikona ulubionych
	 * */
	private Picture favourite_icon;

	/**
	 * Dane o typie miejscowości
	 * */
	private Text locality_type;

	/**
	 * Dane o przydziale administracyjnym
	 * */
	private Text administrative_data;

	/**
	 * Dane o liczbie ludności
	 * */
	private Text population;

	/**
	 * Dane o liczbie atrakcji
	 * */
	private Text number_of_attractions;

	/**
	 * Panel przycisków
	 * */
	private HorizontalComponentsStrip buttons_panel;

	/**
	 * Przycisk otworzenia szczegółów
	 * */
	private Button open_locality_view_button;

	/**
	 * Przycisk edycji miejscowości
	 * */
	private Button edit_button;

	/**
	 * Przycisk usunięcia miejscowości
	 * */
	private Button delete_button;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nowy element interfejsu w ramach wskazanego panelu
	 * @param enable_admin_tools czy mają być widoczne elementy do zarządzania miejscowością
	 */
	public LocalityListElement(JPanel parent, boolean enable_admin_tools, int locality_index, EventHandler eventHandler) {
		super(parent);

		// panel elementów
		elements_panel = new PanelWithHeader(this, "element listy miejscowości");
		elements_panel.setScrollableVertically(false);
		elements_panel.setBorderVisibility(true);

		// ikona ulubionych
		favourite_icon = new Picture(elements_panel, "not_fav.png");
		elements_panel.insertComponent(favourite_icon);

		// typ miejscowości
		locality_type = new Text(elements_panel, LOCALITY_TYPE_DATA_HEADER, 1);
		elements_panel.insertComponent(locality_type);

		// przydział administracyjny
		administrative_data = new Text(elements_panel, ADMINSTRATIVE_DATA_HEADER, 1);
		elements_panel.insertComponent(administrative_data);

		// populacja
		population = new Text(elements_panel, POPULATION_DATA_HEADER, 1);
		elements_panel.insertComponent(population);

		 // liczba atrakcji
		number_of_attractions = new Text(elements_panel, NUMER_OF_ATTRACTION_DATA_HEADER, 1);
		elements_panel.insertComponent(number_of_attractions);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(buttons_panel);

		// przycisk szczegółó miejscowości
		open_locality_view_button = new Button(
			buttons_panel,
			"Szczegóły...",
			EventCommand.openLocalityView + Integer.toString(locality_index),
			eventHandler
		);
		buttons_panel.insertComponent(open_locality_view_button);

		// WIDOK ADMINSTRATORA
		if(enable_admin_tools){
			// przycisk edycji
			edit_button = new Button(
				buttons_panel,
				"Edytuj",
				EventCommand.openLocalityEditor+locality_index,
				eventHandler
			);
			buttons_panel.insertComponent(edit_button);

			// przycisk usunięcia
			delete_button = new Button(
				buttons_panel,
				"Usuń",
				EventCommand.deleteLocality+locality_index,
				eventHandler
			);
			buttons_panel.insertComponent(delete_button);
		}

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		// panel przycisków
		buttons_panel.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, 0);
		elements_panel.setSizeOfElement(
				getWidth(),
				getHeight()
		);

		// rozmiar
		final int HEIGHT = 	35+
							favourite_icon.getHeight()+
							8*VerticalComponentsStrip.SEPARATOR+
							locality_type.getHeight()+
							administrative_data.getHeight()+
							population.getHeight()+
							number_of_attractions.getHeight()+
							Text.LETTER_HEIGHT;
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
	 * Ustalenie nazwy miejscowości
	 * */
	public void setLocalityName(String name){
		elements_panel.setHeaderText(name);
	}

	/**
	 * Ustalenie typu miejscowości
	 * */
	public void setLocalityType(String type_name){
		locality_type.setText(LOCALITY_TYPE_DATA_HEADER+type_name);
	}

	/**
	 * Ustalenie danych adnimistracyjnych
	 * */
	public void setAdministrativeData(String administrative_data){
		this.administrative_data.setText(ADMINSTRATIVE_DATA_HEADER+administrative_data);
	}

	/**
	 * Ustalenie populacji
	 * */
	public void setPopulationData(String population){
		this.population.setText(POPULATION_DATA_HEADER+population);
	}

	/**
	 * Ustalenie liczby atrakcji
	 * */
	public void setNumberOfAttractions(String number_of_attractions){
		this.number_of_attractions.setText(NUMER_OF_ATTRACTION_DATA_HEADER+number_of_attractions);
	}

	/**
	 * Ustalenie czy atrakcja jest ulubiona
	 * */
	public void setFavouriteIcon(boolean active){
		if(active)
			favourite_icon.loadImage("fav.png");
		else
			favourite_icon.loadImage("not_fav.png");
	}
}