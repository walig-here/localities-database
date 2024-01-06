package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class LocalityEditorView extends View {

	private TextField name;
	private TextField desc;
	private TextField population;
	private SingleChoiceList type_list;
	private SingleChoiceList municipalities_list;
	private TextFieldStrip geographical_location;
	private PanelWithHeader locality_attributes_list;

	public LocalityEditorView(JFrame parent) {
		super(parent, false, null);
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}