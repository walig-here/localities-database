package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.event.ActionListener;

/**
 * Przycisk, który po kliknięciu wysyla komendę lub wywołuje zadaną procedurę.
 * */
public class Button extends GuiComponent{

    private JButton button;

    /**
     * Tworzy nowy przycisk wysyłający komendę.
     *
     * @param parent panel lub element GUI, wewnątrz którego ma być umieszczony tworzony element GUI
     * @param label napis przycisku
     * @param command wysyłana komenda
     * @param receiver odbiorca komendy
     */
    public Button(JPanel parent, String label, String command, ActionListener receiver) {
        super(parent);

        button = new JButton(label);
        button.setActionCommand(command);
        button.addActionListener(receiver);

        add(button);
        redraw();

        setLayout(null);
        redraw();
    }

    /**
     * Tworzy nowy przycisk uruchamiający procedurę.
     *
     * @param parent panel lub element GUI, wewnątrz którego ma być umieszczony tworzony element GUI
     * @param label napis przycisku
     * @param procedure wywoływana procedura
     */
    public Button(JPanel parent, String label, ActionListener procedure){
        super(parent);

        button = new JButton(label);
        button.addActionListener(procedure);

        add(button);

        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        button.setBounds(0, 0, getWidth(), getHeight());
    }

    @Override
    protected void updateData(String[] data) {
        // NIC - brak danych do aktualizacji
    }
}
