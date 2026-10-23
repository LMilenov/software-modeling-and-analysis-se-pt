-- Car Service Management Platform
-- File: 07_triggers.sql

CREATE OR REPLACE FUNCTION update_part_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Part
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE PartID = NEW.PartID
      AND StockQuantity >= NEW.Quantity;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Insufficient stock for part ID % or part does not exist',
            NEW.PartID;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_part_stock
BEFORE INSERT ON RepairPart
FOR EACH ROW
EXECUTE FUNCTION update_part_stock();


CREATE OR REPLACE FUNCTION update_invoice_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_invoice_total NUMERIC(12,2);
    v_paid_total NUMERIC(12,2);
BEGIN
    SELECT calculate_repair_total(i.RepairID)
    INTO v_invoice_total
    FROM Invoice i
    WHERE i.InvoiceID = NEW.InvoiceID
      AND i.Status <> 'Cancelled';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invoice does not exist or is cancelled';
    END IF;

    SELECT COALESCE(SUM(p.Amount), 0)
    INTO v_paid_total
    FROM Payment p
    WHERE p.InvoiceID = NEW.InvoiceID;

    IF v_paid_total >= v_invoice_total THEN
        UPDATE Invoice
        SET Status = 'Paid'
        WHERE InvoiceID = NEW.InvoiceID;
    ELSIF v_paid_total > 0 THEN
        UPDATE Invoice
        SET Status = 'PartiallyPaid'
        WHERE InvoiceID = NEW.InvoiceID;
    ELSE
        UPDATE Invoice
        SET Status = 'Unpaid'
        WHERE InvoiceID = NEW.InvoiceID;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_invoice_status
AFTER INSERT ON Payment
FOR EACH ROW
EXECUTE FUNCTION update_invoice_status();