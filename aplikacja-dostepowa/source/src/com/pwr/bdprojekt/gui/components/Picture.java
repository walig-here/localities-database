package com.pwr.bdprojekt.gui.components;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

/**
 * Obrazek wyświetlany na interfejsie.
 * */
public class Picture extends GuiComponent{

//======================================================================================================================
// POLA

    /**
     * Obrazek
     * */
    private JLabel figure;

//======================================================================================================================
// METODY

    /**
     * Tworzy nowy obrazek na podstawie pliku z folderu resources.
     *
     * @param parent panel lub element GUI, wewnątrz którego ma być umieszczony tworzony element GUI
     * @param path ścieżka (względna do folderu resources), pod którą znajduje się obrazek
     */
    public Picture(JPanel parent, String path) {
        super(parent);

        // Obrazek
        try {
            BufferedImage loaded_file = ImageIO.read(new File("resources/"+path));
            figure = new JLabel(new ImageIcon(loaded_file));
            figure.setBounds(0, 0, loaded_file.getWidth(), loaded_file.getHeight());
        } catch (IOException e) {
            figure = new JLabel();
            System.out.println("Cannot load image from file: " + path);
        }
        setBorder(BorderFactory.createLineBorder(Color.BLACK));
        setBackground(Color.BLUE);
        add(figure);

        // Rozkład elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        figure.setBounds(0, 0, figure.getWidth(), figure.getHeight());
    }

    @Override
    protected void updateData(String[] data) {
        // nie ma czego aktualizować
    }
}
