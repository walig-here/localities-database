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

//======================================================================================================================
// ## METODY ##

	/**
	 * Tworzy pusty panel o określonym nagłówku.
	 * @param header treść nagłówka
	 */
	public PanelWithHeader(JPanel parent, String header) {
		super(parent);

		// Nagłówek
		this.header = new Text(this, header);
		elements_subpanel = new VerticalComponentsStrip(this);

		// Pod-panel elementów
		scroll = new JScrollPane(elements_subpanel);
		scroll.setBackground(Color.WHITE);
		scroll.setHorizontalScrollBarPolicy(HORIZONTAL_SCROLLBAR_NEVER);
		this.add(scroll);

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
		if(scrollable){
			scroll.setBorder(BorderFactory.createLineBorder(Color.BLACK));
			scroll.setVerticalScrollBarPolicy(VERTICAL_SCROLLBAR_ALWAYS);
		}
		else {
			scroll.setBorder(null);
			scroll.setVerticalScrollBarPolicy(VERTICAL_SCROLLBAR_NEVER);
		}
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
		scroll.setBounds(
				parent.getX()+S,
				header.getBottomY(),
				parent.getWidth()-2*S,
				parent.getHeight()-2*S-LABEL_H
		);

		// Ustalenie wymiarów panelu z komponentami składowymi
		elements_subpanel.setPosition(0, 0);
		elements_subpanel.setSizeOfElement(scroll.getWidth(), elements_subpanel.getHeight());
	}

	@Override
	protected void updateData(String[] data) {

	}
}