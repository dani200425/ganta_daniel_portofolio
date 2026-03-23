use LENSA

-----------------------------------------------------------------------------------------
----------------------------------------CLIENTI------------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Clienti (nume, prenume, email, telefon, data_inregistrare) VALUES
    ('Cernat', 'Raluca', 'raluca@gmail.com', '0770143551', '2025-08-08'),
    ('Gherban', 'Marius', 'gherban@gmail.com', '0762850225', '2024-08-09'),
    ('Marinache', 'Maria', 'marin@yahoo.com', '0789546214', '2024-04-04'),
    ('Ionescu', 'Maria', 'maria@yahoo.com', '0789546215', '2024-04-04');

SELECT * FROM Clienti;
INSERT INTO Clienti (nume, prenume, email, telefon) VALUES
    ('Ganta', 'Daniel', 'dani@gmail.com', '0771243551');
INSERT INTO Clienti (nume, prenume, email, telefon) VALUES
        ('Gant', 'George', 'dan@gmail.com', '0771243521');

-----------------------------------------------------------------------------------------
----------------------------------------ANGAJATI-----------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Angajati (nume, prenume, functie, salariu) VALUES
    ('Popescu', 'Andrei', 'Vanzator', 3500.00),
    ('Ionescu', 'Maria', 'Optometrist', 5000.00),
    ('Georgescu', 'Cristian', 'Manager', 7000.00),
    ('Popescu', 'George', 'Vanzator', 2500.00);

SELECT * FROM Angajati;

-----------------------------------------------------------------------------------------
------------------------------------CATEGORII_PRODUSE------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Categorii_Produse (denumire) VALUES
    ('Ochelari de soare'),
    ('Lentile de contact'),
    ('Rame de vedere');

SELECT * FROM Categorii_Produse;

-----------------------------------------------------------------------------------------
---------------------------------------BRANDURI------------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Branduri (nume_brand) VALUES
    ('Ray-Ban'),
    ('Johnson & Johnson'),
    ('Polaroid');

SELECT * FROM Branduri;

-----------------------------------------------------------------------------------------
----------------------------------------PRODUSE------------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Produse (nume_produs, pret, stoc, id_categorie, id_brand) VALUES
    ('Aviator Classic', 450.00, 50, 1, 1),   -- Ochelari de soare (1), Ray-Ban (1)
    ('Acuvue Moist', 120.50, 100, 2, 2),    -- Lentile de contact (2), Johnson & Johnson (2)
    ('Montura Eleganta', 300.00, 30, 3, 3), -- Rame de vedere (3), Polaroid (3)
    ('Aviator Modern', 750.00, 20, 1, 1);   -- Ochelari de soare (1), Ray-Ban (1)

SELECT * FROM Produse;

-----------------------------------------------------------------------------------------
----------------------------------------FURNIZORI----------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Furnizori (nume_furnizor, tara, email) VALUES
    ('Razv', 'Romania','ravz@yahoo.com'),
    ('Luxdorapet', 'Romania','lux@gmail.com'),
    ('Mafis','Columbia','col@outlook.com'),
    ('Marfus','Jamaica',NULL);

SELECT * FROM Furnizori;

-----------------------------------------------------------------------------------------
----------------------------------------FURNIZORI_PRODUSE--------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Furnizori_Produse (id_furnizor, id_produs) VALUES 
    (1,1),
    (2,2);

SELECT * FROM Furnizori_Produse;

-----------------------------------------------------------------------------------------
----------------------------------------COMENZI------------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Comenzi (id_client, id_angajat, data_comanda, status_comanda) VALUES
    (1,1,'2025-08-08','finalizat'),
    (2,1,'2025-08-09','finalizat'),
    (2,2,'2025-08-10','finalizat');
SELECT * FROM Comenzi;

-----------------------------------------------------------------------------------------
-----------------------------------------PLATI-------------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Plati (id_comanda, metoda_plata, data_plata) VALUES
    (1,'card','2025-08-08'),
    (2,'card','2025-08-09');

SELECT * FROM Plati;

-----------------------------------------------------------------------------------------
------------------------------------DETALII_COMANDA--------------------------------------
-----------------------------------------------------------------------------------------
INSERT INTO Detalii_Comenzi (id_comanda, id_produs, cantitate) VALUES
    (1,1,2),
    (2,2,1),
    (3,1,1);
SELECT * FROM Detalii_Comenzi;


-----------------------------------------------------------------------------------------
----------------------------------EXEMPLE DE INTEGRITATE---------------------------------
-----------------------------------------------------------------------------------------
-- Exemplu de INSERT care violează integritatea referențială:
-- Încercăm să inserăm o comandă cu un id_client sau id_angajat care nu există (de ex., 99)
-- Această comandă va eșua, demonstrând violarea constrângerii cheii externe.
/*
INSERT INTO Comenzi (id_client, id_angajat, data_comanda, status_comanda)
VALUES (99, 1, '2025-10-31', 'Noua'); -- id_client 99 nu exista în tabelul Clienti
*/
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
----------------------------------SELECT - DELETE & RESET--------------------------------
-----------------------------------------------------------------------------------------
SELECT * FROM Clienti;
SELECT * FROM Angajati;
SELECT * FROM Categorii_Produse;
SELECT * FROM Branduri;
SELECT * FROM Produse;
SELECT * FROM Furnizori;
SELECT * FROM Furnizori_Produse;
SELECT * FROM Comenzi;
SELECT * FROM Plati;
SELECT * FROM Detalii_Comenzi;
SELECT * FROM Produse;


DELETE FROM Detalii_Comenzi;
DBCC CHECKIDENT ('Detalii_Comenzi', RESEED, 0);

DELETE FROM Plati;
DBCC CHECKIDENT ('Plati', RESEED, 0);

DELETE FROM Comenzi;
DBCC CHECKIDENT ('Comenzi', RESEED, 0);

DELETE FROM Furnizori_Produse;
DBCC CHECKIDENT ('Furnizori_Produse', RESEED, 0);

DELETE FROM Furnizori;
DBCC CHECKIDENT ('Furnizori', RESEED, 0);

DELETE FROM Produse;
DBCC CHECKIDENT ('Produse', RESEED, 0);

DELETE FROM Branduri;
DBCC CHECKIDENT ('Branduri', RESEED, 0);

DELETE FROM Categorii_Produse;
DBCC CHECKIDENT ('Categorii_Produse', RESEED, 0);

DELETE FROM Angajati;
DBCC CHECKIDENT ('Angajati', RESEED, 0);

DELETE FROM Clienti;
DBCC CHECKIDENT ('Clienti', RESEED, 0);
