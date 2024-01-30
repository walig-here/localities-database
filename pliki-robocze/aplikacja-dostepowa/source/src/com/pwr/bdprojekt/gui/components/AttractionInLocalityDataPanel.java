package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;

public class AttractionInLocalityDataPanel extends GuiComponent{

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private VerticalComponentsStrip elements_panel;

    /**
     * Panel nagłówka
     * */
    private HorizontalComponentsStrip header_panel;

    /**
     * Nazwa
     * */
    private Text name;

    /**
     * adres
     * */
    private MultiChoiceList addresses;

    /**
     * panel administracyjny
     * */
    private HorizontalComponentsStrip admin_panel;

    /**
     * przycisk edycji atrackji
     * */
    private Button edit_button;

    /**
     * przycisk usunięcia atrakcji z miejscowości
     * */
    private Button delete_button;

    /**
     * opis
     * */
    private Text description;

    /**
     * Typy atrakcji
     * */
    private MultiChoiceList attraction_types;

//======================================================================================================================
// METODY

    public AttractionInLocalityDataPanel(JPanel parent, EventHandler eventHandler, boolean administrative_view, int attraction_index) {
        super(parent);
        setBackground(Color.white);

        // panel elementów
        elements_panel = new VerticalComponentsStrip(this);
        elements_panel.setBorder(BorderFactory.createLineBorder(Color.BLACK));
        elements_panel.setBackground(Color.white);

        // panel nagłówka
        header_panel = new HorizontalComponentsStrip(elements_panel);
        elements_panel.insertComponent(header_panel);

        // nazwa
        name = new Text(header_panel, "nazwa", 1);
        name.setBold(true);
        header_panel.insertComponent(name);

        // panel administracyjny
        admin_panel = new HorizontalComponentsStrip(header_panel);
        header_panel.insertComponent(admin_panel);

        if(administrative_view){
            // przycisk edycji
            edit_button = new Button(
                    admin_panel,
                    "Edytuj",
                    EventCommand.openAttractionEditor+" "+attraction_index,
                    eventHandler
            );
            admin_panel.insertComponent(edit_button);

            // przycisk usunięcia
            delete_button = new Button(
                    admin_panel,
                    "Usuń",
                    EventCommand.unassignAttractionFromLocality+attraction_index,
                    eventHandler
            );
            admin_panel.insertComponent(delete_button);
        }

        // opis
        description = new Text(elements_panel, "opis", 5);
        elements_panel.insertComponent(description);

        // adresy
        addresses = new MultiChoiceList(elements_panel, "Adresy atrakcji w miejscowości:", new int[0], 3);
        elements_panel.insertComponent(addresses);

        // typy
        attraction_types = new MultiChoiceList(elements_panel, "Przypisane typy:", new int[0], 3);
        elements_panel.insertComponent(attraction_types);

        // rozmieszczenie elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        // panel nagłówka
        header_panel.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // panel elementów
        final int HEIGHT =  3*PanelWithHeader.S+
                            header_panel.getHeight()+
                            description.getHeight()+
                            addresses.getHeight()+
                            attraction_types.getHeight();
        elements_panel.setPosition(0, 0);
        elements_panel.setSizeOfElement(getWidth(), getHeight());

        // wymiary elementu
        setBounds(
                getX(),
                getY(),
                getWidth(),
                HEIGHT
        );
    }

    @Override
    protected void updateData(String[] data) {

    }

    public void setAttractionName(String name){
        this.name.setText(name);
    }

    public void setAttractionDesc(String desc){
        this.description.setText(desc);
    }

    public void setAddresses(String list_of_addresses){
        String[] addresses = list_of_addresses.split(";");
        this.addresses.setElements(addresses);
    }

    public void setAttractionTypes(String list_of_types){
        String[] types = list_of_types.split(",");
        this.attraction_types.setElements(types);
    }
}
