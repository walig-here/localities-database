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

    /**
     * Otworzenie widoku konta aktualnie zalogowanego użtykownika
     * */
    static public String openCurrentUserAccount(){
        return EventCommand.openCurrentUserAccount;
    }

    /**
     * Powrót do porzedniego widoku
     * */
    static public String openPreviousView(){
        return EventCommand.openPreviousView;
    }

    /**
     * Przejście do widoku domowego.
     * */
    static public String openHomeView(){
        return EventCommand.openHomeView;
    }

    /**
     * Odświeżenie widoku.
     * */
    static public String refreshView(){
        return EventCommand.refreshView;
    }

    /**
     * Wylogowanie aktualnego użytkownika
     * */
    static public String logOutCurrentUser(){
        return EventCommand.logOutCurrentUser;
    }

    /**
     * Otworzenie widoku listy miejscowości
     * */
    static public String openLocalityList(){
        return EventCommand.openLocalityList;
    }

    /**
     * Otworzenie widoku listy ulubionych miejscowości
     * */
    static public String openFavourtieList(){
        return EventCommand.openFavouriteList;
    }

    /**
     * Otworzenie widoku listy użytkowników
     * */
    static public String openUserList(){
        return EventCommand.openUserList;
    }
}
