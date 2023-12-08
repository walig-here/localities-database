-- Tabela Permissions ------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Permissions (
  permission_id int(10) NOT NULL AUTO_INCREMENT, 
  name          varchar(50) NOT NULL, 
  description   varchar(1000) NOT NULL, 
  PRIMARY KEY (permission_id)
);

-- Tabela Attraction_Types -------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Attraction_Types (
  attraction_type_id int(10) NOT NULL AUTO_INCREMENT, 
  name               varchar(50) NOT NULL, 
  PRIMARY KEY (attraction_type_id), 
  INDEX (NAME)
);

-- Tabela Administrative_units ---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Administrative_units (
  administrative_unit_id       int(10) NOT NULL, 
  name                         varchar(50) NOT NULL, 
  type                         varchar(30) NOT NULL, 
  superior_administrative_unit int(10), 
  PRIMARY KEY (administrative_unit_id), 
  INDEX (superior_administrative_unit)
);
ALTER TABLE Administrative_units ADD CONSTRAINT FKAdministra497736 FOREIGN KEY (superior_administrative_unit) REFERENCES Administrative_units (administrative_unit_id);

-- Tabela Locality_Types --------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Locality_Types (
  locality_type_id int(10) NOT NULL AUTO_INCREMENT, 
  name             varchar(50) NOT NULL, 
  PRIMARY KEY (locality_type_id), 
  INDEX (NAME)
);

-- Tabela Users ------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Users (
  login    varchar(30) NOT NULL, 
  password char(48) NOT NULL, 
  role     VARCHAR(30) NOT NULL, 
  PRIMARY KEY (login)
);

-- Tabela Figures ----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Figures (
  figure_id int(10) NOT NULL AUTO_INCREMENT, 
  figure    blob NOT NULL, 
  PRIMARY KEY (figure_id)
);

-- Tabela Localities ------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Localities (
  locality_id      int(5) NOT NULL AUTO_INCREMENT, 
  name             varchar(50) NOT NULL, 
  DESCRIPTION  	 varchar(1000), 
  population       int(10) UNSIGNED, 
  municipality_id  int(10) NOT NULL, 
  latitude         real, 
  longitude        real, 
  locality_type_id int(10) NOT NULL, 
  PRIMARY KEY (locality_id), 
  INDEX (name), 
  INDEX (municipality_id), 
  INDEX (locality_type_id)
);
ALTER TABLE Localities ADD CONSTRAINT FKLocalities245678 FOREIGN KEY (locality_type_id) REFERENCES Locality_Types (locality_type_id);
ALTER TABLE Localities ADD CONSTRAINT FKLocalities574896 FOREIGN KEY (municipality_id) REFERENCES Administrative_units (administrative_unit_id);

-- Tabela Locations -------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Locations (
  location_id     int(10) NOT NULL AUTO_INCREMENT, 
  locality_id     int(5) NOT NULL, 
  street          varchar(50), 
  building_number varchar(10), 
  flat_number     varchar(10), 
  PRIMARY KEY (location_id), 
  INDEX (locality_id)
);
ALTER TABLE Locations ADD CONSTRAINT FKLocations403057 FOREIGN KEY (locality_id) REFERENCES Localities (locality_id);


-- Tabela Favourite_Localities --------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Favourite_Localities (
  locality_id int(5) NOT NULL, 
  login       varchar(30) NOT NULL, 
  adnotation  varchar(1000), 
  PRIMARY KEY (locality_id, 
  login), 
  INDEX (login)
  );
ALTER TABLE Favourite_Localities ADD CONSTRAINT FKFavourite_981560 FOREIGN KEY (locality_id) REFERENCES Localities (locality_id);
ALTER TABLE Favourite_Localities ADD CONSTRAINT FKFavourite_482397 FOREIGN KEY (login) REFERENCES Users (login);

-- Tabela Voivodships_Administrated_By_Users ------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Voivodships_Administrated_By_Users (
  login         varchar(30) NOT NULL, 
  voivodship_id int(10) NOT NULL, 
  PRIMARY KEY (login, 
  voivodship_id), 
  INDEX (login)
);
ALTER TABLE Voivodships_Administrated_By_Users ADD CONSTRAINT FKVoivodship178065 FOREIGN KEY (login) REFERENCES Users (login);
ALTER TABLE Voivodships_Administrated_By_Users ADD CONSTRAINT FKVoivodship87041 FOREIGN KEY (voivodship_id) REFERENCES Administrative_units (administrative_unit_id);

-- Users_Permissions_In_Voivodships ---------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Users_Permissions_In_Voivodships (
  login         varchar(30) NOT NULL, 
  voivodship_id int(10) NOT NULL, 
  permission_id int(10) NOT NULL, 
  PRIMARY KEY (login, 
  voivodship_id, 
  permission_id), 
  INDEX (login)
);
ALTER TABLE Users_Permissions_In_Voivodships ADD CONSTRAINT FKUsers_Perm990828 FOREIGN KEY (login, voivodship_id) REFERENCES Voivodships_Administrated_By_Users (login, voivodship_id);
ALTER TABLE Users_Permissions_In_Voivodships ADD CONSTRAINT FKUsers_Perm443111 FOREIGN KEY (permission_id) REFERENCES Permissions (permission_id);

-- Tabela Attractions -----------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Attractions (
  attraction_id int(10) NOT NULL AUTO_INCREMENT, 
  name          varchar(100) NOT NULL, 
  description   varchar(1000), 
  PRIMARY KEY (attraction_id), 
  INDEX (name)
);

-- Tabela Types_Assigned_To_Attractions -----------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Types_Assigned_To_Attractions (
  attraction_type_id int(10) NOT NULL, 
  attraction_id      int(10) NOT NULL, 
  PRIMARY KEY (attraction_type_id, 
  attraction_id), 
  INDEX (attraction_id)
);
ALTER TABLE Types_Assigned_To_Attractions ADD CONSTRAINT FKTypes_Assi695374 FOREIGN KEY (attraction_type_id) REFERENCES Attraction_Types (attraction_type_id);
ALTER TABLE Types_Assigned_To_Attractions ADD CONSTRAINT FKTypes_Assi239592 FOREIGN KEY (attraction_id) REFERENCES Attractions (attraction_id);

-- Tabela Figures_Containing_Attractions ----------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Figures_Containing_Attractions (
  figure_id     int(10) NOT NULL, 
  attraction_id int(10) NOT NULL, 
  caption       varchar(255), 
  PRIMARY KEY (figure_id, 
  attraction_id), 
  INDEX (attraction_id)
);
ALTER TABLE Figures_Containing_Attractions ADD CONSTRAINT FKFigures_Co325289 FOREIGN KEY (figure_id) REFERENCES Figures (figure_id);
ALTER TABLE Figures_Containing_Attractions ADD CONSTRAINT FKFigures_Co880499 FOREIGN KEY (attraction_id) REFERENCES Attractions (attraction_id);

-- Tabela Attractions_locations -------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Attractions_locations (
  attraction_id int(10) NOT NULL, 
  location_id   int(10) NOT NULL, 
  PRIMARY KEY (attraction_id, 
  location_id), 
  INDEX (location_id)
);
ALTER TABLE Attractions_locations ADD CONSTRAINT FKAttraction904049 FOREIGN KEY (attraction_id) REFERENCES Attractions (attraction_id);
ALTER TABLE Attractions_locations ADD CONSTRAINT FKAttraction940482 FOREIGN KEY (location_id) REFERENCES Locations (location_id);