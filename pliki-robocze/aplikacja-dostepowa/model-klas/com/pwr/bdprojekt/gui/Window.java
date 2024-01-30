package com.pwr.bdprojekt.gui;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.events.*;

/**
 * Okno aplikacji
 */
public class Window {

	/**
	 * Typ aktualnego widoku
	 */
	private static ViewType current_view_type = com.pwr.bdprojekt.gui.displays.ViewType.NONE;
	/**
	 * Typ porzedniego widoku
	 */
	private static ViewType previous_view_type = com.pwr.bdprojekt.gui.displays.ViewType.NONE;
	/**
	 * Aktualny widok
	 */
	private static View current_view = null;
	private static EventHandler event_handler = null;

	/**
	 * Pobranie typu aktualnego widoku.
	 */
	public static ViewType getCurrentViewType() {
		// TODO - implement Window.getCurrentViewType
		throw new UnsupportedOperationException();
	}

	/**
	 * Prze³¹czenie aktualnego widoku
	 * @param current_display_type
	 */
	public static void switchToView(ViewType current_display_type) {
		// TODO - implement Window.switchToView
		throw new UnsupportedOperationException();
	}

	/**
	 * Odœwie¿enie aktualnego widoku
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
	 * Otwiera okno aplikacji w domyœlnym widoku (logowania). Zwraca informacje o powodzeniu akcji.
	 * @param name
	 * @param w
	 * @param h
	 */
	public static boolean open(String name, int w, int h) {
		// TODO - implement Window.open
		throw new UnsupportedOperationException();
	}

	/**
	 * Zamyka okno aplikacji. Zwraca informacje o powodzeniu akcji.
	 */
	public static boolean close() {
		// TODO - implement Window.close
		throw new UnsupportedOperationException();
	}

}