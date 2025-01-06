CREATE TABLE ascenseurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE ascenseurs_etages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ascenseur_id INT NOT NULL,
    etage_number INT NOT NULL,
    pos_x FLOAT NOT NULL,
    pos_y FLOAT NOT NULL,
    pos_z FLOAT NOT NULL,
    FOREIGN KEY (ascenseur_id) REFERENCES ascenseurs(id) ON DELETE CASCADE
);
