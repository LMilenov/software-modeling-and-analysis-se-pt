-- Car Service Management Platform
-- Database: PostgreSQL
-- File: 01_create_tables.sql

CREATE TABLE Customer (
    CustomerID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Brand (
    BrandID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    BrandName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE VehicleModel (
    ModelID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    BrandID INTEGER NOT NULL REFERENCES Brand(BrandID),
    ModelName VARCHAR(50) NOT NULL,
    ProductionYearFrom INTEGER,
    ProductionYearTo INTEGER,
    CONSTRAINT chk_model_years CHECK (
        ProductionYearFrom IS NULL
        OR ProductionYearFrom BETWEEN 1886 AND 2100
    ),
    CONSTRAINT chk_model_years_order CHECK (
        ProductionYearTo IS NULL
        OR ProductionYearFrom IS NULL
        OR ProductionYearTo >= ProductionYearFrom
    ),
    UNIQUE (BrandID, ModelName)
);

CREATE TABLE Mechanic (
    MechanicID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    HireDate DATE NOT NULL DEFAULT CURRENT_DATE,
    HourlyRate NUMERIC(10,2) NOT NULL CHECK (HourlyRate >= 0),
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Service (
    ServiceID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    StandardPrice NUMERIC(10,2) NOT NULL CHECK (StandardPrice >= 0),
    EstimatedDurationMinutes INTEGER NOT NULL
        CHECK (EstimatedDurationMinutes > 0),
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Supplier (
    SupplierID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    City VARCHAR(80)
);

CREATE TABLE PaymentMethod (
    PaymentMethodID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    MethodName VARCHAR(30) NOT NULL UNIQUE
);