package com.pwr.bdprojekt.logic;

import com.pwr.bdprojekt.gui.Window;
import com.pwr.bdprojekt.gui.components.DataTable;
import com.pwr.bdprojekt.gui.displays.ViewType;
import com.pwr.bdprojekt.logic.entities.*;

import javax.print.attribute.standard.ReferenceUriSchemesSupported;
import java.util.ArrayList;
import java.util.List;


/**
 * Logika aplikacji
 * */
public class Application {

	private static User current_user = null;	// aktualnie zalogowany użytkownik
	private static boolean is_running = false;	// czy aplikacja jest włączona

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
			Window.switchToView(ViewType.LOCALITY_LIST_ADMIN_MERIT, dataForGui.toArray(new String[0]));
		else
			Window.switchToView(ViewType.LOCALITY_LIST, dataForGui.toArray(new String[0]));
	}

	public static void browseFavouriteList() {
		// TODO - implement Logic.browseFavouriteList
		throw new UnsupportedOperationException();
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
			User user = DataBaseApi.selectUsers("login = '"+userLogin+"'").get(0);
			boolean success = DataBaseApi.delUser(user);
			if(success){
				Window.showMessageBox("Konto zostało usunięte");
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
			AdministrativeUnit administrativeUnit = DataBaseApi.selectVoivodships("").get(voivodshipIndex);
			DataBaseApi.unassignPermissionFromUser(user, administrativeUnit, null);
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

	public static void takeAwayPermissionInRegion() {
		// TODO - implement Logic.takeAwayPermissionInRegion
		throw new UnsupportedOperationException();
	}

	public static void addLocalityToFavourites() {
		// TODO - implement Logic.addLocalityToFavourites
		throw new UnsupportedOperationException();
	}

	public static void removeLocalityFromFavourites() {
		// TODO - implement Logic.removeLocalityFromFavourites
		throw new UnsupportedOperationException();
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
				attractionNames += attraction.getName() + ",";
				attractionDescs += attraction.getDescription() + ";";
				attractionAddresses +=
						attraction.getAddress().getStreet()+", "+
						attraction.getAddress().getBuilding_number()+", "+
						attraction.getAddress().getFlat_number()+"'";
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

	public static void assignAttractionToLocality() {
		// TODO - implement Logic.assignAttractionToLocality
		throw new UnsupportedOperationException();
	}

	public static void modifyAttraction(Attraction attraction) {
		if(DataBaseApi.modifyAttraction(attraction))
			Window.showMessageBox("Poprawnie zmodyfikowano!");
		else Window.showMessageBox("Zmiana nie powiodła się!");
	}

	public static void deleteAttractionFromLocality() {
		// TODO - implement Logic.deleteAttractionFromLocality
		throw new UnsupportedOperationException();
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

	public static void addNewAttraction(Attraction attraction, Address address) {
		if(DataBaseApi.addNewAttraction(attraction, address))
			Window.showMessageBox("Nowa atrakcja została poprawnie dodana!");
		else Window.showMessageBox("Nie udało się dodać atrakcji!");
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

	public static void assignAddressToAttraction() {
		// TODO - implement Logic.assignAddressToAttraction
		throw new UnsupportedOperationException();
	}

	public static void addNewAddress() {
		// TODO - implement Logic.addNewAddress
		throw new UnsupportedOperationException();
	}

	public static void assignFigureToAttraction() {
		// TODO - implement Logic.assignFigureToAttraction
		throw new UnsupportedOperationException();
	}

	public static void addNewFiugre() {
		// TODO - implement Logic.addNewFiugre
		throw new UnsupportedOperationException();
	}

	public static void deleteAttraction(Attraction attraction) {
		if(DataBaseApi.delAttraction(attraction))
			Window.showMessageBox("Miejscowość została usunięta!");
		else
			Window.showMessageBox("Usunięcie miejscowości nie powiodło się");
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
				String dataForVoivodship = i + ";" + voivodship.getName();
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