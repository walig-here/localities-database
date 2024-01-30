package com.pwr.bdprojekt.gui.components;

public abstract class GuiCompoment {

	/**
	 * 
	 * @param w
	 * @param h
	 */
	public abstract void setSize(int w, int h);

	/**
	 * 
	 * @param x
	 * @param y
	 */
	public abstract void setPosition(int x, int y);

	/**
	 * 
	 * @param String
	 */
	public abstract void refresh(String[] String);

}