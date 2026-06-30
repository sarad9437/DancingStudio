# PlesniStudio — Dance Studio Management System

> **Academic Project** · University of Belgrade, Faculty of Organizational Sciences  
> Course: *Data Repository Programming* · Academic Year 2025/2026

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Database Schema](#database-schema)
- [Data Model](#data-model)
- [Application Stack](#application-stack)
- [Security Model](#security-model)
- [Functional Modules](#functional-modules)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [References](#references)

---

## Overview

**PlesniStudio** is a full-stack information system for managing a dance studio. It handles student records, instructor management, dance groups, performances, costume assignments, and course prerequisites — all built on a layered database architecture with a React + ASP.NET Core frontend/backend and a Microsoft SQL Server data repository.

The system supports two user roles:

| Role | Access Level |
|------|-------------|
| **Admin** | Full access: students, instructors, groups, performances, costumes, courses, assignments |
| **Instruktor** | Restricted: own students, groups, and upcoming performances |

---

## System Architecture

The database is organized as an **Abstract Data Type (ADT)** using a three-layer schema architecture. Each layer communicates strictly in one direction (`impl → spec → api_studio`), ensuring encapsulation, security, and layer independence.

```
PlesniStudio (SQL Server Database)
│
├── api_studio        ← Public DB API for the React application
│   ├── Views:        UCENIK, GRUPA, NASTUP, INSTRUKTOR, KOSTIM, KURS, ZADUZENJE,
│   │                 KORISNIK, UCENIK_GRUPA
│   ├── Procedures:   DodajUcenika, IzmeniUcenicu, ObrisiUcenika, DodajInstruktora, ...
│   └── Functions:    GetUceniciPoInstruktoru, GetZaduzenjaPoInstruktoru
│
├── spec              ← Public ADT specification (WITH ENCRYPTION)
│   ├── Views:        vw_UCENIK, vw_GRUPA, vw_NASTUP, vw_INSTRUKTOR, vw_KOSTIM, ...
│   ├── Procedures:   upr_InsertUcenik, upr_UpdateUcenik, upr_DeleteUcenik, ...
│   └── Functions:    fnt_UceniciPoInstruktoru, fnt_ZaduzenjaPoInstruktoru,
│                     fns_BrojNastupaUcenika
│
└── impl              ← Private implementation (tables, triggers, indexes)
    ├── Tables:       tblOsoba, tblUcenik, tblInstruktor, tblKorisnik, tblKurs,
    │                 tblGrupa, tblNastup, tblKostim, tblZaduzenje, tblUcenikGrupa
    ├── Log Tables:   tblOsobaLog, tblUcenikLog, tblInstruktorLog, ... tblErrorLog
    ├── Triggers:     trg_tblOsoba_Log, trg_tblUcenikGrupa_UkupnoUcenika, ...
    └── Indexes:      idxGrupa_KursId, idxZaduzenje_UcenikId, ...
```

### Schema Ownership

| Schema | Role | Owner | Permissions |
|--------|------|-------|-------------|
| `impl` | Private implementation (tables, triggers, views, indexes) | Marija (DbDeveloper) | CONTROL on `impl` and `spec` |
| `spec` | Public ADT specification (stored procedures, functions, views) | Marija (DbDeveloper) | Accessed via `api_studio` |
| `api_studio` | Public DB API for the React app (PascalCase procedures, UPPER_CASE views) | Sara (DbApiDeveloper) | CONTROL on `api_studio` |
| `DataProviderStudio` | Application role — principle of least privilege | N/A | EXECUTE on `api_studio` only |

---

## Database Schema

### Application Tables (`impl`)

| Table | Type | Description | Key Attributes |
|-------|------|-------------|----------------|
| `tblOsoba` | Application | Persons (supertype) | `Id` (PK, IDENTITY), `Ime`, `Prezime`, `Email` (UNIQUE) |
| `tblUcenik` | Application | Students (subtype) | `OsobaId` (PK, FK), `BrojKnjizice` (UNIQUE), `DatumUpisa`, `Nivo` |
| `tblInstruktor` | Application | Instructors (subtype) | `OsobaId` (PK, FK), `Specijalnost`, `Sertifikat` (nullable) |
| `tblKorisnik` | Application | User accounts | `Id` (PK), `Email` (UNIQUE), `LozinkaHash`, `Uloga`, `InstruktorId` (FK, nullable) |
| `tblKurs` | Application | Dance courses | `Id` (PK), `Naziv` (UNIQUE), `Opis`, `TrajanjeMeseci` [1–36], `PretKursId` (self-ref FK) |
| `tblGrupa` | Application | Dance groups | `Id` (PK), `Naziv` (UNIQUE), `KursId` (FK), `KoreografId` (FK), `PredavacId` (FK), `UkupnoUcenika` |
| `tblNastup` | Application | Performances | `Id` (PK), `Naziv`, `Datum`, `Lokacija`, `GrupaId` (FK), `InstruktorId` (FK) |
| `tblKostim` | Application | Costumes | `Id` (PK), `Naziv`, `Velicina` (XS/S/M/L/XL), `Boja` |
| `tblZaduzenje` | Application | Costume assignments | `UcenikId` (PK, FK), `NastupId` (PK, FK), `KostimId` (FK), `DatumZaduzenja` |
| `tblUcenikGrupa` | Associative | Student–Group membership (N:M) | `UcenikId` (PK, FK), `GrupaId` (PK, FK) |

### Log Tables (`impl`)

Every key entity has a dedicated log table tracking all INSERT, UPDATE, and DELETE operations:

`tblOsobaLog`, `tblUcenikLog`, `tblInstruktorLog`, `tblKursLog`, `tblGrupaLog`, `tblNastupLog`, `tblKostimLog`, `tblZaduzenjeLog`, `tblKorisnikLog`, `tblUcenikGrupaLog`, `tblErrorLog`

Each log table captures: `LogId`, `ActionType`, old/new field values, `ChangedAt`, `ChangedBy`.

### Triggers

| Trigger | Table | Purpose |
|---------|-------|---------|
| `trg_tblOsoba_Log` | `tblOsoba` | Log INSERT/UPDATE/DELETE on persons |
| `trg_tblUcenik_Log` | `tblUcenik` | Log INSERT/UPDATE/DELETE on students |
| `trg_tblInstruktor_Log` | `tblInstruktor` | Log INSERT/UPDATE/DELETE on instructors |
| `trg_tblKurs_Log` | `tblKurs` | Log INSERT/UPDATE/DELETE on courses |
| `trg_tblGrupa_Log` | `tblGrupa` | Log INSERT/UPDATE/DELETE on groups |
| `trg_tblNastup_Log` | `tblNastup` | Log INSERT/UPDATE/DELETE on performances |
| `trg_tblKostim_Log` | `tblKostim` | Log INSERT/UPDATE/DELETE on costumes |
| `trg_tblZaduzenje_Log` | `tblZaduzenje` | Log INSERT/UPDATE/DELETE on assignments |
| `trg_tblKorisnik_Log` | `tblKorisnik` | Log INSERT/UPDATE/DELETE on user accounts |
| `trg_tblUcenikGrupa_Log` | `tblUcenikGrupa` | Log INSERT/DELETE on group memberships |
| `trg_tblUcenikGrupa_UkupnoUcenika` | `tblUcenikGrupa` | **Auto-updates** `UkupnoUcenika` in `tblGrupa` |

### Non-Clustered Indexes on Foreign Keys

`idxGrupa_KursId`, `idxGrupa_KoreografId`, `idxGrupa_PredavacId`, `idxNastup_GrupaId`, `idxNastup_InstruktorId`, `idxZaduzenje_UcenikId`, `idxZaduzenje_NastupId`, `idxZaduzenje_KostimId`, `idxKorisnik_InstruktorId`, `idxUcenikGrupa_GrupaId`

---

## Data Model

### Key Domain Rules

- **Person hierarchy (supertype–subtype):** Both students and instructors share common person attributes (`Id`, `Ime`, `Prezime`, `Email`), realized via `tblOsoba`.
- **Cyrillic enforcement:** Names, specializations, locations, and other text fields must begin with a Serbian Cyrillic uppercase letter (`LIKE '[А-Ш]%'`). The database collation is `Serbian_Cyrillic_100_CS_AI`.
- **Course prerequisites (recursive):** A course may define another course as its prerequisite (`PretKursId` self-referencing FK). A course cannot be its own prerequisite.
- **Costume assignment (ternary relationship):** A student may only receive a costume assignment for a performance of a group they belong to. Duplicate assignments (same student + same performance) are rejected.
- **Computed values:**
  - `GRUPA.UkupnoUcenika` — automatically maintained by `trg_tblUcenikGrupa_UkupnoUcenika`
  - `UCENIK.BrojNastupa` — returned via scalar function `spec.fns_BrojNastupaUcenika`
- **Student level progression:** Level can only advance forward: `Почетни → Средњи → Напредни`. Downgrading is a business rule violation enforced via `spec.upr_UpdateNivoUcenika`.

### Value Domains

| Domain | Type | Constraint |
|--------|------|------------|
| `DSrpskaCirilica` | `NVARCHAR` | `LIKE '[А-Ш]%'` |
| `DEmail` | `NVARCHAR(100)` | `LIKE '%@%.%'` |
| `DNivo` | `NVARCHAR(20)` | `IN ('Почетни', 'Средњи', 'Напредни')` |
| `DVelicina` | `NVARCHAR(5)` | `IN ('XS', 'S', 'M', 'L', 'XL')` |
| `DUloga` | `NVARCHAR(20)` | `IN ('Admin', 'Instruktor')` |
| `DTrajanje` | `INT` | `BETWEEN 1 AND 36` |

---

## Application Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React + TypeScript |
| Backend | ASP.NET Core Web API |
| Database | Microsoft SQL Server |
| Auth | JWT (JSON Web Tokens) + BCrypt password hashing (`BCrypt.Net`) |
| DB Access | Application role `DataProviderStudio` via `api_studio` schema only |

### Authentication Flow

1. User submits email and password via `LoginPage`.
2. The app calls `api_studio.LoginKorisnik`, which returns a BCrypt password hash, role, first name, and last name.
3. The C# backend verifies the hash using `BCrypt.Net`.
4. On success, a JWT token is generated containing the user's role.
5. Logout removes the token from local memory.

---

## Security Model

All `spec` and `api_studio` objects are protected with `WITH ENCRYPTION` to prevent reverse-engineering of business logic. All `api_studio` procedures define an `EXECUTE AS` execution context.

The application role `DataProviderStudio` is granted **EXECUTE-only** rights on the `api_studio` schema — the principle of least privilege. No direct table access is ever granted to the application.

---

## Functional Modules

### Admin Modules

| Module | Procedures |
|--------|-----------|
| Authentication | `LoginKorisnik`, `DodajKorisnika`, `IzmeniKorisnika` |
| Students | `DodajUcenika`, `IzmeniUcenicu`, `IzmeniNivoUcenika`, `ObrisiUcenika`, `DodajUcenikuUGrupu`, `IzbaciUcenicuIzGrupe` |
| Instructors | `DodajInstruktora`, `IzmeniInstruktora`, `ObrisiInstruktora` |
| Groups | `DodajGrupu`, `IzmeniGrupu`, `ObrisiGrupu` |
| Performances | `DodajNastup`, `IzmeniNastup`, `ObrisiNastup` |
| Costumes | `DodajKostim`, `IzmeniKostim`, `ObrisiKostim` |
| Courses | `DodajKurs`, `IzmeniKurs`, `ObrisiKurs` |
| Assignments | `DodajZaduzenje`, `IzmeniZaduzenje`, `ObrisiZaduzenje` |

### Instructor View

An instructor has limited visibility — only their own students, groups, and upcoming performances. Profile email and password can be changed via `IzmeniKorisnika`.

---

## Testing

The documentation covers **16 functional test sets (ФЗ)** and **7 non-functional test sets (НЗ)**:

### Functional Tests

| Test Set | Description |
|----------|-------------|
| ФЗ-1 | Student registration — validation, Cyrillic enforcement, `UkupnoUcenika` auto-update |
| ФЗ-2 | Student update — field changes, level progression validation |
| ФЗ-3 | Instructor registration — auto user account creation/deletion, referential integrity |
| ФЗ-4 | User account management — BCrypt auth, login procedure |
| ФЗ-5 | Course management — prerequisite chains, circular dependency prevention |
| ФЗ-6 | Group management — UNIQUE name constraint, protected deletion |
| ФЗ-7 | Student–Group N:M membership — `UkupnoUcenika` consistency, minimum group rule |
| ФЗ-8 | Performance management — entry validation, deletion protection |
| ФЗ-9 | Costume management — size validation, protected deletion |
| ФЗ-10 | Costume assignment — group membership check, duplicate prevention |
| ФЗ-11 | `UkupnoUcenica` accuracy — computed vs. stored value consistency |
| ФЗ-12 | `fns_BrojNastupaUcenice` accuracy — function vs. direct COUNT comparison |
| ФЗ-13 | Student–Group view and instructor-scoped function |
| ФЗ-14 | Assignment view and instructor-scoped function |
| ФЗ-15 | Tabular functions — `fnt_UceniciPoInstruktoru`, `fnt_ZaduzenjaPoInstruktoru` |
| ФЗ-16 | Authentication — `LoginKorisnik` procedure, valid and invalid scenarios |

### Non-Functional Tests

| Test Set | Description |
|----------|-------------|
| НЗ-1 | Database collation verification (`Serbian_Cyrillic_100_CS_AI`) |
| НЗ-2 | `WITH ENCRYPTION` coverage across `spec` and `api_studio` |
| НЗ-3 | `EXECUTE AS` presence on all `api_studio` procedures |
| НЗ-4 | Count of tabular (`fnt_`) and scalar (`fns_`) functions |
| НЗ-5 | Layered architecture verification (procedures and views per schema) |
| НЗ-6 | AppRole `DataProviderStudio` existence and GRANT permissions |
| НЗ-7 | Trigger count, non-clustered index count, and log table functionality |

---

## Project Structure

```
PlesniStudio/
├── PlesniStudio_KOMPLETNA_SKRIPTA.sql   # Complete database script (tables, views,
│                                         # triggers, indexes, procedures, functions)
├── PlesniStudio_Dokumentacija.pdf        # Full project documentation (this document)
├── backend/                              # ASP.NET Core Web API
│   ├── Controllers/
│   ├── Models/
│   └── Services/
└── frontend/                             # React + TypeScript application
    ├── src/
    │   ├── pages/
    │   │   ├── LoginPage.tsx
    │   │   ├── DashboardPage.tsx
    │   │   ├── UceniciPage.tsx
    │   │   ├── InstruktoriPage.tsx
    │   │   ├── GrupePage.tsx
    │   │   ├── NastupiPage.tsx
    │   │   ├── ZaduzenjePage.tsx
    │   │   ├── KostimiPage.tsx
    │   │   └── KurseviPage.tsx
    │   └── components/
    └── public/
```

> **Note:** All data entry is performed exclusively through the strictly defined `api_studio` API layer, ensuring data integrity and system security at all times.

---

## References

1. Саша Д. Лазаревић, *Програмирање и подаци: Спецификација софтвера*, III свеска, ИИ ЛСИ, Београд: ФОН, 2025.
2. Dušan Petković, *SQL Server 2019: A Beginner's Guide*, 7th ed., New York: McGraw-Hill Education, 2020.
3. Саша Д. Лазаревић, *Алгебарска спецификација семантике апстрактних типова података*, ИИ ЛСИ, Београд: ФОН, 2015.
4. Paul Nielsen, *SQL Server Bible*, Indianapolis: Wiley Publishing, 2007.
5. С. Д. Лазаревић, „Релациони упитни језик", у *Софтверско инжењерство — практикум*, Уредници: В. Девеџић, С. Влајић, С. Д. Лазаревић, Београд: ФОН, 2017, pp. 276–347.
6. Бранислав Лазаревић и др., *Базе података*, Београд: Факултет организационих наука, 2017.

---

<p align="center">
  <sub>University of Belgrade · Faculty of Organizational Sciences · Department of Software Engineering · 2025/2026</sub>
</p>
