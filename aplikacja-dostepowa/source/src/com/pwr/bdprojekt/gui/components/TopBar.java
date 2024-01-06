package com.pwr.bdprojekt.gui.components;

import com.pwr.bdprojekt.logic.Application;
import com.pwr.bdprojekt.logic.entities.User;

import javax.swing.*;
import java.awt.*;

/**
 * Belka zlokalizowana na szczycie ekranu. Zawiera: dane o aktualnie zalogowanym użytkowniku, przyciski do nawigowania
 * między kluczowymi ekranami aplikacji, przyciski wylogowania i odświeżenia.
 * */
public class TopBar extends GuiComponent {

	private JLabel login;
	private JLabel role;

	public TopBar(JPanel parent) {
		super(parent);
		setBorder(BorderFactory.createLineBorder(Color.BLACK));
		setBackground(Color.WHITE);
	}

	public void setUserData()
	{
		User current_user = Application.getCurrentUser();
		login.setText(current_user.getLogin());
		role.setText("(" + current_user.getRoleName() + ")");
	}

	@Override
	protected void redraw() {

	}

	@Override
	protected void updateData(String[] data) {
		setUserData();
	}
}