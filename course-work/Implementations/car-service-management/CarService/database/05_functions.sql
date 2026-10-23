-- Car Service Management Platform
-- File: 05_functions.sql

CREATE OR REPLACE FUNCTION calculate_repair_total(p_repair_id INTEGER)
RETURNS NUMERIC(12,2)
LANGUAGE SQL
STABLE
AS $$
    SELECT COALESCE(
        (SELECT SUM(rs.Quantity * rs.UnitPrice)
         FROM RepairService rs
         WHERE rs.RepairID = p_repair_id),
        0
    )
    +
    COALESCE(
        (SELECT SUM(rp.Quantity * rp.UnitPrice)
         FROM RepairPart rp
         WHERE rp.RepairID = p_repair_id),
        0
    );
$$;

-- Returns the total number of repairs for a vehicle.
CREATE OR REPLACE FUNCTION get_vehicle_repair_count(p_vehicle_id INTEGER)
RETURNS INTEGER
LANGUAGE SQL
STABLE
AS $$
    SELECT COUNT(*)::INTEGER
    FROM Repair
    WHERE VehicleID = p_vehicle_id;
$$;