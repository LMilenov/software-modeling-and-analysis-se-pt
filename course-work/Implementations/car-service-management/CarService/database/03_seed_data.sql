-- Car Service Management Platform
-- File: 03_seed_data.sql

BEGIN;

INSERT INTO Customer (FirstName, LastName, Phone, Email) VALUES
('Ivan', 'Petrov', '+359888111001', 'ivan.petrov@example.com'),
('Maria', 'Georgieva', '+359888111002', 'maria.georgieva@example.com'),
('Georgi', 'Dimitrov', '+359888111003', 'georgi.dimitrov@example.com'),
('Elena', 'Ivanova', '+359888111004', 'elena.ivanova@example.com'),
('Nikolay', 'Stoyanov', '+359888111005', 'nikolay.stoyanov@example.com'),
('Petar', 'Nikolov', '+359888111006', 'petar.nikolov@example.com'),
('Desislava', 'Todorova', '+359888111007', 'desislava.todorova@example.com'),
('Dimitar', 'Kolev', '+359888111008', 'dimitar.kolev@example.com');

INSERT INTO Brand (BrandName) VALUES
('BMW'), ('Mercedes-Benz'), ('Audi'), ('Volkswagen'),
('Toyota'), ('Ford'), ('Opel'), ('Alfa Romeo');

INSERT INTO VehicleModel
(BrandID, ModelName, ProductionYearFrom, ProductionYearTo) VALUES
(1, '3 Series', 1975, NULL),
(2, 'C-Class', 1993, NULL),
(3, 'A4', 1994, NULL),
(4, 'Golf', 1974, NULL),
(5, 'Corolla', 1966, NULL),
(6, 'Focus', 1998, NULL),
(7, 'Astra', 1991, NULL),
(8, '159', 2005, 2011);

INSERT INTO Mechanic
(FirstName, LastName, Phone, Email, HireDate, HourlyRate) VALUES
('Stefan', 'Ivanov', '+359889200001', 'stefan.ivanov@carservice.example', '2022-03-01', 25.00),
('Martin', 'Petrov', '+359889200002', 'martin.petrov@carservice.example', '2023-06-15', 22.00),
('Kalin', 'Georgiev', '+359889200003', 'kalin.georgiev@carservice.example', '2021-09-10', 28.00);

INSERT INTO Service
(ServiceName, Description, StandardPrice, EstimatedDurationMinutes) VALUES
('Computer Diagnostics', 'Electronic fault diagnosis', 30.00, 45),
('Oil Change', 'Engine oil and oil filter replacement', 25.00, 60),
('Brake Service', 'Brake system inspection and servicing', 60.00, 120),
('Suspension Repair', 'Suspension inspection and repair', 80.00, 180),
('Air Conditioning Service', 'Air conditioning inspection', 45.00, 90),
('Timing Belt Replacement', 'Timing belt kit replacement', 150.00, 240),
('Battery Replacement', 'Battery testing and replacement', 20.00, 30),
('Wheel Alignment', 'Wheel alignment adjustment', 35.00, 45);

INSERT INTO Supplier (SupplierName, Phone, Email, City) VALUES
('Auto Parts Sofia', '+359887300001', 'sales@autoparts-sofia.example', 'Sofia'),
('Motor Supply BG', '+359887300002', 'office@motorsupply.example', 'Plovdiv'),
('Premium Auto Parts', '+359887300003', 'orders@premium-parts.example', 'Pazardzhik');

INSERT INTO PaymentMethod (MethodName) VALUES
('Cash'), ('Card'), ('Bank Transfer');

INSERT INTO Vehicle
(CustomerID, ModelID, RegistrationNumber, VIN, ProductionYear, Mileage, FuelType) VALUES
(1, 8, 'PA1234AB', 'ZAR93900007123451', 2008, 215000, 'Diesel'),
(2, 1, 'CB5678CD', 'WBA8E910X0K123451', 2018, 98000, 'Petrol'),
(3, 4, 'PB2345EF', 'WVWZZZAUZGW123451', 2016, 145000, 'Diesel'),
(4, 3, 'CA6789GH', 'WAUZZZ8K0GA123451', 2015, 132000, 'Diesel'),
(5, 5, 'A1234JK', 'JTDBR32E720123451', 2020, 65000, 'Hybrid'),
(6, 2, 'PB3456LM', 'WDD2050421R123451', 2017, 110000, 'Diesel'),
(7, 6, 'PA4567NO', 'WF0AXXWPDAK123451', 2019, 87000, 'Petrol'),
(8, 7, 'CB7890PQ', 'W0L0AHL08A8123451', 2014, 156000, 'Diesel');

INSERT INTO Part
(SupplierID, PartName, PartNumber, UnitPrice, StockQuantity, MinimumStock) VALUES
(1, 'Engine Oil 5W-30 (1L)', 'OIL-5W30-1L', 9.50, 100, 20),
(1, 'Oil Filter', 'FLT-OIL-001', 8.00, 35, 10),
(2, 'Front Brake Pads', 'BRK-FR-001', 42.00, 18, 5),
(2, 'Brake Discs (Pair)', 'BRK-DS-002', 95.00, 12, 4),
(3, 'Timing Belt Kit', 'TBK-001', 125.00, 8, 2),
(1, 'Car Battery 70Ah', 'BAT-70AH', 110.00, 10, 3),
(3, 'Air Filter', 'FLT-AIR-001', 14.00, 24, 6),
(2, 'Suspension Arm', 'SUS-ARM-001', 75.00, 9, 2);

COMMIT;