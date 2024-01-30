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
        this.label = new Text(this, label, 1);

        // Zawartość pola
        this.default_value = default_value;
        content = new JTextArea(default_value);
		content.setBorder(BorderFactory.createLineBorder(Color.BLACK));
        add(content);
        number_of_lines = lines;
        if(number_of_lines > 1)
            content.setLineWrap(true);
		setSizeOfElement(0, Text.HEIGHT + number_of_lines * Text.HEIGHT);
        setBackground(Color.WHITE);

        // Rozmieszczenie elementów
        setLayout(null);
		redraw();
    }

    /**
     * Pobranie zawartości
     * */
    public String getText() {
        return content.getText();
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

    public void reset() {
        content.setText(default_value);
    }

    @Override
    protected void redraw() {
		// Podpis
        label.setPosition(0, 0);
        label.setSizeOfElement(getWidth(), label.getHeight());

        // Wariant z możliwościa resetu
        if (reset_button != null) {
            // Zawartość
            content.setBounds(
                    0,
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

    /**
     * Ustalenie zawartości domyślnej
     * @param default_value nowa zawartość domyślna
     * @param set_to_default czy pole tekstowe po wykonaniu metody ma zawierać podaną wartośc odmyślną?
     * */
    public void setDefaultValue(String default_value, boolean set_to_default){
        this.default_value = default_value;
        if(set_to_default)
            setText(default_value);
    }

    /**
     * Ustalenie, czy pole jest edytowalne
     * */
    public void setEditable(boolean editable){
        content.setEditable(editable);
    }

    /**
     * Ustalenie zawartości
     * */
    public void setText(String text){
        content.setText(text);
    }

    protected void updateData(String[] data) {
        // zostawić - nie ma tu co tutaj aktualizować
    }
}