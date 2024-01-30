package com.pwr.bdprojekt.logic.entities;

import com.pwr.bdprojekt.logic.DataBaseApi;

public class Address {

	private int id;
	private Locality locality;
	private String street;
	private String building_number;
	private String flat_number;

	public Locality getLocality() {
		return locality;
	}

	public void setLocality(Locality locality) {
		this.locality = locality;
	}

	public String getStreet() {
		return street;
	}

	public void setStreet(String street) {
		this.street = street;
	}

	public String getBuilding_number() {
		return building_number;
	}

	public void setBuilding_number(String building_number) {
		this.building_number = building_number;
	}

	public String getFlat_number() {
		return flat_number;
	}

	public void setFlat_number(String flat_number) {
		this.flat_number = flat_number;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	@Override
	public String toString(){
		String string = "";
		try{
			Locality locality = DataBaseApi.selectLocalities("locality_id="+this.locality.getId()).get(0);
			string += locality.getName();
			if(!street.isEmpty())
				string += ", ";
		} catch (NullPointerException e){
			return "N/A";
		}

		if(!street.isEmpty())
			string += street;
		if(!street.isEmpty() && (!building_number.isEmpty() || !flat_number.isEmpty()))
			string += ", ";
		if(!building_number.isEmpty())
			string += building_number;
		if(!building_number.isEmpty() && !flat_number.isEmpty())
			string += ", ";
		if(!flat_number.isEmpty())
			string += flat_number;

		return string;
	}
}