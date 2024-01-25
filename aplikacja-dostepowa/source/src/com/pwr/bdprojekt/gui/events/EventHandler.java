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

		try {
			switch (Window.getCurrentViewType()) {
				case HOME, HOME_ADMIN_TECH -> {
					handleHomeViewEvent(e);
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
					handleUserListViewEvent(e);
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
				case USER_DATA, USER_DATA_ADMIN_TECH -> {
					handleUserDataViewEvent(e);
				}
				case EMPTY -> {
				}
			}
		} catch (UnsupportedOperationException exception){
			Window.showMessageBox(exception.getMessage());
			Application.quit();
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

	/**
	 * Zdarzenia ekranu domowego
	 * */
	private void handleHomeViewEvent(ActionEvent e){
		HomeView window = (HomeView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openUserList:
				Application.browseUsersList();
				break;
			case EventCommand.openLocalityList:
				Application.browseLocalitiesList();
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}
	}

	/**
	 * Zdarzenia ekranu listy użytkowników
	 * */
	private void handleUserListViewEvent(ActionEvent e){
		UsersListView window = (UsersListView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openHomeView, EventCommand.openPreviousView:
				Application.openHomeDisplay();
				break;
			default:
				if(e.getActionCommand().contains(EventCommand.openUserAccountView))
				{
					String[] command = e.getActionCommand().split(" ");
					Application.openAccountDisplay(command[command.length-1]);
					break;
				}
				else throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}
	}

	/**
	 * Zdarzenia ekranu danych użytkownika
	 * */
	private void handleUserDataViewEvent(ActionEvent e){
		UserDataView window = (UserDataView) Window.getCurrentView();
		switch(e.getActionCommand()){
			case EventCommand.modifyUserRole:
				Application.changeUserRole(window.getUserLogin(), window.getRoleIndex());
				break;
			case EventCommand.openHomeView:
				Application.openHomeDisplay();
				break;
			case EventCommand.openPreviousView:
				Application.browseUsersList();
				break;
			case EventCommand.openAssignPermissionToRegionView:
				Application.givePermissionToRegion(window.getUserLogin());
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}
	}
}