package com.pwr.bdprojekt.gui;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.events.*;
import com.pwr.bdprojekt.logic.Application;

import javax.swing.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

/**
 * Okno aplikacji
 */
public class Window {

	public static JFrame frame = null;
	private static ViewType current_view_type = ViewType.EMPTY;  	// Typ aktualnego widoku
	private static ViewType previous_view_type = ViewType.EMPTY; 	// Typ porzedniego widoku
	private static View current_view = null;						// aktualny widok
	private static EventHandler event_handler = null;				// obsługa zdarzeń

	/**
	 * Pobranie typu aktualnego widoku.
	 */
	public static ViewType getCurrentViewType() {
		// TODO - implement Window.getCurrentViewType
		throw new UnsupportedOperationException();
	}

	/**
	 * Przełączenie aktualnego widoku
	 * @param new_view_type widok, na który chcemy się przełączyć
	 */
	public static void switchToView(ViewType new_view_type)
	{
		current_view_type = new_view_type;
		switch (current_view_type)
		{
			case HOME_ADMIN_TECH:
					current_view = new HomeView(frame,true);
					break;
			case HOME:
					current_view = new HomeView(frame, false);
					break;
			case ADDRESS_EDITOR:
					current_view = new AddressEditorView(frame);
					break;
			case ATTRACTION_EDITOR:
					break;
			case LOCALITY_EDITOR:
					break;
			case PERMISSION_EDITOR:
					break;
			case PERMISSION_TO_REGION_EDITOR:
					break;
			case LOCALITY_FILTER:
					break;
			case USERS_FILTER:
					break;
			case LOCALITY_LIST_ADMIN_MERIT:
					break;
			case LOCALITY_LIST:
					break;
			case USERS_LIST:
					break;
			case LOGIN:
					current_view = new LoginView(frame, event_handler);
					break;
			case ASSIGN_ATTRACTION:
					break;
			case ASSIGN_ADDRESS:
					break;
			case ASSIGN_FIGURE:
					break;
			case LOCALITY_SORT:
					break;
			case USERS_SORT:
					break;
			case LOCALITY_DATA:
					break;
			case LOCALITY_DATA_ADMIN_MERIT:
					break;
			case USER_DATA_ADMIN_TECH:
					break;
			case USER_DATA:
					break;
			case EMPTY:
					break;
		}
	}

	/**
	 * Od�wie�enie aktualnego widoku
	 */
	public static void refresh() {
		// TODO - implement Window.refresh
		throw new UnsupportedOperationException();
	}

	/**
	 * Pobranie typu uprzednio otwartego widoku
	 */
	public static ViewType getPreviousDisplayType() {
		// TODO - implement Window.getPreviousDisplayType
		throw new UnsupportedOperationException();
	}

	/**
	 * Otwiera okno aplikacji w domyślnym widoku (logowania). Zwraca informacje o powodzeniu akcji.
	 * @param name tytuł okna
	 * @param w szerokośc okna
	 * @param h wysokość okna
	 */
	public static boolean open(String name, int w, int h) {
		frame = new JFrame(name);
		frame.setSize(w, h);
		frame.setResizable(false);
		frame.setVisible(true);

		frame.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				super.windowClosing(e);
				Application.quit();
			}
		});

		event_handler = new EventHandler(current_view);

		switchToView(ViewType.LOGIN);

		return true;
	}

	/**
	 * Zamyka okno aplikacji. Zwraca informacje o powodzeniu akcji.
	 */
	public static boolean close() {
		frame.setVisible(false);
		frame.dispose();

		return true;
	}

	public static void showMessageBox(String message){
		JOptionPane.showMessageDialog(frame, message);
	}

}