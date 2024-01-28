package com.pwr.bdprojekt.gui.events;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.*;
import com.pwr.bdprojekt.logic.Application;
import com.pwr.bdprojekt.logic.entities.AdministrativeUnit;
import com.pwr.bdprojekt.logic.entities.Locality;
import com.pwr.bdprojekt.logic.entities.User;
import com.pwr.bdprojekt.logic.entities.UserRole;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class EventHandler implements ActionListener {

	@Override
	public void actionPerformed(ActionEvent e) {
		System.out.println("=> " + e.getActionCommand());

		switch (e.getActionCommand())
		{
			case EventCommand.openCurrentUserAccount:
				Application.openAccountDisplay(Application.getCurrentUser().getLogin(), true);
				return;
			case EventCommand.openHomeView:
				Application.openHomeDisplay();
				return;
			case EventCommand.logOutCurrentUser:
				Application.logOut();
				return;
		}

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
					handleLocalityEditorEvents(e);
				}
				case PERMISSION_EDITOR -> {
					handleAssignPermissionInRegionView(e);
				}
				case PERMISSION_TO_REGION_EDITOR -> {
					handleAssignPermissionToRegionView(e);
				}
				case LOCALITY_FILTER -> {
				}
				case USERS_FILTER -> {
				}
				case LOCALITY_LIST_ADMIN_MERIT, LOCALITY_LIST, FAVOURITE_LOCALITY_LIST, FAVOURITE_LOCALITY_LIST_MERITORICAL_ADMIN -> {
					handleLocalityListEvents(e);
				}
				case USERS_LIST -> {
					handleUserListViewEvent(e);
				}
				case LOGIN -> {
					handleLoginViewEvent(e);
				}
				case ASSIGN_ATTRACTION -> {
					handleAssignAttractionToLocalityViewEvents(e);
				}
				case ASSIGN_ADDRESS -> {
				}
				case ASSIGN_FIGURE -> {
				}
				case LOCALITY_SORT -> {
				}
				case USERS_SORT -> {
				}
				case LOCALITY_DATA, LOCALITY_DATA_ADMIN_MERIT -> {
					handleLocalityDataViewEvents(e);
				}
				case USER_DATA, USER_DATA_ADMIN_TECH -> {
					handleUserDataViewEvent(e);
				}
			}
		} catch (UnsupportedOperationException exception){
			Window.showMessageBox(exception.getMessage());
			Application.quit();
		}
	}

	/**
	 * Zdarzenia ekranu przypisywania atrakcji
	 * */
	private void handleAssignAttractionToLocalityViewEvents(ActionEvent e){
		AssignAttractionView window = (AssignAttractionView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openPreviousView:
				Application.examineLocalityData(window.getLocalityId());
				break;
			case EventCommand.assignAttractionToLocality:
				break;
			default:
				throw new UnsupportedOperationException("Wykryto nieobsługiwany wyjątek: "+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu danych miejscowości
	 * */
	private void handleLocalityDataViewEvents(ActionEvent e){
		LocalityDataView window = (LocalityDataView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openLocalityEditor:
				Application.openLocalityEditor(window.getLocalityId());
				break;
			case EventCommand.deleteLocality:
				Application.deleteLocality(window.getLocalityId());
				break;
			case EventCommand.openPreviousView:
				if(Window.getPreviousDisplayType().equals(ViewType.LOCALITY_LIST) || Window.getPreviousDisplayType().equals(ViewType.LOCALITY_LIST_ADMIN_MERIT))
					Application.browseLocalitiesList();
				else
					Application.browseFavouriteList();
				break;
			case EventCommand.addLocalityToFavourites:
				Locality locality = new Locality();
				locality.setId(window.getLocalityId());
				Application.addLocalityToFavourites(locality, window.getAddnotation());
				break;
			case EventCommand.openAvailableAttractionsView:
				Application.showAvailableAttractions(window.getLocalityId());
				break;
			default:
				throw new UnsupportedOperationException("Wkryto nieobsługiwane zdarzenie: "+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu edytora miejscowości
	 * */
	private void handleLocalityEditorEvents(ActionEvent e){
		LocalityEditorView window = (LocalityEditorView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openPreviousView:
				if(window.getLocalityId() == -1)
					Application.browseLocalitiesList();
				else
					Application.examineLocalityData(window.getLocalityId());
				break;
			case EventCommand.modifyLocalityData:
				int locality_id = window.getLocalityId();
				Locality locality = new Locality();
				locality.setName(window.gerLocalityName());
				locality.setId(window.getLocalityId());
				locality.setDescription(window.getLocalityDesc());
				locality.setLatitude(window.getLatitude());
				locality.setLongitude(window.getLongitude());
				if(locality_id == -1)
					Application.addNewLocality(locality, window.getLocalityMuniciaplityIndex(), window.getLocalityTypeId());
				else
					Application.modifyLocality(locality, window.getLocalityMuniciaplityIndex(), window.getLocalityTypeId());
				break;
			default:
				throw new UnsupportedOperationException("Wykryto nieobdługiwane zdarzenie"+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu przypisania uprawnienia w regionie
	 * */
	private void handleAssignPermissionInRegionView(ActionEvent e){
		PermissionInRegionEditorView window = (PermissionInRegionEditorView) Window.getCurrentView();
		switch (e.getActionCommand())
		{
			case EventCommand.assignPermissionInRegionToUser:
				Application.givePermissionInRegion(window.getVoivodshipId(), window.getUserLogin(), window.getPermissionId());
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}
	}

	/**
	 * Zdarzenia ekranu przypisania uprawnienia do regionu
	 * */
	private void handleAssignPermissionToRegionView(ActionEvent e){
		PermissionToRegionEditorView window = (PermissionToRegionEditorView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openAssignPermissionInRegionView:
				Application.openPermissionInRegionView(window.getVoivodshipIndex(), window.getUserLogin());
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
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
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e.getActionCommand());
		}

	}

	/**
	 * Zdarzenia listy miejscowości
	 * */
	private void handleLocalityListEvents(ActionEvent e){
		LocalitiesListView window = (LocalitiesListView) Window.getCurrentView();

		if(e.getActionCommand().contains(EventCommand.openLocalityEditor)){
			String[] command = e.getActionCommand().split(" ");
			Application.openLocalityEditor(Integer.parseInt(command[2]));
			return;
		}
		else if (e.getActionCommand().contains(EventCommand.deleteLocality)){
			String[] command = e.getActionCommand().split(" ");
			Application.deleteLocality(Integer.parseInt(command[2]));
			return;
		}
		else if (e.getActionCommand().contains(EventCommand.openLocalityView)){
			String[] command = e.getActionCommand().split(" ");
			Application.examineLocalityData(Integer.parseInt(command[1]));
			return;
		}

		switch (e.getActionCommand()){
			case EventCommand.addNewLocality:
				Application.openNewLocalityEditor();
				break;
			case EventCommand.openPreviousView:
				Application.openHomeDisplay();
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsługiwane zdarzenia: "+e.getActionCommand());
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
			case EventCommand.openFavouriteList:
				Application.browseFavouriteList();
				break;
			case EventCommand.openPreviousView:
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
			case EventCommand.openPreviousView:
				Application.openHomeDisplay();
				break;
			default:
				if(e.getActionCommand().contains(EventCommand.openUserAccountView))
				{
					String[] command = e.getActionCommand().split(" ");
					Application.openAccountDisplay(command[command.length-1], false);
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

		if(e.getActionCommand().contains(EventCommand.openAssignPermissionInRegionView)){
			String[] command = e.getActionCommand().split(" ");
			int voivodshipId = Integer.parseInt(command[1]);
			Application.openPermissionInRegionView(voivodshipId, window.getUserLogin());
			return;
		}
		else if (e.getActionCommand().contains(EventCommand.unassignPermissionToRegion)){
			String[] command = e.getActionCommand().split(" ");
			int voivodshipId = Integer.parseInt(command[4]);
			Application.takeAwayPermissionToRegion(voivodshipId, window.getUserLogin());
			return;
		}

		switch(e.getActionCommand()){
			case EventCommand.modifyUserRole:
				Application.changeUserRole(window.getUserLogin(), window.getRoleIndex());
				break;
			case EventCommand.openPreviousView:
				if(Application.getCurrentUser().getRole().equals(UserRole.TECHNICAL_ADMINISTRATOR))
					Application.browseUsersList();
				else
					Application.openHomeDisplay();
				break;
			case EventCommand.openAssignPermissionToRegionView:
				Application.givePermissionToRegion(window.getUserLogin());
				break;
			case EventCommand.deleteUserAccount:
				Application.deleteUserAccount(window.getUserLogin());
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e);
		}
	}
}