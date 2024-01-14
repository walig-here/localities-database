package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ItemListener;

/**
 * Lista jednokrotnego wyboru.
 * */
public class SingleChoiceList extends GuiComponent {

//======================================================================================================================
// POLA

	/**
	 * Nagłowek listy
	 * */
	private Text header;

	/**
	 * Lista
	 * */
	private JComboBox<String> list;

	/**
	 * Przycisk resetu
	 * */
	private Button reset_button;

	/**
	 * Indeks domyślnie wybranej opcji z listy.
	 * */
	private int default_option_index;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nową listę jednokrotnego wyboru.
	 * @param parent panel lub element GUI, w kórym znajduje się lista
	 * @param header nagłówek listy
	 * @param default_option_index indeks domyślnie wybranej opcji z listy
	 * */
	public SingleChoiceList(JPanel parent, String header, int default_option_index) {
		super(parent);
		this.default_option_index = default_option_index;
		setBackground(Color.WHITE);

		// Nagłówek listy
		this.header = new Text(this, header, 1);

		// Lista
		list = new JComboBox<>();
		list.setBackground(Color.WHITE);
		add(list);

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	/**
	 * Ustalenie czy lista jest resetowalna
	 * */
	public void setResetable(boolean resetable) {
		if(resetable){
			reset_button = new Button(this, "Reset", a -> reset());
		}
		else
		{
			reset_button = null;
		}
	}

	public void reset() {
		list.setSelectedIndex(default_option_index);
	}

	@Override
	protected void redraw() {
		// nagłówek
		header.setPosition(0, 0);
		header.setSizeOfElement(getWidth(), header.getHeight());

		// Wariant z możliwością resetu
		if(reset_button != null){
			// lista
			list.setBounds(0,
					header.getBottomY(),
					getWidth()-TextField.RESET_BUTTON_WIDTH,
					20
			);

			// Przycisk
			reset_button.setPosition(list.getX()+list.getWidth(), list.getY());
			reset_button.setSizeOfElement(TextField.RESET_BUTTON_WIDTH, Text.LETTER_HEIGHT);
		}
		else {
			// lista
			list.setBounds(0, header.getBottomY(), getWidth(), 20);
		}

		// rozmiar
		setBounds(getX(), getY(), getWidth(), header.getHeight()+list.getHeight());
	}

	@Override
	protected void updateData(String[] data) {

	}

	/**
	 * Ustalenie elementów dostępnych do wyboru na liście
	 * @param elements elementy dostępne do wyboru na liście
	 * */
	public void setElements(String[] elements){
		list.removeAllItems();
		for (String element : elements) {
			list.addItem(element);
		}
	}

	/**
	 * Ustalenie elementu oznaczonego domyślnie na liscie jako wybrany
	 * @param index indeks wybranego elementu
	 * */
	public void setDefaultSelectedElement(String index){
		default_option_index = Integer.parseInt(index);
		list.setSelectedIndex(default_option_index);
	}

	/**
	 * Pobranie indeksu wybranego elementu
	 * */
	public int getSelectedIndex(){
		return list.getSelectedIndex();
	}

	/**
	 * Ustalenie procedury wykonującej się po zmianie opcji w menu
	 * */
	public void setProcedureForSelectionChange(ItemListener procedure){
		list.addItemListener(procedure);
	}
}