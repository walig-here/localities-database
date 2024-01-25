package com.pwr.bdprojekt.logic.entities;

public class Locality {

	private int id;
	private String name;
	private String description;
	private int population;
    private AdministrativeUnit municipality;
    private AdministrativeUnit county;
    private AdministrativeUnit voivodship;
	private double latitude;
	private double longitude;
	private LocalityType type;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public AdministrativeUnit getMunicipality() {
		return municipality;
	}

	public void setMunicipality(AdministrativeUnit municipality) {
		this.municipality = municipality;
	}

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	public LocalityType getType() {
		return type;
	}

	public void setType(LocalityType type) {
		this.type = type;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getPopulation() {
		return population;
	}

	public void setPopulation(int population) {
		this.population = population;
	}
}