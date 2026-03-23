USE LENSA;
GO

PRINT '--- 2. A. CLUSTERED INDEX SCAN ---';
-- Operatorul citește toate rândurile, parcurgând indexul clusterizat.
SELECT id_client, nume, prenume
FROM Clienti;
GO

PRINT '--- 2. B. CLUSTERED INDEX SEEK ---';
-- Operatorul folosește cheia primară (Clustered Index Key) pentru a găsi rândul direct.
SELECT id_client, nume, prenume
FROM Clienti
WHERE id_client = 3;
GO

PRINT '--- 2. C. NONCLUSTERED INDEX SCAN ---';
-- Operatorul citește întregul index non-clusterizat (UQ_Clienti).
-- Coloanele cerute fac parte din indexul Nonclustered.
SELECT nume, prenume, email
FROM Clienti;
GO

PRINT '--- 2. D. NONCLUSTERED INDEX SEEK ---';
-- Operatorul folosește cheia indexului non-clusterizat (UQ_Clienti) pentru a găsi rândul direct.
SELECT nume, prenume
FROM Clienti
WHERE nume = 'Ionescu' AND prenume = 'Maria';
GO

PRINT '--- 2. E. KEY LOOKUP (urmat de Index Seek) ---';
-- Nonclustered Index Seek pentru nume/prenume, dar se cere o coloană (data_inregistrare) care NU este inclusă în indexul non-clusterizat (UQ_Clienti).
-- SQL Server face Index Seek, apoi Key Lookup (citire costisitoare în indexul clusterizat) pentru coloana lipsă.
SELECT nume, prenume, data_inregistrare
FROM Clienti
WHERE nume = 'Ionescu';
GO

-------------------------------------------------------------------------
-- 3. REZOLVAREA CERINȚEI B. (OPȚIMIZAREA PE TB -> PRODUSE)
-------------------------------------------------------------------------

PRINT '--- 3. A. PLAN INIȚIAL (FĂRĂ INDEX PE PRET) ---';
-- Va rezulta 'Clustered Index Scan', deoarece nu există un index specific pe coloana 'pret'.
SELECT nume_produs, stoc
FROM Produse
WHERE pret = 300.00;
GO

-- Șterge orice index vechi pentru demonstrație
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_Produse_Pret_Simplu')
    DROP INDEX IX_Produse_Pret_Simplu ON Produse;

PRINT '--- 3. B. CREARE INDEX SIMPLU PE PRET ȘI RE-ANALIZĂ ---';
-- Se creează un index pentru a accelera căutarea.
CREATE NONCLUSTERED INDEX IX_Produse_Pret_Simplu ON Produse (pret);

-- Planul va conține 'Index Seek' pe IX_Produse_Pret_Simplu URMAT de 'Key Lookup'
-- (pentru a obține coloanele 'nume_produs' și 'stoc' care nu sunt în index).
SELECT nume_produs, stoc
FROM Produse
WHERE pret = 300.00;
GO

PRINT '--- 3. C. CREARE INDEX COVERING (OPTIZARE MAXIMĂ) ȘI RE-ANALIZĂ ---';
-- Se șterge indexul simplu și se creează un Index Covering pentru a elimina Key Lookup-ul.
DROP INDEX IX_Produse_Pret_Simplu ON Produse;

CREATE NONCLUSTERED INDEX IX_Produse_Pret_Covering
ON Produse (pret)
INCLUDE (nume_produs, stoc);

-- Planul va conține doar 'Index Seek' pe IX_Produse_Pret_Covering
-- (Toate coloanele necesare sunt în index, nu este necesar Key Lookup).
SELECT nume_produs, stoc
FROM Produse
WHERE pret = 300.00;
GO

-------------------------------------------------------------------------
-- 4. REZOLVAREA CERINȚEI C. (VIEW ȘI ANALIZA INDEXĂRII)
-------------------------------------------------------------------------

PRINT '--- 4. A. CREARE VIEW (JOIN CLIENTI ȘI COMENZI) ---';

IF OBJECT_ID('V_Comenzi_Clienti') IS NOT NULL
    DROP VIEW V_Comenzi_Clienti;
go 

CREATE VIEW V_Comenzi_Clienti AS
SELECT
    C.id_client,
    C.nume AS Nume_Client,
    C.prenume AS Prenume_Client,
    CO.id_comanda,
    CO.data_comanda
FROM Clienti C
JOIN Comenzi CO ON C.id_client = CO.id_client;
GO

PRINT '--- 4. B. ANALIZA PLANULUI VIEW-ULUI (VERIFICARE INDECȘI EXISTENȚI) ---';
-- Căutarea după data_comanda.
-- id_client este cheie primară (Clustered) în Clienti
-- id_client este cheie străină (Nonclustered Index) în Comenzi
-- Optimizatorul folosește acești indecși pentru a face join-ul eficient.

SELECT Nume_Client, id_comanda, data_comanda
FROM V_Comenzi_Clienti
WHERE data_comanda > '2024-05-04';
GO
-- Planul de execuție va arăta o combinație de Clustered/Index Seek-uri pe cheile primare/străine 
-- (id_client) urmată de un Nested Loops Join.

-- Reasessare Indecși/Cardinalitate:
-- Coloana data_comanda are o cardinalitate mare (multe valori unice).
-- Dacă View-ul ar fi interogat frecvent doar după data_comanda, ar fi benefic:
-- CREATE NONCLUSTERED INDEX IX_Comenzi_DataComanda ON Comenzi (data_comanda);
-- În contextul interogării de mai sus, optimizatorul folosește 'Clustered Index Scan' pe Comenzi, 
-- deoarece nu există un index pe 'data_comanda' care să acopere (sau să fie mai ieftin decât) un scan.
-- Dacă numărul de rânduri ar fi mare, un index pe (data_comanda) ar fi necesar.

-- DEMONSTRAREA REASESSĂRII
CREATE NONCLUSTERED INDEX IX_Comenzi_DataComanda ON Comenzi (data_comanda);

SELECT Nume_Client, id_comanda, data_comanda
FROM V_Comenzi_Clienti
WHERE data_comanda > '2024-05-04';
GO
-- DUPA CREAREA INDEXULUI: Planul se îmbunătățește, trecând la 'Index Seek' pe noul index, 
-- urmat de un 'Nested Loops Join' cu 'Clienti', ceea ce este mai eficient.