# Car Service Management Platform

**Faculty Number:** 2401322013

## Project Description

Car Service Management Platform is a relational database project designed to support the daily operations of a car service workshop. It manages customers, vehicles, appointments, mechanics, repairs, services, spare parts, invoices, payments, and suppliers.

The project also includes a Data Warehouse designed for analytical reporting and business insights.

## Technologies

- PostgreSQL 17
- SQL
- Relational Database Design
- Entity-Relationship Diagrams
- Data Warehouse and ETL
- diagrams.net

## Project Structure

- `database/` — Operational database schema, sample data, functions, stored procedures, and triggers.
- `data-warehouse/` — Data Warehouse schema, ETL scripts, and analytical queries.
- `diagrams/` — Database relationship diagrams.
- `documentation/` — Additional project documentation.

## Main Features

- Management of customers, vehicles, appointments, and mechanics.
- Tracking of repairs, services, and spare parts.
- Invoice and payment management.
- Database functions for calculating repair totals and counting vehicle repairs.
- Stored procedures for creating appointments and registering payments.
- Triggers for maintaining spare-part stock and updating invoice payment status.
- Data Warehouse with fact and dimension tables.
- Analytical queries for revenue, repairs, services, parts, mechanics, and customers.

## Requirements

- PostgreSQL 17 or a compatible PostgreSQL version.
- pgAdmin 4 or another PostgreSQL client.

## Installation and Startup

1. Install PostgreSQL and pgAdmin 4.
2. Create a new database named `car_service_db`.
3. Open pgAdmin 4 and connect to the new database.
4. Execute the operational SQL scripts in the following order:

   - `database/01_create_tables.sql`
   - `database/02_create_relationships.sql`
   - `database/03_seed_data.sql`
   - `database/04_seed_workshop.sql`
   - `database/05_functions.sql`
   - `database/06_procedures.sql`
   - `database/07_triggers.sql`

5. Create the Data Warehouse tables by executing `data-warehouse/01_create_dw_tables.sql`.
6. Load the Data Warehouse data by executing `data-warehouse/02_load_dw_data.sql`.
7. Execute `data-warehouse/03_analytics.sql` to run the analytical queries.

**Note:** Run the initial database creation and sample-data scripts only when setting up a fresh database. Do not rerun seed scripts on an existing database unless their effects are understood.

## Database Design

The operational database uses a relational model with primary keys, foreign keys, and many-to-many relationships. The Data Warehouse uses fact and dimension tables to support analytical queries and reporting.

## Author

Ludmil Milenov
Martin Mechkov