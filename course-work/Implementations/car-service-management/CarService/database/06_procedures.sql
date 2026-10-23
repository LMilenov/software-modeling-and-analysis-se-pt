-- Car Service Management Platform
-- File: 06_procedures.sql

CREATE OR REPLACE PROCEDURE create_appointment(
    p_vehicle_id INTEGER,
    p_mechanic_id INTEGER,
    p_appointment_date TIMESTAMP,
    p_customer_notes TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Vehicle WHERE VehicleID = p_vehicle_id
    ) THEN
        RAISE EXCEPTION 'Vehicle % does not exist', p_vehicle_id;
    END IF;

    IF p_mechanic_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Mechanic
        WHERE MechanicID = p_mechanic_id AND IsActive = TRUE
    ) THEN
        RAISE EXCEPTION 'Mechanic % does not exist or is inactive', p_mechanic_id;
    END IF;

    INSERT INTO Appointment (
        VehicleID, MechanicID, AppointmentDate, Status, CustomerNotes
    )
    VALUES (
        p_vehicle_id, p_mechanic_id, p_appointment_date, 'Scheduled', p_customer_notes
    );
END;
$$;

CREATE OR REPLACE PROCEDURE register_payment(
    p_invoice_id INTEGER,
    p_payment_method_id INTEGER,
    p_amount NUMERIC(10,2),
    p_transaction_reference VARCHAR(100) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_invoice_status VARCHAR(20);
    v_invoice_total NUMERIC(12,2);
    v_paid_total NUMERIC(12,2);
BEGIN
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Payment amount must be greater than zero';
    END IF;

    SELECT Status
    INTO v_invoice_status
    FROM Invoice
    WHERE InvoiceID = p_invoice_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invoice % does not exist', p_invoice_id;
    END IF;

    IF v_invoice_status = 'Cancelled' THEN
        RAISE EXCEPTION 'Cannot pay a cancelled invoice';
    END IF;

    SELECT calculate_repair_total(RepairID)
    INTO v_invoice_total
    FROM Invoice
    WHERE InvoiceID = p_invoice_id;

    SELECT COALESCE(SUM(Amount), 0)
    INTO v_paid_total
    FROM Payment
    WHERE InvoiceID = p_invoice_id;

    IF v_paid_total + p_amount > v_invoice_total THEN
        RAISE EXCEPTION 'Payment exceeds the outstanding invoice balance';
    END IF;

    INSERT INTO Payment (
        InvoiceID, PaymentMethodID, Amount, TransactionReference
    )
    VALUES (
        p_invoice_id, p_payment_method_id, p_amount, p_transaction_reference
    );
END;
$$;