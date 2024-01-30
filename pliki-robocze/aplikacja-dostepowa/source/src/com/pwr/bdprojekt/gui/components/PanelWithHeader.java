package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;
import java.util.List;

import static javax.swing.ScrollPaneConstants.*;

/**
 * Panel z nagłówkiem, złożony z ułożonych pionowo elementów GUI. Składowe elementy GUI mają taką samą szerokość (równą
 * szerokości panelu), ale mogą mieć różne wysokości. Istnieje możliwość aktywowania skrolowania panelu w pionie.
 * */
public class PanelWithHeader extends GuiComponent {

//======================================================================================================================
// ## STAŁE ##

	/**
	 * Wysokość nagłówka panelu.
	 * */
	public final static int LABEL_H = 25;

	/**
	 * Rozmiar seperatora
	 * */
	public final static int S = 10;

	/**
	 * Szerokość paska sklorowania
	 * */
	public final static int SCROLLBAR_WIDTH = 19;

//======================================================================================================================
// ## POLA ##

	/**
	 * Nagłówek panelu
	 * */
	private final Text header;

	/**
	 * Element umożliwiający skrolowanie
	 * */
	private final JScrollPane scroll;

	/**
	 * Pod-panel zawierający ułożone jeden na drugim elementy GUI, które zawarte są na panelu.
	 * */
	private final VerticalComponentsStrip elements_subpanel;

	/**
	 * Informuje, czy panel jest skrolowalny w pionie
	 * */
	private boolean vertically_scrollable;

//======================================================================================================================
// ## METODY ##

	/**
	 * Tworzy pusty panel o określonym nagłówku.
	 * @param header treść nagłówka
	 */
	public PanelWithHeader(JPanel parent, String header) {
		super(parent);

		// Nagłówek
		this.header = new Text(this, header, 1);
		this.header.setBold(true);
		elements_subpanel = new VerticalComponentsStrip(this);

		// Pod-panel elementów
		scroll = new JScrollPane(elements_subpanel);
		scroll.setBackground(Color.WHITE);
		scroll.setHorizontalScrollBarPolicy(HORIZONTAL_SCROLLBAR_NEVER);
		scroll.setBorder(null);
		elements_subpanel.setBackground(Color.WHITE);
		this.add(scroll);
		vertically_scrollable = false;

		// Zatwierdzenie rozmieszczenia elementów
		setLayout(null);
		setBackground(Color.white);
	}

	/**
	 * Wstawia element GUI na spód panelu.
	 * @param component dodawany element
	 */
	public void insertComponent(GuiComponent component) {
		elements_subpanel.insertComponent(component);
	}

	/**
	 * Usunięcie wszystkich elementów GUI z panelu.
	 * */
	public void removeAllComponents() {
		elements_subpanel.removeAllComponents();
	}

	/**
	 * Pobranie wszystkich elementów GUI zawartych na panelu.
	 * */
	public List<GuiComponent> getAllComponents() {
		return elements_subpanel.getAllComponents();
	}

	/**
	 * Ustalenie, czy panel może być skrolowany w pionie.
	 * @param scrollable czy pasek może być skrolowany w pionie.
	 */
	public void setScrollableVertically(boolean scrollable) {
		vertically_scrollable = scrollable;
		if(vertically_scrollable){
			scroll.setBorder(BorderFactory.createLineBorder(Color.BLACK));
			scroll.setVerticalScrollBarPolicy(VERTICAL_SCROLLBAR_ALWAYS);
		}
		else {
			scroll.setBorder(null);
			scroll.setVerticalScrollBarPolicy(VERTICAL_SCROLLBAR_NEVER);
		}
	}

	/**
	 * Pobranie treści nagłówka
	 * */
	public String getHeaderText(){
		return header.getText();
	}

	/**
	 * Ustalenie treści nagłówka
	 * */
	public void setHeaderText(String text){
		header.setText(text);
	}

	/**
	 * Ustalenie widoczności granicy panelu
	 * */
	public void setBorderVisibility(boolean visible){
		if(visible)
			setBorder(BorderFactory.createLineBorder(Color.BLACK));
		else
			setBorder(null);
	}

	@Override
	protected void redraw() {
		// Ustalenie wymiarów nagłówka
		this.header.setPosition(S, S);
		this.header.setSizeOfElement(
				getWidth()-2*S,
				LABEL_H
		);

		// Ustalenie wymiarów panelu skrolowanego
		final int SCROLL_WIDTH = getWidth()-2*S;
		scroll.setBounds(
				getX()+S,
				header.getBottomY(),
				SCROLL_WIDTH,
				getHeight()-2*S-LABEL_H
		);

		// Ustalenie wymiarów panelu z komponentami składowymi
		elements_subpanel.setPosition(0, 0);
		elements_subpanel.setSizeOfElement(
				vertically_scrollable ? SCROLL_WIDTH - SCROLLBAR_WIDTH : SCROLL_WIDTH,
				elements_subpanel.getHeight()
		);
	}

	@Override
	protected void updateData(String[] data) {

	}
}