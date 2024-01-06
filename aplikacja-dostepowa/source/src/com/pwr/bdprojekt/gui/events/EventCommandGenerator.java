package com.pwr.bdprojekt.gui.events;

public class EventCommandGenerator {

    /**
     * Generowanie komendy logującej użytkownika
     * */
    static public String loginUser(){
        return EventCommand.loginUser;
    }

    /**
     * Generowanie komendy rejestrującej użytkownika
     * */
    static public String registerUser(){
        return EventCommand.registerUser;
    }

}
