package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;

/**
 * Dowolny element GUI.
 * */
public abstract class GuiComponent extends JPanel {

//======================================================================================================================
// POLA

	/**
	 * Panel lub element GUI, wewnątrz którego znajduje się ten element GUI.
	 * */
	protected JPanel parent;

//======================================================================================================================
// POLA

	/**
	 * Tworzy nowy element GUI.
	 * @param parent panel lub element GUI, wewnątrz którego ma być umieszczony tworzony element GUI
	 */
	public GuiComponent(JPanel parent) {
		parent.add(this);
		this.parent = parent;
	}

	/**
	 * Przeniesienie elementu do wnętrza innego elementu GUI lub panelu.
	 * @param parent panel lub element GUI, wewnątrz którego ma być umieszczony ten element GUI
	 * */
	public void moveTo(JPanel parent) {
		this.parent.remove(this);
		this.parent = parent;
		this.parent.add(this);
	}

	/**
	 * Ustalenie pozycji elementu w odniesieniu do rodzica.
	 * @param x pozycja w poziomie
	 * @param y pozycja w pionie
	 * */
	public void setPosition(int x, int y){
		setBounds(x, y, getWidth(), getHeight());
		redraw();
	}

	/**
	 * Ustalenie rozmiaru elementu.
	 * @param width szerokość elementu
	 * @param height wysokość elementu
	 * */
	public void setSizeOfElement(int width, int height)
	{
		setBounds(getX(), getY(), width, height);
		setPreferredSize(new Dimension(width, height));
		redraw();
	}

	/**
	 * Pobranie pozycji dolnej krawędzi elementu.
	 * */
	public int getBottomY()
	{
		return getY()+getHeight();
	}

	/**
	 * Pobranie pozycji prawej krawędzi elementu.
	 * */
	public int getRightX()
	{
		return getX()+getWidth();
	}

	/**
	 * Odświeża element GUI. Na proces odświeżania składa się zaktualizowanie danych przedstawionych na elemencie oraz
	 * zaktualizowanie jego wyglądu (ponowne przeliczenie pozycji i rozmiaru).
	 * @param data zbiór zaktualizowanych danych, których skład różni się w zależności od implementacji elementu GUI
	 */
	public void refresh(String[] data){
		redraw();
		updateData(data);
	}

	/**
	 * Odświeżenie wyglądu elementu GUI. Ponowne przeliczenie pozycji, rozmiaru oraz rozmieszczenia elementów.
	 * */
	protected abstract void redraw();

	/**
	 * Odświeżenie danych przedstawionych na elemencie GUI.
	 * @param data zbiór zaktualizowanych danych, których skład różni się w zależności od implementacji elementu GUI
	 * */
	protected abstract void updateData(String[] data);

}