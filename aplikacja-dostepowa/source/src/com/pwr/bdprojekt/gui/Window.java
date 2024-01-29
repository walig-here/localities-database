package com.pwr.bdprojekt.gui;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.events.*;
import com.pwr.bdprojekt.logic.Application;

import javax.swing.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.Arrays;

/**
 * Okno aplikacji
 */
public class Window {

	public static JFrame frame = null;
	private static ViewType current_view_type = ViewType.EMPTY;  	// Typ aktualnego widoku
	private static ViewType previous_view_type = ViewType.EMPTY; 	// Typ porzedniego widoku
	private static View current_view = null;						// aktualny widok
	private static EventHandler event_handler = null;				// obsługa zdarzeń

	private static String[] dataForGui = null;

	/**
	 * Pobranie typu aktualnego widoku.
	 */
	public static ViewType getCurrentViewType() {
		return current_view_type;
	}

	/**
	 * Przełączenie aktualnego widoku
	 * @param new_view_type widok, na który chcemy się przełączyć
	 */
	public static void switchToView(ViewType new_view_type, String[] data)
	{
		previous_view_type = current_view_type;
		current_view_type = new_view_type;
		switch (current_view_type)
		{
			case HOME_ADMIN_TECH:
					current_view = new HomeView(frame,true, event_handler);
					break;
			case HOME:
					current_view = new HomeView(frame, false, event_handler);
					break;
			case ADDRESS_EDITOR:
					current_view = new AddressEditorView(frame, event_handler);
					break;
			case ATTRACTION_EDITOR:
					current_view = new AttractionEditorView(frame, event_handler, false);
					break;
			case NEW_ATTRACTIOn_EDITOR:
					current_view = new AttractionEditorView(frame, event_handler, true);
					break;
			case LOCALITY_EDITOR:
					current_view = new LocalityEditorView(frame, event_handler);
					break;
			case PERMISSION_EDITOR:
					current_view = new PermissionInRegionEditorView(frame, event_handler);
					break;
			case PERMISSION_TO_REGION_EDITOR:
					current_view = new PermissionToRegionEditorView(frame, event_handler);
					break;
			case LOCALITY_FILTER:
					current_view = new LocalityFilteringView(frame, event_handler);
					break;
			case USERS_FILTER:
					current_view = new UserFilteringView(frame, event_handler);
					break;
			case LOCALITY_LIST_ADMIN_MERIT:
					current_view = new LocalitiesListView(frame, event_handler, true);
					break;
			case LOCALITY_LIST:
					current_view = new LocalitiesListView(frame, event_handler, false);
					break;
			case USERS_LIST:
					current_view = new UsersListView(frame, event_handler);
					break;
			case LOGIN:
					current_view = new LoginView(frame, event_handler);
					break;
			case ASSIGN_ATTRACTION:
					current_view = new AssignAttractionView(frame, event_handler);
					break;
			case ASSIGN_ADDRESS:
					current_view = new AssignAddressView(frame, event_handler);
					break;
			case ASSIGN_FIGURE:
					break;
			case LOCALITY_SORT:
					current_view = new LocalitySortingView(frame, event_handler);
					break;
			case USERS_SORT:
					break;
			case LOCALITY_DATA:
					current_view = new LocalityDataView(frame, event_handler, false);
					break;
			case LOCALITY_DATA_ADMIN_MERIT:
					current_view = new LocalityDataView(frame, event_handler, true);
					break;
			case USER_DATA_ADMIN_TECH:
					current_view = new UserDataView(frame, event_handler, true);
					break;
			case USER_DATA:
					current_view = new UserDataView(frame, event_handler, false);
					break;
			case FAVOURITE_LOCALITY_LIST:
					current_view = new LocalitiesListView(frame, event_handler, false);
					break;
			case FAVOURITE_LOCALITY_LIST_MERITORICAL_ADMIN:
					current_view = new LocalitiesListView(frame, event_handler, true);
					break;
			case EMPTY:
					break;
		}

		dataForGui = data;
		current_view.refresh(data);
	}

	/**
	 * Od�wie�enie aktualnego widoku
	 */
	public static void refresh() {
		switchToView(current_view_type, dataForGui);
	}

	/**
	 * Pobranie typu uprzednio otwartego widoku
	 */
	public static ViewType getPreviousDisplayType() {
		return previous_view_type;
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

		event_handler = new EventHandler();
		switchToView(ViewType.LOGIN, new String[0]);

		return true;
	}

	public static View getCurrentView(){
		return current_view;
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