package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;

/**
 * Panel przedstawiający przypisaną do atrakcji ilustrację
 * */
public class AttractionFigurePanel extends GuiComponent {

//======================================================================================================================
// POLA

	/**
	 * Panel elementów
	 * */
	private VerticalComponentsStrip elements_panel;

	/**
	 * Obrazek
	 * */
	private Picture figure;

	/**
	 * Edytowalny podpis obrazka
	 * */
	private TextField caption_edit;

	/**
	 * Niedytowalny podpis obrazka
	 * */
	private Text caption;

	/**
	 * Panel z przyciskami zarządczymi
	 * */
	private HorizontalComponentsStrip buttons_panel;

	/**
	 * Przycisk zapisania podpisu
	 * */
	private Button modify_caption_button;

	/**
	 * Przycisk usunięcie przypisania obrazka do atrakcji
	 * */
	private Button unassign_button;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nowy panel przedstawiający przypisaną do atrakcji ilustrację.
	 * @param path ścieżka do pliku z obrazkiem
	 * @param administrative_view czy mają być widoczne opcje zarządzania ilustracją?
	 * @param figure_index numer porządkowy obrazka pośród obrazków przypisanych do atrakcji
	 */
	public AttractionFigurePanel(JPanel parent, String path, boolean administrative_view, EventHandler event_handler, String figure_index) {
		super(parent);

		// panel elementów
		elements_panel = new VerticalComponentsStrip(this);
		elements_panel.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		elements_panel.setBackground(Color.white);

		// obrazek
		figure = new Picture(this, path);
		elements_panel.insertComponent(figure);

		if(administrative_view){
			// podpis
			caption_edit = new TextField(this, "Podpis ilustracji", "", 4);
			caption_edit.setResetable(true);
			elements_panel.insertComponent(caption_edit);

			// panel przycisków
			buttons_panel = new HorizontalComponentsStrip(this);
			elements_panel.insertComponent(buttons_panel);

			// przycisk modyfikacji podpisu
			modify_caption_button = new Button(
				this,
				"Zapisz podpis",
				EventCommand.modifyCaptionOfFigureAssignToAttraction + figure_index,
				event_handler
			);
			buttons_panel.insertComponent(modify_caption_button);

			// przycisk usunięcia przypisania
			unassign_button = new Button(
				this,
				"Usuń przypisanie",
				EventCommand.unassignFigureFromAttraction + figure_index,
				event_handler
			);
			buttons_panel.insertComponent(unassign_button);
		}
		else {
			caption = new Text(this, "", 4);
			elements_panel.insertComponent(caption);
		}

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		if(buttons_panel != null){
			// panel przycisków
			buttons_panel.setSizeOfElement(-1, Text.LETTER_HEIGHT);
		}

		// panel elementów
		elements_panel.setPosition(0, 0);
		elements_panel.setSizeOfElement(getWidth(), figure.getHeight());

		// rozmiar elementu
		setBounds(getX(), getY(), getWidth(), elements_panel.getHeight());
	}

	@Override
	protected void updateData(String[] data) {

	}

	/**
	 * Ustalenie podpisu atrakcji
	 * */
	public void setCaption(String caption){
		if(caption_edit != null){
			this.caption_edit.setDefaultValue(caption, this.caption_edit.getText().equals(""));
		}
		else if(caption != null){
			this.caption.setText(caption);
		}
	}
}