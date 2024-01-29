package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok pozwalający na edytowanie danych miejscowości. Dane dla funkcji refresh:
 * [0] - login aktualnego użytkownika
 * [1] - rola aktualnego użytkownika
 * [2] - id edytowanej miejscowości (-1, gdy nowa)
 * [3] - nazwa edytowanej miejscowości
 * [4] - opis edytowanej miejscowości
 * [5] - populacja edytowanej miejscowości
 * [6] - lista nazw wszystkich typów miejscowości dostępnych w bazie (porostowanych względem id) oddzielonych przecinkami: "abc","def","ghi"
 * [7] - identyfikator typu miejscowości przypisanego do edytowanej miejscowości
 * [8] - lista nazw wszystkich gmin dostępnych w bazie (porostowanych względem id) oddzielonych przecinkami: "abc","def","ghi"
 * [9] - numer porządkowy gminy przypisanej do edytowanej miejscowości (która z kolei jest to gmina w bazie)
 * [10] - szerokość geograficzna miejscowości
 * [11] - długość geograficzna miejscowości
 * */
public class LocalityEditorView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel z elementami edytora
	 */
	private PanelWithHeader elements_panel;

	/**
	 * Przycisk powrotu
	 * */
	private Button back_button;

	/**
	 * Identyfikator modyfikowanej miejscowości
	 * */
	private String locality_id;

	/**
	 * Pole z nazwą miejscowości
	 * */
	private TextField name;

	/**
	 * Pole z opisem miejscowości
	 * */
	private TextField description;

	/**
	 * Pole z populacją miejscowości
	 * */
	private TextField population;

	/**
	 * Lista typu miejscowości
	 * */
	private SingleChoiceList locality_type;

	/**
	 * Lista gmin
	 * */
	private SingleChoiceList municipality;

	/**
	 * Panel koordynatów
	 * */
	private HorizontalComponentsStrip coordinates_panel;

	/**
	 * Szerokość geograficzna
	 * */
	private TextField latitude;

	/**
	 * Długość geograficzna
	 * */
	private TextField longitude;

	/**
	 * Przycisk zapisania zmian
	 * */
	private Button apply_changes_button;

//======================================================================================================================
// METODY

	public LocalityEditorView(JFrame parent, EventHandler eventHandler) {
		super(parent, false, eventHandler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Edytor miejscowości");
		elements_panel.setScrollableVertically(true);

		// przycisk powrotu
		back_button = new Button(
			main_panel,
			"Powrót",
			EventCommand.openPreviousView,
			eventHandler
		);

		// nazwa miejscowości
		name = new TextField(elements_panel, "Nazwa miejscowości", "", 1);
		name.setResetable(true);
		elements_panel.insertComponent(name);

		// opis miejscowości
		description = new TextField(elements_panel, "Opis miejscowości", "", 10);
		description.setResetable(true);
		elements_panel.insertComponent(description);

		// populacja
		population = new TextField(elements_panel, "Populacja", "", 1);
		population.setResetable(true);
		elements_panel.insertComponent(population);

		// typ miejscowości
		locality_type = new SingleChoiceList(elements_panel, "Typ miejscowości", 0);
		locality_type.setResetable(true);
		elements_panel.insertComponent(locality_type);

		// gmina
		municipality = new SingleChoiceList(elements_panel, "Gmina", 0);
		municipality.setResetable(true);
		elements_panel.insertComponent(municipality);

		// szerokość geograficzna
		latitude = new TextField(elements_panel, "Szerokość geograficzna", "", 1);
		latitude.setResetable(true);
		elements_panel.insertComponent(latitude);

		// długośc geograficzna
		longitude = new TextField(elements_panel, "Długość geograficzna", "", 1);
		longitude.setResetable(true);
		elements_panel.insertComponent(longitude);

		// przycisk zatwierdzenia
		apply_changes_button = new Button(
				elements_panel,
				"Zatwierdź",
				EventCommand.modifyLocalityData,
				eventHandler
		);
		elements_panel.insertComponent(apply_changes_button);

		// rozmieszczenie elementów
		redraw();
	}

	@Override
	protected void redraw() {
		apply_changes_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-Text.LETTER_HEIGHT-PanelWithHeader.S
		);

		// przycisk powrotu
		back_button.setPosition(main_panel.getWidth()/2-50, elements_panel.getBottomY());
		back_button.setSizeOfElement(100, Text.LETTER_HEIGHT);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// id, nazwa, opis, populacja
		locality_id = data[2];
		name.setDefaultValue(data[3], name.getText().equals(""));
		description.setDefaultValue(data[4], description.getText().equals(""));
		population.setDefaultValue(data[5], population.getText().equals(""));

		// typ miejscowości
		String[] locality_types = data[6].split(",");
		locality_type.setElements(locality_types);
		locality_type.setDefaultSelectedElement(data[7]);

		// gmina
		String[] municiaplities = data[8].split(",");
		municipality.setElements(municiaplities);
		municipality.setDefaultSelectedElement(data[9]);

		// koordynaty
		latitude.setDefaultValue(data[10], latitude.getText().equals(""));
		longitude.setDefaultValue(data[11], longitude.getText().equals(""));
	}

	/**
	 * Pobranie identyfikatora miejscowości
	 * */
	public int getLocalityId(){
		return Integer.parseInt(locality_id);
	}

	/**
	 * Pobranie nazwy miejscowości
	 * */
	public String gerLocalityName(){
		return name.getText();
	}

	/**
	 * Pobranie opisu miejscowości
	 * */
	public String getLocalityDesc(){
		return description.getText();
	}

	/**
	 * Pobranie populacji
	 * */
	public int getPopulation(){
		try{
			return Integer.parseInt(population.getText());
		} catch (NumberFormatException e){
			return 0;
		}
	}

	/**
	 * Pobranie identyfikatora typu miejscowości
	 * */
	public int getLocalityTypeId(){
		return locality_type.getSelectedIndex();
	}

	/**
	 * Pobranie numeru porządkowego gminy
	 * */
	public int getLocalityMuniciaplityIndex(){
		return municipality.getSelectedIndex();
	}

	/**
	 * Pobranie szerokości geograficznej
	 * */
	public double getLatitude(){
		return Double.parseDouble(latitude.getText());
	}

	/**
	 * Pobranie długości geograficznej
	 * */
	public double getLongitude(){
		return Double.parseDouble(longitude.getText());
	}
}