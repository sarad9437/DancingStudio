/*
**  ПРОЈЕКАТ:   ПРП - Програмирање репозиторијума података
**  ДАТОТЕКА:   PlesniStudio_KOMPLETNA_SKRIPTA.sql
**  ОПИС:       Целокупна база са свим изменама и demo подацима
**  АУТОР:    	Сара Да Ролд
**  НАПОМЕНА:   Покренути у SSMS као administrator
**              Лозинке: Admin@2026! / Instruktor@2026!
*/

USE [master];
GO

-- =====================================================
-- 1. Kreiranje baze podataka
-- =====================================================
DROP DATABASE IF EXISTS [PlesniStudio];
CREATE DATABASE [PlesniStudio]
    COLLATE Serbian_Cyrillic_100_CS_AI;
GO

USE [PlesniStudio];
GO

-- =====================================================
-- 2. Kreiranje shema
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'impl')
    EXEC(N'CREATE SCHEMA impl;');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'spec')
    EXEC(N'CREATE SCHEMA spec;');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'api_studio')
    EXEC(N'CREATE SCHEMA api_studio;');
GO

-- =====================================================
-- 3. Kreiranje uloga i korisnika
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DbDeveloper' AND type = 'R')
    EXEC(N'CREATE ROLE [DbDeveloper];');
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DbApiDeveloper' AND type = 'R')
    EXEC(N'CREATE ROLE [DbApiDeveloper];');
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DataProviderStudio' AND type = 'A')
    EXEC(N'CREATE APPLICATION ROLE [DataProviderStudio]
        WITH PASSWORD = N''Studio@2026!'',
        DEFAULT_SCHEMA = [api_studio];');
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Marija' AND type = 'S')
    EXEC(N'CREATE USER [Marija] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [impl];');
GO

EXEC sp_addrolemember N'DbDeveloper', N'Marija';
GO

GRANT CONTROL ON SCHEMA::[impl] TO [Marija];
GRANT CONTROL ON SCHEMA::[spec] TO [Marija];
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'Sara' AND type = 'S')
    EXEC(N'CREATE USER [Sara] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [api_studio];');
GO

EXEC sp_addrolemember N'DbApiDeveloper', N'Sara';
GO

GRANT CONTROL ON SCHEMA::[api_studio] TO [Sara];
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  Uloge i korisnici su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 4. Aplikacione tabele
-- =====================================================

