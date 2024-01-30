package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;

public class LocalityDataTable extends GuiComponent{

//======================================================================================================================
// STAŁE

    private static final String POPULATION_HEADER = "Populacja:\t\t";
    private static final String LOCALITY_TYPE_HEADER = "Typ miejscowości:\t";
    private static final String VOIVODSHIP_HEADER = "Województwo:\t\t";
    private static final String COUNTY_HEADER = "Powiat:\t\t";
    private static final String MUNICIPALITY_HEADER = "Gmina:\t\t";
    private static final String LONGITUDE_HEADER = "Dł. geograficzna:\t";
    private static final String LATITUDE_HEADER = "Sz. geograficzna:\t";

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private VerticalComponentsStrip elements_panel;

    /**
     * Nagłowek
     * */
    private Text header;

    /**
     * Populacja
     * */
    private Text population;

    /**
     * Typ miejscowości
     * */
    private Text locality_type;

    /**
     * Województwo
     * */
    private Text voivodship;

    /**
     * Powiat
     * */
    private Text county;

    /**
     * Gmina
     * */
    private Text municipality;

    /**
     * Długość geograficzna
     * */
    private Text longitude;

    /**
     * Szerokość geograficzna
     * */
    private Text latitude;

//======================================================================================================================
// METODY

    public LocalityDataTable(JPanel parent) {
        super(parent);
        setBackground(Color.white);

        // panel elementów
        elements_panel = new VerticalComponentsStrip(this);
        elements_panel.setBackground(Color.white);

        // nagłówek
        header = new Text(elements_panel, "Dane bazowe", 1);
        header.setBold(true);
        elements_panel.insertComponent(header);

        // populacja
        population = new Text(elements_panel, POPULATION_HEADER, 1);
        elements_panel.insertComponent(population);

        // typ miejscowości
        locality_type = new Text(elements_panel, LOCALITY_TYPE_HEADER, 1);
        elements_panel.insertComponent(locality_type);

        // województwo
        voivodship = new Text(elements_panel, VOIVODSHIP_HEADER, 1);
        elements_panel.insertComponent(voivodship);

        // powiat
        county = new Text(elements_panel, COUNTY_HEADER, 1);
        elements_panel.insertComponent(county);

        // gmina
        municipality = new Text(elements_panel, MUNICIPALITY_HEADER, 1);
        elements_panel.insertComponent(municipality);

        // długość geograficzna
        longitude = new Text(elements_panel, LONGITUDE_HEADER, 1);
        elements_panel.insertComponent(longitude);

        // szerokość geograficzna
        latitude = new Text(elements_panel, LATITUDE_HEADER, 1);
        elements_panel.insertComponent(latitude);

        // rozmieszczenie elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        // panel elementów
        final int HEIGHT =  5*PanelWithHeader.S+
                            header.getHeight()+
                            population.getHeight()+
                            locality_type.getHeight()+
                            voivodship.getHeight()+
                            county.getHeight()+
                            municipality.getHeight()+
                            longitude.getHeight()+
                            latitude.getHeight();
        elements_panel.setPosition(0, 0);
        elements_panel.setSizeOfElement(getWidth(), getHeight());

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

    public void setPopualtion(String popualtion){
        this.population.setText(POPULATION_HEADER+popualtion);
    }

    public void setLocalityType(String type){
        this.locality_type.setText(LOCALITY_TYPE_HEADER+type);
    }

    public void setVoivodship(String voivodship){
        this.voivodship.setText(VOIVODSHIP_HEADER+voivodship);
    }

    public void setCounty(String county){
        this.county.setText(COUNTY_HEADER+county);
    }

    public void setMunicipality(String municipality){
        this.municipality.setText(MUNICIPALITY_HEADER+municipality);
    }

    public void setLongitude(String longitude){
        this.longitude.setText(LONGITUDE_HEADER+longitude);
    }

    public void setLatitude(String latitude){
        this.latitude.setText(LATITUDE_HEADER+latitude);
    }
}
