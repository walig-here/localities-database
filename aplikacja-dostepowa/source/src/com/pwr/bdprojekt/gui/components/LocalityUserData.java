package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;

public class LocalityUserData extends GuiComponent{

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private VerticalComponentsStrip elements_panel;

    /**
     * Nagłówek
     * */
    private Text header;

    /**
     * adnotacja
     * */
    private TextField addnotation;

    /**
     * przycisk dodania do ulubionych
     * */
    private Button add_to_favourite_button;

    /**
     * przycisk usunięcia z ulubionych
     * */
    private Button remove_from_favourite_button;

//======================================================================================================================
// METODY

    public LocalityUserData(JPanel parent, EventHandler eventHandler) {
        super(parent);
        setBackground(Color.white);

        // panel elementów
        elements_panel = new VerticalComponentsStrip(this);
        elements_panel.setBackground(Color.white);

        // nagłówek
        header = new Text(elements_panel, "Dane użytkownika", 1);
        header.setBold(true);
        elements_panel.insertComponent(header);

        // adnotacja
        addnotation = new TextField(elements_panel, "Adnotacja", "", 3);
        elements_panel.insertComponent(addnotation);

        // przycisk dodania do ulubionych
        add_to_favourite_button = new Button(
                elements_panel,
                "Dodaj do ulubionych",
                EventCommand.addLocalityToFavourites,
                eventHandler
        );
        elements_panel.insertComponent(add_to_favourite_button);

        // przycisk usunięcia z ulubionych
        remove_from_favourite_button = new Button(
                elements_panel,
                "Usuń z ulubionych",
                EventCommand.removeLocalityFromFavourites,
                eventHandler
        );
        elements_panel.insertComponent(remove_from_favourite_button);

        // rozmieszczenie elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        // przycisk usunięcia z ulubionych
        remove_from_favourite_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // przycisk dodania do ulubionych
        add_to_favourite_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // panel elementów
        final int HEIGHT =  3*PanelWithHeader.S+
                            header.getHeight()+
                            addnotation.getHeight()+
                            add_to_favourite_button.getHeight()+
                            remove_from_favourite_button.getHeight();
        elements_panel.setPosition(0, 0);
        elements_panel.setSizeOfElement(
                getWidth(),
                HEIGHT
        );

        // rozmiar elementu
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

    public void setAddnotation(String addnotation){
        this.addnotation.setText(addnotation);
    }

    public String getAddnotation() {
        return addnotation.getText();
    }
}
