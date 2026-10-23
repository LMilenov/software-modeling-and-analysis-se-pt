-- 1. Обобщение на ремонтите и техните приходи

SELECT
    COUNT(*) AS total_repairs,
    SUM(service_amount) AS total_service_revenue,
    SUM(parts_amount) AS total_parts_revenue,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS average_repair_value
FROM dw.fact_repair;


-- 2. Най-често използвани услуги
SELECT
    ds.service_name,
    SUM(fsu.quantity) AS total_quantity,
    SUM(fsu.total_amount) AS total_revenue
FROM dw.fact_service_usage fsu
JOIN dw.dim_service ds
    ON ds.service_key = fsu.service_key
GROUP BY ds.service_name
ORDER BY total_quantity DESC, total_revenue DESC;


-- 3. Най-използвани авточасти
SELECT
    dp.part_name,
    SUM(fpu.quantity) AS total_quantity,
    SUM(fpu.total_amount) AS total_cost
FROM dw.fact_parts_usage fpu
JOIN dw.dim_part dp
    ON dp.part_key = fpu.part_key
GROUP BY dp.part_name
ORDER BY total_quantity DESC, total_cost DESC;


-- 4. Приходи от ремонти по месеци
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(fr.source_repair_id) AS total_repairs,
    SUM(fr.total_amount) AS total_revenue
FROM dw.fact_repair fr
JOIN dw.dim_date dd
    ON dd.date_key = fr.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;


-- 5. Ремонти и приходи по механик
SELECT
    dm.first_name,
    dm.last_name,
    COUNT(fr.source_repair_id) AS total_repairs,
    SUM(fr.total_amount) AS total_revenue
FROM dw.fact_repair fr
JOIN dw.dim_mechanic dm
    ON dm.mechanic_key = fr.mechanic_key
GROUP BY dm.mechanic_key, dm.first_name, dm.last_name
ORDER BY total_repairs DESC, total_revenue DESC;


-- 6. Получени плащания по метод
SELECT
    dpm.method_name,
    COUNT(fp.source_payment_id) AS payment_count,
    SUM(fp.amount) AS total_paid
FROM dw.fact_payment fp
JOIN dw.dim_payment_method dpm
    ON dpm.payment_method_key = fp.payment_method_key
GROUP BY dpm.method_name
ORDER BY total_paid DESC;


-- 7. Проверка на фактурите и плащанията

SELECT
    i.invoiceid,
    i.invoicenumber,
    i.status AS invoice_status,
    r.repairid,
    COALESCE(fr.total_amount, 0) AS repair_total,
    COALESCE(SUM(p.amount), 0) AS total_paid,
    COALESCE(fr.total_amount, 0)
        - COALESCE(SUM(p.amount), 0) AS remaining_amount
FROM public.invoice i
JOIN public.repair r
    ON r.repairid = i.repairid
LEFT JOIN dw.fact_repair fr
    ON fr.source_repair_id = r.repairid
LEFT JOIN public.payment p
    ON p.invoiceid = i.invoiceid
GROUP BY
    i.invoiceid,
    i.invoicenumber,
    i.status,
    r.repairid,
    fr.total_amount
ORDER BY i.invoiceid;


-- 8. Сравнение между фактури, ремонти и стойности в DW

SELECT
    i.invoiceid,
    i.invoicenumber,
    i.status AS invoice_status,
    i.notes AS invoice_notes,
    r.repairid,
    r.status AS repair_status,
    r.laborhours,
    fr.service_amount,
    fr.parts_amount,
    fr.total_amount AS dw_repair_total,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM public.invoice i
JOIN public.repair r
    ON r.repairid = i.repairid
LEFT JOIN dw.fact_repair fr
    ON fr.source_repair_id = r.repairid
LEFT JOIN public.payment p
    ON p.invoiceid = i.invoiceid
GROUP BY
    i.invoiceid,
    i.invoicenumber,
    i.status,
    i.notes,
    r.repairid,
    r.status,
    r.laborhours,
    fr.service_amount,
    fr.parts_amount,
    fr.total_amount
ORDER BY i.invoiceid;

