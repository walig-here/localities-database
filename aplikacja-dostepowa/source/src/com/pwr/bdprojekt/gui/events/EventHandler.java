package com.pwr.bdprojekt.gui.events;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.*;
import com.pwr.bdprojekt.logic.Application;
import com.pwr.bdprojekt.logic.DataBaseApi;
import com.pwr.bdprojekt.logic.entities.*;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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
					handleAddressEditorEvents(e);
				}
				case ATTRACTION_EDITOR, NEW_ATTRACTIOn_EDITOR -> {
					handelAttractionEditorEvents(e);
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
					handleAssignAddressViewEvents(e);
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
	 * Zdarzenia ekranu edytora atrakcji
	 * */
	private void handelAttractionEditorEvents(ActionEvent e){
		AttractionEditorView window = (AttractionEditorView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.openAttractionView, EventCommand.openPreviousView:
				Application.examineLocalityData(window.getLocalityId());
				break;
			case EventCommand.refreshView:
				if(window.getAttractionId() == -1)
					Application.openNewAttractionEditor(window.getLocalityId());
				else
					Application.openAttractionEditor(window.getAttractionId(), window.getLocalityId());
				break;
			case EventCommand.modifyBaseAttractionData:
				Attraction attraction = new Attraction();
				attraction.setName(window.getAttractionName());
				attraction.setDescription(window.getAttractionDesc());

				if(window.getAttractionId()==-1)
				{
					Application.setCurrentlyAddedAttraction(attraction);
					Application.showAvailableAddresses(window.getLocalityId(), window.getAttractionId());
				}
				else
				{
					attraction.setId(window.getAttractionId());
					Application.modifyAttraction(attraction);
				}
				break;
			case EventCommand.assignTypesToAttraction:
				Application.assignTypesToAttractions(window.getAttractionTypesIds(), window.getAttractionId(), window.getLocalityId());
				break;
			default:
				throw new UnsupportedOperationException("Wykryto nieobsługiwane zdarzenie: "+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu edyora adresu
	 * */
	private void handleAddressEditorEvents(ActionEvent e){
		AddressEditorView window = (AddressEditorView) Window.getCurrentView();
		switch (e.getActionCommand()){
			case EventCommand.addAddressToLocalityAndAssignAttractionToIt:
				Locality locality = new Locality();
				locality.setId(window.getLocalityId());

				Address address = new Address();
				address.setLocality(locality);
				address.setStreet(window.getStreetName());
				address.setBuilding_number(window.getBuildingNumber());
				address.setFlat_number(window.getFlatNumber());

				if(window.getAttractionId()==-1)
				{
					Application.addNewAttraction(address);
				}
				else{
					Application.assignAttractionToLocality(window.getAttractionId(), address);
				}
				break;
			case EventCommand.refreshView:
				Application.openNewAddressEditor(window.getLocalityId(), window.getAttractionId());
				break;
			default:
				throw new UnsupportedOperationException("Wykryto nieobsługiwane zdarzenie: "+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu przypisania adresu
	 * */
	private void handleAssignAddressViewEvents(ActionEvent e){
		AssignAddressView window = (AssignAddressView) Window.getCurrentView();

		if(e.getActionCommand().contains(EventCommand.assignAddressToAttraction)){
			String[] command = e.getActionCommand().split( " ");
			Application.assignAddressToAttraction(window.getAttractionId(), Integer.parseInt(command[2]), window.getLocalityId());
			return;
		}

		switch (e.getActionCommand()){
			case EventCommand.openAddressEditorView:
				Application.openNewAddressEditor(window.getLocalityId(), window.getAttractionId());
				break;
			case EventCommand.refreshView:
				Application.showAvailableAddresses(window.getLocalityId(), window.getAttractionId());
				break;
			default:
				throw new UnsupportedOperationException("Wykryto nieobsługiwane zdarzenie: "+e.getActionCommand());
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
				Application.openNewAttractionEditor(window.getLocalityId());
				break;
			case EventCommand.refreshView:
				Application.showAvailableAttractions(window.getLocalityId());
				break;
			default:
				if(e.getActionCommand().contains(EventCommand.assignAttractionToLocality)){
					String[] command = e.getActionCommand().split(" ");
					Application.showAvailableAddresses(window.getLocalityId(), Integer.parseInt(command[2]));
					return;
				}
				throw new UnsupportedOperationException("Wykryto nieobsługiwany wyjątek: "+e.getActionCommand());
		}
	}

	/**
	 * Zdarzenia ekranu danych miejscowości
	 * */
	private void handleLocalityDataViewEvents(ActionEvent e){
		LocalityDataView window = (LocalityDataView) Window.getCurrentView();

		if(e.getActionCommand().contains(EventCommand.unassignAttractionFromLocality)){
			String[] command = e.getActionCommand().split(" ");
			Application.deleteAttractionFromLocality(window.getLocalityId(), Integer.parseInt(command[2]));
			return;
		}
		else if(e.getActionCommand().contains(EventCommand.openAttractionEditor)){
			String[] command = e.getActionCommand().split(" ");
			Application.openAttractionEditor(Integer.parseInt(command[2]), window.getLocalityId());
			return;
		}

		switch (e.getActionCommand()){
			case EventCommand.openLocalityEditor:
				Application.openLocalityEditor(window.getLocalityId());
				break;
			case EventCommand.deleteLocality:
				Application.deleteLocality(window.getLocalityId());
				break;
			case EventCommand.openPreviousView:
				if(Window.getPreviousDisplayType().equals(ViewType.FAVOURITE_LOCALITY_LIST) || Window.getPreviousDisplayType().equals(ViewType.FAVOURITE_LOCALITY_LIST_MERITORICAL_ADMIN))
					Application.browseFavouriteList();
				else
					Application.browseLocalitiesList();
				break;
			case EventCommand.addLocalityToFavourites:
				Locality locality = new Locality();
				locality.setId(window.getLocalityId());
				Application.addLocalityToFavourites(locality, window.getAddnotation());
				break;
			case EventCommand.openAvailableAttractionsView:
				Application.showAvailableAttractions(window.getLocalityId());
				break;
			case EventCommand.removeLocalityFromFavourites:
				Application.deleteLocalityFromFavourites(window.getLocalityId());
				break;
			case EventCommand.refreshView:
				Application.examineLocalityData(window.getLocalityId());
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
				locality.setPopulation(window.getPopulation());
				locality.setLatitude(window.getLatitude());
				locality.setLongitude(window.getLongitude());
				if(locality_id == -1)
					Application.addNewLocality(locality, window.getLocalityMuniciaplityIndex(), window.getLocalityTypeId());
				else
					Application.modifyLocality(locality, window.getLocalityMuniciaplityIndex(), window.getLocalityTypeId());
				break;
			case EventCommand.refreshView:
				if(window.getLocalityId() == -1)
					Application.openNewLocalityEditor();
				else
					Application.openLocalityEditor(window.getLocalityId());
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
			case EventCommand.refreshView:
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e.getActionCommand());
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
			case EventCommand.refreshView:
				Application.givePermissionToRegion(window.getUserLogin());
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e.getActionCommand());
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
			case EventCommand.refreshView:
				if(Window.getCurrentViewType().equals(ViewType.FAVOURITE_LOCALITY_LIST_MERITORICAL_ADMIN) || Window.getCurrentViewType().equals(ViewType.FAVOURITE_LOCALITY_LIST))
					Application.browseFavouriteList();
				else
					Application.browseLocalitiesList();
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
			case EventCommand.refreshView:
				Application.openHomeDisplay();
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
			case EventCommand.refreshView:
				Application.browseUsersList();
				break;
			default:
				if(e.getActionCommand().contains(EventCommand.openUserAccountView))
				{
					String[] command = e.getActionCommand().split(" ");
					Application.openAccountDisplay(command[command.length-1], false);
					break;
				}
				else throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e.getActionCommand());
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
			int voivodshipIndex;
			List<AdministrativeUnit> administrativeUnits = DataBaseApi.selectVoivodships("");
			for(voivodshipIndex = 0; voivodshipIndex < administrativeUnits.size(); voivodshipIndex++){
				if(administrativeUnits.get(voivodshipIndex).getId() == voivodshipId)
					break;
			}

			Application.openPermissionInRegionView(voivodshipIndex, window.getUserLogin());
			return;
		}
		else if (e.getActionCommand().contains(EventCommand.unassignPermissionToRegion)){
			String[] command = e.getActionCommand().split(" ");
			int voivodshipId = Integer.parseInt(command[4]);
			Application.takeAwayPermissionToRegion(voivodshipId, window.getUserLogin());
			return;
		}
		else if(e.getActionCommand().contains(EventCommand.unassignPermissionInRegion)){
			String[] command = e.getActionCommand().split(" ");
			Application.takeAwayPermissionInRegion(window.getUserLogin(), Integer.parseInt(command[4]), Integer.parseInt(command[5]));
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
			case EventCommand.refreshView:
				Application.openAccountDisplay(window.getUserLogin(), Application.getCurrentUser().getLogin().equals(window.getUserLogin()));
				break;
			default:
				throw new UnsupportedOperationException("Wystąpiło nieobsugiwane zdarzenie: " + e.getActionCommand());
		}
	}
}