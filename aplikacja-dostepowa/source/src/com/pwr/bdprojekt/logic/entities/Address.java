package com.pwr.bdprojekt.logic.entities;

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
}