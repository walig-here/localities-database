package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class LocalityFilteringView extends View {

	private PanelWithHeader locality_filters_list;
	private TextField name;
	private TextFieldStrip number_of_attractions;
	private TextFieldStrip population;
	private MultiChoiceList locality_type_list;
	private MultiChoiceList attraction_types_list;
	private MultiChoiceList voivodships_list;
	private MultiChoiceList counties_list;
	private MultiChoiceList municipalities_list;

	public LocalityFilteringView(JFrame parent) {
		super(parent, false, null);
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}