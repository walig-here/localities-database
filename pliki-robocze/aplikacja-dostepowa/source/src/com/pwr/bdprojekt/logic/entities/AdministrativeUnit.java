package com.pwr.bdprojekt.logic.entities;

public class AdministrativeUnit {

	private int id;
	private String name;
	private AdministrativeUnit superior_administrative_unit;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public AdministrativeUnit getSuperiorAdministrativeUnit() {
		return superior_administrative_unit;
	}

	public void setSuperiorAdministrativeUnit(AdministrativeUnit superior_administrative_unit) {
		this.superior_administrative_unit = superior_administrative_unit;
	}
}