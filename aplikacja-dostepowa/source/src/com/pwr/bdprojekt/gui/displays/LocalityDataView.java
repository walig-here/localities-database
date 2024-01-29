package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.components.*;
import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Widok pozwalający na wyświetlenie danych miejscowości oraz danych wszystkich zlokalizowanych w niej atrakcji.
 * Dane dla metody refresh():
 * [0] login aktualnego użytkownika
 * [1] rola aktualnego użytkownika
 * [2] identyfikator miejscowości
 * [3] nazwa miejscowości
 * [4] opis miejscowości
 * [5] populacja miejscowosoći
 * [6] nazwa typu miejscowości
 * [7] nazwa województwa
 * [8] nazwa powiatu
 * [9] nazwa gminy
 * [10] długośc geograficzna
 * [11] szerokośc geograficzna
 * [12] czy miejscowość jest ulubiona dla aktualnego użytkownika
 * [13] adnotacja aktualnego użytkownika
 * [14] list identyfikatorów atrakcji przypisanych do miejscowości (posortowana względem id), oddzielana przecinkami
 * [15] lista nazw atrakcji przypisanych do miejscowości (posortowana względem id), oddzielana przecinkami
 * [16] lista opisów atrakcji przypisanych do miejscowości (posortowana względem id), oddzielana przecinkami
 * [17] lista list oddzielanych średnikami adresów przypisanych do atrakcji (posrotowana względem id) oddzialana znakami "'"
 * [18] lista list oddzielanych przecinkami typów przypisanych do atrakcji (posrotowana względem id) oddzielana średnikami
 * */
public class LocalityDataView extends View{

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private PanelWithHeader elements_panel;

    /**
     * IDentyfikator miejscowości
     * */
    private String locality_id;

    /**
     * Panel Zarządzania miejscowością
     * */
    private HorizontalComponentsStrip management_panel;

    /**
     * Ikona ulubionych
     * */
    private Picture favourite_icon;

    /**
     * Panel przycisków zarządzania
     * */
    private HorizontalComponentsStrip management_buttons_panel;

    /**
     * Przycisk przypisania atrakcji
     * */
    private Button assign_attraction_button;

    /**
     * Przycisk edycji miejscowości
     * */
    private Button edit_locality_button;

    /**
     * Przycisk usunięcia miejscowości
     * */
    private Button delete_locality_button;

    /**
     * Nazwa miejscowości
     * */
    private Text name;

    /**
     * Opis miejscowości
     * */
    private Text description;

    /**
     * Panel danych miejscowości
     * */
    private HorizontalComponentsStrip locality_data_panel;

    /**
     * Tabela danych bazowych
     * */
    private LocalityDataTable base_locality_data;

    /**
     * Panel danych użytkownika
     * */
    private LocalityUserData user_data;

    /**
     * Nagłówek listy atrakcji
     * */
    private Text attraction_list_header;

    /**
     * Lista atrakcji
     * */
    private List<AttractionInLocalityDataPanel> attraction_data_panels = new ArrayList<>();

    /**
     * Odbiorca zdarzeń
     * */
    private EventHandler eventHandler;

    /**
     * Czy jest to widok administratora
     * */
    private boolean administrative_view;

//======================================================================================================================
// METODY

