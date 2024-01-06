package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class LocalitiesListView extends View {

	private PanelWithHeader localities_list;
	private LocalityListElement[] localities;

	public LocalitiesListView(JFrame parent) {
		super(parent,false);
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}