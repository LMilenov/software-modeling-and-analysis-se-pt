-- Car Service Management Platform
-- File: 04_seed_workshop.sql

BEGIN;

INSERT INTO Appointment
    (VehicleID, MechanicID, AppointmentDate, Status, CustomerNotes)
VALUES
    (1, 1, '2026-09-15 09:00', 'Completed', 'Engine diagnostics and oil leak inspection'),
    (2, 2, '2026-09-16 10:00', 'Completed', 'Regular maintenance'),
    (3, 1, '2026-09-18 11:00', 'Completed', 'Brake inspection'),
    (4, 3, '2026-09-20 09:30', 'Completed', 'Engine oil and filter change'),
    (5, 2, '2026-09-22 13:00', 'Completed', 'General inspection'),
    (6, 3, '2026-09-24 10:00', 'Completed', 'Suspension noise'),
    (7, 1, '2026-09-26 09:00', 'Completed', 'Computer diagnostics'),
    (8, 2, '2026-09-28 14:00', 'Completed', 'Timing belt inspection');

INSERT INTO Repair
    (AppointmentID, VehicleID, MechanicID, StartDate, EndDate, LaborHours, Status, Notes)
VALUES
    (1, 1, 1, '2026-09-15 09:00', '2026-09-15 10:30', 1.50, 'Completed', 'Diagnostics completed'),
    (2, 2, 2, '2026-09-16 10:00', '2026-09-16 11:00', 1.00, 'Completed', 'Scheduled maintenance'),
    (3, 3, 1, '2026-09-18 11:00', '2026-09-18 13:00', 2.00, 'Completed', 'Brake service completed'),
    (4, 4, 3, '2026-09-20 09:30', '2026-09-20 10:30', 1.00, 'Completed', 'Oil and filter replaced'),
    (5, 5, 2, '2026-09-22 13:00', '2026-09-22 14:00', 1.00, 'Completed', 'Inspection completed'),
    (6, 6, 3, '2026-09-24 10:00', '2026-09-24 12:00', 2.00, 'Completed', 'Suspension repaired'),
    (7, 7, 1, '2026-09-26 09:00', '2026-09-26 10:00', 1.00, 'Completed', 'Diagnostics completed'),
    (8, 8, 2, '2026-09-28 14:00', '2026-09-28 16:00', 2.00, 'Completed', 'Timing belt replaced');

INSERT INTO RepairService (RepairID, ServiceID, Quantity, UnitPrice)
VALUES
    (1, 1, 1, 30.00),
    (2, 2, 1, 25.00),
    (3, 3, 1, 60.00),
    (4, 2, 1, 25.00),
    (5, 1, 1, 30.00),
    (6, 4, 1, 80.00),
    (7, 1, 1, 30.00),
    (8, 6, 1, 150.00);

INSERT INTO RepairPart (RepairID, PartID, Quantity, UnitPrice)
VALUES
    (1, 2, 1, 8.00),
    (2, 1, 4, 9.50),
    (2, 2, 1, 8.00),
    (3, 3, 1, 42.00),
    (3, 4, 1, 95.00),
    (4, 1, 4, 9.50),
    (4, 2, 1, 8.00),
    (6, 8, 1, 75.00),
    (8, 5, 1, 125.00);

INSERT INTO Invoice (RepairID, InvoiceNumber, IssueDate, DueDate, Status)
VALUES
    (1, 'CS-2026-001', '2026-09-15', '2026-09-22', 'Paid'),
    (2, 'CS-2026-002', '2026-09-16', '2026-09-23', 'Paid'),
    (3, 'CS-2026-003', '2026-09-18', '2026-09-25', 'Paid'),
    (4, 'CS-2026-004', '2026-09-20', '2026-09-27', 'PartiallyPaid'),
    (5, 'CS-2026-005', '2026-09-22', '2026-09-29', 'Unpaid'),
    (6, 'CS-2026-006', '2026-09-24', '2026-10-01', 'Paid'),
    (7, 'CS-2026-007', '2026-09-26', '2026-10-03', 'Paid'),
    (8, 'CS-2026-008', '2026-09-28', '2026-10-05', 'Unpaid');

INSERT INTO Payment (InvoiceID, PaymentMethodID, PaymentDate, Amount, TransactionReference)
VALUES
    (1, 2, '2026-09-15 10:35', 38.00, 'TX-001'),
    (2, 1, '2026-09-16 11:05', 71.00, 'TX-002'),
    (3, 2, '2026-09-18 13:05', 197.00, 'TX-003'),
    (4, 3, '2026-09-20 10:35', 30.00, 'TX-004'),
    (6, 2, '2026-09-24 12:05', 155.00, 'TX-006'),
    (7, 1, '2026-09-26 10:05', 30.00, 'TX-007');

COMMIT;