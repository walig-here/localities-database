package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok pozwalający na ustalenie kryteriów filtrowania. Dane dla metody refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] aktualny filtr nazwy miejscowości,
 * [3] lista 2-elementowa z minimalną i maksymalną liczbą atrakcji (oddzielone przecinkami)
 * [4] lista 2-elementowa z minimalną i maksymalną populacją (oddzielone przecinkami),
 * [5] lista nazw wszystkich dostępnych w bazie typów miejscowości (posorotwana względem id), oddzielana przecinkami
 * [6] lista identyfikatorów typów miejscowości, po których odbywa się filtrowanie, oddzielana przecinakami
 * [7] lista nazw wszystkich dostępnych w bazie typów atrakcji (posrotowana względem id), oddzielana przecinkami
 * [8] lista identyfikatorów typów atrakcji, po których odbywa się filtrowanie, oddzielana przecinkami
 * [9] lista nazw wszystkich dostępnych w bazie województw (posortowana względem id), oddzielana przecinkami
 * [10] lista numerów porządkowych województw, po których odbywa się filtrowanie, oddzielana przecinkami
 * [11] lista nazw wszystkich powiatów podlegających pod wybrane województwa (posortowana względem id), oddzielana przecinkami
 * [12] lista numerów porządkowych powiatów, po których odbywa się filtrowanie, oddzielana przecinkami
 * [13] lista nazw wszystkich gmin podlegających pod wybrane powiaty (posortowana względem id), oddzielana przecinkami
 * [14] lista numerów porządkowych gmin, po których odbywa się filtrowanie, oddzielana przecinkami
 * */
public class LocalityFilteringView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel elementów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Nazwa miejscowości
	 * */
	private TextField name;

	/**
	 * Panel liczby atrakcji
	 * */
	private HorizontalComponentsStrip attraction_number_panel;

	/**
	 * Minimalna liczba atrakcji
	 * */
	private TextField minimal_attraction_number;

	/**
	 * Maksymalna liczba atrakcji
	 * */
	private TextField maximal_attraction_number;

	/**
	 * Panel populacji
	 * */
	private HorizontalComponentsStrip population_panel;

	/**
	 * Minimalna populacja
	 * */
	private TextField minimal_population;

	/**
	 * Maksymalna populacja
	 * */
	private TextField maximal_population;

	/**
	 * Typ miejscowości
	 * */
	private MultiChoiceList locality_type;

	/**
	 * Typy atrakcji
	 * */
	private MultiChoiceList attraction_type;

	/**
	 * Województwa
	 * */
	private MultiChoiceList voivodship;

	/**
	 * Powiaty
	 * */
	private MultiChoiceList county;

	/**
	 * Gminy
	 * */
	private MultiChoiceList municipality;

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

