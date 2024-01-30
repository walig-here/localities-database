package com.pwr.bdprojekt.logic.entities;

import com.pwr.bdprojekt.logic.DataBaseApi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Attraction {

	private int id;
	private String name;
	private String description;
	private Address address;
	private List<AttractionType> attractionTypes = new ArrayList<>();

	public List<AttractionType> getAttractionTypes() {
		return attractionTypes;
	}

	public void setAddress(Address address) {
		this.address = address;
	}

	public Address getAddress() {
		return address;
	}

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

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setAttractionTypes(List<Integer> attractionTypeIndices){
		attractionTypes.clear();
		List<AttractionType> availableAttractionTypes = DataBaseApi.selectAttractionTypes("");
		for (Integer attractionTypeIndex : attractionTypeIndices) {
			for(int index = 0; index < availableAttractionTypes.size(); index++)
				if(index == attractionTypeIndex)
					attractionTypes.add(availableAttractionTypes.get(index));
		}
	}
}