package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozawalający na przeglądanie danych i zarządznie kontem użytkownika. Dane dla refresh():
 * [0] login aktualnego użytkwonika
 * [1] rola atktualnego użytkownika
 * [2] login rozważanego użytkownika
 * [3] rola rozważanego użytkownika
 * [4..n] dane na temat uprawnienia użytkownika w regionie w formie:
 *          [id województwa];[nazwa województwa];[id uprawnienia 1zk];[nazwa uprawnienia 1zk];[opis uprawnienia 1zk]...
 * */
public class UserDataView extends View {

//======================================================================================================================
// STAŁE

    private final static String LOGIN_HEADER = "Login:\t\t";
    private final static String ROLE_HEADER = "Aktualnie pełniona rola:\t";

//======================================================================================================================
// POLA

    /**
     * Panel danych użytkowników
     * */
    private PanelWithHeader user_data_panel;

    /**
     * Pole z loginem
     * */
    private Text login;

    /**
     * Pole z rolą
     * */
    private Text role;

    /**
     * Panel zarządzania kontem
     * */
    private PanelWithHeader management_panel;

    /**
     * Przycisk usunięcia konta
     * */
    private Button delete_account_button;

    /**
     * Lista ról
     * */
    private SingleChoiceList roles_list;

    /**
     * Przycisk zmiany roli
     * */
    private Button set_role_button;

    /**
     * Panel uprawnień
     * */
    private PanelWithHeader permission_panel;

    /**
     * Przycisk nadania uprawnienia do regionu
     * */
    private Button assign_region_button = null;

    /**
     * Lista uprawnień do regionu
     * */
    private List<PermissionToRegionDataPanel> permission_to_region_panels = new ArrayList<>();

    /***
     * Odbiorca zdarzeń
     */
    private EventHandler eventHandler;

//======================================================================================================================
// METODY

    public UserDataView(JFrame parent, EventHandler event_handler, boolean administrative_view) {
        super(parent, false, event_handler);
        this.eventHandler = event_handler;

        // panel danych
        user_data_panel = new PanelWithHeader(main_panel, "Dane użytkownika");

        // login
        login = new Text(user_data_panel, LOGIN_HEADER, 1);
        user_data_panel.insertComponent(login);

        // rola
        role = new Text(user_data_panel, ROLE_HEADER, 1);
        user_data_panel.insertComponent(role);

        // panel zarządzania kontem
        management_panel = new PanelWithHeader(main_panel, "Zarządzanie kontem użytkownika");

        // przycisk usunięcia
        delete_account_button = new Button(
                management_panel,
                "Usuń konto",
                EventCommand.deleteUserAccount,
                event_handler
        );
        management_panel.insertComponent(delete_account_button);

        if(administrative_view){
            // lista ról
            roles_list = new SingleChoiceList(management_panel, "Zmiana przypisanej roli", 0);
            roles_list.setResetable(true);
            roles_list.setElements(new String[]{"Przeglądający", "Administrator Techniczny", "Administrator merytoryczny"});
            management_panel.insertComponent(roles_list);

            // przycisk zmiany roli
            set_role_button = new Button(
                    management_panel,
                    "Zmień rolę użytkownika",
                    EventCommand.modifyUserRole,
                    event_handler
            );
            management_panel.insertComponent(set_role_button);
        }

        // panel uprawnień
        permission_panel = new PanelWithHeader(main_panel, "Zarządzane przez użytkownika regiony");
        permission_panel.setScrollableVertically(true);

        if(administrative_view){
            assign_region_button = new Button(
                    permission_panel,
                    "Nadaj uprawnienie do nowego rejonu",
                    EventCommand.openAssignPermissionToRegionView,
                    event_handler
            );
            permission_panel.insertComponent(assign_region_button);
        }

        // rozmieszczenie elementów
        redraw();
    }

    @Override
    protected void redraw() {
        // przycisk nadania nowego uprawniania do regionu
        if(assign_region_button != null)
            assign_region_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // panel danych
        user_data_panel.setPosition(0, topbar.getBottomY());
        user_data_panel.setSizeOfElement(
                main_panel.getWidth(),
                login.getHeight()+role.getHeight()+35+3*PanelWithHeader.S
        );

        // przycisk usunięcia
        delete_account_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // przycisk zmiany roli
        if(set_role_button != null){
            set_role_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);
        }

        // panel zarządzania kontem
        management_panel.setPosition(0, user_data_panel.getBottomY());
        management_panel.setSizeOfElement(
                main_panel.getWidth(),
                150
        );

        // panel uprawnień
        if(permission_panel != null){
            permission_panel.setPosition(0, management_panel.getBottomY());
            permission_panel.setSizeOfElement(
                    main_panel.getWidth(),
                    main_panel.getHeight()-topbar.getHeight()-management_panel.getHeight()-user_data_panel.getHeight()
            );
        }
    }

    @Override
    protected void updateData(String[] data) {
        topbar.refresh(Arrays.copyOfRange(data, 0, 2));

        // login rozważanego użytkownika
        login.setText(LOGIN_HEADER+data[2]);

        // rola rozważanego użytkownika
        role.setText(ROLE_HEADER+data[3]);

        // uprawnienia
        permission_panel.removeAllComponents();
        if(assign_region_button != null)
            permission_panel.insertComponent(assign_region_button);
        permission_to_region_panels.clear();
        for(int i = 4; i < data.length; i++){
            String[] permissions_in_region_data = data[i].split(";");
            PermissionToRegionDataPanel permissionToRegionDataPanel = new PermissionToRegionDataPanel(
                    permission_panel,
                    eventHandler,
                    Integer.parseInt(permissions_in_region_data[0]),
                    assign_region_button != null
            );
            permissionToRegionDataPanel.setRegionName(permissions_in_region_data[1]);
            permissionToRegionDataPanel.setPermissionsInRegion(Arrays.copyOfRange(permissions_in_region_data, 2, permissions_in_region_data.length));

            permission_panel.insertComponent(permissionToRegionDataPanel);
            permission_to_region_panels.add(permissionToRegionDataPanel);
        }
    }
}