CREATE TABLE [impl].[tblOsoba] (
    Id      INT             IDENTITY    NOT NULL,
    Ime     NVARCHAR(50)                NOT NULL
                CONSTRAINT [CK_tblOsoba_Ime]
                    CHECK (Ime LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Prezime NVARCHAR(50)                NOT NULL
                CONSTRAINT [CK_tblOsoba_Prezime]
                    CHECK (Prezime LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Email   NVARCHAR(100)               NOT NULL    UNIQUE
                CONSTRAINT [CK_tblOsoba_Email]
                    CHECK (Email LIKE N'%@%.%'),
    CONSTRAINT PK_tblOsoba PRIMARY KEY (Id)
);
GO

CREATE TABLE [impl].[tblUcenik] (
    OsobaId         INT             NOT NULL,
    BrojKnjizice    NVARCHAR(20)    NOT NULL    UNIQUE,
    DatumUpisa      DATE            NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    Nivo            NVARCHAR(20)    NOT NULL
                CONSTRAINT [CK_tblUcenik_Nivo]
                    CHECK (Nivo IN (N'Почетни', N'Средњи', N'Напредни')),
    CONSTRAINT PK_tblUcenik PRIMARY KEY (OsobaId),
    CONSTRAINT FK_tblUcenik_tblOsoba
        FOREIGN KEY (OsobaId) REFERENCES [impl].[tblOsoba](Id)
);
GO

CREATE TABLE [impl].[tblInstruktor] (
    OsobaId         INT             NOT NULL,
    Specijalnost    NVARCHAR(50)    NOT NULL
                CONSTRAINT [CK_tblInstruktor_Specijalnost]
                    CHECK (Specijalnost LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Sertifikat      NVARCHAR(100)       NULL,
    CONSTRAINT PK_tblInstruktor PRIMARY KEY (OsobaId),
    CONSTRAINT FK_tblInstruktor_tblOsoba
        FOREIGN KEY (OsobaId) REFERENCES [impl].[tblOsoba](Id)
);
GO

CREATE TABLE [impl].[tblKurs] (
    Id              INT             IDENTITY    NOT NULL,
    Naziv           NVARCHAR(80)                NOT NULL    UNIQUE
                            CONSTRAINT [CK_tblKurs_Naziv]
                                CHECK (Naziv LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Opis            NVARCHAR(300)                               NULL,
    TrajanjeMeseci  INT                         NOT NULL
                            CONSTRAINT [CK_tblKurs_Trajanje]
                                CHECK (TrajanjeMeseci BETWEEN 1 AND 36),
    PretKursId      INT                                         NULL,
    CONSTRAINT PK_tblKurs PRIMARY KEY (Id),
    CONSTRAINT FK_tblKurs_Preduslov
        FOREIGN KEY (PretKursId) REFERENCES [impl].[tblKurs](Id)
);
GO

CREATE TABLE [impl].[tblGrupa] (
    Id              INT             IDENTITY    NOT NULL,
    Naziv           NVARCHAR(80)                NOT NULL    UNIQUE
                            CONSTRAINT [CK_tblGrupa_Naziv]
                                CHECK (Naziv LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    KursId          INT                         NOT NULL,
    KoreografId     INT                         NOT NULL,
    PredavacId      INT                         NOT NULL,
    UkupnoUcenika   INT                         NOT NULL    DEFAULT 0
                            CONSTRAINT [CK_tblGrupa_UkupnoUcenika]
                                CHECK (UkupnoUcenika >= 0),
    CONSTRAINT PK_tblGrupa PRIMARY KEY (Id),
    CONSTRAINT FK_tblGrupa_tblKurs
        FOREIGN KEY (KursId) REFERENCES [impl].[tblKurs](Id),
    CONSTRAINT FK_tblGrupa_Koreograf
        FOREIGN KEY (KoreografId) REFERENCES [impl].[tblInstruktor](OsobaId),
    CONSTRAINT FK_tblGrupa_Predavac
        FOREIGN KEY (PredavacId) REFERENCES [impl].[tblInstruktor](OsobaId)
);
GO

CREATE TABLE [impl].[tblNastup] (
    Id              INT             IDENTITY    NOT NULL,
    Naziv           NVARCHAR(100)               NOT NULL
                            CONSTRAINT [CK_tblNastup_Naziv]
                                CHECK (Naziv LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Datum           DATE                        NOT NULL,
    Lokacija        NVARCHAR(100)               NOT NULL
                            CONSTRAINT [CK_tblNastup_Lokacija]
                                CHECK (Lokacija LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    GrupaId         INT                         NOT NULL,
    InstruktorId    INT                         NOT NULL,
    CONSTRAINT PK_tblNastup PRIMARY KEY (Id),
    CONSTRAINT FK_tblNastup_tblGrupa
        FOREIGN KEY (GrupaId) REFERENCES [impl].[tblGrupa](Id),
    CONSTRAINT FK_tblNastup_tblInstruktor
        FOREIGN KEY (InstruktorId) REFERENCES [impl].[tblInstruktor](OsobaId)
);
GO

CREATE TABLE [impl].[tblKostim] (
    Id          INT             IDENTITY    NOT NULL,
    Naziv       NVARCHAR(80)                NOT NULL
                        CONSTRAINT [CK_tblKostim_Naziv]
                            CHECK (Naziv LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    Velicina    NVARCHAR(5)                 NOT NULL
                        CONSTRAINT [CK_tblKostim_Velicina]
                            CHECK (Velicina IN (N'XS', N'S', N'M', N'L', N'XL')),
    Boja        NVARCHAR(30)                NOT NULL
                        CONSTRAINT [CK_tblKostim_Boja]
                            CHECK (Boja LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'),
    CONSTRAINT PK_tblKostim PRIMARY KEY (Id)
);
GO

CREATE TABLE [impl].[tblZaduzenje] (
    UcenikId        INT     NOT NULL,
    NastupId        INT     NOT NULL,
    KostimId        INT     NOT NULL,
    DatumZaduzenja  DATE    NOT NULL    DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT PK_tblZaduzenje PRIMARY KEY (UcenikId, NastupId),
    CONSTRAINT FK_tblZaduzenje_tblUcenik
        FOREIGN KEY (UcenikId) REFERENCES [impl].[tblUcenik](OsobaId),
    CONSTRAINT FK_tblZaduzenje_tblNastup
        FOREIGN KEY (NastupId) REFERENCES [impl].[tblNastup](Id),
    CONSTRAINT FK_tblZaduzenje_tblKostim
        FOREIGN KEY (KostimId) REFERENCES [impl].[tblKostim](Id)
);
GO

CREATE TABLE [impl].[tblKorisnik] (
    Id              INT             IDENTITY    NOT NULL,
    Email           NVARCHAR(100)               NOT NULL    UNIQUE
                        CONSTRAINT [CK_tblKorisnik_Email]
                            CHECK (Email LIKE N'%@%.%'),
    LozinkaHash     NVARCHAR(256)               NOT NULL,
    Uloga           NVARCHAR(20)                NOT NULL
                        CONSTRAINT [CK_tblKorisnik_Uloga]
                            CHECK (Uloga IN (N'Admin', N'Instruktor')),
    InstruktorId    INT                             NULL,
    CONSTRAINT PK_tblKorisnik PRIMARY KEY (Id),
    CONSTRAINT FK_tblKorisnik_Instruktor
        FOREIGN KEY (InstruktorId) REFERENCES [impl].[tblInstruktor](OsobaId)
);
GO

CREATE TABLE [impl].[tblUcenikGrupa] (
    UcenikId    INT     NOT NULL,
    GrupaId     INT     NOT NULL,
    CONSTRAINT PK_tblUcenikGrupa
        PRIMARY KEY (UcenikId, GrupaId),
    CONSTRAINT FK_tblUcenikGrupa_Ucenik
        FOREIGN KEY (UcenikId) REFERENCES [impl].[tblUcenik](OsobaId),
    CONSTRAINT FK_tblUcenikGrupa_Grupa
        FOREIGN KEY (GrupaId) REFERENCES [impl].[tblGrupa](Id)
);
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  Aplikacione tabele su kreirane.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 5. Log tabele
-- =====================================================

CREATE TABLE [impl].[tblOsobaLog] (
    LogId       INT             IDENTITY    NOT NULL,
    ActionType  CHAR(3)                     NOT NULL,
    Old_Id      INT                             NULL,
    New_Id      INT                             NULL,
    Old_Ime     NVARCHAR(50)                    NULL,
    New_Ime     NVARCHAR(50)                    NULL,
    Old_Prezime NVARCHAR(50)                    NULL,
    New_Prezime NVARCHAR(50)                    NULL,
    Old_Email   NVARCHAR(100)                   NULL,
    New_Email   NVARCHAR(100)                   NULL,
    ChangedAt   DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy   NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblOsobaLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblUcenikLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_OsobaId         INT                             NULL,
    New_OsobaId         INT                             NULL,
    Old_BrojKnjizice    NVARCHAR(20)                    NULL,
    New_BrojKnjizice    NVARCHAR(20)                    NULL,
    Old_DatumUpisa      DATE                            NULL,
    New_DatumUpisa      DATE                            NULL,
    Old_Nivo            NVARCHAR(20)                    NULL,
    New_Nivo            NVARCHAR(20)                    NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblUcenikLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblInstruktorLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_OsobaId         INT                             NULL,
    New_OsobaId         INT                             NULL,
    Old_Specijalnost    NVARCHAR(50)                    NULL,
    New_Specijalnost    NVARCHAR(50)                    NULL,
    Old_Sertifikat      NVARCHAR(100)                   NULL,
    New_Sertifikat      NVARCHAR(100)                   NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblInstruktorLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblKursLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_Id              INT                             NULL,
    New_Id              INT                             NULL,
    Old_Naziv           NVARCHAR(80)                    NULL,
    New_Naziv           NVARCHAR(80)                    NULL,
    Old_Opis            NVARCHAR(300)                   NULL,
    New_Opis            NVARCHAR(300)                   NULL,
    Old_TrajanjeMeseci  INT                             NULL,
    New_TrajanjeMeseci  INT                             NULL,
    Old_PretKursId      INT                             NULL,
    New_PretKursId      INT                             NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblKursLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblGrupaLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_Id              INT                             NULL,
    New_Id              INT                             NULL,
    Old_Naziv           NVARCHAR(80)                    NULL,
    New_Naziv           NVARCHAR(80)                    NULL,
    Old_KursId          INT                             NULL,
    New_KursId          INT                             NULL,
    Old_KoreografId     INT                             NULL,
    New_KoreografId     INT                             NULL,
    Old_PredavacId      INT                             NULL,
    New_PredavacId      INT                             NULL,
    Old_UkupnoUcenika   INT                             NULL,
    New_UkupnoUcenika   INT                             NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblGrupaLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblNastupLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_Id              INT                             NULL,
    New_Id              INT                             NULL,
    Old_Naziv           NVARCHAR(100)                   NULL,
    New_Naziv           NVARCHAR(100)                   NULL,
    Old_Datum           DATE                            NULL,
    New_Datum           DATE                            NULL,
    Old_Lokacija        NVARCHAR(100)                   NULL,
    New_Lokacija        NVARCHAR(100)                   NULL,
    Old_GrupaId         INT                             NULL,
    New_GrupaId         INT                             NULL,
    Old_InstruktorId    INT                             NULL,
    New_InstruktorId    INT                             NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblNastupLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblKostimLog] (
    LogId           INT             IDENTITY    NOT NULL,
    ActionType      CHAR(3)                     NOT NULL,
    Old_Id          INT                             NULL,
    New_Id          INT                             NULL,
    Old_Naziv       NVARCHAR(80)                    NULL,
    New_Naziv       NVARCHAR(80)                    NULL,
    Old_Velicina    NVARCHAR(5)                     NULL,
    New_Velicina    NVARCHAR(5)                     NULL,
    Old_Boja        NVARCHAR(30)                    NULL,
    New_Boja        NVARCHAR(30)                    NULL,
    ChangedAt       DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy       NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblKostimLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblZaduzenjeLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_UcenikId        INT                             NULL,
    New_UcenikId        INT                             NULL,
    Old_NastupId        INT                             NULL,
    New_NastupId        INT                             NULL,
    Old_KostimId        INT                             NULL,
    New_KostimId        INT                             NULL,
    Old_DatumZaduzenja  DATE                            NULL,
    New_DatumZaduzenja  DATE                            NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblZaduzenjeLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblKorisnikLog] (
    LogId               INT             IDENTITY    NOT NULL,
    ActionType          CHAR(3)                     NOT NULL,
    Old_Id              INT                             NULL,
    New_Id              INT                             NULL,
    Old_Email           NVARCHAR(100)                   NULL,
    New_Email           NVARCHAR(100)                   NULL,
    Old_LozinkaHash     NVARCHAR(256)                   NULL,
    New_LozinkaHash     NVARCHAR(256)                   NULL,
    Old_Uloga           NVARCHAR(20)                    NULL,
    New_Uloga           NVARCHAR(20)                    NULL,
    Old_InstruktorId    INT                             NULL,
    New_InstruktorId    INT                             NULL,
    ChangedAt           DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy           NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblKorisnikLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblUcenikGrupaLog] (
    LogId           INT             IDENTITY    NOT NULL,
    ActionType      CHAR(3)                     NOT NULL,
    Old_UcenikId    INT                             NULL,
    New_UcenikId    INT                             NULL,
    Old_GrupaId     INT                             NULL,
    New_GrupaId     INT                             NULL,
    ChangedAt       DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    ChangedBy       NVARCHAR(128)               NOT NULL    DEFAULT SUSER_SNAME(),
    CONSTRAINT PK_tblUcenikGrupaLog PRIMARY KEY (LogId)
);
GO

CREATE TABLE [impl].[tblErrorLog] (
    LogId           INT             IDENTITY    NOT NULL,
    ErrorNumber     INT                         NOT NULL,
    ErrorMessage    NVARCHAR(400)               NOT NULL,
    ProcedureName   NVARCHAR(300)               NOT NULL,
    LogDate         DATETIME2                   NOT NULL    DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_tblErrorLog PRIMARY KEY (LogId)
);
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  Log tabele su kreirane.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 6. Indeksi
-- =====================================================
CREATE NONCLUSTERED INDEX [idxGrupa_KursId]         ON [impl].[tblGrupa](KursId);
CREATE NONCLUSTERED INDEX [idxGrupa_KoreografId]    ON [impl].[tblGrupa](KoreografId);
CREATE NONCLUSTERED INDEX [idxGrupa_PredavacId]     ON [impl].[tblGrupa](PredavacId);
CREATE NONCLUSTERED INDEX [idxNastup_GrupaId]       ON [impl].[tblNastup](GrupaId);
CREATE NONCLUSTERED INDEX [idxNastup_InstruktorId]  ON [impl].[tblNastup](InstruktorId);
CREATE NONCLUSTERED INDEX [idxZaduzenje_UcenikId]   ON [impl].[tblZaduzenje](UcenikId);
CREATE NONCLUSTERED INDEX [idxZaduzenje_NastupId]   ON [impl].[tblZaduzenje](NastupId);
CREATE NONCLUSTERED INDEX [idxZaduzenje_KostimId]   ON [impl].[tblZaduzenje](KostimId);
CREATE NONCLUSTERED INDEX [idxKorisnik_InstruktorId] ON [impl].[tblKorisnik](InstruktorId);
CREATE NONCLUSTERED INDEX [idxUcenikGrupa_GrupaId]  ON [impl].[tblUcenikGrupa](GrupaId);
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  Indeksi su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 7. Trigeri za logovanje
-- =====================================================

CREATE OR ALTER TRIGGER [impl].[trg_tblOsoba_Log]
ON [impl].[tblOsoba]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblOsobaLog]
            (ActionType, Old_Id, New_Id, Old_Ime, New_Ime, Old_Prezime, New_Prezime, Old_Email, New_Email)
        SELECT 'INS', NULL, i.Id, NULL, i.Ime, NULL, i.Prezime, NULL, i.Email FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblOsobaLog]
            (ActionType, Old_Id, New_Id, Old_Ime, New_Ime, Old_Prezime, New_Prezime, Old_Email, New_Email)
        SELECT 'DEL', d.Id, NULL, d.Ime, NULL, d.Prezime, NULL, d.Email, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblOsobaLog]
        (ActionType, Old_Id, New_Id, Old_Ime, New_Ime, Old_Prezime, New_Prezime, Old_Email, New_Email)
    SELECT 'UPD', d.Id, i.Id, d.Ime, i.Ime, d.Prezime, i.Prezime, d.Email, i.Email
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblUcenik_Log]
ON [impl].[tblUcenik]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblUcenikLog]
            (ActionType, Old_OsobaId, New_OsobaId, Old_BrojKnjizice, New_BrojKnjizice,
             Old_DatumUpisa, New_DatumUpisa, Old_Nivo, New_Nivo)
        SELECT 'INS', NULL, i.OsobaId, NULL, i.BrojKnjizice, NULL, i.DatumUpisa, NULL, i.Nivo
        FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblUcenikLog]
            (ActionType, Old_OsobaId, New_OsobaId, Old_BrojKnjizice, New_BrojKnjizice,
             Old_DatumUpisa, New_DatumUpisa, Old_Nivo, New_Nivo)
        SELECT 'DEL', d.OsobaId, NULL, d.BrojKnjizice, NULL, d.DatumUpisa, NULL, d.Nivo, NULL
        FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblUcenikLog]
        (ActionType, Old_OsobaId, New_OsobaId, Old_BrojKnjizice, New_BrojKnjizice,
         Old_DatumUpisa, New_DatumUpisa, Old_Nivo, New_Nivo)
    SELECT 'UPD', d.OsobaId, i.OsobaId, d.BrojKnjizice, i.BrojKnjizice,
        d.DatumUpisa, i.DatumUpisa, d.Nivo, i.Nivo
    FROM deleted d INNER JOIN inserted i ON i.OsobaId = d.OsobaId;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblInstruktor_Log]
ON [impl].[tblInstruktor]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblInstruktorLog]
            (ActionType, Old_OsobaId, New_OsobaId, Old_Specijalnost, New_Specijalnost,
             Old_Sertifikat, New_Sertifikat)
        SELECT 'INS', NULL, i.OsobaId, NULL, i.Specijalnost, NULL, i.Sertifikat FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblInstruktorLog]
            (ActionType, Old_OsobaId, New_OsobaId, Old_Specijalnost, New_Specijalnost,
             Old_Sertifikat, New_Sertifikat)
        SELECT 'DEL', d.OsobaId, NULL, d.Specijalnost, NULL, d.Sertifikat, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblInstruktorLog]
        (ActionType, Old_OsobaId, New_OsobaId, Old_Specijalnost, New_Specijalnost,
         Old_Sertifikat, New_Sertifikat)
    SELECT 'UPD', d.OsobaId, i.OsobaId, d.Specijalnost, i.Specijalnost, d.Sertifikat, i.Sertifikat
    FROM deleted d INNER JOIN inserted i ON i.OsobaId = d.OsobaId;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblKurs_Log]
