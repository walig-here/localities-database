package com.pwr.bdprojekt.gui.events;

import com.pwr.bdprojekt.gui.displays.*;
import com.pwr.bdprojekt.gui.*;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class EventHandler implements ActionListener {

	private View current_view;

	public void actionPerformed() {
		// TODO - implement EventHandler.actionPerformed
		throw new UnsupportedOperationException();
	}

	/**
	 * 
	 * @param current_view
	 */
	public EventHandler(View current_view) {
		this.current_view = current_view;
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		System.out.println("=> " + e.getActionCommand());
	}
}