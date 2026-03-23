DROP DATABASE IF EXISTS LENSA;



create database LENSA
use LENSA

-- Stergere tabele in ordinea corecta (pentru a evita erorile FK)
DROP TABLE IF EXISTS Detalii_Comenzi;
DROP TABLE IF EXISTS Furnizori_Produse;
DROP TABLE IF EXISTS Plati;
DROP TABLE IF EXISTS Comenzi;
DROP TABLE IF EXISTS Produse;
DROP TABLE IF EXISTS Clienti;
DROP TABLE IF EXISTS Angajati;
DROP TABLE IF EXISTS Categorii_Produse;
DROP TABLE IF EXISTS Branduri;
DROP TABLE IF EXISTS Furnizori;

-- Creare tabele cu IDENTITY pentru ID-uri
CREATE TABLE Clienti (
    id_client INT PRIMARY KEY IDENTITY(1,1),
    nume VARCHAR(100),
    prenume VARCHAR(100),
    email VARCHAR(100),
    telefon VARCHAR(20),
    data_inregistrare DATE
    constraint uq_clienti unique(nume,prenume,email,telefon)
);

CREATE TABLE Angajati (
    id_angajat INT PRIMARY KEY IDENTITY(1,1),
    nume VARCHAR(100),
    prenume VARCHAR(100),
    functie VARCHAR(50),
    salariu DECIMAL(10,2),
    CONSTRAINT UQ_Angajati UNIQUE (nume, prenume, functie)
);

CREATE TABLE Categorii_Produse (
    id_categorie INT PRIMARY KEY IDENTITY(1,1),
    denumire VARCHAR(100)
);

CREATE TABLE Branduri (
    id_brand INT PRIMARY KEY IDENTITY(1,1),
    nume_brand VARCHAR(100)
);

CREATE TABLE Produse (
    id_produs INT PRIMARY KEY IDENTITY(1,1),
    nume_produs VARCHAR(100),
    pret DECIMAL(10,2),
    stoc INT,
    id_categorie INT,
    id_brand INT,
    FOREIGN KEY (id_categorie) REFERENCES Categorii_Produse(id_categorie),
    FOREIGN KEY (id_brand) REFERENCES Branduri(id_brand)
);

CREATE TABLE Comenzi (
    id_comanda INT PRIMARY KEY IDENTITY(1,1),
    id_client INT,
    id_angajat INT,
    data_comanda DATE,
    status_comanda VARCHAR(50),
    FOREIGN KEY (id_client) REFERENCES Clienti(id_client),
    FOREIGN KEY (id_angajat) REFERENCES Angajati(id_angajat)
);

CREATE TABLE Detalii_Comenzi (
    id_comanda INT,
    id_produs INT,
    cantitate INT,
    pret_unitar DECIMAL(10,2),
    suma_totala decimal(10,2),
    PRIMARY KEY (id_comanda, id_produs),
    FOREIGN KEY (id_comanda) REFERENCES Comenzi(id_comanda),
    FOREIGN KEY (id_produs) REFERENCES Produse(id_produs)
);

CREATE TABLE Furnizori (
    id_furnizor INT PRIMARY KEY IDENTITY(1,1),
    nume_furnizor VARCHAR(100),
    tara VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE Furnizori_Produse (
    id_furnizor INT,
    id_produs INT,
    PRIMARY KEY (id_furnizor, id_produs),
    FOREIGN KEY (id_furnizor) REFERENCES Furnizori(id_furnizor),
    FOREIGN KEY (id_produs) REFERENCES Produse(id_produs)
);

CREATE TABLE Plati (
    id_plata INT PRIMARY KEY IDENTITY(1,1),
    id_comanda INT,
    metoda_plata VARCHAR(50),
    data_plata DATE,
    FOREIGN KEY (id_comanda) REFERENCES Comenzi(id_comanda)
);


GO  ---separa batch-urile (block-urile de comenzi)
CREATE TRIGGER trg_CompleteazaPretSiSuma    ----construim trigger pentru ca la introducere sau update de date pretul si suma totala sa se completeze singure
------dc, p, i sunt alias-uri. se face inner join pentru ca datele de la un tabel sa treaca la cel de detalii comenzi
ON Detalii_Comenzi
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE dc   ----se completeaza sau corecteaza automat pretul unitar si suma totala pentru detaliile comenzii curente.
    SET 
        dc.pret_unitar = p.pret,
        dc.suma_totala = i.cantitate * p.pret
    FROM Detalii_Comenzi dc
    INNER JOIN inserted i 
        ON dc.id_comanda = i.id_comanda AND dc.id_produs = i.id_produs
    INNER JOIN Produse p 
        ON i.id_produs = p.id_produs;
END;
GO

CREATE TRIGGER trg_UpdateStocProduse
ON Detalii_Comenzi
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.stoc = p.stoc - (i.cantitate - ISNULL(d.cantitate, 0))
    FROM Produse p
    INNER JOIN inserted i ON p.id_produs = i.id_produs
    LEFT JOIN deleted d ON p.id_produs = d.id_produs;

    PRINT 'Stocurile produselor au fost actualizate automat.';
END;
GO

select * from Categorii_Produse
select * from Produse