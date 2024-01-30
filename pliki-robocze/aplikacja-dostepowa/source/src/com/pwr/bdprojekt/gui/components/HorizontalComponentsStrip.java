package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Panel składający się ułożonych poziomo elementów GUI. Elementy składowe mają jednakowe wysokości równe wysokości
 * panelu. Ich szerokości są identyczne i są one równe stosunkowi W/n, gdzie W to szerokość panelu, a n to liczba
 * elementów składowych.
 *
 * Wygląd elementu:
 * ----------------------------
 * |   A    |    B   |    C   |
 * ----------------------------
 * */
public class HorizontalComponentsStrip extends GuiComponent {

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
    public HorizontalComponentsStrip(JPanel parent) {
        super(parent);
        setLayout(null);
        setSizeOfElement(0, SEPARATOR);
        setBackground(Color.WHITE);
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
        int n = getAllComponents().size();
        if(n == 0)
            return;
        int element_width = (getWidth()-(n+1)*SEPARATOR)/n;
        int i = 0;
        for (GuiComponent child_component : getAllComponents()) {
            child_component.setPosition(SEPARATOR+i*(element_width+SEPARATOR), 0);
            child_component.setSizeOfElement(element_width, getHeight());
            i++;
        }
    }

    @Override
    protected void updateData(String[] data) {

    }
}
