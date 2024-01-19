package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok pozwalający na przydzielnie użytkownikowi uprawnień do administrowania regionem. Dane dla funkcji refresh:
 * [0] - login aktualnego użytkownika
 * [1] - rola aktualnego użytkownika
 * [2] - login użytkownika, któremu nadawane jest uprawnienie
 * [3] - lista wszystkich województw dostępnych w bazie danych (posortowana względem id) oddzielonych przecinkami: "abc","def","ghi"
 **/
public class PermissionToRegionEditorView extends View {

//======================================================================================================================
// POLA

	/**
	 * Panel z elementami edytora
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Przycisk powrotu
	 * */
	private Button back_button;

	/**
	 * Login użytkownika, któremu nadawane jest uprawnienie do regionu
	 * */
	private String user_login;

	/**
	 * Lista województw
	 * */
	private SingleChoiceList voivodships;

	/**
	 * Przycisk nadania uprawnienia
	 * */
	private Button give_permission_button;

//======================================================================================================================
// METODY

	public PermissionToRegionEditorView(JFrame parent, EventHandler eventHandler) {
		super(parent, false, eventHandler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "Nadawanie uprawnień w rejonie użytkownikowi ");
		elements_panel.setScrollableVertically(true);

		// przycisk powrotu
		back_button = new Button(
			main_panel,
			"Powrót",
			EventCommand.openUserAccountView,
			eventHandler
		);

		// wojewóztwa
		voivodships = new SingleChoiceList(elements_panel, "Województwo", 0);
		elements_panel.insertComponent(voivodships);

		// przycisk nadania uprawnienia
		give_permission_button = new Button(
			elements_panel,
			"Nadaj uprawnienie do regionu",
			EventCommand.openAssignPermissionInRegionView,
			eventHandler
		);
		elements_panel.insertComponent(give_permission_button);

		// rozmieszczenie elementów
		redraw();
	}

	@Override
	protected void redraw() {
		// przycisk nadania uprawnienia
		give_permission_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-PanelWithHeader.S-Text.LETTER_HEIGHT
		);

		// przycisk powrotu
		back_button.setPosition(main_panel.getWidth()/2-50, elements_panel.getBottomY());
		back_button.setSizeOfElement(100, Text.LETTER_HEIGHT);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));

		// login użytkownika, któremu nadawane jest uprawnienie
		elements_panel.setHeaderText("Nadawanie uprawnień w rejonie użytkownikowi \"" + data[2] + "\"");

		// lista województw
		String[] voivodships_list = data[3].split(",");
		voivodships.setElements(voivodships_list);
	}

	/**
	 * Pobranie loginu użytkownika, któremu nadawane jest uprawnienie
	 * */
	public String getUserLogin(){
		return user_login;
	}

	/**
	 * Pobranie numery porządkowego województwa, do którego uprawnienie ma otrzymać użytkownik
	 * */
	public int getVoivodshipIndex(){
		return voivodships.getSelectedIndex();
	}
}