CREATE DATABASE gestion_app;
USE gestion_app;

-- Table des comptes utilisateurs
CREATE TABLE Auth_accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(150) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role ENUM('Client','Medecin','Admin','SuperAdmin') NOT NULL,
    actif BOOLEAN DEFAULT TRUE,
    derniere_connexion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table Clients
CREATE TABLE Clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    auth_id INT UNIQUE,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    telephone VARCHAR(20),
    date_naissance DATE,
    sexe ENUM('M','F'),
    adresse TEXT,
    ville VARCHAR(100),
    photo VARCHAR(255),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auth_id) REFERENCES Auth_accounts(id) ON DELETE CASCADE
);

-- Table Médecins
CREATE TABLE Medecins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    auth_id INT UNIQUE,
    matricule VARCHAR(50),
    nom VARCHAR(100),
    prenom VARCHAR(100),
    specialite VARCHAR(100),
    numero_licence VARCHAR(100),
    telephone VARCHAR(20),
    biographie TEXT,
    photo VARCHAR(255),
    horaires TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auth_id) REFERENCES Auth_accounts(id) ON DELETE CASCADE
);

-- Table Admins
CREATE TABLE Admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    auth_id INT UNIQUE,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    telephone VARCHAR(20),
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auth_id) REFERENCES Auth_accounts(id) ON DELETE CASCADE
);

-- Table Catégories
CREATE TABLE Categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table Produits
CREATE TABLE Produits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categorie_id INT NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(150) NOT NULL,
    description TEXT,
    prix DECIMAL(10,2) NOT NULL,
    quantite_stock INT NOT NULL,
    image VARCHAR(255),
    necessite_ordonnance ENUM('OUI','NON'),
    date_ajout DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categorie_id) REFERENCES Categories(id) ON DELETE RESTRICT
);

-- Table Commandes
CREATE TABLE Commandes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    date_commande DATETIME NOT NULL,
    statut ENUM('En attente','Validée','Annulée','Livrée') DEFAULT 'En attente',
    montant_total DECIMAL(10,2) NOT NULL,
    methode ENUM('Mobile Money','Carte bancaire') NOT NULL,
    ordonnance_url VARCHAR(255),
    FOREIGN KEY (client_id) REFERENCES Clients(id) ON DELETE CASCADE
);

-- Table Détails Commande
CREATE TABLE Details_commande (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commande_id INT NOT NULL,
    produit_id INT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    sous_total DECIMAL(10,2),
    FOREIGN KEY (commande_id) REFERENCES Commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (produit_id) REFERENCES Produits(id) ON DELETE RESTRICT
);

-- Table Paiements
CREATE TABLE Paiements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commande_id INT,
    montant DECIMAL(10,2) NOT NULL,
    methode ENUM('Mobile Money','Carte bancaire') NOT NULL,
    statut ENUM('En attente','Confirmé','Echec') DEFAULT 'En attente',
    transaction_reference VARCHAR(150),
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES Commandes(id) ON DELETE CASCADE
);

-- Table Ordonnances
CREATE TABLE Ordonnances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commande_id INT,
    client_id INT,
    fichier_url VARCHAR(255) NOT NULL,
    statut ENUM('En attente','Validée','Refusée') DEFAULT 'En attente',
    date_upload DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES Commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES Clients(id) ON DELETE CASCADE
);

-- Table Validation Ordonnances
CREATE TABLE Validation_Ordonnances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ordonnance_id INT,
    medecin_id INT,
    decision ENUM('Validée','Refusée','En attente') DEFAULT 'En attente',
    commentaire TEXT,
    date_validation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ordonnance_id) REFERENCES Ordonnances(id) ON DELETE CASCADE,
    FOREIGN KEY (medecin_id) REFERENCES Medecins(id) ON DELETE SET NULL
);

-- Table Avis Clients
CREATE TABLE Avis_Clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    produit_id INT,
    note INT NOT NULL,
    commentaire TEXT,
    date_avis DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES Clients(id) ON DELETE CASCADE,
    FOREIGN KEY (produit_id) REFERENCES Produits(id) ON DELETE RESTRICT
);

-- Table Statistiques Ventes
CREATE TABLE Statistiques_Ventes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date_stat DATE DEFAULT CURRENT_TIMESTAMP,
    total_ventes DECIMAL(10,2),
    nombre_commandes INT
);

-- Table Planning Médecins
CREATE TABLE Planning_Medecins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    medecin_id INT,
    jour ENUM('Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche') NOT NULL,
    heure_debut TIME,
    heure_fin TIME,
    FOREIGN KEY (medecin_id) REFERENCES Medecins(id) ON DELETE CASCADE
);

ALTER TABLE Auth_accounts
ADD CONSTRAINT chk_email_gmail
CHECK (email LIKE '%@gmail.com');

-- Mot de passe non vide
ALTER TABLE Auth_accounts
ADD CONSTRAINT chk_password CHECK (LENGTH(mot_de_passe) >= 8);

-- Prix positif
ALTER TABLE Produits
ADD CONSTRAINT chk_prix CHECK (prix > 0);

-- Stock non négatif
ALTER TABLE Produits
ADD CONSTRAINT chk_stock CHECK (quantite_stock >= 0);

-- Montant total positif
ALTER TABLE Commandes
ADD CONSTRAINT chk_montant CHECK (montant_total > 0);

-- Statut valide
ALTER TABLE Commandes
ADD CONSTRAINT chk_statut CHECK (statut IN ('En attente','Validée','Annulée','Livrée'));


-- Montant positif
ALTER TABLE Paiements
ADD CONSTRAINT chk_paiement_montant CHECK (montant > 0);


-- Statut valide
ALTER TABLE Paiements
ADD CONSTRAINT chk_paiement_statut CHECK (statut IN ('En attente','Confirmé','Echec'));


-- Note entre 1 et 5
ALTER TABLE Avis_Clients
ADD CONSTRAINT chk_note CHECK (note BETWEEN 1 AND 5);

-- Total ventes positif
ALTER TABLE Statistiques_Ventes
ADD CONSTRAINT chk_total_ventes CHECK (total_ventes >= 0);

-- Nombre de commandes positif
ALTER TABLE Statistiques_Ventes
ADD CONSTRAINT chk_nombre_commandes CHECK (nombre_commandes >= 0);

