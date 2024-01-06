package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Panel składający się ułożonych pionowo elementów GUI. Elementy składowe mają jednakową szerokość (równą szerokości
 * panelu), ale mogą mieć różne wysokości.
 *
 * Wygląd elementu:
 * ----------
 * |   A    |
 * ----------
 * |        |
 * |   B    |
 * |        |
 * ----------
 * |   C    |
 * ----------
 * */
public class VerticalComponentsStrip extends GuiComponent {

//======================================================================================================================
// ## STAŁE ##

    /**
     * Rozmiar sepraratora.
     * * */
    public static final int SEPARATOR = 5;

//======================================================================================================================
// ## METODY ##

    /**
     * Tworzy pusty panel.
     * @param parent nadrzędny element GUI
     */
    public VerticalComponentsStrip(JPanel parent) {
        super(parent);
        setLayout(null);
        setSizeOfElement(0, SEPARATOR);
    }

    /**
     * Dodaje element GUI na spód panelu.
     * @param component dodawany element GUI
     */
    public void insertComponent(GuiComponent component) {
        component.moveTo(this);
        this.add(component);
    }

    /**
     * Usunięcie wszystkich elementów GUI z panelu.
     * */
    public void removeAllComponents() {
        this.removeAll();
    }

    /**
     * Pobranie wszystkich elementów GUI zawartych w panelu.
     * */
    public List<GuiComponent> getAllComponents() {
        List<GuiComponent> components = new ArrayList<>();
        for (Component component : super.getComponents()) {
            if(component instanceof GuiComponent)
                components.add((GuiComponent) component);
        }
        return components;
    }

    @Override
    protected void redraw() {
        int height = SEPARATOR;
        for (GuiComponent child_component : getAllComponents()) {
            child_component.setPosition(0, height);
            child_component.setSizeOfElement(getWidth(), child_component.getHeight());
            height += child_component.getHeight()+SEPARATOR;
        }
        setBounds(getX(), getY(), getWidth(), height);
    }

    @Override
    protected void updateData(String[] data) {

    }
}
