package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemListener;

public class MultiChoiceList extends GuiComponent {

//======================================================================================================================
// POLA

	/**
	 * Indeksy domyślnie wybranyuch opcji z listy.
	 * */
	private int[] default_options_indices;

	/**
	 * Nagłówek listy
	 * */
	private Text header;

	/**
	 * Mechanizm skrolowania listy
	 * */
	private JScrollPane scroll;

	/**
	 * Lista
	 * */
	private JList<String> list;
	private DefaultListModel<String> list_data;

	/**
	 * Przycisk resetu
	 * */
	private Button reset_button;

//======================================================================================================================
// METODY

	/**
	 * Tworzy nową listę wielokrotnego wyboru.
	 * @param parent panel lub element GUI, w kórym znajduje się lista
	 * @param header nagłówek listy
	 * @param default_options_indices indeks domyślnie wybranej opcji z listy
	 * */
	public MultiChoiceList(JPanel parent, String header, int[] default_options_indices, int visible_options) {
		super(parent);
		setBackground(Color.white);

		// nagłówek
		this.header = new Text(this, header, 1);

		// lista
		list_data = new DefaultListModel<>();
		list = new JList<>(list_data);
		list.setVisibleRowCount(visible_options);
		list.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);

		// skroll
		scroll = new JScrollPane(list);
		scroll.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		scroll.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		add(scroll);

		// rozmieszczenie elementów
		setLayout(null);
		redraw();
	}

	@Override
	protected void redraw() {
		// nagłówek
		header.setPosition(0, 0);
		header.setSizeOfElement(getWidth(), header.getHeight());

		// Wariant z możliwością resetu
		if(reset_button != null){
			// lista
			list.setBounds(
					0,
					0,
					getWidth()-TextField.RESET_BUTTON_WIDTH,
					list.getModel().getSize()
			);

			// skroll
			scroll.setBounds(
					0,
					header.getBottomY(),
					getWidth()-TextField.RESET_BUTTON_WIDTH,
					list.getVisibleRowCount()*20
			);

			// Przycisk
			reset_button.setPosition(scroll.getX()+scroll.getWidth(), scroll.getY());
			reset_button.setSizeOfElement(TextField.RESET_BUTTON_WIDTH, Text.LETTER_HEIGHT);
		}
		else {
			// lista
			list.setBounds(0, 0, getWidth(), list.getModel().getSize());

			// skroll
			scroll.setBounds(0, header.getBottomY(), getWidth(), list.getVisibleRowCount()*20);
		}

		// całość
		setBounds(getX(), getY(), getWidth(), header.getHeight()+scroll.getHeight());
	}

	@Override
	protected void updateData(String[] data) {

	}

	/**
	 * Ustalenie, czy lista jest resetowalna
	 */
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
		list.setSelectedIndices(default_options_indices);
	}

	/**
	 * Ustalenie elementów dostępnych do wyboru na liście
	 * @param elements elementy dostępne do wyboru na liście
	 * */
	public void setElements(String[] elements){
		list_data.removeAllElements();
		for (String element : elements) {
			list_data.addElement(element);
		}
	}

	/**
	 * Ustalenie elementów oznaczonych domyślnie na liscie jako wybrane
	 * @param indices indeksy wybranych elementów
	 * */
	public void setDefaultSelectedElements(String[] indices){
		default_options_indices = new int[indices.length];
		for (int i = 0; i < indices.length; i++) {
			default_options_indices[i] = Integer.parseInt(indices[i]);
		}
		list.setSelectedIndices(default_options_indices);
	}

	/**
	 * Pobranie listy wybranych indeksów
	 * */
	public int[] getSelectedIndices(){
		return list.getSelectedIndices();
	}

	/**
	 * Ustalenie elementów oznaczonych jako wybrane
	 * @param indices indeksy wybranych elementów
	 * */
	public void setSelectedElements(String[] indices){
		int[] selected_indices = new int[indices.length];
		for(int i = 0; i < indices.length; i++){
			selected_indices[i] = Integer.parseInt(indices[i]);
		}
		list.setSelectedIndices(selected_indices);
	}

	/**
	 * Ustalenie komendy systemu zdarzeń i jej odbiorcy wysyłanej po zmianie wybranego elementu
	 * @param command treść komendy
	 * @param receiver odbiorca komendy
	 * */
	public void setSelectionChangeCommand(String command, ActionListener receiver){
		list.addListSelectionListener(e -> {
			if(!e.getValueIsAdjusting()){
				ActionEvent event = new ActionEvent(list, 0, command);
				receiver.actionPerformed(event);
			}
		});
	}
}