    public LocalityDataView(JFrame parent, EventHandler event_handler, boolean adminitrative_view) {
        super(parent, false, event_handler);
        this.eventHandler = event_handler;
        this.administrative_view = adminitrative_view;

        // panel elemnentów
        elements_panel = new PanelWithHeader(main_panel, "");
        elements_panel.setScrollableVertically(true);

        // panel zarządzania
        management_panel = new HorizontalComponentsStrip(elements_panel);
        elements_panel.insertComponent(management_panel);

        // ikona ulubionych
        favourite_icon = new Picture(management_panel, "fav.png");
        management_panel.insertComponent(favourite_icon);

        // panel przycisków zarządzania
        management_buttons_panel = new HorizontalComponentsStrip(management_panel);
        management_panel.insertComponent(management_buttons_panel);

        if(adminitrative_view){
            // przycisk przyisania atrakcji
            assign_attraction_button = new Button(
                    management_buttons_panel,
                    "Przypisz atrakcję",
                    EventCommand.openAvailableAttractionsView,
                    event_handler
            );
            management_buttons_panel.insertComponent(assign_attraction_button);

            // przycisk edytowania miejscowości
            edit_locality_button = new Button(
                    management_buttons_panel,
                    "Edytuj",
                    EventCommand.openLocalityEditor,
                    event_handler
            );
            management_buttons_panel.insertComponent(edit_locality_button);

            // przycisk usunięcia miejscowości
            delete_locality_button = new Button(
                    management_buttons_panel,
                    "Usuń",
                    EventCommand.deleteLocality,
                    event_handler
            );
            management_buttons_panel.insertComponent(delete_locality_button);
        }

        // nazwa miejscowości
        name = new Text(elements_panel, "nazwa miejscowości", 1);
        name.setBold(true);
        elements_panel.insertComponent(name);

        // opis miejscowości
        description = new Text(elements_panel, "opis miejscowości", 5);
        elements_panel.insertComponent(description);

        // panel danych miejscowości
        locality_data_panel = new HorizontalComponentsStrip(elements_panel);
        elements_panel.insertComponent(locality_data_panel);

        // tabela danych bazowych
        base_locality_data = new LocalityDataTable(locality_data_panel);
        locality_data_panel.insertComponent(base_locality_data);

        // panel danych użytkownika
        user_data = new LocalityUserData(locality_data_panel, event_handler);
        locality_data_panel.insertComponent(user_data);

        // nagłówek listy miejscowości
        attraction_list_header = new Text(elements_panel, "Lokalne atrakcje", 1);
        attraction_list_header.setBold(true);
        elements_panel.insertComponent(attraction_list_header);

        // rozmieszczenie elementów
        redraw();
    }

    @Override
    protected void redraw() {
        // panel danych miejscowości
        locality_data_panel.setSizeOfElement(
                -1,
                base_locality_data.getHeight()
        );

        // panel zarządzania
        management_panel.setSizeOfElement(-1, 25);

        // panel elementów
        elements_panel.setPosition(0, topbar.getBottomY());
        elements_panel.setSizeOfElement(
                main_panel.getWidth(),
                main_panel.getHeight()-topbar.getHeight()
        );
    }

    @Override
    protected void updateData(String[] data) {
        topbar.refresh(Arrays.copyOfRange(data, 0, 2));

        // identyfikator miejscowości
        locality_id = data[2];

        // nazwa miejscowości
        name.setText(data[3]);

        // opis miejscowości
        description.setText(data[4]);

        // dane bazowe
        base_locality_data.setPopualtion(data[5]);
        base_locality_data.setLocalityType(data[6]);
        base_locality_data.setVoivodship(data[7]);
        base_locality_data.setCounty(data[8]);
        base_locality_data.setMunicipality(data[9]);
        base_locality_data.setLongitude(data[10]);
        base_locality_data.setLatitude(data[11]);

        // ulubiona miejscowość
        boolean is_favourite = Boolean.parseBoolean(data[12]);
        user_data.setFavourite(is_favourite);
        if(is_favourite){
            favourite_icon.loadImage("fav.png");
        }
        else{
            favourite_icon.loadImage("not_fav.png");
        }

        // adnotacja
        user_data.setAddnotation(data[13]);

        //atrakcja
        String[] attractions_ids = data[14].split(",");
        String[] attractions_names = data[15].split(";");
        String[] attractions_descs = data[16].split(";");
        String[] attractions_addresses = data[17].split("'");
        String[] attractions_types = data[18].split(";");

        if(attractions_ids.length == 0 || attractions_ids[0].equals(""))
            return;

        elements_panel.removeAllComponents();
        elements_panel.insertComponent(management_panel);
        elements_panel.insertComponent(name);
        elements_panel.insertComponent(description);
        elements_panel.insertComponent(locality_data_panel);
        elements_panel.insertComponent(attraction_list_header);

        attraction_data_panels.clear();

        for (int i = 0; i < attractions_ids.length; i++){
            AttractionInLocalityDataPanel attraction = new AttractionInLocalityDataPanel(
                    elements_panel,
                    eventHandler,
                    administrative_view,
                    Integer.parseInt(attractions_ids[i])
            );
            attraction.setAttractionName(attractions_names[i]);
            attraction.setAttractionDesc(attractions_descs[i]);
            attraction.setAddresses(attractions_addresses[i]);
            attraction.setAttractionTypes(attractions_types[i]);

            attraction_data_panels.add(attraction);
            elements_panel.insertComponent(attraction);
        }
    }

    /**
     * Pobranie ID miejscowości
     * */
    public int getLocalityId(){
        return Integer.parseInt(locality_id);
    }

    /**
     * Pobranie adnotacji
     * */
    public String getAddnotation(){
        return user_data.getAddnotation();
    }
}
