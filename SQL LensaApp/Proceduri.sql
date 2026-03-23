USE LENSA;
GO

/*******************************************************************************************
    SISTEM COMPLET DE VERSIONARE BAZA DE DATE – LENSA
********************************************************************************************/

--============================================================
-- 0. CREARE TABELE DE VERSIONARE
--============================================================

DROP TABLE VersionScripts;
DROP TABLE VersionTable;
DROP PROCEDURE change_version;
DROP PROCEDURE do_modify_client_phone_type;
DROP PROCEDURE undo_modify_client_phone_type;
DROP PROCEDURE do_add_cod_fiscal;
DROP PROCEDURE undo_add_cod_fiscal;
DROP PROCEDURE do_add_default_data_inreg;
DROP PROCEDURE undo_add_default_data_inreg;
DROP PROCEDURE do_create_BranduriInfo;
DROP PROCEDURE undo_create_BranduriInfo;
DROP PROCEDURE do_add_pk_BranduriInfo;
DROP PROCEDURE undo_add_pk_BranduriInfo;
DROP PROCEDURE do_add_candidate_key_email;
DROP PROCEDURE undo_add_candidate_key_email;
DROP PROCEDURE do_add_fk_BranduriInfo;
DROP PROCEDURE undo_add_fk_BranduriInfo;


IF OBJECT_ID('VersionTable') IS NOT NULL DROP TABLE VersionTable;
IF OBJECT_ID('VersionScripts') IS NOT NULL DROP TABLE VersionScripts;

CREATE TABLE VersionTable (
    current_version INT NOT NULL
);

INSERT INTO VersionTable VALUES (0);

CREATE TABLE VersionScripts (
    version_nr INT PRIMARY KEY,
    do_procedure SYSNAME NOT NULL,
    undo_procedure SYSNAME NOT NULL
);



--============================================================
-- 1. PROCEDURA PRINCIPALA DE SCHIMBARE A VERSIUNII
--============================================================

GO
CREATE OR ALTER PROCEDURE change_version
    @Version INT
AS
BEGIN
    DECLARE @CrtVersion INT;
    DECLARE @Procedure SYSNAME;

    SELECT @CrtVersion = current_version FROM VersionTable;

    IF @Version = @CrtVersion OR @Version < 0 RETURN;

    IF @Version > (SELECT MAX(version_nr) FROM VersionScripts) RETURN;

    -------------------------
    -- VERSION UP
    -------------------------
    WHILE @CrtVersion < @Version
    BEGIN
        SELECT @Procedure = do_procedure
        FROM VersionScripts
        WHERE version_nr = @CrtVersion + 1;

        IF @Procedure IS NULL RETURN;

        EXEC(@Procedure);

        SELECT @CrtVersion = current_version FROM VersionTable;
    END

    -------------------------
    -- VERSION DOWN
    -------------------------
    WHILE @CrtVersion > @Version
    BEGIN
        SELECT @Procedure = undo_procedure
        FROM VersionScripts
        WHERE version_nr = @CrtVersion;

        IF @Procedure IS NULL RETURN;

        EXEC(@Procedure);

        SELECT @CrtVersion = current_version FROM VersionTable;
    END
END;
GO

/*******************************************************************************************
    CERINTA (a) — MODIFY COLUMN TYPE (VERSION 1)
********************************************************************************************/
go
CREATE OR ALTER PROCEDURE do_modify_client_phone_type
AS
BEGIN
    ALTER TABLE Clienti DROP CONSTRAINT uq_clienti;

    ALTER TABLE Clienti
        ALTER COLUMN telefon VARCHAR(30);

    ALTER TABLE Clienti
        ADD CONSTRAINT uq_clienti UNIQUE(nume, prenume, email, telefon);

    UPDATE VersionTable SET current_version = 1;
END;
GO

CREATE OR ALTER PROCEDURE undo_modify_client_phone_type
AS
BEGIN
    ALTER TABLE Clienti DROP CONSTRAINT uq_clienti;

    ALTER TABLE Clienti
        ALTER COLUMN telefon VARCHAR(20);

    ALTER TABLE Clienti
        ADD CONSTRAINT uq_clienti UNIQUE(nume, prenume, email, telefon);

    UPDATE VersionTable SET current_version = 0;
END;
GO


/*******************************************************************************************
    CERINTA (b) — ADD COLUMN (VERSION 2)
********************************************************************************************/

GO
CREATE OR ALTER PROCEDURE do_add_cod_fiscal
AS
BEGIN
    ALTER TABLE Furnizori
        ADD cod_fiscal VARCHAR(50);

    UPDATE VersionTable SET current_version = 2;
END;
GO

CREATE OR ALTER PROCEDURE undo_add_cod_fiscal
AS
BEGIN
    ALTER TABLE Furnizori
        DROP COLUMN cod_fiscal;

    UPDATE VersionTable SET current_version = 1;
