package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozwalający na nadawanie użytkownikowi uprawnienia w ramach regionu. Elementy dla metody refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] login użytkownika, któremu nadawane są uprawnienia
 * [3] identyfikator województwa, w którym nadawane są uprawnienia
 * [4] nazwa województwa, w którym nadawane są uprawnienia
 * [5] lista nazw wszystkich uprawnień (posortowana względem id), oddzielonych przecinkami: "abc","abd","efg"
 * [6] lista opisów wszystkich uprawnień (posortowana względem id), oddzielonych średnikami: "abc";"efg";"esda"
 * */
public class PermissionInRegionEditorView extends View {

//======================================================================================================================
// POLA

	/**
	 * Lista opisów typów uprawnień dostępnych w bazie
	 * */
	private List<String> permission_descriptions = new ArrayList<>();

	/**
	 * Panel z elementami edytora
	 * */
	private PanelWithHeader elements_panel;

	/**
	 * Login użytkownika, któremu nadawane jest uprawnienie
	 * */
	private String user_login;

	/**
	 * Identyfikator województwa, w którym nadawane jest uprawnienie
	 * */
	private String voivodship_id;

	/**
	 * Lista z uprawnieniami
	 * */
	private SingleChoiceList permissions_list;

	/**
	 * Opis wybranego uprawnienia
	 * */
	private TextField permission_desc;

	/**
	 * Przycisk powrotu do profilu użytkownika
	 * */
	private Button back_button;

	/**
	 * Przycisk nadania uprawnienia
	 * */
	private Button assign_permission_button;

//======================================================================================================================
// METODY

	public PermissionInRegionEditorView(JFrame parent, EventHandler eventHandler) {
		super(parent, false, eventHandler);

		// panel elementów
		elements_panel = new PanelWithHeader(main_panel, "...");
		elements_panel.setScrollableVertically(true);

		// lista uprawnień
		permissions_list = new SingleChoiceList(elements_panel, "Uprawnienie", 0);
		elements_panel.insertComponent(permissions_list);

		// opis uprawnienia
		permission_desc = new TextField(elements_panel, "Opis typu uprawnień", "", 5);
		permission_desc.setEditable(false);
		elements_panel.insertComponent(permission_desc);

		// Przycisk powrotu
		back_button = new Button(
				main_panel,
				"Anuluj",
				EventCommand.openUserAccountView,
				eventHandler
		);

		// przycisk nadania uprawnienia
		assign_permission_button = new Button(
				elements_panel,
				"Przypisz uprawnienie w regionie",
				EventCommand.assignPermissionInRegionToUser,
				eventHandler
		);
		elements_panel.insertComponent(assign_permission_button);

		// rozmieszczenie elementów
		redraw();
	}

	@Override
	protected void redraw() {
		// przycisk nadawania uprawnienia
		assign_permission_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

		// panel elementów
		elements_panel.setPosition(0, topbar.getBottomY());
		elements_panel.setSizeOfElement(
				main_panel.getWidth(),
				main_panel.getHeight()-topbar.getHeight()-Text.LETTER_HEIGHT-PanelWithHeader.S
		);

		// przycisk powrotu
		back_button.setPosition(main_panel.getWidth()/2-50, elements_panel.getBottomY());
		back_button.setSizeOfElement(100, Text.LETTER_HEIGHT);
	}

	@Override
	protected void updateData(String[] data) {
		topbar.refresh(Arrays.copyOfRange(data, 0, 2));


		// login użytkownika, któremu nadawane są uprawnienia
		user_login = data[2];

		// dane wojdwództwa, w którym nadawane są uprawnienia
		voivodship_id = data[3];
		elements_panel.setHeaderText(
				"Uprawnienia do przypisania użytkownikowi \"" + user_login + "\" w województwie \"" + data[4] + "\""
		);

		// typy uprawnień
		String[] permissions = data[5].split(",");
		permissions_list.setElements(permissions);
		permissions_list.setProcedureForSelectionChange(e -> {
			if (e.getStateChange() == ItemEvent.SELECTED && e.getSource() instanceof JComboBox){
				JComboBox item = (JComboBox) e.getSource();
				permission_desc.setText(permission_descriptions.get(item.getSelectedIndex()));
			}
		});

		// opisy uprawnień
		permission_descriptions = Arrays.stream(data[6].split(";")).toList();
		permission_desc.setDefaultValue(permission_descriptions.get(permissions_list.getSelectedIndex()), permission_desc.getText().equals(""));
	}

	/**
	 * Pobranie loginu użytkownikowi, któremu nadawane jest uprawnienie
	 * */
	public String getUserLogin(){
		return user_login;
	}

	/**
	 * Pobranie identyfikatora województwa, w którym nadawane jest uprawnienie
	 * */
	public int getVoivodshipId(){
		return Integer.parseInt(voivodship_id);
	}

	/**
	 * Pobranie identyfikatora typu uprawnienia nadanego użytkownikowi
	 * */
	public int getPermissionId(){
		return permissions_list.getSelectedIndex();
	}
}