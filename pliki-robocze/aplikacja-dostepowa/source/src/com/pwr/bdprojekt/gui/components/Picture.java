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
            add(figure);
        } catch (IOException e) {
            figure = new JLabel();
            System.out.println("Cannot load image from file: " + path);
        }
        setBackground(Color.WHITE);

        // Rozkład elementów
        setLayout(null);
        redraw();
    }

    /**
     * Wczytanie obrazka
     * */
    public void loadImage(String path){
        BufferedImage loaded_file = null;
        try {
            loaded_file = ImageIO.read(new File("resources/"+path));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Cannot load image from file: " + path);
        }
        figure.setIcon(new ImageIcon(loaded_file));
        redraw();
    }

    @Override
    protected void redraw() {
        figure.setBounds(0, 0, figure.getWidth(), figure.getHeight());
        setBounds(getX(), getY(), getWidth(), figure.getHeight());
    }

    @Override
    protected void updateData(String[] data) {
        // nie ma czego aktualizować
    }
}
