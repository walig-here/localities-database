package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozwalający na edytowanie danych atrakcji. Dane dla funkcji refresh:
 * [0] - login aktualnego użytkownika
 * [1] - rola aktualnego użytkownika
 * [2] - id edytowanej atrakcji
 * [3] - nazwa edytowanej atrakcji
 * [4] - opis edytowanej atrakcji
 * [5] - lista nazw wszystkich typów atrakcji dostępnych w bazie (posortowanych względem id) oddzielonych przecinkami: "abc","def","ghi"
 * [6] - lista identyfikatorów typów atrakcji przypisanych do atrakcji oddzielonych przecinkami: "1","2","3"
 * [7] - lista adresów przypisanych do atrakcji posortowana względem id oddzielonych średnikami: "abc";"def";"ghi"
 * [8] - lista ścieżek do obrazków przypisanych do atrakcji posorotwana względem id oddzielonych przecinkami: "abc","def","ghi"
 * [9] - lista opisów do obrazków przypisanych do atrakcji posortowana względem id oddzielonych średnikami: "abc";"def";"ghi"
 * [10] - identyfikator miejscowości, z której danych dotarto do tej atrakcji
 * */
public class AttractionEditorView extends View {

//======================================================================================================================
// POLA

	/**
	 * Identyfikatora edytowanej w widoku atrakcji
	 * */
	private String attraction_id;

	/**
	 * Identyfikator miejscowości, z której dotarto do tej atrackji
	 * */
	private String locality_id;

	/**
	 * Panel zawierający elementy edytora
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Przycisk powrotu do widoku atrakcji
	 * */
	private Button back_button;

	/**
	 * Pole do edytowania nazwy atrakcji
	 * */
	private TextField name;

	/**
	 * Pole do edytowania opisu atrakcji
	 * */
	private TextField description;

	/**
	 * Lista do wyboru typu atrakcji
	 * */
	private MultiChoiceList attraction_type;

	/**
	 * Przycisk zapisania danych podstawowych
	 * */
	private Button save_base_data_button;

	/**
	 * Panel z adresami atrakcji
	 * */
	private PanelWithHeader address_panel;

	/**
	 * Adresy atrakcji
	 * */
	private List<AddressBar> addresses = new ArrayList<>();

	/**
	 * Odniesienie do mechanizmu kontroli zdarzeń
	 * */
	private EventHandler eventHandler;

	/**
	 * Panel ilustacji
	 * */
	private PanelWithHeader figures_panel;

	/**
	 * Ilustracje
	 * */
	private List<AttractionFigurePanel> pictures = new ArrayList<>();

	/**
	 * Przycisk przypisania ilustracji
	 * */
	private Button assign_figure_button;

	/**
	 * Przycisk przypisania typów do atrakcji
	 * */
	private Button assignTypesButton;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nowy panel edytora atrakcji.
	 * */
	public AttractionEditorView(JFrame parent, EventHandler event_handler) {
		super(parent, false, event_handler);
		this.eventHandler = event_handler;

		// Panel z elementami edytora
		elements_panel = new PanelWithHeader(main_panel, "Edytor atrakcji");
		elements_panel.setScrollableVertically(true);

		// Przycisk powrotu do widoku danych atrakcji
		back_button = new Button(
				main_panel,
				"Powrót",
				EventCommand.openAttractionView,
				event_handler
		);

		// Nazwa atrakcji
		name = new TextField(elements_panel, "Nazwa atrakcji", "", 1);
		name.setResetable(true);
		elements_panel.insertComponent(name);

		// Opis atrakcji
		description = new TextField(elements_panel, "Opis atrakcji", "", 10);
		description.setResetable(true);
		elements_panel.insertComponent(description);

		// Przycisk zapisu danych bazowych
		save_base_data_button = new Button(
				elements_panel,
				"Zapisz dane bazowe atrakcji",
				EventCommand.modifyBaseAttractionData,
				event_handler
		);
		save_base_data_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);
		elements_panel.insertComponent(save_base_data_button);

		// Typ atrakcji
		attraction_type = new MultiChoiceList(elements_panel, "Typy atrakcji", new int[0], 5);
		attraction_type.setResetable(true);
		elements_panel.insertComponent(attraction_type);

