package com.pwr.bdprojekt.logic;

import com.pwr.bdprojekt.gui.Window;
import com.pwr.bdprojekt.gui.displays.AttractionEditorView;
import com.pwr.bdprojekt.gui.displays.ViewType;
import com.pwr.bdprojekt.logic.entities.*;

import java.util.ArrayList;
import java.util.List;


/**
 * Logika aplikacji
 * */
public class Application {

	private static User current_user = null;	// aktualnie zalogowany użytkownik
	private static boolean is_running = false;	// czy aplikacja jest włączona

	private static Attraction currentlyAddedAttraction = null;

	public static User getCurrentUser() {
		return current_user;
	}

	public static void register(String login, String password) {
		// TODO - implement Logic.register

		String errorMessage = DataBaseApi.registerUser(login, password);
		if(errorMessage.equals("")){
			Window.showMessageBox("Rejestracja powiodła się");
		}else{
			Window.showMessageBox(errorMessage);
		}
	}

	public static void logiIn(String login, String password) {
		if(!DataBaseApi.connect(login, password)){
			Window.showMessageBox("Logowanie nieudane!");
			return;
		}
		current_user = DataBaseApi.getCurrentUser(login);

		openHomeDisplay();
	}

	public static void logOut() {
		boolean success = DataBaseApi.closeConnection(current_user.getLogin());
		if(!success){
			Window.showMessageBox("Nie udało się wylogować!");
			return;
		}
		Window.switchToView(ViewType.LOGIN, new String[]{});
	}

	public static void setCurrentlyAddedAttraction(Attraction attraction){
		currentlyAddedAttraction = attraction;
	}

