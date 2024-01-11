package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;

/**
 * Pasek wyświetlający dane adresowe. Posiada przycisk, do którego można przypisać dowolną komendę systemu zdarzeń.
 * */
public class AddressBar extends GuiComponent {

//======================================================================================================================
// STAŁE

	public static final int BUTTON_W = 250;

//======================================================================================================================
// POLA

	/**
	 * Dane adresowe
	 * */
	private Text address_data;

	/**
	 * Przycisk
	 * */
	private Button button;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nowy pasek adresowy
	 */
	public AddressBar(JPanel parent, EventHandler event_handler, String button_label, String button_command) {
		super(parent);
		setBackground(Color.WHITE);
		setBorder(BorderFactory.createLineBorder(Color.BLACK));

		// dane adresowe
		address_data = new Text(this, "adres", 1);

		// przycisk
		button = new Button(
			this,
			button_label,
			button_command,
			event_handler
		);

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		// dane adresowe
		address_data.setPosition(1, 2);
		address_data.setSizeOfElement(getWidth()-BUTTON_W-PanelWithHeader.S-1, address_data.getHeight());

		// przycisk
		button.setPosition(address_data.getRightX()+PanelWithHeader.S, 0);
		button.setSizeOfElement(BUTTON_W, address_data.getHeight()+4);

		// rozmiar elementu
		setBounds(getX(), getY(), getWidth(), address_data.getHeight()+4);
	}

	@Override
	protected void updateData(String[] data) {

	}

	/**
	 * Ustala dane adresowe
	 * */
	public void setAddressData(String address){
		address_data.setText(address);
	}
}