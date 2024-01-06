package com.pwr.bdprojekt.gui.components;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Edytowalne pole tekstowe, posiadające podpis, który znajduje się bezpośrednio nad nim. Możliwe jest uruchomienie
 * resetowania zawartości pola do wybranej wartości domyślnej na żądanie użytkownika. Wówczas po prawej stronie pola
 * pojawia się przycisk resetujący.
 * <p>
 * Przykładowy wygląd:
 * <p>-----------------------</p>
 * <p>| zawartość...| reset |</p>
 * <p>-----------------------</p>
 */
public class TextField extends GuiComponent {

//======================================================================================================================
// STAŁE

	public static final int RESET_BUTTON_WIDTH = 70;

//======================================================================================================================
// POLA

    /**
     * Domyślna zawartość pola
     */
    private String default_value;

    /**
     * Podpis pola
     */
    private Text label;

    /**
     * Zawartość pola
     */
    private JTextArea content;

    /**
     * Przycisk resetu
     */
    private Button reset_button;

    /**
     * Liczba linijek pola
     */
    private int number_of_lines;

//======================================================================================================================
// METODY

    /**
     * Tworzy nowe pole tekstowe wypełnione domyślną zawartością (bez możliwości resetu).
     *
     * @param parent        panel lub element GUI, wewnątrz którego ma być umieszczony tworzony element GUI
     * @param label         podpis
     * @param default_value domyślna zawartość
	 * @param lines 		liczba linijek pola
     */
    public TextField(JPanel parent, String label, String default_value, int lines) {
        super(parent);

        // Podpis
        this.label = new Text(this, label);

        // Zawartość pola
        this.default_value = default_value;
        content = new JTextArea(default_value);
		content.setBorder(BorderFactory.createLineBorder(Color.BLACK));
        add(content);
        number_of_lines = lines;
		setSizeOfElement(0, Text.HEIGHT + number_of_lines * Text.HEIGHT);

        // Rozmieszczenie elementów
        setLayout(null);
		redraw();
    }

    public String getText() {
        // TODO - implement ResetableTextField.getText
        throw new UnsupportedOperationException();
    }

    /**
     * @param number_of_lines
     */
    public void setNumberOfLines(int number_of_lines) {
        // TODO - implement ResetableTextField.setNumberOfLines
        throw new UnsupportedOperationException();
    }

    /**
	 * Ustala, czy pole tekstowe ma mieć możliwość resetowania zawartości od wartości domyślnej.
     * @param resetable czy pole tekstowe ma być resetowalne?
     */
    public void setResetable(boolean resetable) {
		if(resetable){
			reset_button = new Button(this, "Reset", a -> reset());
		}
		else
		{
			reset_button = null;
		}
    }

    private void reset() {
        content.setText(default_value);
    }


    /**
     * @param editable
     */
    public void setEditable(boolean editable) {
        // TODO - implement ResetableTextField.setEditable
        throw new UnsupportedOperationException();
    }

    @Override
    protected void redraw() {
		// Podpis
        label.setPosition(0, 0);
        label.setSizeOfElement(getWidth(), Text.LETTER_HEIGHT);

        // Wariant z możliwościa resetu
        if (reset_button != null) {
            // Zawartość
            content.setBounds(
                    parent.getX(),
                    label.getBottomY(),
                    getWidth() - RESET_BUTTON_WIDTH,
                    Text.LETTER_HEIGHT * number_of_lines
            );

			// Przycisk
			reset_button.setPosition(content.getX()+content.getWidth(), content.getY());
			reset_button.setSizeOfElement(RESET_BUTTON_WIDTH, Text.LETTER_HEIGHT);
        }
        // Wariant bez resetu
        else {
            // Zawartość
            content.setBounds(
                    label.getX(),
                    label.getBottomY(),
                    getWidth(),
                    Text.LETTER_HEIGHT * number_of_lines
            );
        }

		// Ustalenie wysokości elementu
		final int this_height = label.getHeight() + content.getHeight();
		setBounds(getX(), getY(), getWidth(), this_height);
    }

    @Override
    protected void updateData(String[] data) {
        // zostawić - nie ma tu co tutaj aktualizować
    }
}