	/**
	 * Przeglądanie listy użytkowników
	 * */
	public static void browseUsersList()
	{
		// pobranie użytkowników z bazy
		List<String> dataForGui = new ArrayList<>();
		List<User> usersFromDatabase = DataBaseApi.selectUsers("");
		if(usersFromDatabase == null){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add("");
		dataForGui.add(String.join(",", new String[]{}));
		dataForGui.add(String.join(",", new String[]{}));

		// ustalenie danych użytkowników
		for (User user : usersFromDatabase) {
			dataForGui.add(user.getLogin() + ";" + user.getRoleName());
		}

		// otworzenie widoku listy miejscowości
		Window.switchToView(ViewType.USERS_LIST, dataForGui.toArray(new String[]{}));
	}

	public static void browseLocalitiesList() {
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add("1,1");
		dataForGui.add("1,1");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");

		List<Locality> localities = DataBaseApi.selectLocalities("");
		if(localities == null){
			Window.showMessageBox("Błąd pobierania danych miejscowości");
			return;
		}
		for (Locality locality : localities) {
			String localityData = locality.getId()+";";
			localityData += locality.getName() + ";";
			localityData += locality.getType().getName() + ";";
			localityData += locality.getMunicipality().getName() + ", " +
							locality.getMunicipality().getSuperiorAdministrativeUnit().getName() + ", " +
							locality.getMunicipality().getSuperiorAdministrativeUnit().getSuperiorAdministrativeUnit().getName() + ";";
			localityData += locality.getPopulation() + ";";
			localityData += DataBaseApi.getLocalitiesNumberOfAttraction(locality) + ";";

			if(DataBaseApi.selectFavouriteLocalities("locality_id="+locality.getId()).size()>0){
				localityData += "true";
			}
			else{
				localityData += "false";
			}

			dataForGui.add(localityData);
		}

		if(current_user.getRole().equals(UserRole.MERITORICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.LOCALITY_LIST_ADMIN_MERIT, dataForGui.toArray(new String[0]));
		else
			Window.switchToView(ViewType.LOCALITY_LIST, dataForGui.toArray(new String[0]));
	}

	public static void browseFavouriteList() {
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add("1,1");
		dataForGui.add("1,1");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");

		List<Locality> localities = DataBaseApi.selectFavouriteLocalities("");
		if(localities == null){
			Window.showMessageBox("Błąd pobierania danych miejscowości");
			return;
		}
		for (Locality locality : localities) {
			String localityData = locality.getId()+";";
			localityData += locality.getName() + ";";
			localityData += locality.getType().getName() + ";";
			localityData += locality.getMunicipality().getName() + ", " +
					locality.getMunicipality().getSuperiorAdministrativeUnit().getName() + ", " +
					locality.getMunicipality().getSuperiorAdministrativeUnit().getSuperiorAdministrativeUnit().getName() + ";";
			localityData += locality.getPopulation() + ";";
			localityData += "0" + ";";

			if(DataBaseApi.selectFavouriteLocalities("locality_id="+locality.getId()).size()>0){
				localityData += "true";
			}
			else{
				localityData += "false";
			}

			dataForGui.add(localityData);
		}

		if(current_user.getRole().equals(UserRole.MERITORICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.FAVOURITE_LOCALITY_LIST_MERITORICAL_ADMIN, dataForGui.toArray(new String[0]));
		else
			Window.switchToView(ViewType.FAVOURITE_LOCALITY_LIST, dataForGui.toArray(new String[0]));
	}

	public static void examineUserData() {
		// TODO - implement Logic.examineUserData
		throw new UnsupportedOperationException();
	}

	public static void changeUserRole(String login, int roleIndex) {
		UserRole role;
		switch (roleIndex){
			case 0: role = UserRole.VIEWER; break;
			case 1: role = UserRole.MERITORICAL_ADMINISTRATOR; break;
			case 2: role = UserRole.TECHNICAL_ADMINISTRATOR; break;
			default:
				Window.showMessageBox("Wybrana rola nie jest poprawna!");
				return;
		}
		User user = new User(login, role);

		if(DataBaseApi.modifyUserRole(user, user.getRole())){
			Window.showMessageBox("Zmieniono rolę użytkownika!");
			Application.openAccountDisplay(user.getLogin(), false);
		}
		else{
			Window.showMessageBox("Nie udało się zmienić roli!");
		}
	}

	public static void deleteUserAccount(String userLogin) {
		try{
			User user;
			if(userLogin.equals(current_user.getLogin()))
				user = current_user;
			else
				user = DataBaseApi.selectUsers("login = '"+userLogin+"'").get(0);
			boolean success = DataBaseApi.delUser(user);
			if(success){
				Window.showMessageBox("Konto zostało usunięte");
				if(current_user.getLogin().equals(userLogin))
					Application.logOut();
				else
					Application.browseUsersList();
			}
			else{
				Window.showMessageBox("Nie udało się usunąć konta!");
			}
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
		}
	}

	public static void givePermissionToRegion(String userLogin) {
		try{
			User user = DataBaseApi.selectUsers("login = '"+userLogin+"'").get(0);
			if(!user.getRole().equals(UserRole.MERITORICAL_ADMINISTRATOR)){
				Window.showMessageBox("Nie można nadać uprawnień\nużytkownikowi!");
				return;
			}
		} catch(NullPointerException e){
			Window.showMessageBox("Błąd pobierania użytkownika");
			return;
		}

		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add(userLogin);

		List<AdministrativeUnit> voivodships = DataBaseApi.selectVoivodships("");
		String voivodshipList = "";
		for (AdministrativeUnit voivodship : voivodships) {
			voivodshipList += voivodship.getName() + ",";
		}
		dataForGui.add(voivodshipList);

		Window.switchToView(ViewType.PERMISSION_TO_REGION_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void takeAwayPermissionToRegion(int voivodshipIndex, String userLogin) {
		try{
			User user = DataBaseApi.selectUsers("login = '"+userLogin+"'").get(0);
			AdministrativeUnit administrativeUnit = DataBaseApi.selectVoivodships("administrative_unit_id="+voivodshipIndex).get(0);
			if(DataBaseApi.unassignPermissionFromUser(user, administrativeUnit, null)){
				Application.openAccountDisplay(userLogin, false);
			}
			else {
				Window.showMessageBox("Nie udało się usunąć uprawnienia!");
			}
		}
		catch(NullPointerException e){
			Window.showMessageBox("Błąd pobierania dnaych z bazy");
		}
	}

	public static void givePermissionInRegion(int voivodship_id, String user_login, int permission_id){
		try{
			AdministrativeUnit voivodship = DataBaseApi.selectVoivodships("administrative_unit_id = "+voivodship_id).get(0);
			User user = DataBaseApi.selectUsers("login = '"+user_login+"'").get(0);
			Permission permission = DataBaseApi.selectPermissions().get(permission_id);

			boolean success = DataBaseApi.assignPermissionToUser(voivodship, user, permission);
			if(!success){
				Window.showMessageBox("Nie udało się nadać\n uprawnienia!");
				return;
			}

			Application.openAccountDisplay(user_login, false);
		} catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
		}
	}

	public static void openPermissionInRegionView(int voivodship_index, String user_login) {
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add(user_login);

		// województwo, w którym nadawane jest uprawnienie
		try{
			AdministrativeUnit voivodship = DataBaseApi.selectVoivodships("").get(voivodship_index);
			dataForGui.add(Integer.toString(voivodship.getId()));
			dataForGui.add(voivodship.getName());

			List<Permission> permissions = DataBaseApi.selectPermissions();
			String permission_names = "";
			String permission_descs = "";
			for (Permission permission : permissions) {
				permission_names += permission.getName() + ",";
				permission_descs += permission.getDesc() + ";";
			}
			dataForGui.add(permission_names);
			dataForGui.add(permission_descs);
		}
		catch (NullPointerException e){
			Window.showMessageBox("Błąd pobieranie województwa z bazy!");
			return;
		}

		Window.switchToView(ViewType.PERMISSION_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void takeAwayPermissionInRegion(String userLogin, int voivodshipId, int permissionId) {
		try{
			User user = DataBaseApi.selectUsers("login = '"+userLogin+"'").get(0);
			AdministrativeUnit administrativeUnit = DataBaseApi.selectVoivodships("administrative_unit_id="+voivodshipId).get(0);
			Permission permission = DataBaseApi.selectPermissions().get(permissionId-1);
			if(DataBaseApi.unassignPermissionFromUser(user, administrativeUnit, permission)){
				Application.openAccountDisplay(userLogin, false);
			}
			else {
				Window.showMessageBox("Nie udało się usunąć uprawnienia!");
			}
		}
		catch(NullPointerException e){
			Window.showMessageBox("Błąd pobierania dnaych z bazy");
		}
	}

	public static void addLocalityToFavourites(Locality locality, String adnotation) {
		if(DataBaseApi.addLocalityToFavList(locality, adnotation)){
			Window.showMessageBox("Dodano do ulubionych!");
			Application.examineLocalityData(locality.getId());
		}
		else Window.showMessageBox("Dodanie do ulubionych nie powiodło się!");
	}

	public static void deleteLocalityFromFavourites(int localityId) {
		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id="+localityId).get(0);
			if(DataBaseApi.delLocalityFromFavList(locality)){
				Window.showMessageBox("Usunięto miejscowość z ulubionych!");
				Application.examineLocalityData(localityId);
			}
			else {
				Window.showMessageBox("Nie udało się usunąć miejscowości z ulubionych!");
			}
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy");
		}
	}

	public static void examineLocalityData(int localityId) {
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id = "+Integer.toString(localityId)).get(0);
			dataForGui.add(Integer.toString(locality.getId()));
			dataForGui.add(locality.getName());
			dataForGui.add(locality.getDescription());
			dataForGui.add(Integer.toString(locality.getPopulation()));
			dataForGui.add(locality.getType().getName());
			dataForGui.add(locality.getMunicipality().getSuperiorAdministrativeUnit().getSuperiorAdministrativeUnit().getName());
			dataForGui.add(locality.getMunicipality().getSuperiorAdministrativeUnit().getName());
			dataForGui.add(locality.getMunicipality().getName());
			dataForGui.add(Double.toString(locality.getLongitude()));
			dataForGui.add(Double.toString(locality.getLatitude()));

			List<Locality> favouriteLocality = DataBaseApi.selectFavouriteLocalities("locality_id = "+locality.getId());
			if(favouriteLocality.size() == 0){
				dataForGui.add("false");
				dataForGui.add("");
			}else{
				dataForGui.add("true");
				dataForGui.add(favouriteLocality.get(0).getAddnotation());
			}

			// atrakcje
			String attractionIds = "";
			String attractionNames = "";
			String attractionDescs = "";
			String attractionAddresses = "";
			String attractionTypes = "";

			List<Attraction> attractions = DataBaseApi.getAttractionsInLocality(locality);
			for (Attraction attraction : attractions) {
				attractionIds += attraction.getId() + ",";
				attractionNames += attraction.getName() + ";";
				attractionDescs += (attraction.getDescription().isEmpty() ? " " : attraction.getDescription()) + ";";
				attractionAddresses += attraction.getAddress().toString()+"'";

				List<AttractionType> attractionsTypes = DataBaseApi.getTypesAssignedToAttraction(attraction);
				for (AttractionType attractionsType : attractionsTypes) {
					attractionTypes += attractionsType.getName()+",";
				}
				if(attractionsTypes.size() == 0)
					attractionTypes += " ";
				attractionTypes += ";";
			}

			dataForGui.add(attractionIds);
			dataForGui.add(attractionNames);
			dataForGui.add(attractionDescs);
			dataForGui.add(attractionAddresses);
			dataForGui.add(attractionTypes);
		}catch (NullPointerException e) {
			Window.showMessageBox("Błąd pobierania danych miejscowości");
			return;
		}

		if(current_user.getRole().equals(UserRole.MERITORICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.LOCALITY_DATA_ADMIN_MERIT, dataForGui.toArray(new String[0]));
		else
			Window.switchToView(ViewType.LOCALITY_DATA, dataForGui.toArray(new String[0]));
	}

	public static void addAddnotation() {
		// TODO - implement Logic.addAddnotation
		throw new UnsupportedOperationException();
	}

	public static void openNewLocalityEditor(){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add("-1");
		dataForGui.add("");
		dataForGui.add("");
		dataForGui.add("");

		// typy miejscowości
		List<LocalityType> localityTypes = DataBaseApi.selectLocalityType("");
		if(localityTypes == null){
			Window.showMessageBox("Błąd pobierania typów miejscowości z bazy!");
			return;
		}
		String localityTypesNames = "";
		for (LocalityType localityType : localityTypes) {
			localityTypesNames += localityType.getName() + ",";
		}
		dataForGui.add(localityTypesNames);
		dataForGui.add("0");

		// gminy
		List<AdministrativeUnit> municipalities = DataBaseApi.selectMunicipalities("");
		if(municipalities == null){
			Window.showMessageBox("Błąd pobierania gmin z bazy!");
			return;
		}
		String municipalitiesNames = "";
		for (AdministrativeUnit municipality : municipalities) {
			municipalitiesNames += municipality.getName() + ",";
		}
		dataForGui.add(municipalitiesNames);
		dataForGui.add("0");

		dataForGui.add("0");
		dataForGui.add("0");

		Window.switchToView(ViewType.LOCALITY_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void openLocalityEditor(int localityId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add(Integer.toString(localityId));

		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id = "+localityId).get(0);
			dataForGui.add(locality.getName());
			dataForGui.add(locality.getDescription());
			dataForGui.add(Integer.toString(locality.getPopulation()));
			
			List<LocalityType> localityTypes = DataBaseApi.selectLocalityType("");
			String localityTypesNames = "";
			String assinedTypeIndex = "";
			int i = 0;
			for (LocalityType localityType : localityTypes) {
				localityTypesNames += localityType.getName()+",";
				if(localityType.getId() == locality.getType().getId()){
					assinedTypeIndex = Integer.toString(i);
				}
				i++;
			}
			dataForGui.add(localityTypesNames);
			dataForGui.add(assinedTypeIndex);

			List<AdministrativeUnit> municipalities = DataBaseApi.selectMunicipalities("");
			i = 0;
			String municipalitiesNames = "";
			String assignedMunicipalityIndex = "";
			for (AdministrativeUnit municipality : municipalities) {
				municipalitiesNames += municipality.getName() + ",";
				if(municipality.getId() == locality.getMunicipality().getId()){
					assignedMunicipalityIndex = Integer.toString(i);
				}
				i++;
			}
			dataForGui.add(municipalitiesNames);
			dataForGui.add(assignedMunicipalityIndex);

			dataForGui.add(Double.toString(locality.getLatitude()));
			dataForGui.add(Double.toString(locality.getLongitude()));
		} catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.LOCALITY_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void addNewLocality(Locality locality, int municipality_index, int type_index) {
		// pobranie gminy
		AdministrativeUnit municipality = DataBaseApi.selectMunicipalities("").get(municipality_index);
		locality.setMunicipality(municipality);

		// typ
		LocalityType localityType = DataBaseApi.selectLocalityType("").get(type_index);
		locality.setType(localityType);

		if(DataBaseApi.addNewLocality(locality)){
			Window.showMessageBox("Nowa miejscowość została dodana!");
			Application.browseLocalitiesList();
		}
		else
			Window.showMessageBox("Dodanie miejscowości nie powiodło się");
	}

	public static void assignAttractionToLocality(int attraction_id, Address address) {
		if(DataBaseApi.assignAttractionToLocality(attraction_id, address)){
			Window.showMessageBox("Przypisanie powiodło się!");
			Application.examineLocalityData(address.getLocality().getId());
		}
		else Window.showMessageBox("Przypisanie nie powiodło się!");
	}

	public static void modifyAttraction(Attraction attraction) {
		if(DataBaseApi.modifyAttraction(attraction))
			Window.showMessageBox("Poprawnie zmodyfikowano!");
		else Window.showMessageBox("Zmiana nie powiodła się!");
	}

	public static void deleteAttractionFromLocality(int localityId, int attractionId) {
		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id="+localityId).get(0);
			if(DataBaseApi.unassignAttractionFromLocality(attractionId, locality)){
				Window.showMessageBox("Usunięto atrakcję z miejscowości");
				Application.examineLocalityData(localityId);
			}
			else {
				Window.showMessageBox("Nie udało się usunąć atrakcji z miejscowości");
			}
		}
		catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania miejsciowości z bazy!");
		}
	}

	public static void openNewAttractionEditor(int localityId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		dataForGui.add("-1");
		dataForGui.add("");
		dataForGui.add("");

		try{
			List<AttractionType> attractionTypes = DataBaseApi.selectAttractionTypes("");
			String availableAttractionTypes = "";
			for (AttractionType attractionType : attractionTypes) {
				availableAttractionTypes += attractionType.getName()+",";
			}
			dataForGui.add(availableAttractionTypes);
			dataForGui.add("-1");

			dataForGui.add("");
			dataForGui.add("");
			dataForGui.add("");

			dataForGui.add(Integer.toString(localityId));
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.ATTRACTION_EDITOR, dataForGui.toArray(new String[0]));
	}



	public static void openAttractionEditor(int attractionId, int localityId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		try{
			Attraction attraction = DataBaseApi.selectAttractions("attraction_id="+attractionId).get(0);
			dataForGui.add(Integer.toString(attraction.getId()));
			dataForGui.add(attraction.getName());
			dataForGui.add(attraction.getDescription());

			// typy
			List<AttractionType> attractionTypes = DataBaseApi.selectAttractionTypes("");
			String availableAttractionTypes = "";
			for (AttractionType attractionType : attractionTypes) {
				availableAttractionTypes += attractionType.getName()+",";
			}
			dataForGui.add(availableAttractionTypes);

			String attractionTypesIndex = "";
			List<AttractionType> assignedAttractionTypes = DataBaseApi.getTypesAssignedToAttraction(attraction);
			for (AttractionType attractionType : assignedAttractionTypes) {
				for(int i = 0; i < attractionTypes.size(); i++){
					AttractionType type = attractionTypes.get(i);
					if(type.getId() == attractionType.getId())
						attractionTypesIndex += i + ",";
				}
			}
			if(attractionTypesIndex.isEmpty())
				attractionTypesIndex = "-1";
			dataForGui.add(attractionTypesIndex);

			// adresy
			List<Attraction> currentAttraction = DataBaseApi.selectAttractions("attraction_id="+attractionId);
			String addresses = "";
			for (Attraction attraction1 : currentAttraction) {
				addresses += attraction1.getAddress().toString() + ";";
			}
			dataForGui.add(addresses);

			// obrazki
			dataForGui.add("");
			dataForGui.add("");

			dataForGui.add(Integer.toString(localityId));
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.ATTRACTION_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void showAvailableAttractions(int localityId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());
		dataForGui.add(Integer.toString(localityId));

		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id = "+localityId).get(0);
			dataForGui.add(locality.getName());

			List<Attraction> attractions = DataBaseApi.selectAttractions(
					"attraction_id NOT IN (" +
							"SELECT attraction_id FROM locations_of_attractions WHERE locality_id="+localityId +
							")"
			);
			String attractionsNames = "";
			String attractionsDescs = "";
			String attractionIds = "";
			for (Attraction attraction : attractions) {
				attractionsNames += attraction.getName()+";";
				attractionsDescs += (attraction.getDescription().isEmpty() ? " " : attraction.getDescription())+";";
				attractionIds += attraction.getId()+",";
			}
			dataForGui.add(attractionsNames);
			dataForGui.add(attractionsDescs);
			dataForGui.add(attractionIds);
		} catch(NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.ASSIGN_ATTRACTION, dataForGui.toArray(new String[0]));
	}

	public static void deleteLocality(int localityId) {
		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id="+localityId).get(0);
			if(DataBaseApi.delLocality(locality)){
				Window.showMessageBox("Usunięto miejscowość!");
				Application.browseLocalitiesList();
			}
			else {
				Window.showMessageBox("Nie udało się usunąć miejscowości!");
			}
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy");
		}
	}

	public static void addNewAttraction(Address address) {
		boolean success = DataBaseApi.addNewAttraction(currentlyAddedAttraction, address);
		if(!success) Window.showMessageBox("Nie udało się dodać atrakcji!");
		else{
			Window.showMessageBox("Nowa atrakcja została poprawnie dodana!");
			Application.examineLocalityData(address.getLocality().getId());
		}
	}

	public static void modifyLocality(Locality locality, int municiplaity_index, int type_index) {
		// pobranie gminy
		AdministrativeUnit municipality = DataBaseApi.selectMunicipalities("").get(municiplaity_index);
		locality.setMunicipality(municipality);

		// typ
		LocalityType localityType = DataBaseApi.selectLocalityType("").get(type_index);
		locality.setType(localityType);

		if(DataBaseApi.modifyLocality(locality)){
			Window.showMessageBox("Poprawnie zmodyfikowano!");
			Application.browseLocalitiesList();
		}
		else Window.showMessageBox("Zmiana nie powiodła się!");
	}

	public static void openNewAddressEditor(int localityId, int attractionId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id = "+localityId).get(0);
			dataForGui.add(locality.getName());
			dataForGui.add(Integer.toString(locality.getId()));
			dataForGui.add(Integer.toString(attractionId));
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.ADDRESS_EDITOR, dataForGui.toArray(new String[0]));
	}

	public static void showAvailableAddresses(int localityId, int attractionId){
		List<String> dataForGui = new ArrayList<>();
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		dataForGui.add(Integer.toString(localityId));
		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id = "+localityId).get(0);
			dataForGui.add(locality.getName());

			dataForGui.add(Integer.toString(attractionId));
			dataForGui.add("");

			List<Address> addresses = DataBaseApi.getLocationsFromLocality(locality);
			String addressesList = "";
			for (Address address : addresses) {
				addressesList += address.toString()+";";
			}
			dataForGui.add(addressesList);
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		Window.switchToView(ViewType.ASSIGN_ADDRESS, dataForGui.toArray(new String[0]));
	}

	public static void assignAddressToAttraction(int attractionId, int addressIndex, int localityId) {
		Locality locality = new Locality();
		locality.setId(localityId);
		try{
			Address address = DataBaseApi.getLocationsFromLocality(locality).get(addressIndex);
			if(attractionId == -1)
				Application.addNewAttraction(address);
			else
				Application.assignAttractionToLocality(attractionId, address);
		}catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych adresu!");
		}
	}

	public static void assignFigureToAttraction() {
		// TODO - implement Logic.assignFigureToAttraction
		throw new UnsupportedOperationException();
	}

	public static void addNewFiugre() {
		// TODO - implement Logic.addNewFiugre
		throw new UnsupportedOperationException();
	}

	public static void assignTypesToAttractions(int[] typesIndices, int attractionId, int localityId){
		Attraction attraction = new Attraction();
		attraction.setId(attractionId);
		List<AttractionType> assignedTypes = DataBaseApi.getTypesAssignedToAttraction(attraction);
		for (AttractionType assignedType : assignedTypes) {
			DataBaseApi.unassignTypeFromAttraction(attractionId, assignedType);
		}

		List<AttractionType> types = DataBaseApi.selectAttractionTypes("");
		for(int i = 0; i < types.size(); i++){
			for (int typesIndex : typesIndices) {
				if(typesIndex == i && !DataBaseApi.assignTypeToAttraction(attractionId, types.get(i))){
					Window.showMessageBox("Nie udało się przypisać\ntypu do atrackji!");
					return;
				}
			}
		}
		Window.showMessageBox("Przypisano typy do atrakcji");
		Application.openAttractionEditor(attractionId, localityId);
	}

	public static void open() {
		is_running = true;
		Window.open("Baza danych miejscowości", 975, 600);
		if(!DataBaseApi.connect("root", "admin")){
			Window.showMessageBox("Nie udało się połączyć z bazą danych!\nZamykanie aplikacji...");
			quit();
		}
	}

	public static void quit() {
		is_running = false;
		Window.close();
		DataBaseApi.closeConnection("root");
		if(current_user != null)
			DataBaseApi.closeConnection(current_user.getLogin());
	}

	public static void openHomeDisplay() {
		if(current_user.getRole().equals(UserRole.TECHNICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.HOME_ADMIN_TECH, new String[]{current_user.getLogin(), current_user.getRoleName()});
		else
			Window.switchToView(ViewType.HOME, new String[]{current_user.getLogin(), current_user.getRoleName()});
	}

	public static void openAccountDisplay(String login, boolean openMyAccount)
	{
		List<String> dataForGui = new ArrayList<>();
		// dane aktualnego użytkownika
		dataForGui.add(current_user.getLogin());
		dataForGui.add(current_user.getRoleName());

		// pobranie danych użytkownika, którego konto przeglądamy
		try{
			User user;
			if(openMyAccount)
				user = current_user;
			else
				user = DataBaseApi.selectUsers("login = '" + login + "'").get(0);
			dataForGui.add(user.getLogin());
			dataForGui.add(user.getRoleName());

			List<AdministrativeUnit> voivodshipsManagedByUser = DataBaseApi.getVoivodshipsManagedByUser(user);
			int i = 0;
			for (AdministrativeUnit voivodship : voivodshipsManagedByUser) {
				String dataForVoivodship = voivodship.getId() + ";" + voivodship.getName();
				i++;

				List<Permission> permissionsInVoivodship = DataBaseApi.getUserPermissionsInVoivodship(user, voivodship);
				for (Permission permission : permissionsInVoivodship) {
					dataForVoivodship += ";" + permission.getId();
					dataForVoivodship += ";" + permission.getName();
					dataForVoivodship += ";" + permission.getDesc();
				}
				dataForGui.add(dataForVoivodship);
			}
		}
		catch (NullPointerException e){
			Window.showMessageBox("Błąd pobierania danych z bazy!");
			return;
		}

		if(current_user.getRole().equals(UserRole.TECHNICAL_ADMINISTRATOR))
			Window.switchToView(ViewType.USER_DATA_ADMIN_TECH, dataForGui.toArray(new String[0]));
		else
			Window.switchToView(ViewType.USER_DATA, dataForGui.toArray(new String[0]));
	}

	public static void openPreviousDisplay() {
		// TODO - implement Logic.openPreviousDisplay
		throw new UnsupportedOperationException();
	}

	public static void refreshDisplay() {
		Window.refresh();
	}

	/**
	 * 
	 * @param attraction_id
	 * @param figure_id
	 * @param caption
	 */
	public static void modifyCaption(String attraction_id, String figure_id, String caption) {
		// TODO - implement Logic.editCaption
		throw new UnsupportedOperationException();
	}

	private Application(){}

}