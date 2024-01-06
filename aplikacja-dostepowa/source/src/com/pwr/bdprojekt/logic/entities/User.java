package com.pwr.bdprojekt.logic.entities;

public class User {

	private String login;
	private UserRole role;

	public User(String login, UserRole role)
	{
		this.login = login;
		this.role = role;
	}

	public String getLogin() {
		return login;
	}

	public UserRole getRole() {
		return role;
	}

	public String getRoleName()
	{
		switch (role) {
			case VIEWER -> {
				return "PRZEGLĄDAJĄCY";
			}
			case TECHNICAL_ADMIN -> {
				return "ADMINISTRATOR TECHNICZNY";
			}
			case MERITORICAL_ADMIN -> {
				return "ADMINISTRATOR MERYTORYCZNY";
			}
		}
		return "BRAK ROLI";
	}

}