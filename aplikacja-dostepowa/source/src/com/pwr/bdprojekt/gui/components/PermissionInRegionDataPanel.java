package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;

public class PermissionInRegionDataPanel extends GuiComponent{

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private PanelWithHeader elements_panel;

    /**
     * Opis
     * */
    private Text desc;

    /**
     * Przycisk odebrania uprawnienia
     * */
    private Button unassign_permission_button;

//======================================================================================================================
// METODY
    public PermissionInRegionDataPanel(JPanel parent, EventHandler eventHandler, boolean administrative_view, int permission_id) {
        super(parent);

        // panel elementów
        elements_panel = new PanelWithHeader(this, "nazwa uprawnienia");
        elements_panel.setScrollableVertically(false);
        elements_panel.setBorderVisibility(true);

        // opis
        desc = new Text(elements_panel, "opis", 2);
        elements_panel.insertComponent(desc);

        // przycisk
        if(administrative_view){
            unassign_permission_button = new Button(
                    elements_panel,
                    "Odbierz uprawnienie",
                    EventCommand.unassignPermissionInRegion+" "+permission_id,
                    eventHandler
            );
            elements_panel.insertComponent(unassign_permission_button);
        }

        // rozmieszczenie elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        // przycisk
        if(unassign_permission_button != null){
            unassign_permission_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);
        }

        // panel elementów
        elements_panel.setPosition(0 ,0);
        elements_panel.setSizeOfElement(
                getWidth(),
                35+2*PanelWithHeader.S+desc.getHeight()+(unassign_permission_button!=null ? 1 : 0)*Text.LETTER_HEIGHT
        );

        // rozmiar elementu
        setBounds(
                getX(),
                getY(),
                getWidth(),
                elements_panel.getHeight()
        );
    }

    @Override
    protected void updateData(String[] data) {

    }

    public void setPermissionName(String name){
        elements_panel.setHeaderText(name);
    }

    public void setPermissionDescription(String desc){
        this.desc.setText(desc);
    }
}
