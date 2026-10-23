-- Car Service Management Platform
-- File: 02_create_relationships.sql

CREATE TABLE Vehicle (
    VehicleID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CustomerID INTEGER NOT NULL REFERENCES Customer(CustomerID),
    ModelID INTEGER NOT NULL REFERENCES VehicleModel(ModelID),
    RegistrationNumber VARCHAR(15) NOT NULL UNIQUE,
    VIN VARCHAR(17) UNIQUE,
    ProductionYear INTEGER CHECK (ProductionYear BETWEEN 1886 AND 2100),
    Mileage INTEGER NOT NULL DEFAULT 0 CHECK (Mileage >= 0),
    FuelType VARCHAR(20),
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Appointment (
    AppointmentID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    VehicleID INTEGER NOT NULL REFERENCES Vehicle(VehicleID),
    MechanicID INTEGER REFERENCES Mechanic(MechanicID),
    AppointmentDate TIMESTAMP NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
        CHECK (Status IN ('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'NoShow')),
    CustomerNotes TEXT,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Repair (
    RepairID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AppointmentID INTEGER UNIQUE REFERENCES Appointment(AppointmentID),
    VehicleID INTEGER NOT NULL REFERENCES Vehicle(VehicleID),
    MechanicID INTEGER NOT NULL REFERENCES Mechanic(MechanicID),
    StartDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    EndDate TIMESTAMP,
    LaborHours NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (LaborHours >= 0),
    Status VARCHAR(20) NOT NULL DEFAULT 'InProgress'
        CHECK (Status IN ('InProgress', 'Completed', 'Cancelled')),
    Notes TEXT,
    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

CREATE TABLE Part (
    PartID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SupplierID INTEGER REFERENCES Supplier(SupplierID),
    PartName VARCHAR(100) NOT NULL,
    PartNumber VARCHAR(50) UNIQUE,
    UnitPrice NUMERIC(10,2) NOT NULL CHECK (UnitPrice >= 0),
    StockQuantity INTEGER NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    MinimumStock INTEGER NOT NULL DEFAULT 5 CHECK (MinimumStock >= 0)
);

CREATE TABLE RepairPart (
    RepairID INTEGER NOT NULL REFERENCES Repair(RepairID),
    PartID INTEGER NOT NULL REFERENCES Part(PartID),
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    UnitPrice NUMERIC(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (RepairID, PartID)
);

CREATE TABLE RepairService (
    RepairID INTEGER NOT NULL REFERENCES Repair(RepairID),
    ServiceID INTEGER NOT NULL REFERENCES Service(ServiceID),
    Quantity INTEGER NOT NULL DEFAULT 1 CHECK (Quantity > 0),
    UnitPrice NUMERIC(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (RepairID, ServiceID)
);

CREATE TABLE Invoice (
    InvoiceID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RepairID INTEGER NOT NULL UNIQUE REFERENCES Repair(RepairID),
    InvoiceNumber VARCHAR(30) NOT NULL UNIQUE,
    IssueDate DATE NOT NULL DEFAULT CURRENT_DATE,
    DueDate DATE,
    Status VARCHAR(20) NOT NULL DEFAULT 'Unpaid'
        CHECK (Status IN ('Unpaid', 'PartiallyPaid', 'Paid', 'Cancelled')),
    Notes TEXT,
    CHECK (DueDate IS NULL OR DueDate >= IssueDate)
);

CREATE TABLE Payment (
    PaymentID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InvoiceID INTEGER NOT NULL REFERENCES Invoice(InvoiceID),
    PaymentMethodID INTEGER NOT NULL REFERENCES PaymentMethod(PaymentMethodID),
    PaymentDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Amount NUMERIC(10,2) NOT NULL CHECK (Amount > 0),
    TransactionReference VARCHAR(100)
);