//======================================================================================================================
// METODY

	public LocalityFilteringView(JFrame parent, EventHandler event_handler) {
		super(parent, false, event_handler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Kryteria filtrowania miejscowości");
		elements_panel.setScrollableVertically(true);

		// nazwa
		name = new TextField(elements_panel, "Nazwa miejscowości", "", 1);
		name.setResetable(true);
		elements_panel.insertComponent(name);

		// panel liczby atrakcji
		attraction_number_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(attraction_number_panel);

		// minimalna liczba atrakcji
		minimal_attraction_number = new TextField(elements_panel, "Min. liczba atrakcji", "0", 1);
		minimal_attraction_number.setResetable(true);
		attraction_number_panel.insertComponent(minimal_attraction_number);

		// maksymalna liczba atrakcji
		maximal_attraction_number = new TextField(elements_panel, "Maks. liczba atrakcji", "", 1);
		maximal_attraction_number.setResetable(true);
		attraction_number_panel.insertComponent(maximal_attraction_number);

		// panel populacji
		population_panel = new HorizontalComponentsStrip(elements_panel);
		elements_panel.insertComponent(population_panel);

		// minimalna populacja
		minimal_population = new TextField(elements_panel, "Min. populacja", "0", 1);
		minimal_population.setResetable(true);
		population_panel.insertComponent(minimal_population);

		// maksymalna populacja
		maximal_population = new TextField(elements_panel, "Maks. populacja", "", 1);
		maximal_population.setResetable(true);
		population_panel.insertComponent(maximal_population);

		// typ miejscowości
		locality_type = new MultiChoiceList(elements_panel, "Typ miejscowości", new int[0], 5);
		locality_type.setResetable(true);
		elements_panel.insertComponent(locality_type);

		// typy atrakcji
		attraction_type = new MultiChoiceList(elements_panel, "Dostępne typy atrakcji", new int[0], 5);
		attraction_type.setResetable(true);
		elements_panel.insertComponent(attraction_type);

		// województwo
		voivodship = new MultiChoiceList(elements_panel, "Województwo", new int[0], 5);
		voivodship.setResetable(true);
		voivodship.setSelectionChangeCommand(EventCommand.localityVoivodshipFilterChanged, event_handler);
		elements_panel.insertComponent(voivodship);

		// powiaty
		county = new MultiChoiceList(elements_panel, "Powiat", new int[0], 5);
		county.setResetable(true);
		county.setSelectionChangeCommand(EventCommand.localityCountyFilterChanged, event_handler);
		elements_panel.insertComponent(county);

		// gminy
		municipality = new MultiChoiceList(elements_panel, "Gmina", new int[0], 5);
		municipality.setResetable(true);
		elements_panel.insertComponent(municipality);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk zatwierdzenia
		apply_filters_button = new Button(
				buttons_panel,
				"Zastosuj filtry",
				EventCommand.applyFiltersForLocalities,
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

		// rozmieszczenie elementów
		redraw();
	}

	private void resetAll(){
		name.reset();
		minimal_attraction_number.reset();
		maximal_attraction_number.reset();
		minimal_population.reset();
		maximal_population.reset();
		locality_type.reset();
		attraction_type.reset();
		voivodship.reset();
		county.reset();
		municipality.reset();
	}

	@Override
	protected void redraw() {
		// panel populacji
		population_panel.setSizeOfElement(elements_panel.getWidth(), minimal_population.getHeight());

		// panel liczby atrakcji
		attraction_number_panel.setSizeOfElement(elements_panel.getWidth(), minimal_attraction_number.getHeight());

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

		// nazwa
		name.setText(data[2]);

		// liczba atrakcji
		String[] attraction_number = data[3].split(",");
		minimal_attraction_number.setText(attraction_number[0]);
		maximal_attraction_number.setText(attraction_number[1]);

		// populacja
		String[] population = data[4].split(",");
		minimal_population.setText(population[0]);
		maximal_population.setText(population[1]);

		// typy miejscowości
		String[] available_locality_types = data[5].split(",");
		String[] selected_locality_type_ids = data[6].split(",");
		locality_type.setElements(available_locality_types);
		locality_type.setSelectedElements(selected_locality_type_ids);

		// typy atrakcji
		String[] available_attraction_types = data[7].split(",");
		String[] selected_attraction_type_ids = data[8].split(",");
		attraction_type.setElements(available_attraction_types);
		attraction_type.setSelectedElements(selected_attraction_type_ids);

		// województwa
		String[] available_voivodships = data[9].split(",");
		String[] selected_voivodships = data[10].split(",");
		voivodship.setElements(available_voivodships);
		voivodship.setSelectedElements(selected_voivodships);

		// powiaty
		String[] available_counties = data[11].split(",");
		String[] selected_counties = data[12].split(",");
		county.setElements(available_counties);
		county.setSelectedElements(selected_counties);

		// gminy
		String[] available_municipalities = data[13].split(",");
		String[] selected_municipalities = data[14].split(",");
		municipality.setElements(available_municipalities);
		municipality.setSelectedElements(selected_municipalities);
	}

	/**
	 * Pobranie nazwy
	 * */
	public String getLocalityName(){
		return name.getText();
	}

	/**
	 * Pobranie minimalnej liczby atrakcji
	 * */
	public int getMinimalNumberOfAttraction() throws NumberFormatException {
		return Integer.parseInt(minimal_attraction_number.getText());
	}

	/**
	 * Pobranie maksymalnej liczby atrakcji
	 * */
	public int getMaximalNumberOfAttraction() throws NumberFormatException {
		return Integer.parseInt(maximal_attraction_number.getText());
	}

	/**
	 * Pobranie minimalnej populacji
	 * */
	public int getMinimalPopulation() throws NumberFormatException {
		return Integer.parseInt(minimal_population.getText());
	}

	/**
	 * Pobranie maksymalnej populacji
	 * */
	public int getMaximalPopulation() throws NumberFormatException {
		return Integer.parseInt(maximal_population.getText());
	}

	/**
	 * Pobranie listy identyfikatorów wybranych typów miejscowości
	 * */
	public int[] getSelectedLocalityTypeIDs(){
		return locality_type.getSelectedIndices();
	}

	/**
	 * Pobranie listy identyfikatorów wybranych typów atrakcji
	 * */
	public int[] getSelectedAttractionTypeIDs(){
		return attraction_type.getSelectedIndices();
	}

	/**
	 * Pobranie listy numerów porządkowych wybranych województw
	 * */
	public int[] getSelectedVoivodshipIndices(){
		return voivodship.getSelectedIndices();
	}

	/**
	 * Pobranie listy numerów porządkowych powiatów
	 * */
	public int[] getSelectedCountyIndices(){
		return county.getSelectedIndices();
	}

	/**
	 * Pobranie listy numerów porządkowych gmin
	 * */
	public int[] getSelectedMunicipalityIndices(){
		return municipality.getSelectedIndices();
	}
}