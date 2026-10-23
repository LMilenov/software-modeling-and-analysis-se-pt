
BEGIN;

-- 1. Зареждане на измерението Customer
INSERT INTO dw.dim_customer
    (source_customer_id, first_name, last_name, email)
SELECT
    customerid, firstname, lastname, email
FROM public.customer
ON CONFLICT (source_customer_id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name  = EXCLUDED.last_name,
    email      = EXCLUDED.email;

-- 2. Зареждане на измерението Supplier
INSERT INTO dw.dim_supplier
    (source_supplier_id, supplier_name, city)
SELECT
    supplierid, suppliername, city
FROM public.supplier
ON CONFLICT (source_supplier_id) DO UPDATE SET
    supplier_name = EXCLUDED.supplier_name,
    city          = EXCLUDED.city;

-- 3. Зареждане на измерението Payment Method
INSERT INTO dw.dim_payment_method
    (source_payment_method_id, method_name)
SELECT
    paymentmethodid, methodname
FROM public.paymentmethod
ON CONFLICT (source_payment_method_id) DO UPDATE SET
    method_name = EXCLUDED.method_name;

-- 4. Зареждане на измерението Mechanic
INSERT INTO dw.dim_mechanic
    (source_mechanic_id, first_name, last_name, hourly_rate, is_active)
SELECT
    mechanicid, firstname, lastname, hourlyrate, isactive
FROM public.mechanic
ON CONFLICT (source_mechanic_id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name  = EXCLUDED.last_name,
    hourly_rate = EXCLUDED.hourly_rate,
    is_active   = EXCLUDED.is_active;

-- 5. Зареждане на измерението Service
INSERT INTO dw.dim_service
    (source_service_id, service_name, description,
     standard_price, estimated_duration_minutes)
SELECT
    serviceid, servicename, description,
    standardprice, estimateddurationminutes
FROM public.service
ON CONFLICT (source_service_id) DO UPDATE SET
    service_name = EXCLUDED.service_name,
    description = EXCLUDED.description,
    standard_price = EXCLUDED.standard_price,
    estimated_duration_minutes = EXCLUDED.estimated_duration_minutes;

-- 6. Зареждане на измерението Vehicle
INSERT INTO dw.dim_vehicle
    (source_vehicle_id, registration_number, vin, production_year,
     fuel_type, model_name, brand_name)
SELECT
    v.vehicleid, v.registrationnumber, v.vin, v.productionyear,
    v.fueltype, vm.modelname, b.brandname
FROM public.vehicle v
JOIN public.vehiclemodel vm ON vm.modelid = v.modelid
JOIN public.brand b ON b.brandid = vm.brandid
ON CONFLICT (source_vehicle_id) DO UPDATE SET
    registration_number = EXCLUDED.registration_number,
    vin = EXCLUDED.vin,
    production_year = EXCLUDED.production_year,
    fuel_type = EXCLUDED.fuel_type,
    model_name = EXCLUDED.model_name,
    brand_name = EXCLUDED.brand_name;

-- 7. Зареждане на измерението Part
INSERT INTO dw.dim_part
    (source_part_id, part_name, part_number, supplier_key,
     unit_price, minimum_stock)
SELECT
    p.partid, p.partname, p.partnumber,
    ds.supplier_key, p.unitprice, p.minimumstock
FROM public.part p
LEFT JOIN dw.dim_supplier ds
    ON ds.source_supplier_id = p.supplierid
ON CONFLICT (source_part_id) DO UPDATE SET
    part_name = EXCLUDED.part_name,
    part_number = EXCLUDED.part_number,
    supplier_key = EXCLUDED.supplier_key,
    unit_price = EXCLUDED.unit_price,
    minimum_stock = EXCLUDED.minimum_stock;

-- 8. Зареждане на измерението Date
INSERT INTO dw.dim_date
    (date_key, full_date, year, quarter, month,
     month_name, day_of_month, day_of_week)
SELECT
    TO_CHAR(d::date, 'YYYYMMDD')::INTEGER,
    d::date,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    TO_CHAR(d::date, 'FMMonth'),
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(ISODOW FROM d)::INTEGER
FROM generate_series(
    LEAST(
        COALESCE((SELECT MIN(startdate)::date FROM public.repair), CURRENT_DATE),
        COALESCE((SELECT MIN(appointmentdate)::date FROM public.appointment), CURRENT_DATE),
        COALESCE((SELECT MIN(paymentdate)::date FROM public.payment), CURRENT_DATE)
    ),
    GREATEST(
        COALESCE((SELECT MAX(startdate)::date FROM public.repair), CURRENT_DATE),
        COALESCE((SELECT MAX(appointmentdate)::date FROM public.appointment), CURRENT_DATE),
        COALESCE((SELECT MAX(paymentdate)::date FROM public.payment), CURRENT_DATE),
        CURRENT_DATE
    ),
    INTERVAL '1 day'
) AS dates(d)
ON CONFLICT (date_key) DO UPDATE SET
    full_date = EXCLUDED.full_date,
    year = EXCLUDED.year,
    quarter = EXCLUDED.quarter,
    month = EXCLUDED.month,
    month_name = EXCLUDED.month_name,
    day_of_month = EXCLUDED.day_of_month,
    day_of_week = EXCLUDED.day_of_week;

-- 9. Зареждане на фактите за ремонтите
INSERT INTO dw.fact_repair
    (source_repair_id, date_key, customer_key, vehicle_key, mechanic_key,
     repair_status, labor_hours, service_amount, parts_amount, total_amount)
SELECT
    r.repairid,
    TO_CHAR(r.startdate::date, 'YYYYMMDD')::INTEGER,
    dc.customer_key,
    dv.vehicle_key,
    dm.mechanic_key,
    r.status,
    COALESCE(r.laborhours, 0),
    COALESCE(s.service_amount, 0),
    COALESCE(p.parts_amount, 0),
    COALESCE(s.service_amount, 0) + COALESCE(p.parts_amount, 0)
FROM public.repair r
JOIN public.vehicle v ON v.vehicleid = r.vehicleid
JOIN dw.dim_customer dc ON dc.source_customer_id = v.customerid
JOIN dw.dim_vehicle dv ON dv.source_vehicle_id = v.vehicleid
LEFT JOIN dw.dim_mechanic dm ON dm.source_mechanic_id = r.mechanicid
LEFT JOIN (
    SELECT repairid, SUM(quantity * unitprice) AS service_amount
    FROM public.repairservice
    GROUP BY repairid
) s ON s.repairid = r.repairid
LEFT JOIN (
    SELECT repairid, SUM(quantity * unitprice) AS parts_amount
    FROM public.repairpart
    GROUP BY repairid
) p ON p.repairid = r.repairid
ON CONFLICT (source_repair_id) DO UPDATE SET
    date_key = EXCLUDED.date_key,
    customer_key = EXCLUDED.customer_key,
    vehicle_key = EXCLUDED.vehicle_key,
    mechanic_key = EXCLUDED.mechanic_key,
    repair_status = EXCLUDED.repair_status,
    labor_hours = EXCLUDED.labor_hours,
    service_amount = EXCLUDED.service_amount,
    parts_amount = EXCLUDED.parts_amount,
    total_amount = EXCLUDED.total_amount;

-- 10. Зареждане на използваните услуги
INSERT INTO dw.fact_service_usage
    (service_key, date_key, quantity, unit_price,
     total_amount, source_repair_id)
SELECT
    ds.service_key,
    TO_CHAR(r.startdate::date, 'YYYYMMDD')::INTEGER,
    rs.quantity,
    rs.unitprice,
    rs.quantity * rs.unitprice,
    rs.repairid
FROM public.repairservice rs
JOIN public.repair r ON r.repairid = rs.repairid
JOIN dw.dim_service ds
    ON ds.source_service_id = rs.serviceid
ON CONFLICT (source_repair_id, service_key) DO UPDATE SET
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    total_amount = EXCLUDED.total_amount;


-- 11. Зареждане на използваните части
INSERT INTO dw.fact_parts_usage
    (part_key, date_key, quantity, unit_price,
     total_amount, source_repair_id)
SELECT
    dp.part_key,
    TO_CHAR(r.startdate::date, 'YYYYMMDD')::INTEGER,
    rp.quantity,
    rp.unitprice,
    rp.quantity * rp.unitprice,
    rp.repairid
FROM public.repairpart rp
JOIN public.repair r ON r.repairid = rp.repairid
JOIN dw.dim_part dp
    ON dp.source_part_id = rp.partid
ON CONFLICT (source_repair_id, part_key) DO UPDATE SET
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    total_amount = EXCLUDED.total_amount;

-- 12. Зареждане на плащанията
INSERT INTO dw.fact_payment
    (source_payment_id, invoice_id, date_key, payment_method_key, amount)
SELECT
    p.paymentid,
    p.invoiceid,
    TO_CHAR(p.paymentdate::date, 'YYYYMMDD')::INTEGER,
    dpm.payment_method_key,
    p.amount
FROM public.payment p
JOIN dw.dim_payment_method dpm
    ON dpm.source_payment_method_id = p.paymentmethodid
ON CONFLICT (source_payment_id) DO UPDATE SET
    invoice_id = EXCLUDED.invoice_id,
    date_key = EXCLUDED.date_key,
    payment_method_key = EXCLUDED.payment_method_key,
    amount = EXCLUDED.amount;

COMMIT;