END;
GO

/*******************************************************************************************
    CERINTA (c) — ADD DEFAULT (VERSION 3)
********************************************************************************************/

CREATE OR ALTER PROCEDURE do_add_default_data_inreg
AS
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.default_constraints dc
        JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
        JOIN sys.tables t ON t.object_id = c.object_id
        WHERE t.name = 'Clienti' AND c.name = 'data_inregistrare'
    )
    BEGIN
        ALTER TABLE Clienti
            ADD CONSTRAINT DF_Clienti_Data DEFAULT GETDATE() FOR data_inregistrare;
    END

    UPDATE VersionTable SET current_version = 3;
END;
GO

CREATE OR ALTER PROCEDURE undo_add_default_data_inreg
AS
BEGIN
    DECLARE @ConstraintName NVARCHAR(200);

    SELECT @ConstraintName = dc.name
    FROM sys.default_constraints dc
    JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    JOIN sys.tables t ON t.object_id = c.object_id
    WHERE t.name = 'Clienti' AND c.name = 'data_inregistrare';

    IF @ConstraintName IS NOT NULL
    BEGIN
        ALTER TABLE Clienti DROP CONSTRAINT [DF_Clienti_Data];
    END

    UPDATE VersionTable SET current_version = 2;
END;
GO




/*******************************************************************************************
    CERINTA (g) — CREATE TABLE (VERSION 4)
********************************************************************************************/

CREATE OR ALTER PROCEDURE do_create_BranduriInfo
AS
BEGIN
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'BranduriInfo'
    )
    BEGIN
        CREATE TABLE BranduriInfo (
            id_info INT NOT NULL,
            id_brand INT NOT NULL,
            detalii VARCHAR(200)
        );
    END

    UPDATE VersionTable SET current_version = 4;
END;
GO


CREATE OR ALTER PROCEDURE undo_create_BranduriInfo
AS
BEGIN
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'BranduriInfo'
    )
    BEGIN
        DROP TABLE BranduriInfo;
    END

    UPDATE VersionTable SET current_version = 3;
END;
GO
/*******************************************************************************************
    CERINTA (d) — ADD PRIMARY KEY (VERSION 5)
********************************************************************************************/

GO
CREATE OR ALTER PROCEDURE do_add_pk_BranduriInfo
AS
BEGIN
    ALTER TABLE BranduriInfo
        ADD CONSTRAINT PK_BranduriInfo PRIMARY KEY(id_info);

    UPDATE VersionTable SET current_version = 5;
END;
GO

CREATE OR ALTER PROCEDURE undo_add_pk_BranduriInfo
AS
BEGIN
    ALTER TABLE BranduriInfo
        DROP CONSTRAINT PK_BranduriInfo;

    UPDATE VersionTable SET current_version = 4;
END;
GO



/*******************************************************************************************
    CERINTA (e) — ADD CANDIDATE KEY (UNIQUE) (VERSION 6)
********************************************************************************************/

GO
CREATE OR ALTER PROCEDURE do_add_candidate_key_email
AS
BEGIN
    ALTER TABLE Furnizori
        ADD CONSTRAINT UQ_Furnizori_Email UNIQUE (email);

    UPDATE VersionTable SET current_version = 6;
END;
GO

CREATE OR ALTER PROCEDURE undo_add_candidate_key_email
AS
BEGIN
    ALTER TABLE Furnizori
        DROP CONSTRAINT UQ_Furnizori_Email;

    UPDATE VersionTable SET current_version = 5;
END;
GO



/*******************************************************************************************
    CERINTA (f) — ADD FOREIGN KEY (VERSION 7)
********************************************************************************************/

GO
CREATE OR ALTER PROCEDURE do_add_fk_BranduriInfo
AS
BEGIN
    ALTER TABLE BranduriInfo
        ADD CONSTRAINT FK_BranduriInfo_Branduri
            FOREIGN KEY(id_brand) REFERENCES Branduri(id_brand);

    UPDATE VersionTable SET current_version = 7;
END;
GO

CREATE OR ALTER PROCEDURE undo_add_fk_BranduriInfo
AS
BEGIN
    ALTER TABLE BranduriInfo
        DROP CONSTRAINT FK_BranduriInfo_Branduri;

    UPDATE VersionTable SET current_version = 6;
END;
GO



/*******************************************************************************************
    INSERAREA TUTUROR PROCEDURILOR IN VersionScripts
********************************************************************************************/

TRUNCATE TABLE VersionScripts;

