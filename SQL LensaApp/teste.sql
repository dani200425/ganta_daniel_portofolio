USE LENSA;
GO

----------------------------------------------------------------------------------------------------
-- SECTIUNEA 1: CURATAREA SI RE-CREAREA SCHEMEI DE TESTARE
----------------------------------------------------------------------------------------------------

-- Ordine ajustata pentru stergere corecta (Copil -> Parinte)
DROP TABLE IF EXISTS TestRunView;
DROP TABLE IF EXISTS TestRunTables;
DROP TABLE IF EXISTS TestViews;
DROP TABLE IF EXISTS TestTables;
DROP TABLE IF EXISTS TestRuns;
DROP TABLE IF EXISTS Tests;
DROP TABLE IF EXISTS Tables;
DROP TABLE IF EXISTS Views;
GO 

-- 2. Crearea tabelelor de metadate
CREATE TABLE [Tables] (
    [TableID] INT IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (50) NOT NULL UNIQUE,
    CONSTRAINT [PK_Tables] PRIMARY KEY ([TableID])
);

CREATE TABLE [Views] (
    [ViewID] INT IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (50) NOT NULL UNIQUE,
    CONSTRAINT [PK_Views] PRIMARY KEY ([ViewID])
);

CREATE TABLE [Tests] (
    [TestID] INT IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (50) NOT NULL UNIQUE,
    [Description] VARCHAR (100),
    CONSTRAINT [PK_Tests] PRIMARY KEY ([TestID])
);

CREATE TABLE [TestRuns] (
    [TestRunID] INT IDENTITY (1, 1) NOT NULL,
    [TestID] INT NOT NULL,
    [RunDate] DATETIME NULL,
    [Duration] DECIMAL(10, 3) NULL,
    CONSTRAINT [PK_TestRuns] PRIMARY KEY ([TestRunID]),
    CONSTRAINT [FK_TestRuns_Tests] FOREIGN KEY ([TestID]) REFERENCES [Tests] ([TestID])
);