ON [impl].[tblKurs]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblKursLog]
            (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
             Old_Opis, New_Opis, Old_TrajanjeMeseci, New_TrajanjeMeseci,
             Old_PretKursId, New_PretKursId)
        SELECT 'INS', NULL, i.Id, NULL, i.Naziv,
            NULL, i.Opis, NULL, i.TrajanjeMeseci,
            NULL, i.PretKursId
        FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblKursLog]
            (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
             Old_Opis, New_Opis, Old_TrajanjeMeseci, New_TrajanjeMeseci,
             Old_PretKursId, New_PretKursId)
        SELECT 'DEL', d.Id, NULL, d.Naziv, NULL,
            d.Opis, NULL, d.TrajanjeMeseci, NULL,
            d.PretKursId, NULL
        FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblKursLog]
        (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
         Old_Opis, New_Opis, Old_TrajanjeMeseci, New_TrajanjeMeseci,
         Old_PretKursId, New_PretKursId)
    SELECT 'UPD', d.Id, i.Id, d.Naziv, i.Naziv,
        d.Opis, i.Opis, d.TrajanjeMeseci, i.TrajanjeMeseci,
        d.PretKursId, i.PretKursId
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblGrupa_Log]
ON [impl].[tblGrupa]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblGrupaLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_KursId, New_KursId, Old_KoreografId, New_KoreografId,
            Old_PredavacId, New_PredavacId, Old_UkupnoUcenika, New_UkupnoUcenika)
        SELECT 'INS', NULL, i.Id, NULL, i.Naziv, NULL, i.KursId, NULL, i.KoreografId,
            NULL, i.PredavacId, NULL, i.UkupnoUcenika FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblGrupaLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_KursId, New_KursId, Old_KoreografId, New_KoreografId,
            Old_PredavacId, New_PredavacId, Old_UkupnoUcenika, New_UkupnoUcenika)
        SELECT 'DEL', d.Id, NULL, d.Naziv, NULL, d.KursId, NULL, d.KoreografId, NULL,
            d.PredavacId, NULL, d.UkupnoUcenika, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblGrupaLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
        Old_KursId, New_KursId, Old_KoreografId, New_KoreografId,
        Old_PredavacId, New_PredavacId, Old_UkupnoUcenika, New_UkupnoUcenika)
    SELECT 'UPD', d.Id, i.Id, d.Naziv, i.Naziv, d.KursId, i.KursId,
        d.KoreografId, i.KoreografId, d.PredavacId, i.PredavacId, d.UkupnoUcenika, i.UkupnoUcenika
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblNastup_Log]
ON [impl].[tblNastup]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblNastupLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_Datum, New_Datum, Old_Lokacija, New_Lokacija, Old_GrupaId, New_GrupaId,
            Old_InstruktorId, New_InstruktorId)
        SELECT 'INS', NULL, i.Id, NULL, i.Naziv, NULL, i.Datum, NULL, i.Lokacija,
            NULL, i.GrupaId, NULL, i.InstruktorId FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblNastupLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_Datum, New_Datum, Old_Lokacija, New_Lokacija, Old_GrupaId, New_GrupaId,
            Old_InstruktorId, New_InstruktorId)
        SELECT 'DEL', d.Id, NULL, d.Naziv, NULL, d.Datum, NULL, d.Lokacija, NULL,
            d.GrupaId, NULL, d.InstruktorId, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblNastupLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
        Old_Datum, New_Datum, Old_Lokacija, New_Lokacija, Old_GrupaId, New_GrupaId,
        Old_InstruktorId, New_InstruktorId)
    SELECT 'UPD', d.Id, i.Id, d.Naziv, i.Naziv, d.Datum, i.Datum, d.Lokacija, i.Lokacija,
        d.GrupaId, i.GrupaId, d.InstruktorId, i.InstruktorId
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblKostim_Log]
ON [impl].[tblKostim]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblKostimLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_Velicina, New_Velicina, Old_Boja, New_Boja)
        SELECT 'INS', NULL, i.Id, NULL, i.Naziv, NULL, i.Velicina, NULL, i.Boja FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblKostimLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
            Old_Velicina, New_Velicina, Old_Boja, New_Boja)
        SELECT 'DEL', d.Id, NULL, d.Naziv, NULL, d.Velicina, NULL, d.Boja, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblKostimLog] (ActionType, Old_Id, New_Id, Old_Naziv, New_Naziv,
        Old_Velicina, New_Velicina, Old_Boja, New_Boja)
    SELECT 'UPD', d.Id, i.Id, d.Naziv, i.Naziv, d.Velicina, i.Velicina, d.Boja, i.Boja
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblZaduzenje_Log]
ON [impl].[tblZaduzenje]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblZaduzenjeLog] (ActionType, Old_UcenikId, New_UcenikId,
            Old_NastupId, New_NastupId, Old_KostimId, New_KostimId,
            Old_DatumZaduzenja, New_DatumZaduzenja)
        SELECT 'INS', NULL, i.UcenikId, NULL, i.NastupId, NULL, i.KostimId,
            NULL, i.DatumZaduzenja FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblZaduzenjeLog] (ActionType, Old_UcenikId, New_UcenikId,
            Old_NastupId, New_NastupId, Old_KostimId, New_KostimId,
            Old_DatumZaduzenja, New_DatumZaduzenja)
        SELECT 'DEL', d.UcenikId, NULL, d.NastupId, NULL, d.KostimId, NULL,
            d.DatumZaduzenja, NULL FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblZaduzenjeLog] (ActionType, Old_UcenikId, New_UcenikId,
        Old_NastupId, New_NastupId, Old_KostimId, New_KostimId,
        Old_DatumZaduzenja, New_DatumZaduzenja)
    SELECT 'UPD', d.UcenikId, i.UcenikId, d.NastupId, i.NastupId, d.KostimId, i.KostimId,
        d.DatumZaduzenja, i.DatumZaduzenja
    FROM deleted d INNER JOIN inserted i ON i.UcenikId = d.UcenikId AND i.NastupId = d.NastupId;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblKorisnik_Log]
ON [impl].[tblKorisnik]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblKorisnikLog]
            (ActionType, Old_Id, New_Id, Old_Email, New_Email,
             Old_LozinkaHash, New_LozinkaHash, Old_Uloga, New_Uloga,
             Old_InstruktorId, New_InstruktorId)
        SELECT 'INS', NULL, i.Id, NULL, i.Email,
            NULL, i.LozinkaHash, NULL, i.Uloga,
            NULL, i.InstruktorId
        FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblKorisnikLog]
            (ActionType, Old_Id, New_Id, Old_Email, New_Email,
             Old_LozinkaHash, New_LozinkaHash, Old_Uloga, New_Uloga,
             Old_InstruktorId, New_InstruktorId)
        SELECT 'DEL', d.Id, NULL, d.Email, NULL,
            d.LozinkaHash, NULL, d.Uloga, NULL,
            d.InstruktorId, NULL
        FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblKorisnikLog]
        (ActionType, Old_Id, New_Id, Old_Email, New_Email,
         Old_LozinkaHash, New_LozinkaHash, Old_Uloga, New_Uloga,
         Old_InstruktorId, New_InstruktorId)
    SELECT 'UPD', d.Id, i.Id, d.Email, i.Email,
        d.LozinkaHash, i.LozinkaHash, d.Uloga, i.Uloga,
        d.InstruktorId, i.InstruktorId
    FROM deleted d INNER JOIN inserted i ON i.Id = d.Id;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblUcenikGrupa_Log]
ON [impl].[tblUcenikGrupa]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO [impl].[tblUcenikGrupaLog]
            (ActionType, Old_UcenikId, New_UcenikId, Old_GrupaId, New_GrupaId)
        SELECT 'INS', NULL, i.UcenikId, NULL, i.GrupaId
        FROM inserted i;
        RETURN;
    END;
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO [impl].[tblUcenikGrupaLog]
            (ActionType, Old_UcenikId, New_UcenikId, Old_GrupaId, New_GrupaId)
        SELECT 'DEL', d.UcenikId, NULL, d.GrupaId, NULL
        FROM deleted d;
        RETURN;
    END;
    INSERT INTO [impl].[tblUcenikGrupaLog]
        (ActionType, Old_UcenikId, New_UcenikId, Old_GrupaId, New_GrupaId)
    SELECT 'UPD', d.UcenikId, i.UcenikId, d.GrupaId, i.GrupaId
    FROM deleted d INNER JOIN inserted i
        ON i.UcenikId = d.UcenikId AND i.GrupaId = d.GrupaId;
END;
GO

CREATE OR ALTER TRIGGER [impl].[trg_tblUcenikGrupa_UkupnoUcenika]
ON [impl].[tblUcenikGrupa]
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [impl].[tblGrupa]
    SET UkupnoUcenika = (
        SELECT COUNT(*)
        FROM [impl].[tblUcenikGrupa]
        WHERE GrupaId = [impl].[tblGrupa].Id
    )
    WHERE Id IN (
        SELECT DISTINCT GrupaId FROM inserted
        UNION
        SELECT DISTINCT GrupaId FROM deleted
    );
END;
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  Trigeri su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 8. impl pogledi
-- =====================================================

CREATE OR ALTER VIEW [impl].[vwUcenikDetalji]
AS
    SELECT
        u.OsobaId,
        o.Ime,
        o.Prezime,
        o.Email,
        u.BrojKnjizice,
        u.DatumUpisa,
        u.Nivo
    FROM [impl].[tblUcenik] u
    INNER JOIN [impl].[tblOsoba] o ON o.Id = u.OsobaId;
GO

CREATE OR ALTER VIEW [impl].[vwGrupaDetalji]
AS
    SELECT
        g.Id            AS GrupaId,
        g.Naziv         AS GrupaNaziv,
        g.KursId,
        k.Naziv         AS KursNaziv,
        k.TrajanjeMeseci,
        g.KoreografId,
        ok.Ime          AS KoreografIme,
        ok.Prezime      AS KoreografPrezime,
        g.PredavacId,
        op.Ime          AS PredavacIme,
        op.Prezime      AS PredavacPrezime,
        g.UkupnoUcenika
    FROM [impl].[tblGrupa] g
    INNER JOIN [impl].[tblKurs]         k   ON k.Id        = g.KursId
    INNER JOIN [impl].[tblInstruktor]   ik  ON ik.OsobaId  = g.KoreografId
    INNER JOIN [impl].[tblOsoba]        ok  ON ok.Id       = ik.OsobaId
    INNER JOIN [impl].[tblInstruktor]   ip  ON ip.OsobaId  = g.PredavacId
    INNER JOIN [impl].[tblOsoba]        op  ON op.Id       = ip.OsobaId;
GO

CREATE OR ALTER VIEW [impl].[vwInstruktorDetalji]
AS
    SELECT
        i.OsobaId,
        o.Ime,
        o.Prezime,
        o.Email,
        i.Specijalnost,
        i.Sertifikat
    FROM [impl].[tblInstruktor] i
    INNER JOIN [impl].[tblOsoba] o ON o.Id = i.OsobaId;
GO

CREATE OR ALTER VIEW [impl].[vwNastupDetalji]
AS
    SELECT
        n.Id                AS NastupId,
        n.Naziv             AS NastupNaziv,
        n.Datum,
        n.Lokacija,
        g.Naziv             AS GrupaNaziv,
        n.GrupaId,
        n.InstruktorId,
        oi.Ime              AS OrganizatorIme,
        oi.Prezime          AS OrganizatorPrezime
    FROM [impl].[tblNastup] n
    INNER JOIN [impl].[tblGrupa]        g   ON g.Id        = n.GrupaId
    INNER JOIN [impl].[tblInstruktor]   i   ON i.OsobaId   = n.InstruktorId
    INNER JOIN [impl].[tblOsoba]        oi  ON oi.Id       = i.OsobaId;
GO

