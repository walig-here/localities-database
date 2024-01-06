package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.Button;
import com.pwr.bdprojekt.gui.components.PanelWithHeader;
import com.pwr.bdprojekt.gui.components.Text;
import com.pwr.bdprojekt.gui.components.VerticalComponentsStrip;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventCommandGenerator;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;
import java.util.Arrays;

/**
 * Widok domowy. Dane dla metody refresh():
 * 0. login użytkownika
 * 1. rola użytkownika
 * */
public class HomeView extends View {

//======================================================================================================================

    /**
     * Panel z elementami widoku
     * */
    private PanelWithHeader elements_panel;

    /**
     * Opis bazy danych
     * */
    private Text data_base_desc;

    /**
     * Panel listy miejscowości
     * */
    private PanelWithHeader locality_list_panel;

    /**
     * Opis listy miejscowości
     * */
    private Text locality_list_desc;

    /**
     * Przycisk otwarcia listy miejscowości
     * */
    private Button locality_list_button;

    /**
     * Panel listy ulubionych miejscowości
     * */
    private PanelWithHeader favourite_list_panel;

    /**
     * Opis listy ulubionych
     * */
    private Text favourite_list_desc;

    /**
     * Przycisk otwarcia ulubionych
     * */
    private Button favourite_list_button;

    /**
     * Panel listy użytkowników
     * */
    private PanelWithHeader user_list_panel;

    /**
     * Opis listy użytkowników
     * */
    private Text user_list_desc;

    /**
     * Przycisk otwarcia listy uzytkowników
     * */
    private Button user_list_button;

//======================================================================================================================

    /**
     * @param tech_admin_view czy ma być to widok administratora technicznego
     */
    public HomeView(JFrame parent, boolean tech_admin_view, EventHandler event_handler)
    {
        super(parent, false, event_handler);

        // panel z elementami
        elements_panel = new PanelWithHeader(main_panel, "Turystyczna baza danych miejscowości w Polsce");

        // opis bazy
        data_base_desc = new Text(elements_panel, "Opis bazy", 1);
        elements_panel.insertComponent(data_base_desc);

        // panel listy miejscowości
        locality_list_panel = new PanelWithHeader(elements_panel, "Lista miejscowości");
        elements_panel.insertComponent(locality_list_panel);

        // opis listy miejscowości
        locality_list_desc = new Text(locality_list_panel, "Opis listy miejscowości", 1);
        locality_list_panel.insertComponent(locality_list_desc);

        // przycisk otwarcia listy miejscowości
        locality_list_button = new Button(
                locality_list_panel,
                "Otwórz listę miejscowości",
                EventCommandGenerator.openLocalityList(),
                event_handler
        );
        locality_list_panel.insertComponent(locality_list_button);

        // panel listy ulubionych
        favourite_list_panel = new PanelWithHeader(elements_panel, "Lista ulubionych miejscowości");
        elements_panel.insertComponent(favourite_list_panel);

        // opis listy ulubionych
        favourite_list_desc = new Text(elements_panel, "Opis listy ulubinych", 1);
        favourite_list_panel.insertComponent(favourite_list_desc);

        // przycisk otwarcia listy ulubionych
        favourite_list_button = new Button(
                elements_panel,
                "Otwórz listę ulubionych miejscowości",
                EventCommandGenerator.openFavourtieList(),
                event_handler
        );
        favourite_list_panel.insertComponent(favourite_list_button);

        // WIDOK ADMINISTRATORA TECHNICZNEGO
        if(tech_admin_view){
            // panel listy użytkowników
            user_list_panel = new PanelWithHeader(main_panel, "Lista użytkowników");
            elements_panel.insertComponent(user_list_panel);

            // opis listy użytkowników
            user_list_desc = new Text(main_panel, "Opis listy użytkowników", 1);
            user_list_panel.insertComponent(user_list_desc);

            // przycisk listy użytkowników
            user_list_button = new Button(
                    main_panel,
                    "Otwórz listę użytkowników",
                    EventCommandGenerator.openUserList(),
                    event_handler
            );
            user_list_panel.insertComponent(user_list_button);
        }

        // rozmieszczenie elementów
        redraw();
    }

    @Override
    protected void redraw() {
        // WIDOK ADMINISTRATORA TECHNICZNEGO
        if(user_list_panel != null){
            // przycisk otwarcia listy użytkowników
            user_list_button.setSizeOfElement(0, Text.LETTER_HEIGHT);

            // panel listy użytkowników
            user_list_panel.setSizeOfElement(0, (main_panel.getHeight()-topbar.getHeight())/4);
        }

        // przucisk otwarcia listy ulubionych
        favourite_list_button.setSizeOfElement(0, Text.LETTER_HEIGHT);

        // panel listy ulubionych
        favourite_list_panel.setSizeOfElement(0, (main_panel.getHeight()-topbar.getHeight())/4);

        // przycisk otwarcia listy miejscowości
        locality_list_button.setSizeOfElement(0, Text.LETTER_HEIGHT);

        // panel listy miejscowości
        locality_list_panel.setSizeOfElement(-1, (main_panel.getHeight()-topbar.getHeight())/4);

        // panel z elementami
        elements_panel.setPosition(0,topbar.getBottomY());
        elements_panel.setSizeOfElement(
                main_panel.getWidth(),
                main_panel.getHeight()-topbar.getHeight()
        );
    }

    @Override
    protected void updateData(String[] data) {
        topbar.refresh(Arrays.copyOfRange(data, 0, 1));
    }
}