CREATE TABLE [TestTables] (
    [TestTableID] INT IDENTITY (1, 1) NOT NULL,
    [TestID] INT NOT NULL,
    [TableID] INT NOT NULL,
    [Position] INT NOT NULL,
    [NoOfRows] INT NOT NULL,
    CONSTRAINT [PK_TestTables] PRIMARY KEY ([TestTableID]),
    CONSTRAINT [UQ_TestTables_Compus] UNIQUE ([TestID], [TableID]),
    CONSTRAINT [FK_TestTables_Tables] FOREIGN KEY ([TableID]) REFERENCES [Tables] ([TableID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_TestTables_Tests] FOREIGN KEY ([TestID]) REFERENCES [Tests] ([TestID]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [TestViews] (
    [TestViewsID] INT IDENTITY (1, 1) NOT NULL,
    [TestID] INT NOT NULL,
    [ViewID] INT NOT NULL,
    CONSTRAINT [PK_TestViews] PRIMARY KEY ([TestViewsID]),
    CONSTRAINT [UQ_TestViews_Compus] UNIQUE ([TestID], [ViewID]),
    CONSTRAINT [FK_TestViews_Tests] FOREIGN KEY ([TestID]) REFERENCES [Tests] ([TestID]),
    CONSTRAINT [FK_TestViews_Views] FOREIGN KEY ([ViewID]) REFERENCES [Views] ([ViewID])
);

CREATE TABLE [TestRunTables] (
    [TestRunTablesID] INT IDENTITY (1, 1) NOT NULL,
    [TestRunID] INT NOT NULL,
    [TableID] INT NOT NULL,
    [InsertDuration] DECIMAL(10, 3) NOT NULL,
    [NoOfRowsInserted] INT NOT NULL,
    CONSTRAINT [PK_TestRunTables] PRIMARY KEY ([TestRunTablesID]),
    CONSTRAINT [UQ_TestRunTables_Compus] UNIQUE ([TestRunID], [TableID]),
    CONSTRAINT [FK_TestRunTables_Tables] FOREIGN KEY ([TableID]) REFERENCES [Tables] ([TableID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_TestRunTables_TestRuns] FOREIGN KEY ([TestRunID]) REFERENCES [TestRuns] ([TestRunID]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [TestRunView] (
    [TestRunID] INT NOT NULL,
    [ViewID] INT NOT NULL,
    [QueryDuration] DECIMAL(10, 3) NOT NULL,
    CONSTRAINT [PK_TestRunView] PRIMARY KEY ([TestRunID], [ViewID]),
    CONSTRAINT [FK_TestRunView_TestRuns] FOREIGN KEY ([TestRunID]) REFERENCES [TestRuns] ([TestRunID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_TestRunView_Views] FOREIGN KEY ([ViewID]) REFERENCES [Views] ([ViewID]) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

----------------------------------------------------------------------------------------------------
-- SECTIUNEA 2: DEFINIREA VIEW-URILOR DE TESTARE
----------------------------------------------------------------------------------------------------

CREATE OR ALTER VIEW V_ClientiSimpli AS
SELECT id_client, nume, prenume FROM Clienti;
GO

CREATE OR ALTER VIEW V_ProduseBranduri AS
SELECT p.nume_produs, p.pret, b.nume_brand
FROM Produse p
INNER JOIN Branduri b ON p.id_brand = b.id_brand;
GO

CREATE OR ALTER VIEW V_TotalComenziClienti AS
SELECT c.nume, c.prenume, COUNT(co.id_comanda) AS NumarComenzi
FROM Clienti c
INNER JOIN Comenzi co ON c.id_client = co.id_client
GROUP BY c.nume, c.prenume;
GO
----------------------------------------------------------------------------------------------------
-- SECTIUNEA 3: PROCEDURA DE INSERARE (CORECTATA PENTRU Furnizori_Produse)
----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE insert_data_sp
    @TableID INT,
    @NoOfRows INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName NVARCHAR(50);
    SELECT @TableName = Name FROM Tables WHERE TableID = @TableID;

    IF @TableName IS NULL RETURN;

    -- =============================================
    -- TABEL: Categorii_Produse
    -- =============================================
    IF @TableName = 'Categorii_Produse'
    BEGIN
        DECLARE @i INT = 1;
        WHILE @i <= @NoOfRows
        BEGIN
            INSERT INTO Categorii_Produse (denumire)
            VALUES ('Categorie_Test_' + CAST(@i AS NVARCHAR) + '_' + CONVERT(NVARCHAR(50), NEWID()));
            SET @i = @i + 1;
        END
    END

    -- =============================================
    -- TABEL: Produse
    -- =============================================
    ELSE IF @TableName = 'Produse'
    BEGIN
        -- Generam parinti (Brand/Categorie) daca nu exista
        IF NOT EXISTS (SELECT 1 FROM Branduri) INSERT INTO Branduri (nume_brand) VALUES ('Brand_Default');
        IF NOT EXISTS (SELECT 1 FROM Categorii_Produse) INSERT INTO Categorii_Produse (denumire) VALUES ('Cat_Default');

        DECLARE @j INT = 1;
        DECLARE @RandCatID INT;
        DECLARE @RandBrandID INT;

        WHILE @j <= @NoOfRows
        BEGIN
            -- Selectam ID real existent
            SELECT TOP 1 @RandCatID = id_categorie FROM Categorii_Produse ORDER BY NEWID();
            SELECT TOP 1 @RandBrandID = id_brand FROM Branduri ORDER BY NEWID();

            INSERT INTO Produse (nume_produs, pret, stoc, id_categorie, id_brand)
            VALUES (
                'Produs_Test_' + CAST(@j AS NVARCHAR) + '_' + CONVERT(NVARCHAR(50), NEWID()),
                CAST(ABS(CHECKSUM(NEWID())) % 1000 + 100 AS DECIMAL(10,2)),
                ABS(CHECKSUM(NEWID())) % 100,
                @RandCatID,
                @RandBrandID
            );
            SET @j = @j + 1;
        END
    END

    -- =============================================
    -- TABEL: Detalii_Comenzi
    -- =============================================
    ELSE IF @TableName = 'Detalii_Comenzi'
    BEGIN
        -- Logica de suport (Angajat, Comanda, Client, Produs)
        IF NOT EXISTS (SELECT 1 FROM Angajati)
        BEGIN
            INSERT INTO Angajati (nume, prenume, functie, salariu)
            VALUES ('Angajat_Test', 'Default', 'Tester', 3000.00);
        END
        IF NOT EXISTS (SELECT 1 FROM Comenzi) 
        BEGIN
             IF NOT EXISTS (SELECT 1 FROM Clienti) 
             BEGIN
                INSERT INTO Clienti(nume, prenume, email, telefon, data_inregistrare) 
                VALUES (
                    'Client_Test', 
                    'User', 
                    'test_' + LEFT(CAST(NEWID() AS VARCHAR(50)), 8) + '@test.com', 
                    LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 15), 
                    GETDATE()
                );
             END
             DECLARE @ClientID INT = (SELECT TOP 1 id_client FROM Clienti);
             DECLARE @AngajatID INT = (SELECT TOP 1 id_angajat FROM Angajati);
             INSERT INTO Comenzi (id_client, id_angajat, data_comanda, status_comanda) 
             VALUES (@ClientID, @AngajatID, GETDATE(), 'Test_Initial');
        END
        IF NOT EXISTS (SELECT 1 FROM Produse) 
        BEGIN
           DECLARE @ProdTableID INT = (SELECT TableID FROM Tables WHERE Name = 'Produse');
           EXEC insert_data_sp @TableID = @ProdTableID, @NoOfRows = 10;
        END

        DECLARE @k INT = 1;
        DECLARE @RandComandaID INT;
        DECLARE @RandProdusID INT;

        WHILE @k <= @NoOfRows
        BEGIN
            -- Selectam ID real existent
            SELECT TOP 1 @RandComandaID = id_comanda FROM Comenzi ORDER BY NEWID();
            SELECT TOP 1 @RandProdusID = id_produs FROM Produse ORDER BY NEWID();

            BEGIN TRY
                INSERT INTO Detalii_Comenzi (id_comanda, id_produs, cantitate, pret_unitar, suma_totala)
                VALUES (
                    @RandComandaID,
                    @RandProdusID,
                    ABS(CHECKSUM(NEWID())) % 5 + 1,
                    CAST(ABS(CHECKSUM(NEWID())) % 500 + 50 AS DECIMAL(10,2)),
                    0 
                );
            END TRY
            BEGIN CATCH
                -- Ignoram duplicate PK
            END CATCH
            
            SET @k = @k + 1;
        END
    END
    
    -- =============================================
    -- TABEL: Furnizori_Produse 
    -- =============================================
    ELSE IF @TableName = 'Furnizori_Produse'
    BEGIN
        IF @NoOfRows > 0
        BEGIN
            -- Asiguram ca Furnizori si Produse exista
            IF NOT EXISTS (SELECT 1 FROM Furnizori) INSERT INTO Furnizori (nume_furnizor) VALUES ('Furnizor_Test_Default');
            IF NOT EXISTS (SELECT 1 FROM Produse) 
            BEGIN
                DECLARE @ProdTableID_FP INT = (SELECT TableID FROM Tables WHERE Name = 'Produse');
                EXEC insert_data_sp @TableID = @ProdTableID_FP, @NoOfRows = 10;
            END

            DECLARE @l INT = 1;
            DECLARE @RandProdusID_FP INT;
            DECLARE @RandFurnizorID INT = (SELECT TOP 1 id_furnizor FROM Furnizori);

            WHILE @l <= @NoOfRows
            BEGIN
                 SELECT TOP 1 @RandProdusID_FP = id_produs FROM Produse ORDER BY NEWID();

                 BEGIN TRY
                    -- CORECTIE: Inseram doar id_produs si id_furnizor (coloanele reale din schema ta)
                    INSERT INTO Furnizori_Produse (id_produs, id_furnizor) 
                    VALUES (
                        @RandProdusID_FP,
                        @RandFurnizorID
                    );
                 END TRY
                 BEGIN CATCH
                    -- Ignoram duplicate 
                 END CATCH
                 SET @l = @l + 1;
            END
        END
    END
END
GO

----------------------------------------------------------------------------------------------------
-- SECTIUNEA 4: POPULAREA METADATELOR DE TESTARE
----------------------------------------------------------------------------------------------------

-- 1. Inserare Tabele in tabelul 'Tables'
IF NOT EXISTS (SELECT * FROM Tables WHERE Name = 'Categorii_Produse') INSERT INTO Tables (Name) VALUES ('Categorii_Produse');
IF NOT EXISTS (SELECT * FROM Tables WHERE Name = 'Produse') INSERT INTO Tables (Name) VALUES ('Produse');
IF NOT EXISTS (SELECT * FROM Tables WHERE Name = 'Detalii_Comenzi') INSERT INTO Tables (Name) VALUES ('Detalii_Comenzi');
IF NOT EXISTS (SELECT * FROM Tables WHERE Name = 'Furnizori_Produse') INSERT INTO Tables (Name) VALUES ('Furnizori_Produse'); 

-- 2. Inserare Views... 
IF NOT EXISTS (SELECT * FROM Views WHERE Name = 'V_ClientiSimpli') INSERT INTO Views (Name) VALUES ('V_ClientiSimpli');
IF NOT EXISTS (SELECT * FROM Views WHERE Name = 'V_ProduseBranduri') INSERT INTO Views (Name) VALUES ('V_ProduseBranduri');
IF NOT EXISTS (SELECT * FROM Views WHERE Name = 'V_TotalComenziClienti') INSERT INTO Views (Name) VALUES ('V_TotalComenziClienti');

-- 3. Inserare Numele Testului
IF NOT EXISTS (SELECT * FROM Tests WHERE Name = 'Test_Performanta_Initial')
    INSERT INTO Tests (Name, Description) VALUES ('Test_Performanta_Initial', 'Test cu 4 tabele si 3 view-uri');

----------------------------------------------------------------------------------------------------
-- CONFIGURAREA PROPRIU-ZISA A TESTULUI
----------------------------------------------------------------------------------------------------
DECLARE @TestID INT;
SELECT @TestID = TestID FROM Tests WHERE Name = 'Test_Performanta_Initial'; 

IF @TestID IS NULL
BEGIN
    PRINT 'Eroare de configurare: Testul "Test_Performanta_Initial" nu a fost gasit in tabela Tests.';
    RETURN;
END

DELETE FROM TestTables WHERE TestID = @TestID;
DELETE FROM TestViews WHERE TestID = @TestID;

-- Configurare Tabele - Position ajustata
INSERT INTO TestTables (TestID, TableID, Position, NoOfRows)
SELECT @TestID, TableID, 4, 1000 FROM Tables WHERE Name = 'Categorii_Produse' --------position cu aceste pozitii pentru a sterge in ordine copil-parinte
UNION ALL																				---union all pentru a nu folosi de mai multe ori insert
SELECT @TestID, TableID, 3, 1000 FROM Tables WHERE Name = 'Produse' 
UNION ALL
SELECT @TestID, TableID, 2, 1000 FROM Tables WHERE Name = 'Detalii_Comenzi' 
UNION ALL
SELECT @TestID, TableID, 1, 1000 FROM Tables WHERE Name = 'Furnizori_Produse'; 

-- Configurare View-uri 
INSERT INTO TestViews (TestID, ViewID)
SELECT @TestID, ViewID FROM Views WHERE Name = 'V_ClientiSimpli'
UNION ALL
SELECT @TestID, ViewID FROM Views WHERE Name = 'V_ProduseBranduri'
UNION ALL
SELECT @TestID, ViewID FROM Views WHERE Name = 'V_TotalComenziClienti';

-- Verificare vizuala
SELECT 'Configurare Reusita' AS Status;
GO

----------------------------------------------------------------------------------------------------
-- SECTIUNEA 5: PROCEDURA PRINCIPALA DE RULARE A TESTULUI (run_test_sp)
----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE run_test_sp
    @TestID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTestRun DATETIME = GETDATE();
    DECLARE @TestRunID INT;
    DECLARE @TableName NVARCHAR(50);
    DECLARE @ViewName NVARCHAR(50);
    DECLARE @TableID INT;
    DECLARE @ViewID INT;
    DECLARE @NoOfRows INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @StartAt DATETIME;
    DECLARE @EndAt DATETIME;
    DECLARE @Duration DECIMAL(10, 3);

    -- 0. Creare noua inregistrare TestRun
    INSERT INTO TestRuns (TestID, RunDate, Duration)
    VALUES (@TestID, @StartTestRun, NULL);
    SET @TestRunID = SCOPE_IDENTITY();

    -- Dezactivare Triggere 
    IF OBJECT_ID('trg_CompleteazaPretSiSuma', 'TR') IS NOT NULL
        DISABLE TRIGGER trg_CompleteazaPretSiSuma ON Detalii_Comenzi;
    IF OBJECT_ID('trg_UpdateStocProduse', 'TR') IS NOT NULL
        DISABLE TRIGGER trg_UpdateStocProduse ON Detalii_Comenzi;

    -- 1. DELETE (Copil -> Parinte) - Position ASC
    DECLARE table_delete_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT T.TableID, T.Name
    FROM Tables T
    INNER JOIN TestTables TT ON T.TableID = TT.TableID
    WHERE TT.TestID = @TestID
    ORDER BY TT.Position ASC; 

    OPEN table_delete_cursor;
    FETCH NEXT FROM table_delete_cursor INTO @TableID, @TableName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = N'DELETE FROM ' + QUOTENAME(@TableName) + ';';
        BEGIN TRY
            EXEC sp_executesql @SQL;
            PRINT 'Stergere reusita in: ' + @TableName; 
        END TRY
        BEGIN CATCH
            PRINT 'Eroare stergere ' + @TableName + ': ' + ERROR_MESSAGE();
        END CATCH
        FETCH NEXT FROM table_delete_cursor INTO @TableID, @TableName;
    END

    CLOSE table_delete_cursor;
    DEALLOCATE table_delete_cursor;

    -- 2. INSERT (Parinte -> Copil) - Position DESC
    DECLARE table_insert_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT T.TableID, T.Name, TT.NoOfRows
    FROM Tables T
    INNER JOIN TestTables TT ON T.TableID = TT.TableID
    WHERE TT.TestID = @TestID
    ORDER BY TT.Position DESC;

    OPEN table_insert_cursor;
    FETCH NEXT FROM table_insert_cursor INTO @TableID, @TableName, @NoOfRows;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @StartAt = GETDATE();

        EXEC insert_data_sp @TableID, @NoOfRows; 

        SET @EndAt = GETDATE();
        SET @Duration = DATEDIFF(millisecond, @StartAt, @EndAt) / 1000.0;
        PRINT 'Inserare reusita in: ' + @TableName + ' (' + CAST(@Duration AS NVARCHAR(10)) + 's)'; 

        INSERT INTO TestRunTables (TestRunID, TableID, InsertDuration, NoOfRowsInserted)
        VALUES (@TestRunID, @TableID, @Duration, @NoOfRows);

        FETCH NEXT FROM table_insert_cursor INTO @TableID, @TableName, @NoOfRows;
    END

    CLOSE table_insert_cursor;
    DEALLOCATE table_insert_cursor;

    -- 3. VIEWS 
    DECLARE view_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT V.ViewID, V.Name
    FROM Views V
    INNER JOIN TestViews TV ON V.ViewID = TV.ViewID
    WHERE TV.TestID = @TestID;

    OPEN view_cursor;
    FETCH NEXT FROM view_cursor INTO @ViewID, @ViewName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @StartAt = GETDATE();
        
        -- Rulam view-ul fara a afisa mii de randuri 
        SET @SQL = N'SELECT @cnt = COUNT(*) FROM ' + QUOTENAME(@ViewName);
        DECLARE @cnt INT;
        EXEC sp_executesql @SQL, N'@cnt INT OUTPUT', @cnt = @cnt OUTPUT;

        SET @EndAt = GETDATE();
        SET @Duration = DATEDIFF(millisecond, @StartAt, @EndAt) / 1000.0;
        PRINT 'View rulat: ' + @ViewName + ' (' + CAST(@Duration AS NVARCHAR(10)) + 's)'; 

        INSERT INTO TestRunView (TestRunID, ViewID, QueryDuration)
        VALUES (@TestRunID, @ViewID, @Duration);

        FETCH NEXT FROM view_cursor INTO @ViewID, @ViewName;
    END

    CLOSE view_cursor;
    DEALLOCATE view_cursor;

    -- 4. Finalizare 
    SET @Duration = DATEDIFF(millisecond, @StartTestRun, GETDATE()) / 1000.0;

    UPDATE TestRuns
    SET Duration = @Duration
    WHERE TestRunID = @TestRunID;

    -- Reactivare Triggere
    IF OBJECT_ID('trg_CompleteazaPretSiSuma', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_CompleteazaPretSiSuma ON Detalii_Comenzi;
    IF OBJECT_ID('trg_UpdateStocProduse', 'TR') IS NOT NULL
        ENABLE TRIGGER trg_UpdateStocProduse ON Detalii_Comenzi;

    PRINT '--- Test Run ' + CAST(@TestRunID AS NVARCHAR) + ' finished in ' + CAST(@Duration AS NVARCHAR(10)) + 's ---';
END;
GO

----------------------------------------------------------------------------------------------------
-- SECTIUNEA 6: RULAREA SI VERIFICAREA
----------------------------------------------------------------------------------------------------

-- Rularea testului
DECLARE @TestToRunID INT = (SELECT TestID FROM Tests WHERE Name = 'Test_Performanta_Initial');

IF @TestToRunID IS NOT NULL
BEGIN
    EXEC run_test_sp @TestToRunID;
END
ELSE
BEGIN
    PRINT 'Testul nu a fost gasit in tabela Tests. Verificati numele.';
END

-- Afisarea rezultatelor
SELECT
    TR.TestRunID,
    T.Name AS TestName,
    TR.RunDate,
    TR.Duration AS TotalDuration_s,
    '---' AS Sep,
    TA.Name AS TableName,
    TRT.NoOfRowsInserted,
    TRT.InsertDuration AS InsertDuration_s,
    V.Name AS ViewName,
    TRV.QueryDuration AS QueryDuration_s
FROM TestRuns TR
INNER JOIN Tests T ON TR.TestID = T.TestID
LEFT JOIN TestRunTables TRT ON TR.TestRunID = TRT.TestRunID
LEFT JOIN Tables TA ON TRT.TableID = TA.TableID
LEFT JOIN TestRunView TRV ON TR.TestRunID = TRV.TestRunID
LEFT JOIN Views V ON TRV.ViewID = V.ViewID
ORDER BY TR.TestRunID DESC;
GO


select * from Views
select * from TestRunView
select * from TestRuns