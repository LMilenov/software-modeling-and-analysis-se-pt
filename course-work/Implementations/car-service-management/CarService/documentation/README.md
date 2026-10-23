# Car Service Management Platform

## 1. Project Overview

The Car Service Management Platform is a database
system designed to manage the daily operations of
an automotive repair workshop.

The system stores information about customers,
vehicles, vehicle brands and models, mechanics,
appointments, repairs, services, spare parts,
suppliers, invoices and payments.

The project also includes database functions,
stored procedures, triggers and a Data Warehouse
for analytical reporting.

## 2. Technologies Used

- PostgreSQL 17
- SQL and PL/pgSQL
- Visual Studio Code
- diagrams.net
- Data Warehouse and ETL

## 3. Project Structure

- `database/` — operational database scripts
- `data-warehouse/` — Data Warehouse tables,
  data loading and analytical queries
- `diagrams/` — database diagrams
- `documentation/` — project documentation

## 4. Relational Database Design

The operational database is implemented in PostgreSQL 17.
It consists of 15 tables that represent the main entities
and processes of the car service workshop.

### 4.1. Main Tables

- `Customer` — stores customer information.
- `Brand` — stores vehicle brands.
- `VehicleModel` — stores vehicle models and their brands.
- `Vehicle` — stores registered vehicles and their owners.
- `Mechanic` — stores information about workshop mechanics.
- `Appointment` — manages customer appointments.
- `Repair` — records repair operations.
- `Service` — stores the services offered by the workshop.
- `RepairService` — connects repairs with performed services.
- `Supplier` — stores spare-parts supplier information.
- `Part` — stores spare-parts information and stock quantities.
- `RepairPart` — records parts used during repairs.
- `Invoice` — stores invoices associated with repairs.
- `PaymentMethod` — stores available payment methods.
- `Payment` — records payments made against invoices.

### 4.2. Relationships

The database uses primary keys and foreign keys
to maintain referential integrity.

- A customer can own multiple vehicles.
- A brand can have multiple vehicle models.
- A vehicle model can be associated with multiple vehicles.
- A vehicle can have multiple appointments and repairs.
- A mechanic can be assigned to multiple appointments and repairs.
- A repair can include multiple services and spare parts.
- A supplier can supply multiple spare parts.
- A repair can have an associated invoice.
- An invoice can have multiple payments.
- A payment method can be used for multiple payments.

The `RepairService` and `RepairPart` tables implement
many-to-many relationships between repairs and services,
and between repairs and spare parts, respectively.

### 4.3. Data Integrity

Primary keys uniquely identify records.
Foreign keys connect related entities.
Unique constraints prevent duplicate values in selected
fields, such as customer email addresses, vehicle
registration numbers and invoice numbers.

The database also uses nullable foreign keys where
the business process allows optional relationships,
such as an appointment without an assigned mechanic.

## 5. Database Functions, Procedures and Triggers

The database includes functions, stored procedures and
triggers that implement business logic and automate
selected operations.

### 5.1. Database Functions

**calculate_repair_total(p_repair_id)**

Calculates the total value of a repair by adding the
cost of services and spare parts associated with it.
The function returns zero for missing service or part
amounts.

**get_vehicle_repair_count(p_vehicle_id)**

Returns the number of repairs associated with a
specific vehicle.

### 5.2. Stored Procedures

**create_appointment(...)**

Creates a new appointment by storing the vehicle,
assigned mechanic, appointment date and customer notes.

**register_payment(...)**

Registers a payment for an invoice. It validates the
payment amount, checks whether the invoice exists and
is not cancelled, and prevents a new payment from
exceeding the outstanding invoice balance.

### 5.3. Database Triggers

**trg_update_invoice_status**

Executes after a payment is inserted. It calculates
the total value of the associated repair, sums the
payments for the invoice and updates the invoice status
to `Unpaid`, `PartiallyPaid` or `Paid`.

**Part stock update trigger**

Updates the stock quantity of a spare part when a
record is inserted into `RepairPart`.

### 5.4. Testing

The database logic was tested using sample data.

- The repair total function returned a total of 197.00
  for repair ID 3.
- The vehicle repair count function was tested.
- The appointment creation procedure successfully
  created a test appointment.
- The part stock trigger decreased the stock quantity
  after a part was assigned to a repair.
- The payment registration procedure successfully
  registered a test payment and updated the invoice status.

## 6. Data Warehouse

The project includes a Data Warehouse implemented in a
separate PostgreSQL schema named `dw`. The schema is
located in the same database as the operational system.

The Data Warehouse contains 12 tables:
8 dimension tables and 4 fact tables.

### 6.1. Dimension Tables

