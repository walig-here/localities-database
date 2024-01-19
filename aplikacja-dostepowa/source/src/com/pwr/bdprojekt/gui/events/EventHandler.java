package com.pwr.bdprojekt.gui.events;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.*;
import com.pwr.bdprojekt.logic.Application;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class EventHandler implements ActionListener {

	@Override
	public void actionPerformed(ActionEvent e) {
		System.out.println("=> " + e.getActionCommand());

		switch (Window.getCurrentViewType()) {
			case HOME_ADMIN_TECH -> {
			}
			case HOME -> {
			}
			case ADDRESS_EDITOR -> {
			}
			case ATTRACTION_EDITOR -> {
			}
			case LOCALITY_EDITOR -> {
			}
			case PERMISSION_EDITOR -> {
			}
			case PERMISSION_TO_REGION_EDITOR -> {
			}
			case LOCALITY_FILTER -> {
			}
			case USERS_FILTER -> {
			}
			case LOCALITY_LIST_ADMIN_MERIT -> {
			}
			case LOCALITY_LIST -> {
			}
			case USERS_LIST -> {
			}
			case LOGIN -> {
				handleLoginViewEvent(e);
			}
			case ASSIGN_ATTRACTION -> {
			}
			case ASSIGN_ADDRESS -> {
			}
			case ASSIGN_FIGURE -> {
			}
			case LOCALITY_SORT -> {
			}
			case USERS_SORT -> {
			}
			case LOCALITY_DATA -> {
			}
			case LOCALITY_DATA_ADMIN_MERIT -> {
			}
			case USER_DATA_ADMIN_TECH -> {
			}
			case USER_DATA -> {
			}
			case EMPTY -> {
			}
		}
	}

	/**
	 * Zdarzenia ekranu logowania
	 * */
	private void handleLoginViewEvent(ActionEvent e){

		LoginView window = (LoginView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.loginUser:
				Application.logiIn(window.getLoginData()[0], window.getLoginData()[1]);
				break;
			case EventCommand.registerUser:
				Application.register(window.getLoginData()[0], window.getLoginData()[1]);
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}

	}
}