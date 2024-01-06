package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;

import javax.swing.*;
import java.awt.*;

/**
 * Układ okna aplikacji, widoczny dla użytkownika
 * */
public abstract class View {

//======================================================================================================================
// POLA

	/**
	 * Okno, w którym zastosowany został widok
	 * */
	protected JFrame parent_window;

	/**
	 * Główny panel okna aplikacji
	 * */
	protected JPanel main_panel;

	/**
	 * Belka nawigacyjna, która jest widoczna w górnej części ekranu
	 * */
	protected TopBar topbar;

//======================================================================================================================
// STAŁE

	/**
	 * Wysokość belki nawigacyjnej
	 * */
	protected static final int TOPBAR_HEIGHT = 30;

//======================================================================================================================
// METODY

	/**
	 * Stworzenie nowego, pustego widoku.
	 * @param parent okno, w którym wyświetlony ma zostać widok
	 * @param hide_top_bar czy belka nawigacyjna ma zostać ukryta?
	 * */
	public View(JFrame parent, boolean hide_top_bar)
	{
		parent_window = parent;

		// Panel główny
		main_panel = new JPanel();
		main_panel.setBackground(Color.WHITE);
		main_panel.setLayout(null);

		// Belka nawigacyjna
		if(!hide_top_bar){
			topbar = new TopBar(main_panel);
		}
		else
			topbar = null;

		// Rozłożenie elementów
		parent_window.add(main_panel);
		parent_window.setLayout(null);
		redrawBaseView();
	}

	/**
	 * Odświeżenie rozkładu elementów. Ponowne przeliczenie szerokości i pozycji elementów.
	 * */
	public void redrawBaseView()
	{
		// Główny panel
		Rectangle frame_dimensions = parent_window.getContentPane().getBounds();
		main_panel.setBounds(frame_dimensions.x, frame_dimensions.y, frame_dimensions.width, frame_dimensions.height);

		// Belka nawigacyjna
		if(topbar != null)
		{
			topbar.setPosition(0,0);
			topbar.setSizeOfElement(-1, TOPBAR_HEIGHT);
			topbar.setSizeOfElement(main_panel.getWidth(), topbar.getHeight());
		}
	}

	/**
	 * Odświeża widoku. Na proces odświeżania składa się zaktualizowanie danych przedstawionych w widoku oraz
	 * zaktualizowanie jego wyglądu (ponowne przeliczenie pozycji i rozmiaru elementów GUI).
	 * @param data zbiór zaktualizowanych danych, których skład różni się w zależności od implementacji widoku
	 */
	public void refresh(String[] data){
		redrawBaseView();
		redraw();
		updateData(data);
	}

	/**
	 * Odświeżenie wyglądu widoku. Ponowne przeliczenie pozycji, rozmiaru oraz rozmieszczenia elementów GUI.
	 * */
	protected abstract void redraw();

	/**
	 * Odświeżenie danych przedstawionych w widoku.
	 * @param data zbiór zaktualizowanych danych, których skład różni się w zależności od implementacji widokuI
	 * */
	protected abstract void updateData(String[] data);

}