- `dim_date` — stores calendar information.
- `dim_customer` — stores customer details.
- `dim_vehicle` — stores vehicle details, including brand and model.
- `dim_mechanic` — stores mechanic information.
- `dim_service` — stores service descriptions and standard prices.
- `dim_supplier` — stores supplier information.
- `dim_part` — stores spare-part details.
- `dim_payment_method` — stores payment method descriptions.

### 6.2. Fact Tables

- `fact_repair` — stores repair-level information, including
  service amounts, parts amounts and total amounts.
- `fact_service_usage` — records services used in repairs.
- `fact_parts_usage` — records spare parts used in repairs.
- `fact_payment` — records payments associated with invoices.

### 6.3. ETL Process

The ETL script uses conflict-handling logic to update existing records
 in selected dimension and fact tables. Unique constraints on the service 
 usage and parts usage fact tables prevent duplicate records for the same 
 repair-service and repair-part combinations. During validation, the ETL 
 process was checked for duplicate combinations, and none were found. 
 The row counts and repair totals remained unchanged during the validation checks.

### 6.4. Initial Load Results

The initial Data Warehouse load produced the following
record counts:

| Table | Records |
|---|---:|
| `dim_customer` | 8 |
| `dim_date` | 36 |
| `dim_mechanic` | 3 |
| `dim_part` | 8 |
| `dim_payment_method` | 3 |
| `dim_service` | 8 |
| `dim_supplier` | 3 |
| `dim_vehicle` | 8 |
| `fact_parts_usage` | 10 |
| `fact_payment` | 7 |
| `fact_repair` | 8 |
| `fact_service_usage` | 8 |

These counts represent the results of the initial load
and may change when the source data changes.

## 7. Analytical Queries and Results

The Data Warehouse supports analytical queries that help
evaluate workshop activity, service usage, spare-part
consumption, mechanic performance and payment methods.

### 7.1. Repair Revenue Summary

The analysis returned the following results:

- Total repairs: 8
- Service revenue: 430.00
- Parts revenue: 451.00
- Total repair value: 881.00
- Average repair value: 110.13

### 7.2. Most Frequently Used Services

Computer Diagnostics was the most frequently used service,
with 3 recorded uses and a total value of 90.00.

Oil Change was used 2 times, with a total value of 50.00.

Other recorded services included Timing Belt Replacement,
Suspension Repair and Brake Service.

### 7.3. Spare-Part Consumption

Engine Oil 5W-30 (1L) was the most frequently used spare part,
with 8 units recorded and a total cost of 76.00.

Other frequently used items included Oil Filters,
Timing Belt Kits, Brake Discs, Suspension Arms,
Front Brake Pads and Air Filters.

### 7.4. Monthly Repair Revenue

All 8 repairs in the current dataset were recorded in
September 2026, with a combined repair value of 881.00.

### 7.5. Repair Activity by Mechanic

The analysis returned the following results:

| Mechanic | Repairs | Repair Value |
|---|---:|---:|
| Martin Petrov | 3 | 390.00 |
| Stefan Ivanov | 3 | 265.00 |
| Kalin Georgiev | 2 | 226.00 |

### 7.6. Payments by Method

| Payment Method | Number of Payments | Total Amount |
|---|---:|---:|
| Card | 3 | 470.00 |
| Cash | 3 | 111.00 |
| Bank Transfer | 1 | 30.00 |

The analytical results are based on the current sample
dataset and demonstrate the reporting capabilities of
the Data Warehouse.

## 8. Testing and Data Quality

The project was tested using SQL queries and sample data
in PostgreSQL 17.

The following operations were verified:

- Creation of the operational database tables.
- Loading of sample data.
- Calculation of repair totals.
- Retrieval of repair counts for a vehicle.
- Creation of appointments.
- Automatic spare-part stock updates.
- Registration of invoice payments.
- Automatic invoice status updates.
- Loading of dimension and fact tables.
- Execution of analytical queries.

### 8.1. Data Quality Observations

During testing, two invoices were found to have payment
totals exceeding their calculated repair values.

- Invoice CS-2026-001: repair value 38.00, payments 68.00.
- Invoice CS-2026-006: repair value 155.00, payments 205.00.

These inconsistencies exist in the sample data.
The payment registration procedure prevents new payments
from exceeding the outstanding balance, but it does not
automatically correct pre-existing records inserted
directly into the payment table.

The dataset should therefore be reviewed before using
the financial figures as production accounting data.

## 9. Conclusion

The Car Service Management Platform demonstrates the
design and implementation of a relational database for
an automotive repair workshop.

The project includes related database entities,
referential integrity constraints, sample data,
functions, stored procedures and triggers.

A Data Warehouse and an ETL process were implemented
to support analytical reporting. The analytical queries
demonstrate how the collected data can be used to examine
repair values, service usage, spare-part consumption,
mechanic activity and payment methods.

Possible future improvements include a graphical user
interface, user authentication, more comprehensive
financial validation, automated ETL scheduling and
interactive analytical dashboards.


