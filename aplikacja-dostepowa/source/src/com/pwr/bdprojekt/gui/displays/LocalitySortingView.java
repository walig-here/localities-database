package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok pozwalający na ustalenie kryteriów sortowania listy miejscowości. Dane dla refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] indeks opcji sortowania nazw miejscowości
 * [3] indeks opcji sortowania po liczbie atrakcji
 * [5] indeks opcji sortowania po populacji
 **/
public class LocalitySortingView extends View {

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
	 * Przycisk sortowania
	 * */
	private Button sort_button;

	/**
	 * Przycisk resetu
	 * */
	private Button reset_button;

	/**
	 * Nazwa
	 * */
	private SingleChoiceList name;

	/**
	 * Liczba atrakcji
	 * */
	private SingleChoiceList number_of_attractions;

	/**
	 * Populacja
	 * */
	private SingleChoiceList population;

//======================================================================================================================
// METODY

	public LocalitySortingView(JFrame parent, EventHandler eventHandler) {
		super(parent, false, eventHandler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Kryteria sortowania miejscowości");
		elements_panel.setScrollableVertically(true);

		// panel przycisków
		buttons_panel = new HorizontalComponentsStrip(main_panel);

		// przycisk sortowania
		sort_button = new Button(
				buttons_panel,
				"Sortuj",
				EventCommand.applySortingForLocalities,
				eventHandler
		);
		buttons_panel.insertComponent(sort_button);

		// przycisk resetu
		reset_button = new Button(
				buttons_panel,
				"Resetuj sortowanie",
				a -> resetAll()
		);
		buttons_panel.insertComponent(reset_button);

		// nazwa
		name = new SingleChoiceList(elements_panel, "Nazwa miejscowości", 0);
		name.setElements(new String[]{
				"",
				"Od A do Z",
				"Od Z do A"
		});
		name.setResetable(true);
		elements_panel.insertComponent(name);

		// liczba atrakcji
		number_of_attractions = new SingleChoiceList(elements_panel, "Liczba atrakcji", 0);
		number_of_attractions.setElements(new String[]{
				"",
				"Rosnąco",
				"Malejąco"
		});
		number_of_attractions.setResetable(true);
		elements_panel.insertComponent(number_of_attractions);

		// populacja
		population = new SingleChoiceList(elements_panel, "Populacja", 0);
		population.setElements(new String[]{
				"",
				"Rosnąco",
				"Malejąco"
		});
		population.setResetable(true);
		elements_panel.insertComponent(population);

		// rozmieszczenie elementów
		redraw();
	}

	public void resetAll(){
		name.reset();
		number_of_attractions.reset();
		population.reset();
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
		buttons_panel.setSizeOfElement(main_panel.getWidth(), Text.LETTER_HEIGHT);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// nazwa
		name.setDefaultSelectedElement(data[2]);

		// liczba atrakcji
		number_of_attractions.setDefaultSelectedElement(data[3]);

		// populacaja
		population.setDefaultSelectedElement(data[4]);
	}

	/**
	 * Pobranie sortowania nazwy
	 * */
	public int getNameSorting(){
		return name.getSelectedIndex();
	}

	/**
	 * Pobranie sortowania liczby atrakcji
	 * */
	public int getNumberOfAttractionSorting(){
		return number_of_attractions.getSelectedIndex();
	}

	/**
	 * Pobranie sortowania populacji
	 * */
	public int getPopulation(){
		return population.getSelectedIndex();
	}
}