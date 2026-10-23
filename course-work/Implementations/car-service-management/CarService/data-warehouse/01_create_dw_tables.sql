
-- =========================================
-- CAR SERVICE DATA WAREHOUSE
-- Step 1: Create schema, dimensions and facts
-- =========================================

CREATE SCHEMA IF NOT EXISTS dw;

-- =========================================
-- DIMENSION TABLES
-- =========================================

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS dw.dim_vehicle (
    vehicle_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_vehicle_id INTEGER NOT NULL UNIQUE,
    registration_number VARCHAR(50),
    vin VARCHAR(100),
    production_year INTEGER,
    fuel_type VARCHAR(50),
    model_name VARCHAR(100),
    brand_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dw.dim_mechanic (
    mechanic_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_mechanic_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    hourly_rate NUMERIC(10,2),
    is_active BOOLEAN
);

CREATE TABLE IF NOT EXISTS dw.dim_service (
    service_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_service_id INTEGER NOT NULL UNIQUE,
    service_name VARCHAR(150),
    description TEXT,
    standard_price NUMERIC(10,2),
    estimated_duration_minutes INTEGER
);

CREATE TABLE IF NOT EXISTS dw.dim_supplier (
    supplier_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_supplier_id INTEGER NOT NULL UNIQUE,
    supplier_name VARCHAR(150),
    city VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dw.dim_part (
    part_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_part_id INTEGER NOT NULL UNIQUE,
    part_name VARCHAR(150),
    part_number VARCHAR(100),
    supplier_key INTEGER REFERENCES dw.dim_supplier(supplier_key),
    unit_price NUMERIC(10,2),
    minimum_stock INTEGER
);

CREATE TABLE IF NOT EXISTS dw.dim_payment_method (
    payment_method_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_payment_method_id INTEGER NOT NULL UNIQUE,
    method_name VARCHAR(100)
);

-- =========================================
-- FACT TABLES
-- =========================================

-- One row per repair
CREATE TABLE IF NOT EXISTS dw.fact_repair (
    repair_fact_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_repair_id INTEGER NOT NULL UNIQUE,
    date_key INTEGER REFERENCES dw.dim_date(date_key),
    customer_key INTEGER REFERENCES dw.dim_customer(customer_key),
    vehicle_key INTEGER REFERENCES dw.dim_vehicle(vehicle_key),
    mechanic_key INTEGER REFERENCES dw.dim_mechanic(mechanic_key),
    repair_status VARCHAR(50),
    labor_hours NUMERIC(10,2),
    service_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    parts_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0
);

-- One row per repair and service
CREATE TABLE IF NOT EXISTS dw.fact_service_usage (
    service_usage_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_repair_id INTEGER NOT NULL,
    service_key INTEGER NOT NULL REFERENCES dw.dim_service(service_key),
    date_key INTEGER REFERENCES dw.dim_date(date_key),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    CONSTRAINT uq_fact_service_usage_repair_service
    UNIQUE (source_repair_id, service_key)
);

-- One row per repair and part
CREATE TABLE IF NOT EXISTS dw.fact_parts_usage (
    parts_usage_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_repair_id INTEGER NOT NULL,
    part_key INTEGER NOT NULL REFERENCES dw.dim_part(part_key),
    date_key INTEGER REFERENCES dw.dim_date(date_key),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    CONSTRAINT uq_fact_parts_usage_repair_part
        UNIQUE (source_repair_id, part_key)
);

-- One row per payment
CREATE TABLE IF NOT EXISTS dw.fact_payment (
    payment_fact_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_payment_id INTEGER NOT NULL UNIQUE,
    invoice_id INTEGER NOT NULL,
    date_key INTEGER REFERENCES dw.dim_date(date_key),
    payment_method_key INTEGER
        REFERENCES dw.dim_payment_method(payment_method_key),
    amount NUMERIC(12,2) NOT NULL
);
