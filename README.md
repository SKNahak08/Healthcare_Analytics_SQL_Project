# Healthcare_Analytics_SQL_Project

A SQL analysis of a multi-specialty hospital to understand where revenue comes from and where the biggest opportunities are to grow it and serve patients better.

## Business goal

MediCore Health Network has 8 departments, 16 doctors and about 3,000 patients across 6 cities. Patient volume is growing, and leadership wants a clear picture of how the business is doing: which departments and doctors drive revenue, how many booked appointments turn into visits, and how quickly bills are collected.

I used SQL to answer these questions:

1. How much do we bill, and which departments and doctors earn the most?
2. How many booked appointments become visits, and what are the missed ones worth?
3. What is the 30-day readmission rate?
4. Do a few patients bring in most of the revenue?
5. How much money is still to be collected, and how old is it?

## Key results

| Metric | Result |
|---|---|
| Total billed | ₹11.01 crore |
| Appointments completed | 70.5% (10,579 of 15,000) |
| Value of missed appointments | ₹38.9 lakh |
| Share of revenue from inpatient stays | 92% |
| 30-day readmission rate | 2.67% (40 of 1,500 admissions) |
| Patients behind 80% of revenue | 26.8% (779 of 2,902) |
| Outstanding bills older than 90 days | 88% of ₹3.26 crore |

Full findings and opportunities are in [insights.md].

## Tools

MySQL 8.0, MySQL Workbench, Excel (dashboard), GitHub

## Database

Six tables. `billing` is the main table and links to either an appointment (outpatient bill) or an admission (inpatient bill).

| Table | Rows |
|---|---|
| departments | 8 |
| doctors | 16 |
| patients | 3,000 |
| appointments | 15,000 |
| admissions | 1,500 |
| billing | 12,079 |

I also created a view, `billing_detail`, which combines outpatient and inpatient bills with the doctor who handled them.

## The 16 queries

| # | Question | SQL concepts |
|---|---|---|
| 1 | Overall business snapshot | Subqueries |
| 2 | Appointment status mix | GROUP BY, window SUM |
| 3 | Patients by city and insurance | Multi-column GROUP BY |
| 4 | Revenue by department (OPD vs IPD) | View, CASE |
| 5 | Top 10 doctors by revenue | JOIN, LIMIT |
| 6 | Monthly revenue and growth | CTE, LAG |
| 7 | Value of missed appointments | Conditional aggregation |
| 8 | Length of stay and bill by diagnosis | DATEDIFF, AVG |
| 9 | Revenue by age group | CASE, TIMESTAMPDIFF |
| 10 | Insurance split and outstanding dues | CASE inside SUM |
| 11 | Top doctor in each department | RANK, PARTITION BY |
| 12 | 30-day readmission rate | LAG, PARTITION BY |
| 13 | Patient retention by cohort | Multiple CTEs |
| 14 | Patients behind 80% of revenue | Running total |
| 15 | Doctor workload vs department average | AVG OVER, CASE |
| 16 | Aging of outstanding bills | CASE buckets |

## Folder structure

```
Healthcare_Analytics_SQL_Project
├── Dataset
│   ├── admission.csv
│   ├── appointments.csv
│   ├── billing.csv
│   ├── departments.csv
│   ├── doctors.csv
│   └── patients.csv
├── Results
│   ├── Dashboard.pdf
│   ├── Medicore_Health_16_queries.xlsx
│   └── Supporting_chart.pdf
├── SQL_files
│   ├── 01_Schema.sql
│   ├── 02_Seed_data.sql
│   ├── 03_Data_validation.sql
│   ├── Analysis_01-05_queries.sql
│   ├── Analysis_06-10_queries.sql
│   ├── Analysis_11-16_queries.sql
│   ├── Billing_details_view.sql
│   └── procedure_department_report.sql
├── insights.md
├── README.md
└── Schema_EER_diagram.png
```

## How to run

1. Install MySQL 8.0 or higher.
2. Run the files in `SQL_files/` in order.
3. Run `Billing_details_view.sql & procedure_department_report.sql` before the queries, also added date-column indexes in the Appointments, Patients, and Admissions tables, because queries 4, 5, 11 and 14 use the view.

## Data note

The dataset is simulated, not real patient data. I generated it in SQL (`sql/02_Seed_data.sql`), so numbers will differ slightly if you re-run it. Before analysing, I ran six data quality checks (orphan records, invalid dates, insurance above bill amount, bad bill links, row counts, duplicate bookings). The first four returned zero issues.