CREATE OR ALTER VIEW [impl].[vwZaduzenjeDetalji]
AS
    SELECT
        z.UcenikId,
        ou.Ime              AS UcenikIme,
        ou.Prezime          AS UcenikPrezime,
        z.NastupId,
        n.Naziv             AS NastupNaziv,
        n.Datum             AS NastupDatum,
        z.KostimId,
        k.Naziv             AS KostimNaziv,
        k.Velicina          AS KostimVelicina,
        k.Boja              AS KostimBoja,
        z.DatumZaduzenja
    FROM [impl].[tblZaduzenje] z
    INNER JOIN [impl].[tblUcenik]   u   ON u.OsobaId    = z.UcenikId
    INNER JOIN [impl].[tblOsoba]    ou  ON ou.Id        = u.OsobaId
    INNER JOIN [impl].[tblNastup]   n   ON n.Id         = z.NastupId
    INNER JOIN [impl].[tblKostim]   k   ON k.Id         = z.KostimId;
GO

CREATE OR ALTER VIEW [impl].[vwKorisnikDetalji]
AS
    SELECT
        k.Id,
        k.Email,
        k.LozinkaHash,
        k.Uloga,
        k.InstruktorId,
        o.Ime,
        o.Prezime
    FROM [impl].[tblKorisnik] k
    LEFT JOIN [impl].[tblInstruktor]    i   ON i.OsobaId    = k.InstruktorId
    LEFT JOIN [impl].[tblOsoba]         o   ON o.Id         = i.OsobaId;
GO

CREATE OR ALTER VIEW [impl].[vwKursDetalji]
AS
    SELECT
        k.Id,
        k.Naziv,
        k.Opis,
        k.TrajanjeMeseci,
        k.PretKursId,
        pk.Naziv AS PretKursNaziv
    FROM [impl].[tblKurs] k
    LEFT JOIN [impl].[tblKurs] pk ON pk.Id = k.PretKursId;
GO

CREATE OR ALTER VIEW [impl].[vwUcenikGrupaDetalji]
AS
    SELECT
        u.OsobaId,
        o.Ime,
        o.Prezime,
        o.Email,
        u.BrojKnjizice,
        u.DatumUpisa,
        u.Nivo,
        g.Id            AS GrupaId,
        g.Naziv         AS GrupaNaziv,
        g.KoreografId,
        g.PredavacId
    FROM [impl].[tblUcenikGrupa]    ug
    INNER JOIN [impl].[tblUcenik]   u   ON u.OsobaId    = ug.UcenikId
    INNER JOIN [impl].[tblOsoba]    o   ON o.Id         = u.OsobaId
    INNER JOIN [impl].[tblGrupa]    g   ON g.Id         = ug.GrupaId;
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  impl pogledi su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 9. spec pogledi
-- =====================================================

CREATE OR ALTER VIEW [spec].[vw_UCENIK]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, BrojKnjizice, DatumUpisa, Nivo
    FROM [impl].[vwUcenikDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_GRUPA]
WITH ENCRYPTION
AS
    SELECT GrupaId, GrupaNaziv, KursId, KursNaziv, TrajanjeMeseci,
           KoreografId, KoreografIme, KoreografPrezime,
           PredavacId, PredavacIme, PredavacPrezime, UkupnoUcenika
    FROM [impl].[vwGrupaDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_NASTUP]
WITH ENCRYPTION
AS
    SELECT NastupId, NastupNaziv, Datum, Lokacija,
           GrupaNaziv, GrupaId, InstruktorId, OrganizatorIme, OrganizatorPrezime
    FROM [impl].[vwNastupDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_INSTRUKTOR]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, Specijalnost, Sertifikat
    FROM [impl].[vwInstruktorDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_KOSTIM]
WITH ENCRYPTION
AS
    SELECT Id AS KostimId, Naziv, Velicina, Boja
    FROM [impl].[tblKostim];
GO

CREATE OR ALTER VIEW [spec].[vw_KURS]
WITH ENCRYPTION
AS
    SELECT Id, Naziv, Opis, TrajanjeMeseci, PretKursId
    FROM [impl].[tblKurs];
GO

CREATE OR ALTER VIEW [spec].[vw_ZADUZENJE]
WITH ENCRYPTION
AS
    SELECT UcenikId, UcenikIme, UcenikPrezime, NastupId, NastupNaziv,
           NastupDatum, KostimId, KostimNaziv, KostimVelicina, KostimBoja, DatumZaduzenja
    FROM [impl].[vwZaduzenjeDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_KORISNIK]
WITH ENCRYPTION
AS
    SELECT Id, Email, LozinkaHash, Uloga, InstruktorId, Ime, Prezime
    FROM [impl].[vwKorisnikDetalji];
GO

CREATE OR ALTER VIEW [spec].[vw_UCENIK_GRUPA]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, BrojKnjizice, DatumUpisa, Nivo,
           GrupaId, GrupaNaziv, KoreografId, PredavacId
    FROM [impl].[vwUcenikGrupaDetalji];
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  spec pogledi su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 10. api_studio pogledi
-- =====================================================

CREATE OR ALTER VIEW [api_studio].[UCENIK]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, BrojKnjizice, DatumUpisa, Nivo
    FROM [spec].[vw_UCENIK];
GO

CREATE OR ALTER VIEW [api_studio].[GRUPA]
WITH ENCRYPTION
AS
    SELECT GrupaId, GrupaNaziv, KursId, KursNaziv,
           KoreografId, KoreografIme, KoreografPrezime,
           PredavacId, PredavacIme, PredavacPrezime, UkupnoUcenika
    FROM [spec].[vw_GRUPA];
GO

CREATE OR ALTER VIEW [api_studio].[NASTUP]
WITH ENCRYPTION
AS
    SELECT NastupId, NastupNaziv, Datum, Lokacija,
           GrupaNaziv, GrupaId, InstruktorId, OrganizatorIme, OrganizatorPrezime
    FROM [spec].[vw_NASTUP];
GO

CREATE OR ALTER VIEW [api_studio].[INSTRUKTOR]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, Specijalnost, Sertifikat
    FROM [spec].[vw_INSTRUKTOR];
GO

CREATE OR ALTER VIEW [api_studio].[KOSTIM]
WITH ENCRYPTION
AS
    SELECT KostimId, Naziv, Velicina, Boja
    FROM [spec].[vw_KOSTIM];
GO

CREATE OR ALTER VIEW [api_studio].[KURS]
WITH ENCRYPTION
AS
    SELECT Id, Naziv, Opis, TrajanjeMeseci, PretKursId
    FROM [spec].[vw_KURS];
GO

CREATE OR ALTER VIEW [api_studio].[ZADUZENJE]
WITH ENCRYPTION
AS
    SELECT UcenikId, UcenikIme, UcenikPrezime, NastupId, NastupNaziv,
           NastupDatum, KostimId, KostimNaziv, KostimVelicina, KostimBoja, DatumZaduzenja
    FROM [spec].[vw_ZADUZENJE];
GO

CREATE OR ALTER VIEW [api_studio].[KORISNIK]
WITH ENCRYPTION
AS
    SELECT Id, Email, LozinkaHash, Uloga, InstruktorId, Ime, Prezime
    FROM [spec].[vw_KORISNIK];
GO

CREATE OR ALTER VIEW [api_studio].[UCENIK_GRUPA]
WITH ENCRYPTION
AS
    SELECT OsobaId, Ime, Prezime, Email, BrojKnjizice, DatumUpisa, Nivo,
           GrupaId, GrupaNaziv, KoreografId, PredavacId
    FROM [spec].[vw_UCENIK_GRUPA];
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  api_studio pogledi su kreirani.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 11. impl helper procedure
-- =====================================================

CREATE OR ALTER PROCEDURE impl.uprLogError
    @ErrorNumber   INT,
    @ErrorMessage  NVARCHAR(400),
    @ProcedureName NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO impl.tblErrorLog (ErrorNumber, ErrorMessage, ProcedureName)
    VALUES (@ErrorNumber, @ErrorMessage, @ProcedureName);
END;
GO

CREATE OR ALTER PROCEDURE impl.uprValidateOsobaValues
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @CallerName NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF @ime IS NULL OR @ime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50001,
            @ErrorMessage  = N'Ime особе мора започети великим словом ћирилице.',
            @ProcedureName = @CallerName;
        THROW 50001, N'Ime особе мора започети великим словом ћирилице.', 1;
    END;

    IF @prezime IS NULL OR @prezime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50002,
            @ErrorMessage  = N'Презиме особе мора започети великим словом ћирилице.',
            @ProcedureName = @CallerName;
        THROW 50002, N'Презиме особе мора започети великим словом ћирилице.', 1;
    END;

    IF @email IS NULL OR @email NOT LIKE N'%@%.%'
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50003,
            @ErrorMessage  = N'Адреса е-поште особе није исправна.',
            @ProcedureName = @CallerName;
        THROW 50003, N'Адреса е-поште особе није исправна.', 1;
    END;

    IF EXISTS (SELECT 1 FROM impl.tblOsoba WHERE Email = @email)
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50004,
            @ErrorMessage  = N'Особа са задатом адресом е-поште већ постоји.',
            @ProcedureName = @CallerName;
        THROW 50004, N'Особа са задатом адресом е-поште већ постоји.', 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE impl.uprValidateUcenikValues
    @nivo       NVARCHAR(20),
    @datumUpisa DATE,
    @CallerName NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nivo NOT IN (N'Почетни', N'Средњи', N'Напредни')
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50010,
            @ErrorMessage  = N'Ниво мора бити: Почетни, Средњи или Напредни.',
            @ProcedureName = @CallerName;
        THROW 50010, N'Ниво мора бити: Почетни, Средњи или Напредни.', 1;
    END;

    IF @datumUpisa IS NULL
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50011,
            @ErrorMessage  = N'Датум уписа је обавезан.',
            @ProcedureName = @CallerName;
        THROW 50011, N'Датум уписа је обавезан.', 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE impl.uprCheckUcenikConstraints
    @grupaId    INT,
    @CallerName NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM impl.tblGrupa WHERE Id = @grupaId)
    BEGIN
        EXEC impl.uprLogError
            @ErrorNumber   = 50012,
            @ErrorMessage  = N'Не постоји наведена група. Унос ученика није могућ.',
            @ProcedureName = @CallerName;
        THROW 50012, N'Не постоји наведена група. Унос ученика није могућ.', 1;
    END;
END;
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  impl helper procedure su kreirane.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 12. spec procedure
-- =====================================================

