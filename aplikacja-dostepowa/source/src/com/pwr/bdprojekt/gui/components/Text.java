package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;

/**
 * Niemodyfikowalny tekst wyświetlany na GUI. Dane dla metody updateData():
 *
 *
 *  <p> 0. login użytkownika </p>
 *  <p> 1. rola użytkownika </p>
 * */
public class Text extends GuiComponent {

//======================================================================================================================
// STAŁE

    /**
     * Wysokość tekstu
     * */
    public static final int LETTER_HEIGHT = 20;

//======================================================================================================================
// POLA

    /**
     * Wyświetlany tekst
     * */
    JTextArea label;

    /**
     * Liczba wyświetlanych linii tekstu
     * */
    private int number_of_lines;

//======================================================================================================================
// METODY

    /**
     * Stworzenie elementu wyświetlającego tekst na GUI.
     * @param parent element lub panel, na którym wyświetlany ma być tekst
     * @param text tekst do wyświetlenia
     * @param number_of_lines liczba linii tekstu do wyświetlenia
     * */
    public Text(JPanel parent, String text, int number_of_lines) {
        super(parent);
        label = new JTextArea(text);
        label.setEditable(false);
        add(label);
        setSizeOfElement(0,LETTER_HEIGHT * number_of_lines + 2);
        setLayout(null);
        this.number_of_lines = number_of_lines;
        if(number_of_lines > 1)
            label.setLineWrap(true);

        redraw();
    }

    @Override
    protected void redraw() {
        label.setBounds(0, 0, getWidth(), getHeight());
    }

    @Override
    protected void updateData(String[] data) {
        // nie ma czego aktualizować
    }

    public String getText(){
        return label.getText();
    }

    public void setText(String text){
        label.setText(text);
    }

    public void setBold(boolean bold){
        Font f = label.getFont();
        if(bold)
            label.setFont(f.deriveFont(f.getStyle() | Font.BOLD));
        else
            label.setFont(f.deriveFont(f.getStyle() & ~Font.BOLD));
    }
}
