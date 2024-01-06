package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class LocalitySortingView extends View {

	private PanelWithHeader sorting_criteria_list;
	private SingleChoiceList name;
	private SingleChoiceList number_of_attractions;
	private SingleChoiceList population;

	public LocalitySortingView(JFrame parent) {
		super(parent, false);
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}