CREATE OR ALTER PROCEDURE [spec].[upr_InsertOsoba]
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @NewId      INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @ime IS NULL OR @ime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50001, N'Ime особе мора започети великим словом ћирилице.', 1;
    IF @prezime IS NULL OR @prezime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50002, N'Презиме особе мора започети великим словом ћирилице.', 1;
    IF @email IS NULL OR @email NOT LIKE N'%@%.%'
        THROW 50003, N'Адреса е-поште особе није исправна.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblOsoba] WHERE Email = @email)
        THROW 50004, N'Особа са задатом адресом е-поште већ постоји.', 1;

    BEGIN TRY
        INSERT INTO [impl].[tblOsoba] (Ime, Prezime, Email) VALUES (@ime, @prezime, @email);
        SET @NewId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum1 INT = ERROR_NUMBER();
        DECLARE @ErrMsg1 NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum1, @ErrMsg1, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertUcenikGrupa]
    @ucenikId   INT,
    @grupaId    INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblUcenik] WHERE OsobaId = @ucenikId)
        THROW 50130, N'Не постоји наведена ученица.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50131, N'Не постоји наведена група.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblUcenikGrupa]
        WHERE UcenikId = @ucenikId AND GrupaId = @grupaId)
        THROW 50132, N'Ученица је већ у наведеној групи.', 1;

    BEGIN TRY
        INSERT INTO [impl].[tblUcenikGrupa] (UcenikId, GrupaId)
        VALUES (@ucenikId, @grupaId);
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertUcenik]
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @datumUpisa DATE,
    @nivo       NVARCHAR(20),
    @grupaId    INT,
    @NewId      INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @nivo NOT IN (N'Почетни', N'Средњи', N'Напредни')
        THROW 50010, N'Ниво мора бити: Почетни, Средњи или Напредни.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50011, N'Не постоји наведена група.', 1;

    DECLARE @godina     NVARCHAR(4)  = CAST(YEAR(GETDATE()) AS NVARCHAR(4));
    DECLARE @prefix     NVARCHAR(10) = N'K-' + @godina + N'-';
    DECLARE @sledbBroj  INT;

    SELECT @sledbBroj = ISNULL(MAX(
        CAST(SUBSTRING(BrojKnjizice, LEN(@prefix) + 1,
            LEN(BrojKnjizice) - LEN(@prefix)) AS INT)), 0) + 1
    FROM [impl].[tblUcenik]
    WHERE BrojKnjizice LIKE @prefix + N'%'
      AND ISNUMERIC(SUBSTRING(BrojKnjizice, LEN(@prefix) + 1,
            LEN(BrojKnjizice) - LEN(@prefix))) = 1;

    DECLARE @brojKnjizice NVARCHAR(20) =
        @prefix + RIGHT(N'000' + CAST(@sledbBroj AS NVARCHAR(10)), 3);

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @OsobaId INT;
        EXEC [spec].[upr_InsertOsoba]
            @ime=@ime, @prezime=@prezime, @email=@email, @NewId=@OsobaId OUTPUT;
        INSERT INTO [impl].[tblUcenik] (OsobaId, BrojKnjizice, DatumUpisa, Nivo)
        VALUES (@OsobaId, @brojKnjizice, @datumUpisa, @nivo);
        EXEC [spec].[upr_InsertUcenikGrupa]
            @ucenikId=@OsobaId, @grupaId=@grupaId;
        SET @NewId = @OsobaId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum2 INT = ERROR_NUMBER();
        DECLARE @ErrMsg2 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum2, @ErrMsg2, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateUcenik]
    @ucenikId   INT,
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @datumUpisa DATE,
    @nivo       NVARCHAR(20)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblUcenik] WHERE OsobaId = @ucenikId)
        THROW 50140, N'Не постоји наведена ученица.', 1;
    IF @ime IS NULL OR @ime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50141, N'Име мора започети великим словом ћирилице.', 1;
    IF @prezime IS NULL OR @prezime NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50142, N'Презиме мора започети великим словом ћирилице.', 1;
    IF @email IS NULL OR @email NOT LIKE N'%@%.%'
        THROW 50143, N'Адреса е-поште није исправна.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblOsoba]
        WHERE Email = @email AND Id <> @ucenikId)
        THROW 50144, N'Особа са наведеном адресом е-поште већ постоји.', 1;
    IF @nivo NOT IN (N'Почетни', N'Средњи', N'Напредни')
        THROW 50145, N'Ниво мора бити: Почетни, Средњи или Напредни.', 1;
    IF @datumUpisa IS NULL
        THROW 50146, N'Датум уписа је обавезан.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblOsoba]
        SET Ime = @ime, Prezime = @prezime, Email = @email
        WHERE Id = @ucenikId;
        UPDATE [impl].[tblUcenik]
        SET DatumUpisa = @datumUpisa, Nivo = @nivo
        WHERE OsobaId = @ucenikId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateNivoUcenika]
    @ucenikId   INT,
    @noviNivo   NVARCHAR(20)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @noviNivo NOT IN (N'Почетни', N'Средњи', N'Напредни')
        THROW 50090, N'Ниво мора бити: Почетни, Средњи или Напредни.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblUcenik] WHERE OsobaId = @ucenikId)
        THROW 50091, N'Не постоји наведени ученик. Није могуће изменити ниво.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblUcenik] SET Nivo = @noviNivo WHERE OsobaId = @ucenikId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum10 INT = ERROR_NUMBER();
        DECLARE @ErrMsg10 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum10, @ErrMsg10, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteUcenik]
    @ucenikId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblUcenik] WHERE OsobaId = @ucenikId)
        THROW 50100, N'Не постоји наведена ученица. Брисање није могуће.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblZaduzenje]   WHERE UcenikId = @ucenikId;
        DELETE FROM [impl].[tblUcenikGrupa] WHERE UcenikId = @ucenikId;
        DELETE FROM [impl].[tblUcenik]      WHERE OsobaId  = @ucenikId;
        DELETE FROM [impl].[tblOsoba]       WHERE Id       = @ucenikId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum11 INT = ERROR_NUMBER();
        DECLARE @ErrMsg11 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum11, @ErrMsg11, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertInstruktor]
    @ime            NVARCHAR(50),
    @prezime        NVARCHAR(50),
    @email          NVARCHAR(100),
    @specijalnost   NVARCHAR(50),
    @sertifikat     NVARCHAR(100) = NULL,
    @NewId          INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @specijalnost IS NULL OR @specijalnost NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50020, N'Специјалност инструктора мора започети великим словом ћирилице.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @OsobaId INT;
        EXEC [spec].[upr_InsertOsoba]
            @ime=@ime, @prezime=@prezime, @email=@email, @NewId=@OsobaId OUTPUT;
        INSERT INTO [impl].[tblInstruktor] (OsobaId, Specijalnost, Sertifikat)
        VALUES (@OsobaId, @specijalnost, @sertifikat);
        SET @NewId = @OsobaId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum3 INT = ERROR_NUMBER();
        DECLARE @ErrMsg3 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum3, @ErrMsg3, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteInstruktor]
    @instruktorId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @instruktorId)
        THROW 50030, N'Не постоји наведени инструктор. Брисање није могуће.', 1;

    DECLARE @NazivGrupe NVARCHAR(80);
    SELECT TOP 1 @NazivGrupe = Naziv FROM [impl].[tblGrupa]
    WHERE KoreografId = @instruktorId OR PredavacId = @instruktorId;
    IF @NazivGrupe IS NOT NULL
        THROW 50031, N'Није могуће обрисати инструктора – активан је у групи.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblKorisnik]    WHERE InstruktorId = @instruktorId;
        DELETE FROM [impl].[tblInstruktor]  WHERE OsobaId      = @instruktorId;
        DELETE FROM [impl].[tblOsoba]       WHERE Id           = @instruktorId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum4 INT = ERROR_NUMBER();
        DECLARE @ErrMsg4 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum4, @ErrMsg4, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertGrupa]
    @naziv          NVARCHAR(80),
    @kursId         INT,
    @koreografId    INT,
    @predavacId     INT,
    @NewId          INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50040, N'Назив групе мора започети великим словом ћирилице.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Naziv = @naziv)
        THROW 50041, N'Група са наведеним називом већ постоји.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @kursId)
        THROW 50042, N'Не постоји наведени курс. Није могуће унети нову групу.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @koreografId)
        THROW 50043, N'Не постоји наведени кореограф. Није могуће унети нову групу.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @predavacId)
        THROW 50044, N'Не постоји наведени предавач. Није могуће унети нову групу.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [impl].[tblGrupa] (Naziv, KursId, KoreografId, PredavacId)
        VALUES (@naziv, @kursId, @koreografId, @predavacId);
        SET @NewId = SCOPE_IDENTITY();
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum5 INT = ERROR_NUMBER();
        DECLARE @ErrMsg5 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum5, @ErrMsg5, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateGrupa]
    @grupaId        INT,
    @naziv          NVARCHAR(80),
    @kursId         INT,
    @koreografId    INT,
    @predavacId     INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50170, N'Не постоји наведена група.', 1;
    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50171, N'Назив групе мора започети великим словом ћирилице.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Naziv = @naziv AND Id <> @grupaId)
        THROW 50172, N'Група са наведеним називом већ постоји.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @kursId)
        THROW 50173, N'Не постоји наведени курс.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @koreografId)
        THROW 50174, N'Не постоји наведени кореограф.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @predavacId)
        THROW 50175, N'Не постоји наведени предавач.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblGrupa]
        SET Naziv = @naziv, KursId = @kursId,
            KoreografId = @koreografId, PredavacId = @predavacId
        WHERE Id = @grupaId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteGrupa]
    @grupaId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50176, N'Не постоји наведена група. Брисање није могуће.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblNastup] WHERE GrupaId = @grupaId)
        THROW 50177, N'Није могуће обрисати групу – постоје наступи везани за њу.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblUcenikGrupa] WHERE GrupaId = @grupaId)
        THROW 50178, N'Није могуће обрисати групу – постоје ученице у групи.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblGrupa] WHERE Id = @grupaId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertNastup]
    @naziv          NVARCHAR(100),
    @datum          DATE,
    @lokacija       NVARCHAR(100),
    @grupaId        INT,
    @instruktorId   INT,
    @NewId          INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50050, N'Назив наступа мора започети великим словом ћирилице.', 1;
    IF @datum IS NULL
        THROW 50051, N'Датум наступа је обавезан.', 1;
    IF @lokacija IS NULL OR @lokacija NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50052, N'Локација наступа мора започети великим словом ћирилице.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50053, N'Не постоји наведена група. Није могуће унети нови наступ.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @instruktorId)
        THROW 50054, N'Не постоји наведени инструктор. Није могуће унети нови наступ.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [impl].[tblNastup] (Naziv, Datum, Lokacija, GrupaId, InstruktorId)
        VALUES (@naziv, @datum, @lokacija, @grupaId, @instruktorId);
        SET @NewId = SCOPE_IDENTITY();
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum6 INT = ERROR_NUMBER();
        DECLARE @ErrMsg6 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum6, @ErrMsg6, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateNastup]
    @nastupId       INT,
    @naziv          NVARCHAR(100),
    @datum          DATE,
    @lokacija       NVARCHAR(100),
    @grupaId        INT,
    @instruktorId   INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblNastup] WHERE Id = @nastupId)
        THROW 50180, N'Не постоји наведени наступ.', 1;
    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50181, N'Назив наступа мора започети великим словом ћирилице.', 1;
    IF @datum IS NULL
        THROW 50182, N'Датум наступа је обавезан.', 1;
    IF @lokacija IS NULL OR @lokacija NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50183, N'Локација мора започети великим словом ћирилице.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE Id = @grupaId)
        THROW 50184, N'Не постоји наведена група.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @instruktorId)
        THROW 50185, N'Не постоји наведени инструктор.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblNastup]
        SET Naziv = @naziv, Datum = @datum, Lokacija = @lokacija,
            GrupaId = @grupaId, InstruktorId = @instruktorId
        WHERE Id = @nastupId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteNastup]
    @nastupId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblNastup] WHERE Id = @nastupId)
        THROW 50186, N'Не постоји наведени наступ. Брисање није могуће.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblZaduzenje] WHERE NastupId = @nastupId)
        THROW 50187, N'Није могуће обрисати наступ – постоје задужења везана за њега.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblNastup] WHERE Id = @nastupId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertKostim]
    @naziv      NVARCHAR(80),
    @velicina   NVARCHAR(5),
    @boja       NVARCHAR(30),
    @NewId      INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50060, N'Назив костима мора започети великим словом ћирилице.', 1;
    IF @velicina NOT IN (N'XS', N'S', N'M', N'L', N'XL')
        THROW 50061, N'Величина костима мора бити: XS, S, M, L или XL.', 1;
    IF @boja IS NULL OR @boja NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50062, N'Боја костима мора започети великим словом ћирилице.', 1;

    BEGIN TRY
        INSERT INTO [impl].[tblKostim] (Naziv, Velicina, Boja) VALUES (@naziv, @velicina, @boja);
        SET @NewId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum7 INT = ERROR_NUMBER();
        DECLARE @ErrMsg7 NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum7, @ErrMsg7, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateKostim]
    @kostimId   INT,
    @naziv      NVARCHAR(80),
    @velicina   NVARCHAR(5),
    @boja       NVARCHAR(30)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKostim] WHERE Id = @kostimId)
        THROW 50190, N'Не постоји наведени костим.', 1;
    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50191, N'Назив костима мора започети великим словом ћирилице.', 1;
    IF @velicina NOT IN (N'XS', N'S', N'M', N'L', N'XL')
        THROW 50192, N'Величина мора бити: XS, S, M, L или XL.', 1;
    IF @boja IS NULL OR @boja NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50193, N'Боја мора започети великим словом ћирилице.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblKostim]
        SET Naziv = @naziv, Velicina = @velicina, Boja = @boja
        WHERE Id = @kostimId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteKostim]
    @kostimId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKostim] WHERE Id = @kostimId)
        THROW 50194, N'Не постоји наведени костим. Брисање није могуће.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblZaduzenje] WHERE KostimId = @kostimId)
        THROW 50195, N'Није могуће обрисати костим – постоје задужења везана за њега.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblKostim] WHERE Id = @kostimId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertKurs]
    @naziv          NVARCHAR(80),
    @opis           NVARCHAR(300) = NULL,
    @trajanjeMeseci INT,
    @pretKursId     INT = NULL,
    @NewId          INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50070, N'Назив курса мора започети великим словом ћирилице.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Naziv = @naziv)
        THROW 50071, N'Курс са наведеним називом већ постоји.', 1;
    IF @trajanjeMeseci IS NULL OR @trajanjeMeseci < 1 OR @trajanjeMeseci > 36
        THROW 50072, N'Трајање курса мора бити у интервалу од 1 до 36 месеци.', 1;
    IF @pretKursId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @pretKursId)
        THROW 50073, N'Не постоји наведени курс предуслов. Није могуће унети нови курс.', 1;

    BEGIN TRY
        INSERT INTO [impl].[tblKurs] (Naziv, Opis, TrajanjeMeseci, PretKursId)
        VALUES (@naziv, @opis, @trajanjeMeseci, @pretKursId);
        SET @NewId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum8 INT = ERROR_NUMBER();
        DECLARE @ErrMsg8 NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum8, @ErrMsg8, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateKurs]
    @kursId         INT,
    @naziv          NVARCHAR(80),
    @opis           NVARCHAR(300) = NULL,
    @trajanjeMeseci INT,
    @pretKursId     INT = NULL
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @kursId)
        THROW 50200, N'Не постоји наведени курс.', 1;
    IF @naziv IS NULL OR @naziv NOT LIKE N'[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]%'
        THROW 50201, N'Назив курса мора започети великим словом ћирилице.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Naziv = @naziv AND Id <> @kursId)
        THROW 50202, N'Курс са наведеним називом већ постоји.', 1;
    IF @trajanjeMeseci IS NULL OR @trajanjeMeseci < 1 OR @trajanjeMeseci > 36
        THROW 50203, N'Трајање курса мора бити у интервалу од 1 до 36 месеци.', 1;
    IF @pretKursId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @pretKursId)
        THROW 50204, N'Не постоји наведени курс предуслов.', 1;
    IF @pretKursId = @kursId
        THROW 50205, N'Курс не може бити предуслов самом себи.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblKurs]
        SET Naziv = @naziv, Opis = @opis,
            TrajanjeMeseci = @trajanjeMeseci, PretKursId = @pretKursId
        WHERE Id = @kursId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteKurs]
    @kursId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE Id = @kursId)
        THROW 50206, N'Не постоји наведени курс. Брисање није могуће.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblGrupa] WHERE KursId = @kursId)
        THROW 50207, N'Није могуће обрисати курс – постоје групе везане за њега.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblKurs] WHERE PretKursId = @kursId)
        THROW 50208, N'Није могуће обрисати курс – други курсеви га користе као предуслов.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblKurs] WHERE Id = @kursId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertZaduzenje]
    @ucenikId       INT,
    @nastupId       INT,
    @kostimId       INT,
    @datumZaduzenja DATE = NULL
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @datumZaduzenja IS NULL SET @datumZaduzenja = CAST(GETDATE() AS DATE);

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblUcenik] WHERE OsobaId = @ucenikId)
        THROW 50080, N'Не постоји наведени ученик. Није могуће унети задужење.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblNastup] WHERE Id = @nastupId)
        THROW 50081, N'Не постоји наведени наступ. Није могуће унети задужење.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKostim] WHERE Id = @kostimId)
        THROW 50082, N'Не постоји наведени костим. Није могуће унети задужење.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblZaduzenje]
        WHERE UcenikId = @ucenikId AND NastupId = @nastupId)
        THROW 50083, N'Ученик већ има задужени костим за наведени наступ.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO [impl].[tblZaduzenje] (UcenikId, NastupId, KostimId, DatumZaduzenja)
        VALUES (@ucenikId, @nastupId, @kostimId, @datumZaduzenja);
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum9 INT = ERROR_NUMBER();
        DECLARE @ErrMsg9 NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum9, @ErrMsg9, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_UpdateZaduzenje]
    @ucenikId       INT,
    @nastupId       INT,
    @noviKostimId   INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblZaduzenje]
        WHERE UcenikId = @ucenikId AND NastupId = @nastupId)
        THROW 50150, N'Не постоји наведено задужење.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKostim] WHERE Id = @noviKostimId)
        THROW 50151, N'Не постоји наведени костим.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [impl].[tblZaduzenje]
        SET KostimId = @noviKostimId
        WHERE UcenikId = @ucenikId AND NastupId = @nastupId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_DeleteZaduzenje]
    @ucenikId   INT,
    @nastupId   INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF NOT EXISTS (SELECT 1 FROM [impl].[tblZaduzenje]
        WHERE UcenikId = @ucenikId AND NastupId = @nastupId)
        THROW 50160, N'Не постоји наведено задужење.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [impl].[tblZaduzenje]
        WHERE UcenikId = @ucenikId AND NastupId = @nastupId;
        IF XACT_STATE() = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_InsertKorisnik]
    @email          NVARCHAR(100),
    @lozinkaHash    NVARCHAR(256),
    @uloga          NVARCHAR(20),
    @instruktorId   INT = NULL,
    @NewId          INT OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @email IS NULL OR @email NOT LIKE N'%@%.%'
        THROW 50120, N'Адреса е-поште није исправна.', 1;
    IF EXISTS (SELECT 1 FROM [impl].[tblKorisnik] WHERE Email = @email)
        THROW 50121, N'Корисник са наведеном адресом е-поште већ постоји.', 1;
    IF @uloga NOT IN (N'Admin', N'Instruktor')
        THROW 50122, N'Улога мора бити Admin или Instruktor.', 1;
    IF @uloga = N'Instruktor' AND @instruktorId IS NULL
        THROW 50123, N'Инструктор мора имати повезан ИД.', 1;
    IF @uloga = N'Instruktor' AND NOT EXISTS
        (SELECT 1 FROM [impl].[tblInstruktor] WHERE OsobaId = @instruktorId)
        THROW 50124, N'Не постоји инструктор са наведеним ИД-ом.', 1;

    BEGIN TRY
        INSERT INTO [impl].[tblKorisnik] (Email, LozinkaHash, Uloga, InstruktorId)
        VALUES (@email, @lozinkaHash, @uloga, @instruktorId);
        SET @NewId = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum2 INT = ERROR_NUMBER();
        DECLARE @ErrMsg2 NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum2, @ErrMsg2, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_LoginKorisnik]
    @email          NVARCHAR(100),
    @uloga          NVARCHAR(20)    OUTPUT,
    @lozinkaHash    NVARCHAR(256)   OUTPUT,
    @instruktorId   INT             OUTPUT,
    @ime            NVARCHAR(50)    OUTPUT,
    @prezime        NVARCHAR(50)    OUTPUT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcName NVARCHAR(300) =
        QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)) + N'.' + QUOTENAME(OBJECT_NAME(@@PROCID));

    IF @email IS NULL OR @email NOT LIKE N'%@%.%'
        THROW 50110, N'Адреса е-поште није исправна.', 1;
    IF NOT EXISTS (SELECT 1 FROM [impl].[tblKorisnik] WHERE Email = @email)
        THROW 50111, N'Корисник са наведеном адресом е-поште не постоји.', 1;

    BEGIN TRY
        SELECT
            @lozinkaHash    = LozinkaHash,
            @uloga          = Uloga,
            @instruktorId   = InstruktorId,
            @ime            = Ime,
            @prezime        = Prezime
        FROM [impl].[vwKorisnikDetalji]
        WHERE Email = @email;
    END TRY
    BEGIN CATCH
        DECLARE @ErrNum INT = ERROR_NUMBER();
        DECLARE @ErrMsg NVARCHAR(400) = ERROR_MESSAGE();
        INSERT INTO [impl].[tblErrorLog] (ErrorNumber, ErrorMessage, ProcedureName)
        VALUES (@ErrNum, @ErrMsg, @ProcName);
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_IzmeniKorisnika]
    @trenutniEmail  NVARCHAR(200),
    @ime            NVARCHAR(100) = NULL,
    @prezime        NVARCHAR(100) = NULL,
    @noviEmail      NVARCHAR(200) = NULL,
    @noviHash       NVARCHAR(256) = NULL
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM impl.tblKorisnik WHERE Email = @trenutniEmail)
        THROW 50090, N'Корисник није пронађен.', 1;

    IF @noviEmail IS NOT NULL AND @noviEmail <> @trenutniEmail
    BEGIN
        IF EXISTS (SELECT 1 FROM impl.tblKorisnik WHERE Email = @noviEmail)
            THROW 50091, N'Email је већ у употреби.', 1;
    END

    DECLARE @instruktorId INT;
    SELECT @instruktorId = InstruktorId
    FROM impl.tblKorisnik
    WHERE Email = @trenutniEmail;

    UPDATE impl.tblKorisnik SET
        Email       = ISNULL(@noviEmail, Email),
        LozinkaHash = ISNULL(@noviHash,  LozinkaHash)
    WHERE Email = @trenutniEmail;

    IF @instruktorId IS NOT NULL AND (@ime IS NOT NULL OR @prezime IS NOT NULL)
    BEGIN
        UPDATE impl.tblOsoba SET
            Ime     = ISNULL(@ime,      Ime),
            Prezime = ISNULL(@prezime,  Prezime),
            Email   = ISNULL(@noviEmail, Email)
        WHERE Id = @instruktorId;
    END
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_GetUceniciPoInstruktoru]
    @instruktorId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [impl].[vwUcenikGrupaDetalji]
    WHERE KoreografId = @instruktorId
       OR PredavacId  = @instruktorId;