		// przycisk typów
		assignTypesButton = new Button(
			elements_panel,
			"Przypisz typy do atrakcji",
			EventCommand.assignTypesToAttraction,
			event_handler
		);
		assignTypesButton.setSizeOfElement(-1, Text.LETTER_HEIGHT);
		elements_panel.insertComponent(assignTypesButton);

		// Panel adresów
		//address_panel = new PanelWithHeader(elements_panel, "Adresy atrakcji");
		//address_panel.setScrollableVertically(true);
		//elements_panel.insertComponent(address_panel);

		// Panel ilustracji
		//figures_panel = new PanelWithHeader(elements_panel, "Ilustracje atrakcji");
		//figures_panel.setScrollableVertically(true);
		//elements_panel.insertComponent(figures_panel);

		// Przycisk przypisania ilustracji
		//assign_figure_button = new Button(
		//	main_panel,
		//	"Przypisz nową ilustrację",
		//	EventCommand.openAssignAttractionToFigure,
		//	event_handler
		//);
		//figures_panel.insertComponent(assign_figure_button);

		redraw();
	}

	@Override
	protected void redraw() {
		// Przycisk przypisania ilustracji
		//assign_figure_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// Panel ilustracji
		//figures_panel.setSizeOfElement(-1, 600);

		// Panel adresów
		//address_panel.setSizeOfElement(-1, 120);

		// Panel z elementami
		elements_panel.setPosition(0,topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-Text.LETTER_HEIGHT-PanelWithHeader.S/2
		);

		// Przycisk powrotu
		final int BACK_BTN_W = 100;
		back_button.setPosition(main_panel.getWidth()/2-BACK_BTN_W/2, elements_panel.getBottomY());
		back_button.setSizeOfElement(BACK_BTN_W, Text.LETTER_HEIGHT);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// dane bazowe
		attraction_id = data[2];
		name.setDefaultValue(data[3], name.getText().equals(""));
		description.setDefaultValue(data[4], description.getText().equals(""));

		// typy
		attraction_type.setElements(data[5].split(","));
		attraction_type.setDefaultSelectedElements(data[6].split(","));

		locality_id = data[10];

		if(figures_panel == null)
			return;

		// adresy
		address_panel.removeAllComponents();
		addresses.clear();
		String[] new_addresses = data[7].split(";");
		if(!new_addresses[0].isEmpty()){
			for (int i = 0; i < new_addresses.length; i++) {
				AddressBar addressBar = new AddressBar(
						address_panel,
						eventHandler,
						"Usuń przypisanie",
						EventCommand.unassignAddressFromAttraction + i
				);
				addressBar.setAddressData(new_addresses[i]);
				address_panel.insertComponent(addressBar);
				addresses.add(addressBar);
			}
		}

		// obrazki
		figures_panel.removeAllComponents();
		figures_panel.insertComponent(assign_figure_button);
		pictures.clear();
		String[] new_figures = data[8].split(",");
		String[] new_figures_desc = data[9].split(";");
		for (int i = 0; i < new_figures.length; i++) {
			AttractionFigurePanel figurePanel = new AttractionFigurePanel(
					figures_panel,
					new_figures[i],
					true,
					eventHandler,
					Integer.toString(i)
			);
			figurePanel.setCaption(new_figures_desc[i]);
			figures_panel.insertComponent(figurePanel);
			pictures.add(figurePanel);
		}
	}

	public int getLocalityId(){
		return Integer.parseInt(locality_id);
	}

	/**
	 * Pobranie id atrakcji
	 * */
	public int getAttractionId(){
		return Integer.parseInt(attraction_id);
	}

	/**
	 * Pobranie nazwy atrakcji
	 * */
	public String getAttractionName(){
		return name.getText();
	}

	/**
	 * Pobranie opisu atrakcji
	 * */
	public String getAttractionDesc(){
		return description.getText();
	}

	/**
	 * Pobranie listy identyfikatorów wybranych typów atrakcji
	 * */
	public int[] getAttractionTypesIds(){
		return attraction_type.getSelectedIndices();
	}
}