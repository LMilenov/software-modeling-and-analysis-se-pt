-- =========================================
-- OPERATIONAL DATABASE ANALYTICS
-- =========================================
-- Displays customers and their vehicles, including brand, model, registration number and production year.
SELECT
    c.firstname AS first_name,
    c.lastname AS last_name,
    v.registrationnumber AS registration_number,
    b.brandname AS brand,
    vm.modelname AS model,
    v.productionyear AS production_year
FROM public.customer c
JOIN public.vehicle v
    ON v.customerid = c.customerid
JOIN public.vehiclemodel vm
    ON vm.modelid = v.modelid
JOIN public.brand b
    ON b.brandid = vm.brandid
ORDER BY c.customerid;

-- Displays all repairs with vehicle, mechanic, dates, labor hours, status and notes.
SELECT
    r.repairid,
    r.vehicleid,
    r.mechanicid,
    r.startdate,
    r.enddate,
    r.laborhours,
    r.status,
    r.notes
FROM public.repair r
ORDER BY r.repairid;

-- Calculates and displays the total cost of each repair using the calculate_repair_total() function.
SELECT
    r.repairid,
    r.startdate,
    r.status,
    calculate_repair_total(r.repairid) AS total_amount
FROM public.repair r
ORDER BY r.repairid;

-- Shows the total number of repairs, total repair revenue and average repair value.
SELECT
    COUNT(*) AS total_repairs,
    SUM(calculate_repair_total(repairid)) AS total_revenue,
    ROUND(
        AVG(calculate_repair_total(repairid)),
        2
    ) AS average_repair_value
FROM public.repair;

-- Shows the total number of payments, total amount paid and average payment amount.
SELECT
    COUNT(*) AS total_payments,
    SUM(amount) AS total_paid,
    ROUND(AVG(amount), 2) AS average_payment
FROM public.payment;

-- Displays invoice details and calculates the amount of each invoice based on its repair.
SELECT
    i.invoiceid,
    i.invoicenumber,
    i.repairid,
    i.issuedate,
    i.duedate,
    i.status,
    calculate_repair_total(i.repairid) AS invoice_amount
FROM public.invoice i
ORDER BY i.invoiceid;

-- Compares invoice amounts with payments received and calculates the remaining balance for each invoice.
SELECT
    i.invoiceid,
    i.invoicenumber,
    i.status,
    calculate_repair_total(i.repairid) AS invoice_amount,
    COALESCE(SUM(p.amount), 0) AS amount_paid,
    calculate_repair_total(i.repairid)
        - COALESCE(SUM(p.amount), 0) AS balance
FROM public.invoice i
LEFT JOIN public.payment p
    ON p.invoiceid = i.invoiceid
GROUP BY
    i.invoiceid,
    i.invoicenumber,
    i.status,
    i.repairid
ORDER BY i.invoiceid;

-- =========================================
-- DATA WAREHOUSE ANALYTICS
-- =========================================

-- Summarizes repair count, service costs, parts costs, total revenue and average repair value.
SELECT
    COUNT(*) AS total_repairs,
    SUM(service_amount) AS total_service_amount,
    SUM(parts_amount) AS total_parts_amount,
    SUM(total_amount) AS total_repair_amount,
    ROUND(AVG(total_amount), 2) AS average_repair_amount
FROM dw.fact_repair;

-- Analyzes service usage, total quantities, revenue and average unit prices, ranked by revenue.
SELECT
    s.service_name,
    SUM(f.quantity) AS total_quantity,
    SUM(f.total_amount) AS total_service_amount,
    ROUND(AVG(f.unit_price), 2) AS average_unit_price
FROM dw.fact_service_usage f
JOIN dw.dim_service s
    ON s.service_key = f.service_key
GROUP BY s.service_key, s.service_name
ORDER BY total_service_amount DESC;

-- Analyzes parts usage, total quantities, revenue and average unit prices, ranked by revenue.
SELECT
    p.part_name,
    SUM(f.quantity) AS total_quantity,
    SUM(f.total_amount) AS total_parts_amount,
    ROUND(AVG(f.unit_price), 2) AS average_unit_price
FROM dw.fact_parts_usage f
JOIN dw.dim_part p
    ON p.part_key = f.part_key
GROUP BY p.part_key, p.part_name
ORDER BY total_parts_amount DESC;

-- Groups payments by payment method and calculates payment count, total amount and average payment.
SELECT
    pm.method_name AS payment_method,
    COUNT(fp.payment_fact_key) AS total_payments,
    SUM(fp.amount) AS total_amount,
    ROUND(AVG(fp.amount), 2) AS average_payment
FROM dw.fact_payment fp
JOIN dw.dim_payment_method pm
    ON pm.payment_method_key = fp.payment_method_key
GROUP BY
    pm.payment_method_key,
    pm.method_name
ORDER BY total_amount DESC;

-- Compares mechanics by number of repairs, total revenue and average repair value.
SELECT
    m.first_name,
    m.last_name,
    COUNT(fr.repair_fact_key) AS total_repairs,
    SUM(fr.total_amount) AS total_revenue,
    ROUND(AVG(fr.total_amount), 2) AS average_repair_value
FROM dw.fact_repair fr
JOIN dw.dim_mechanic m
    ON m.mechanic_key = fr.mechanic_key
GROUP BY
    m.mechanic_key,
    m.first_name,
    m.last_name
ORDER BY total_revenue DESC;

-- Analyzes monthly repair count and revenue using the date dimension.
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(fr.repair_fact_key) AS total_repairs,
    SUM(fr.total_amount) AS total_revenue
FROM dw.fact_repair fr
JOIN dw.dim_date d
    ON d.date_key = fr.date_key
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;

-- Ranks customers by total spending and displays their number of repairs.
SELECT
    c.first_name,
    c.last_name,
    COUNT(fr.repair_fact_key) AS total_repairs,
    SUM(fr.total_amount) AS total_spent
FROM dw.fact_repair fr
JOIN dw.dim_customer c
    ON c.customer_key = fr.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC;

-- Counts how many repairs have been registered for each vehicle.
SELECT
    v.vehicleid,
    v.registrationnumber,
    get_vehicle_repair_count(v.vehicleid) AS repair_count
FROM public.vehicle v
ORDER BY v.vehicleid;