END;
GO

CREATE OR ALTER PROCEDURE [spec].[upr_GetZaduzenjaPoInstruktoru]
    @instruktorId INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT
        z.UcenikId, z.UcenikIme, z.UcenikPrezime,
        z.NastupId, z.NastupNaziv, z.NastupDatum,
        z.KostimId, z.KostimNaziv, z.KostimVelicina,
        z.KostimBoja, z.DatumZaduzenja
    FROM [impl].[vwZaduzenjeDetalji] z
    INNER JOIN [impl].[tblUcenikGrupa] ug ON ug.UcenikId = z.UcenikId
    INNER JOIN [impl].[tblGrupa] g ON g.Id = ug.GrupaId
    WHERE g.KoreografId = @instruktorId
       OR g.PredavacId  = @instruktorId;
END;
GO

-- spec skalarnu funkciju za broj nastupa ucenika
CREATE OR ALTER FUNCTION [spec].[fns_BrojNastupaUcenika] (@ucenikId INT)
RETURNS INT
WITH ENCRYPTION
AS
BEGIN
    DECLARE @broj INT;
    SELECT @broj = COUNT(*) FROM [impl].[tblZaduzenje] WHERE UcenikId = @ucenikId;
    RETURN ISNULL(@broj, 0);
END;
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  spec procedure i funkcije su kreirane.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 13. api_studio procedure
-- =====================================================

