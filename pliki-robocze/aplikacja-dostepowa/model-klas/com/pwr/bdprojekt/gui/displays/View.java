package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

public abstract class View {

	private Topbar topbar;

	/**
	 * 
	 * @param data
	 */
	public abstract void refresh(String[] data);

}