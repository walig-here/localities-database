package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class AddressEditorView extends View {

	/* DANE */
	private String locality_id;					// id lokalizacji, w ramach której znajduje się edytowany adres
	private String attraction_id;				// id atrakcji, która zostanie przypisana do adresu

	/* ELEMENTY GUI */
	private PanelWithHeader address_attributes;	// panel z atrybutami adresu

	public AddressEditorView(JFrame parent) {
		super(parent, false, null);
		address_attributes = new PanelWithHeader(main_panel, "Edytor...");
	}

	public String getLocalityId() {
		// TODO - implement AddressEditorView.getLocalityId
		throw new UnsupportedOperationException();
	}

	public String getAttractionId() {
		// TODO - implement AddressEditorView.getAttractionId
		throw new UnsupportedOperationException();
	}

	public String[] getAddress() {
		// TODO - implement AddressEditorView.getAddress
		throw new UnsupportedOperationException();
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}