CREATE OR ALTER PROCEDURE [api_studio].[DodajUcenika]
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @datumUpisa DATE,
    @nivo       NVARCHAR(20),
    @grupaId    INT,
    @newId      INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertUcenik]
        @ime=@ime, @prezime=@prezime, @email=@email,
        @datumUpisa=@datumUpisa, @nivo=@nivo,
        @grupaId=@grupaId, @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniUcenicu]
    @ucenikId   INT,
    @ime        NVARCHAR(50),
    @prezime    NVARCHAR(50),
    @email      NVARCHAR(100),
    @datumUpisa DATE,
    @nivo       NVARCHAR(20)
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateUcenik]
        @ucenikId=@ucenikId, @ime=@ime, @prezime=@prezime,
        @email=@email, @datumUpisa=@datumUpisa, @nivo=@nivo;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniNivoUcenika]
    @ucenikId   INT,
    @noviNivo   NVARCHAR(20)
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateNivoUcenika] @ucenikId=@ucenikId, @noviNivo=@noviNivo;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiUcenika]
    @ucenikId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteUcenik] @ucenikId=@ucenikId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajUcenikuUGrupu]
    @ucenikId   INT,
    @grupaId    INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertUcenikGrupa]
        @ucenikId=@ucenikId, @grupaId=@grupaId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[BrojNastupaUcenika]
    @ucenikId   INT,
    @rezultat   INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SET @rezultat = [spec].[fns_BrojNastupaUcenika](@ucenikId);
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajInstruktora]
    @ime            NVARCHAR(50),
    @prezime        NVARCHAR(50),
    @email          NVARCHAR(100),
    @specijalnost   NVARCHAR(50),
    @sertifikat     NVARCHAR(100) = NULL,
    @newId          INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertInstruktor]
        @ime=@ime, @prezime=@prezime, @email=@email,
        @specijalnost=@specijalnost, @sertifikat=@sertifikat,
        @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiInstruktora]
    @instruktorId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteInstruktor] @instruktorId=@instruktorId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajGrupu]
    @naziv          NVARCHAR(80),
    @kursId         INT,
    @koreografId    INT,
    @predavacId     INT,
    @newId          INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertGrupa]
        @naziv=@naziv, @kursId=@kursId,
        @koreografId=@koreografId, @predavacId=@predavacId,
        @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniGrupu]
    @grupaId        INT,
    @naziv          NVARCHAR(80),
    @kursId         INT,
    @koreografId    INT,
    @predavacId     INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateGrupa]
        @grupaId=@grupaId, @naziv=@naziv, @kursId=@kursId,
        @koreografId=@koreografId, @predavacId=@predavacId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiGrupu]
    @grupaId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteGrupa] @grupaId=@grupaId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajNastup]
    @naziv          NVARCHAR(100),
    @datum          DATE,
    @lokacija       NVARCHAR(100),
    @grupaId        INT,
    @instruktorId   INT,
    @newId          INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertNastup]
        @naziv=@naziv, @datum=@datum, @lokacija=@lokacija,
        @grupaId=@grupaId, @instruktorId=@instruktorId,
        @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniNastup]
    @nastupId       INT,
    @naziv          NVARCHAR(100),
    @datum          DATE,
    @lokacija       NVARCHAR(100),
    @grupaId        INT,
    @instruktorId   INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateNastup]
        @nastupId=@nastupId, @naziv=@naziv, @datum=@datum,
        @lokacija=@lokacija, @grupaId=@grupaId,
        @instruktorId=@instruktorId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiNastup]
    @nastupId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteNastup] @nastupId=@nastupId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajKostim]
    @naziv      NVARCHAR(80),
    @velicina   NVARCHAR(5),
    @boja       NVARCHAR(30),
    @newId      INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertKostim]
        @naziv=@naziv, @velicina=@velicina,
        @boja=@boja, @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniKostim]
    @kostimId   INT,
    @naziv      NVARCHAR(80),
    @velicina   NVARCHAR(5),
    @boja       NVARCHAR(30)
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateKostim]
        @kostimId=@kostimId, @naziv=@naziv,
        @velicina=@velicina, @boja=@boja;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiKostim]
    @kostimId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteKostim] @kostimId=@kostimId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajKurs]
    @naziv          NVARCHAR(80),
    @opis           NVARCHAR(300) = NULL,
    @trajanjeMeseci INT,
    @pretKursId     INT = NULL,
    @newId          INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertKurs]
        @naziv=@naziv, @opis=@opis,
        @trajanjeMeseci=@trajanjeMeseci,
        @pretKursId=@pretKursId, @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniKurs]
    @kursId         INT,
    @naziv          NVARCHAR(80),
    @opis           NVARCHAR(300) = NULL,
    @trajanjeMeseci INT,
    @pretKursId     INT = NULL
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateKurs]
        @kursId=@kursId, @naziv=@naziv, @opis=@opis,
        @trajanjeMeseci=@trajanjeMeseci, @pretKursId=@pretKursId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiKurs]
    @kursId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteKurs] @kursId=@kursId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajZaduzenje]
    @ucenikId       INT,
    @nastupId       INT,
    @kostimId       INT,
    @datumZaduzenja DATE = NULL
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertZaduzenje]
        @ucenikId=@ucenikId, @nastupId=@nastupId,
        @kostimId=@kostimId, @datumZaduzenja=@datumZaduzenja;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniZaduzenje]
    @ucenikId       INT,
    @nastupId       INT,
    @noviKostimId   INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_UpdateZaduzenje]
        @ucenikId=@ucenikId, @nastupId=@nastupId,
        @noviKostimId=@noviKostimId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[ObrisiZaduzenje]
    @ucenikId   INT,
    @nastupId   INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_DeleteZaduzenje]
        @ucenikId=@ucenikId, @nastupId=@nastupId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[LoginKorisnik]
    @email          NVARCHAR(100),
    @uloga          NVARCHAR(20)    OUTPUT,
    @lozinkaHash    NVARCHAR(256)   OUTPUT,
    @instruktorId   INT             OUTPUT,
    @ime            NVARCHAR(50)    OUTPUT,
    @prezime        NVARCHAR(50)    OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_LoginKorisnik]
        @email=@email, @uloga=@uloga OUTPUT,
        @lozinkaHash=@lozinkaHash OUTPUT,
        @instruktorId=@instruktorId OUTPUT,
        @ime=@ime OUTPUT, @prezime=@prezime OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[DodajKorisnika]
    @email          NVARCHAR(100),
    @lozinkaHash    NVARCHAR(256),
    @uloga          NVARCHAR(20),
    @instruktorId   INT = NULL,
    @newId          INT OUTPUT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_InsertKorisnik]
        @email=@email, @lozinkaHash=@lozinkaHash,
        @uloga=@uloga, @instruktorId=@instruktorId,
        @NewId=@newId OUTPUT;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[IzmeniKorisnika]
    @trenutniEmail  NVARCHAR(200),
    @ime            NVARCHAR(100) = NULL,
    @prezime        NVARCHAR(100) = NULL,
    @noviEmail      NVARCHAR(200) = NULL,
    @noviHash       NVARCHAR(256) = NULL
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    EXEC [spec].[upr_IzmeniKorisnika]
        @trenutniEmail=@trenutniEmail, @ime=@ime,
        @prezime=@prezime, @noviEmail=@noviEmail,
        @noviHash=@noviHash;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[GetUceniciPoInstruktoru]
    @instruktorId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_GetUceniciPoInstruktoru]
        @instruktorId=@instruktorId;
END;
GO

CREATE OR ALTER PROCEDURE [api_studio].[GetZaduzenjaPoInstruktoru]
    @instruktorId INT
WITH EXECUTE AS 'Marija', ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [spec].[upr_GetZaduzenjaPoInstruktoru]
        @instruktorId=@instruktorId;
END;
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  api_studio procedure su kreirane.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 14. GRANT prava
-- =====================================================
GRANT EXECUTE ON SCHEMA::[api_studio] TO [DataProviderStudio];
GRANT SELECT  ON SCHEMA::[api_studio] TO [DataProviderStudio];
GO

PRINT N'-------------------------------------------------------------';
PRINT N'  GRANT prava su dodata.';
PRINT N'-------------------------------------------------------------';
GO

-- =====================================================
-- 15. Demo podaci
-- =====================================================

-- Instruktori
DECLARE @ana INT, @milos INT;

EXEC spec.upr_InsertInstruktor
    @ime          = N'Ана',
    @prezime      = N'Марковић',
    @email        = N'ana.markovic@plesni.rs',
    @specijalnost = N'Балет',
    @sertifikat   = N'Државни испит за балет 2022',
    @NewId        = @ana OUTPUT;

EXEC spec.upr_InsertInstruktor
    @ime          = N'Милош',
    @prezime      = N'Петровић',
    @email        = N'milos.petrovic@plesni.rs',
    @specijalnost = N'Латински плесови',
    @sertifikat   = N'ISTD Latin Gold 2021',
    @NewId        = @milos OUTPUT;

