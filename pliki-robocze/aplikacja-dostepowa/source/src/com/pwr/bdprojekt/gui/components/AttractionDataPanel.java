package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;

public class AttractionDataPanel extends GuiComponent {

//======================================================================================================================
// POLA

	/**
	 * Panel elementów
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Opis atrakcji
	 * */
	private Text description;

	/**
	 * Przycisk pzypisania
	 * */
	private Button assign_button;

//======================================================================================================================
// METODY

	public AttractionDataPanel(JPanel parent, EventHandler eventHandler, int attraction_index) {
		super(parent);

		// panel elementów
		elements_panel = new PanelWithHeader(this, "atrakcja...");
		elements_panel.setScrollableVertically(false);
		elements_panel.setBorderVisibility(true);

		// opis
		description = new Text(elements_panel, "Opis", 5);
		elements_panel.insertComponent(description);

		// przycisk przypisania
		assign_button = new Button(
				elements_panel,
				"Przypisz",
				EventCommand.assignAttractionToLocality+attraction_index,
				eventHandler
		);
		elements_panel.insertComponent(assign_button);

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	public void setAttractionName(String name){
		elements_panel.setHeaderText(name);
	}

	public void setAttractionDescription(String desc){
		description.setText(desc);
	}

	@Override
	protected void redraw() {
		// przycisk przypisania
		assign_button.setSizeOfElement(100, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, 0);
		elements_panel.setSizeOfElement(
				getWidth(),
				30+description.getHeight()+assign_button.getHeight()+3*PanelWithHeader.S
		);

		// rozmiar elementu
		setBounds(
				getX(),
				getY(),
				getWidth(),
				elements_panel.getHeight()
		);
	}

	@Override
	protected void updateData(String[] data) {

	}
}