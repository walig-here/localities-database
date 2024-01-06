package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;

public class PermissionInRegionEditorView extends View {

	private PanelWithHeader permission_in_region_attributes;
	private SingleChoiceList permission;
	private TextField desc;

	public PermissionInRegionEditorView(JFrame parent) {
		super(parent, false);
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {

	}
}