-- Korisnici za instruktore
DECLARE @kid1 INT, @kid2 INT;
EXEC spec.upr_InsertKorisnik
    @email        = N'ana.markovic@plesni.rs',
    @lozinkaHash  = N'$2a$11$YdS0VjGIDuMAy.aoieKxmu9m68tQp.dxGVdpDgY147./J7rDIX3m2',
    @uloga        = N'Instruktor',
    @instruktorId = @ana,
    @NewId        = @kid1 OUTPUT;

EXEC spec.upr_InsertKorisnik
    @email        = N'milos.petrovic@plesni.rs',
    @lozinkaHash  = N'$2a$11$VaS.JQNrvkmBUn8Lw.phnehrNy7y5ni6tCMuqlBsjDwHNS754IZ.6',
    @uloga        = N'Instruktor',
    @instruktorId = @milos,
    @NewId        = @kid2 OUTPUT;

-- Admin korisnik
INSERT INTO [impl].[tblKorisnik] (Email, LozinkaHash, Uloga, InstruktorId)
VALUES (
    N'plesni.studio@gmail.com',
    N'$2a$11$JyVa5f5agvOXcTm8vqoDb.JZSnZXbxhbNmAx5bamW.u6qQuRZWU/2',
    N'Admin',
    NULL
);
GO

-- Kursevi
DECLARE @kBalet INT, @kBaletNap INT, @kLatino INT, @kLatinoNap INT;

EXEC spec.upr_InsertKurs
    @naziv          = N'Балет почетни',
    @opis           = N'Уводни курс класичног балета – основни кораци и позиције.',
    @trajanjeMeseci = 6,
    @pretKursId     = NULL,
    @NewId          = @kBalet OUTPUT;

EXEC spec.upr_InsertKurs
    @naziv          = N'Балет напредни',
    @opis           = N'Напредна техника балета – pointé, grand jeté.',
    @trajanjeMeseci = 12,
    @pretKursId     = @kBalet,
    @NewId          = @kBaletNap OUTPUT;

EXEC spec.upr_InsertKurs
    @naziv          = N'Латино почетни',
    @opis           = N'Уводни курс латино плесова – самба, ча-ча.',
    @trajanjeMeseci = 6,
    @pretKursId     = NULL,
    @NewId          = @kLatino OUTPUT;

EXEC spec.upr_InsertKurs
    @naziv          = N'Латино напредни',
    @opis           = N'Напредна латино техника – румба, пасодобле.',
    @trajanjeMeseci = 12,
    @pretKursId     = @kLatino,
    @NewId          = @kLatinoNap OUTPUT;
GO

-- Grupe
DECLARE @gBalet INT, @gLatino INT;
DECLARE @anaId INT = (SELECT OsobaId FROM impl.tblInstruktor
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblInstruktor.OsobaId
    WHERE tblOsoba.Email = N'ana.markovic@plesni.rs');
DECLARE @milosId INT = (SELECT OsobaId FROM impl.tblInstruktor
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblInstruktor.OsobaId
    WHERE tblOsoba.Email = N'milos.petrovic@plesni.rs');
DECLARE @kBaletId INT = (SELECT Id FROM impl.tblKurs WHERE Naziv = N'Балет почетни');
DECLARE @kLatinoId INT = (SELECT Id FROM impl.tblKurs WHERE Naziv = N'Латино почетни');

EXEC spec.upr_InsertGrupa
    @naziv       = N'Балет група А',
    @kursId      = @kBaletId,
    @koreografId = @anaId,
    @predavacId  = @anaId,
    @NewId       = @gBalet OUTPUT;

EXEC spec.upr_InsertGrupa
    @naziv       = N'Латино група Б',
    @kursId      = @kLatinoId,
    @koreografId = @milosId,
    @predavacId  = @milosId,
    @NewId       = @gLatino OUTPUT;
GO

-- Kostimi
DECLARE @k1 INT, @k2 INT, @k3 INT, @k4 INT;
EXEC spec.upr_InsertKostim @naziv=N'Балерина хаљина', @velicina=N'S', @boja=N'Бела',   @NewId=@k1 OUTPUT;
EXEC spec.upr_InsertKostim @naziv=N'Балерина хаљина', @velicina=N'M', @boja=N'Бела',   @NewId=@k2 OUTPUT;
EXEC spec.upr_InsertKostim @naziv=N'Латино фустан',   @velicina=N'S', @boja=N'Црвена', @NewId=@k3 OUTPUT;
EXEC spec.upr_InsertKostim @naziv=N'Латино фустан',   @velicina=N'M', @boja=N'Црна',   @NewId=@k4 OUTPUT;
GO

-- Ucenici — Balet grupa A
DECLARE @gBaletId INT = (SELECT Id FROM impl.tblGrupa WHERE Naziv = N'Балет група А');
DECLARE @gLatinoId INT = (SELECT Id FROM impl.tblGrupa WHERE Naziv = N'Латино група Б');
DECLARE @u1 INT, @u2 INT, @u3 INT, @u4 INT, @u5 INT, @u6 INT;

EXEC spec.upr_InsertUcenik
    @ime=N'Јована', @prezime=N'Нешић',
    @email=N'jovana.nesic@gmail.com',
    @datumUpisa='2026-01-10', @nivo=N'Почетни',
    @grupaId=@gBaletId, @NewId=@u1 OUTPUT;

EXEC spec.upr_InsertUcenik
    @ime=N'Катарина', @prezime=N'Ђорђевић',
    @email=N'katarina.djordjevic@gmail.com',
    @datumUpisa='2026-01-20', @nivo=N'Почетни',
    @grupaId=@gBaletId, @NewId=@u2 OUTPUT;

EXEC spec.upr_InsertUcenik
    @ime=N'Тамара', @prezime=N'Илић',
    @email=N'tamara.ilic@gmail.com',
    @datumUpisa='2026-02-05', @nivo=N'Средњи',
    @grupaId=@gBaletId, @NewId=@u3 OUTPUT;

-- Ucenici — Latino grupa B
EXEC spec.upr_InsertUcenik
    @ime=N'Милица', @prezime=N'Стојановић',
    @email=N'milica.stojanovic@gmail.com',
    @datumUpisa='2026-01-15', @nivo=N'Почетни',
    @grupaId=@gLatinoId, @NewId=@u4 OUTPUT;

EXEC spec.upr_InsertUcenik
    @ime=N'Сара', @prezime=N'Лазић',
    @email=N'sara.lazic@gmail.com',
    @datumUpisa='2026-02-10', @nivo=N'Почетни',
    @grupaId=@gLatinoId, @NewId=@u5 OUTPUT;

EXEC spec.upr_InsertUcenik
    @ime=N'Ана', @prezime=N'Вуковић',
    @email=N'ana.vukovic@gmail.com',
    @datumUpisa='2026-03-01', @nivo=N'Средњи',
    @grupaId=@gLatinoId, @NewId=@u6 OUTPUT;
GO

-- Nastupi
DECLARE @anaId2 INT = (SELECT OsobaId FROM impl.tblInstruktor
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblInstruktor.OsobaId
    WHERE tblOsoba.Email = N'ana.markovic@plesni.rs');
DECLARE @milosId2 INT = (SELECT OsobaId FROM impl.tblInstruktor
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblInstruktor.OsobaId
    WHERE tblOsoba.Email = N'milos.petrovic@plesni.rs');
DECLARE @gBaletId2 INT = (SELECT Id FROM impl.tblGrupa WHERE Naziv = N'Балет група А');
DECLARE @gLatinoId2 INT = (SELECT Id FROM impl.tblGrupa WHERE Naziv = N'Латино група Б');
DECLARE @n1 INT, @n2 INT;

EXEC spec.upr_InsertNastup
    @naziv=N'Пролећни концерт 2026',
    @datum='2026-05-15',
    @lokacija=N'Дом омладине Београд',
    @grupaId=@gBaletId2,
    @instruktorId=@anaId2,
    @NewId=@n1 OUTPUT;

EXEC spec.upr_InsertNastup
    @naziv=N'Летња смотра 2026',
    @datum='2026-06-20',
    @lokacija=N'Културни центар Нови Сад',
    @grupaId=@gLatinoId2,
    @instruktorId=@milosId2,
    @NewId=@n2 OUTPUT;
GO

-- Zaduzenja
DECLARE @n1Id INT = (SELECT Id FROM impl.tblNastup WHERE Naziv = N'Пролећни концерт 2026');
DECLARE @n2Id INT = (SELECT Id FROM impl.tblNastup WHERE Naziv = N'Летња смотра 2026');
DECLARE @k1Id INT = (SELECT Id FROM impl.tblKostim WHERE Naziv = N'Балерина хаљина' AND Velicina = N'S');
DECLARE @k2Id INT = (SELECT Id FROM impl.tblKostim WHERE Naziv = N'Балерина хаљина' AND Velicina = N'M');
DECLARE @k3Id INT = (SELECT Id FROM impl.tblKostim WHERE Naziv = N'Латино фустан' AND Velicina = N'S');
DECLARE @k4Id INT = (SELECT Id FROM impl.tblKostim WHERE Naziv = N'Латино фустан' AND Velicina = N'M');
DECLARE @u1Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'jovana.nesic@gmail.com');
DECLARE @u2Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'katarina.djordjevic@gmail.com');
DECLARE @u3Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'tamara.ilic@gmail.com');
DECLARE @u4Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'milica.stojanovic@gmail.com');
DECLARE @u5Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'sara.lazic@gmail.com');
DECLARE @u6Id INT = (SELECT OsobaId FROM impl.tblUcenik
    INNER JOIN impl.tblOsoba ON tblOsoba.Id = tblUcenik.OsobaId
    WHERE tblOsoba.Email = N'ana.vukovic@gmail.com');

-- Balet grupa A - Prolecni koncert
EXEC spec.upr_InsertZaduzenje @ucenikId=@u1Id, @nastupId=@n1Id, @kostimId=@k1Id, @datumZaduzenja='2026-03-18';
EXEC spec.upr_InsertZaduzenje @ucenikId=@u2Id, @nastupId=@n1Id, @kostimId=@k2Id, @datumZaduzenja='2026-03-18';
EXEC spec.upr_InsertZaduzenje @ucenikId=@u3Id, @nastupId=@n1Id, @kostimId=@k1Id, @datumZaduzenja='2026-03-18';

-- Latino grupa B - Letnja smotra
EXEC spec.upr_InsertZaduzenje @ucenikId=@u4Id, @nastupId=@n2Id, @kostimId=@k3Id, @datumZaduzenja='2026-03-18';
EXEC spec.upr_InsertZaduzenje @ucenikId=@u5Id, @nastupId=@n2Id, @kostimId=@k4Id, @datumZaduzenja='2026-03-18';
EXEC spec.upr_InsertZaduzenje @ucenikId=@u6Id, @nastupId=@n2Id, @kostimId=@k3Id, @datumZaduzenja='2026-03-18';
GO

PRINT N'';
PRINT N'=============================================================';
PRINT N'  PlesniStudio_KOMPLETNA_SKRIPTA.sql uspesno izvrsena!';
PRINT N'';
PRINT N'  Nalozi:';
PRINT N'  Admin:   plesni.studio@gmail.com / Admin@2026!';
PRINT N'  Ana:     ana.markovic@plesni.rs  / Instruktor@2026!';
PRINT N'  Milos:   milos.petrovic@plesni.rs / Instruktor@2026!';
PRINT N'=============================================================';
GO
