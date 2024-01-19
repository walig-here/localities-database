package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.gui.events.EventCommand;
import com.pwr.bdprojekt.gui.events.EventHandler;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;

public class PermissionToRegionDataPanel extends GuiComponent {

//======================================================================================================================
// POLA

    /**
     * Panel elementów
     * */
    private VerticalComponentsStrip elements_panel;

    /**
     * Panel nagłówka
     * */
    private HorizontalComponentsStrip header_panel;

    /**
     * Nazwa regionu
     * */
    private Text name;

    /**
     * Przycisk usunięcia uprawnienai do regionu
     * */
    private Button unassign_region_button;

    /**
     * Panel uprawnień w regionie
     * */
    private PanelWithHeader permissions_in_region_panel;

    /**
     * Przycisk nadania uprawnienia w regionie
     * */
    private Button add_permission_button;

    /**
     * Panele uprawnień w regionie
     * */
    private List<PermissionInRegionDataPanel> permission_in_region_data_panels = new ArrayList<>();

    /**
     * Odbiorca zdarzeń
     * */
    private EventHandler eventHandler;

//======================================================================================================================
// METODY

    public PermissionToRegionDataPanel(JPanel parent, EventHandler eventHandler, int voivodship_id, boolean admin_view) {
        super(parent);
        this.eventHandler = eventHandler;

        // panel elementów
        elements_panel = new VerticalComponentsStrip(this);
        elements_panel.setBackground(Color.white);
        elements_panel.setBorder(BorderFactory.createLineBorder(Color.BLACK));

        // panel nagłówka
        header_panel = new HorizontalComponentsStrip(elements_panel);
        elements_panel.insertComponent(header_panel);

        // nazwa regionu
        name = new Text(header_panel, "nazwa regionu", 1);
        header_panel.insertComponent(name);

        // przycisk usunięcia uprawnienia do regionu
        if(admin_view){
            unassign_region_button = new Button(
                    header_panel,
                    "Odbierz uprawnienie do regionu",
                    EventCommand.unassignPermissionToRegion+" "+voivodship_id,
                    eventHandler
            );
            header_panel.insertComponent(unassign_region_button);
        }

        // panel uprawnień w regionie
        permissions_in_region_panel = new PanelWithHeader(elements_panel, "Uprawnienia w regionie");
        permissions_in_region_panel.setScrollableVertically(true);
        elements_panel.insertComponent(permissions_in_region_panel);

        if(admin_view){
            add_permission_button = new Button(
                    permissions_in_region_panel,
                    "Nadaj nowe uprawnienie w regionie",
                    EventCommand.openAssignPermissionInRegionView+" "+voivodship_id,
                    eventHandler
            );
            permissions_in_region_panel.insertComponent(add_permission_button);
        }

        // rozmieszczenie elementów
        setLayout(null);
        redraw();
    }

    @Override
    protected void redraw() {
        // przycisk nadaniwa uprawnienia
        if(add_permission_button != null)
            add_permission_button.setSizeOfElement(-1, Text.LETTER_HEIGHT);

        // panel nagłówka
        header_panel.setSizeOfElement(-1 , Text.LETTER_HEIGHT);

        // panel uprawnień w regionie
        permissions_in_region_panel.setSizeOfElement(-1, 200);

        // panel elementów
        final int HEIGHT =  35+
                            2*PanelWithHeader.S+
                            header_panel.getHeight()+
                            permissions_in_region_panel.getHeight();
        elements_panel.setPosition(0, 0);
        elements_panel.setSizeOfElement(
                getWidth(),
                getHeight()
        );

        // rozmair elementu
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

    public void setRegionName(String name){
        this.name.setText(name);
    }

    public void setPermissionsInRegion(String[] data){
        permission_in_region_data_panels.clear();
        permissions_in_region_panel.removeAllComponents();
        if(add_permission_button != null)
            permissions_in_region_panel.insertComponent(add_permission_button);

        for(int i = 2; i < data.length; i+=3){
            PermissionInRegionDataPanel permissionInRegionDataPanel = new PermissionInRegionDataPanel(
                    permissions_in_region_panel,
                    eventHandler,
                    unassign_region_button != null,
                    Integer.parseInt(data[i-2])
            );
            permissionInRegionDataPanel.setPermissionName(data[i-1]);
            permissionInRegionDataPanel.setPermissionDescription(data[i]);

            permissions_in_region_panel.insertComponent(permissionInRegionDataPanel);
            permission_in_region_data_panels.add(permissionInRegionDataPanel);
        }
    }
}