INSERT INTO VersionScripts VALUES
(1, 'do_modify_client_phone_type',     'undo_modify_client_phone_type'),
(2, 'do_add_cod_fiscal',               'undo_add_cod_fiscal'),
(3, 'do_add_default_data_inreg',       'undo_add_default_data_inreg'),
(4, 'do_create_BranduriInfo',          'undo_create_BranduriInfo'),
(5, 'do_add_pk_BranduriInfo',          'undo_add_pk_BranduriInfo'),
(6, 'do_add_candidate_key_email',      'undo_add_candidate_key_email'),
(7, 'do_add_fk_BranduriInfo',          'undo_add_fk_BranduriInfo');


select * from VersionScripts
/*******************************************************************************************
    TESTARE
********************************************************************************************

-- DU-TE LA O VERSIUNE
EXEC change_version 7;

-- REVINO LA O VERSIUNE INFERIOARĂ
-- EXEC change_version 3;

-- VERIFICA VERSIUNEA CURENTA
-- SELECT * FROM VersionTable;

********************************************************************************************/
EXEC change_version 1;
SELECT * FROM VersionTable;

EXEC change_version 7;
SELECT * FROM VersionTable;

exec change_version 0;
select * from VersionTable
EXEC sp_help 'Clienti';
-----------------------------------------------------

/*******************************************************************************************
    TESTARE VERSIONARE – VERIFICARE PAS CU PAS
*******************************************************************************************/


/***************************************************************
    ----------------------- VERSION 1 ---------------------------
    Modificare tip coloana telefon în Clienti
***************************************************************/
PRINT '================ VERSION 1 ================';

EXEC change_version 1;
exec do_modify_client_phone_type
exec undo_modify_client_phone_type
PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- STRUCTURA CLIENTI ---';
EXEC sp_help 'Clienti';

PRINT '--- TIP COLOANA TELEFON ---';
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Clienti' AND COLUMN_NAME = 'telefon';


/***************************************************************
    ----------------------- VERSION 2 ---------------------------
    Adăugare coloana cod_fiscal în Furnizori
***************************************************************/
PRINT '================ VERSION 2 ================';

EXEC change_version 2;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- STRUCTURA FURNIZORI ---';
EXEC sp_help 'Furnizori';

PRINT '--- COLOANA cod_fiscal EXISTĂ? ---';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Furnizori' AND COLUMN_NAME = 'cod_fiscal';
select * from Furnizori

/***************************************************************
    ----------------------- VERSION 3 ---------------------------
    Adăugare default la data_inregistrare
***************************************************************/
PRINT '================ VERSION 3 ================';

EXEC change_version 3;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- CONSTRÂNGERI CLIENTI ---';
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Clienti';
select * from Clienti


/***************************************************************
    ----------------------- VERSION 4 ---------------------------
    Creare tabel BranduriInfo
***************************************************************/
PRINT '================ VERSION 4 ================';

EXEC change_version 4;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;
select * from BranduriInfo;
PRINT '--- EXISTĂ TABELA BranduriInfo? ---';
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'BranduriInfo';

PRINT '--- STRUCTURA BRANDURIINFO ---';
EXEC sp_help 'BranduriInfo';

/***************************************************************
    ----------------------- VERSION 5 ---------------------------
    Adăugare Primary Key în BranduriInfo
***************************************************************/
PRINT '================ VERSION 5 ================';

EXEC change_version 5;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- PRIMARY KEY BRANDURIINFO ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'BranduriInfo'
AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';


/***************************************************************
    ----------------------- VERSION 6 ---------------------------
    Adăugare Candidate Key (UNIQUE) pe email
***************************************************************/
PRINT '================ VERSION 6 ================';

EXEC change_version 6;
ALTER TABLE Furnizori
DROP CONSTRAINT UQ_Furnizori_Email;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- UNIQUE CONSTRAINT FURNIZORI (email) ---';
SELECT tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE, kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'Furnizori'
AND tc.CONSTRAINT_TYPE = 'UNIQUE';


/***************************************************************
    ----------------------- VERSION 7 ---------------------------
    Adăugare Foreign Key BranduriInfo -> Branduri
***************************************************************/
PRINT '================ VERSION 7 ================';

EXEC change_version 7;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- FOREIGN KEYS EXISTENTE ---';
SELECT fk.name AS FK_Name, tp.name AS Parent_Table, tr.name AS Referenced_Table
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tp.name = 'BranduriInfo';


/***************************************************************
    ----------------------- REVENIRE LA 0 ----------------------
***************************************************************/
PRINT '================ VERSION 0 ================';

EXEC change_version 0;

PRINT '--- VERSIONTABLE ---';
SELECT * FROM VersionTable;

PRINT '--- STRUCTURA CLIENTI (telefon revine la varchar(20)) ---';
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Clienti' AND COLUMN_NAME = 'telefon';

PRINT '--- TABELA BranduriInfo ar trebui să nu mai existe ---';
SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'BranduriInfo';

