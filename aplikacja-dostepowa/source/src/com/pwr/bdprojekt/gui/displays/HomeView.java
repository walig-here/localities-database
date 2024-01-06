package com.pwr.bdprojekt.gui.displays;

import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.util.Arrays;

/**
 * Widok domowy. Dane dla metody refresh():
 * 0. login użytkownika
 * 1. rola użytkownika
 * */
public class HomeView extends View {


    /**
     * @param tech_admin_view czy ma być to widok administratora technicznego
     */
    public HomeView(JFrame parent, boolean tech_admin_view, EventHandler event_handler)
    {
        super(parent, false, event_handler);

    }

    @Override
    protected void redraw() {

    }

    @Override
    protected void updateData(String[] data) {
        topbar.refresh(Arrays.copyOfRange(data, 0, 1));
    }
}