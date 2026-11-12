**Language:** English | [Tiếng Việt](README_VI.md)

# Olist E-commerce Order and Delivery Performance Analysis

**SQL Server · Power BI · Data Quality · Business Analysis**

A portfolio case study using historical Brazilian e-commerce data.

## Project overview

This project uses the public Olist Brazilian E-Commerce Dataset to analyze order volume, the value of items in delivered orders, and delivery reliability. It is written for a hypothetical e-commerce operations manager. The analysis describes historical patterns and identifies areas for follow-up. Forecasting and causal analysis are outside its scope.

The workflow covers data profiling, data cleaning, SQL analysis, KPI validation, Power BI reporting, and operational recommendations.

**Scope:** 99,441 orders, 112,650 order-item rows, and 99,441 customer records. The order data spans **September 2016–October 2018**. Monthly trend charts focus on **January 2017–August 2018** to exclude months with sparse data at the start and end of the period. KPI cards cover the full historical period unless the report indicates a filter applied by the user.

## Dashboard previews

### Page 1 — Order Overview

![Olist order overview dashboard](images/dashboard_overview.png)

Shows total orders, delivered item value, the late-delivery rate, and monthly trends.

### Page 2 — Delivery Performance

![Olist delivery performance dashboard](images/dashboard_delivery.png)

Compares late-delivery **rates** and **counts** across all 27 Brazilian customer-state codes in the dataset. Rates show where a larger share of orders arrived late. Counts show where more orders were affected.

> **Reading note:** The KPI cards cover the full dataset by default. Monthly trends use the January 2017–August 2018 focus window. State comparisons cover the full historical period. Read filtered results within their selected scope.

## Business questions

1. How did **order volume** change by purchase month?
2. How did **delivered item value** change by purchase month?
3. What share of eligible delivered orders arrived **after the estimated delivery date**?
4. Which customer states had the highest **late-delivery rates**? Which had the most **late orders**?

## Core KPIs

| KPI | Historical result | Definition |
| --- | ---: | --- |
| Total Orders | **99,441** | Count of distinct `order_id` values across all order statuses |
| Delivered Item Value | **BRL 13,221,498.11** | Sum of cleaned item `price` for orders with status `delivered`, excluding freight |
| Eligible Delivered Orders | **96,470** | Delivered orders with both an actual and an estimated delivery date |
| Late Orders | **6,534** | Eligible orders that arrived on a **calendar date** later than the estimated delivery date |
| Late Delivery Rate | **6.77%** | Late Orders ÷ Eligible Delivered Orders |

**Interpretation:** Delivered Item Value measures the value of items. Verified accounting revenue, cash receipts, and profit are outside this KPI's scope. The late-delivery calculation compares calendar dates, so differences in delivery time within the same date do not count as late.

## Selected findings

- **November 2017** had the most orders of any month, with **7,544 orders** and **BRL 987,765.37** in delivered item value.
- **AL** had the highest late-delivery rate at **21.41%** (85 late orders out of 397 eligible orders). Consider the smaller sample when prioritizing follow-up.
- **SP** had the most late orders (**1,820**) and a relatively low late-delivery rate of **4.49%** (40,494 eligible orders).
- **RJ** had **1,495** late orders and a late-delivery rate of **12.11%** (12,350 eligible orders), making it a candidate for further investigation.
- **RJ, BA, and CE** are candidates for follow-up because their late-delivery rates were above the overall **6.77%** and they had notable volumes of late orders. These comparisons identify where to investigate. The causes of the delays remain unverified.

See [`docs/insights_recommendations.md`](docs/insights_recommendations.md) for supporting calculations, caveats, and recommendations.

## Data cleaning and quality

- **Monetary values during import:** In this project's SQL Server import, `price` and `freight_value` were **100×** the amounts in the original CSV. The `dbo.v_olist_order_items_clean` view corrects the imported values while leaving the source CSV intact. Row counts and aggregate totals were independently checked against the source CSV. **Apply this correction only when the import has the documented scaling problem.**
- **Missing order-item rows:** 775 orders have no matching order-item record. The orders dataset retains them. Use distinct order IDs from the orders table for the full order count, since counting joined rows can give a misleading result.
- **Missing delivery dates:** 8 `delivered` orders lack an actual delivery date. They remain in the data and are excluded from the late-delivery denominator.
- **Timeline anomalies:** 23 orders have an actual customer delivery timestamp earlier than the carrier handoff timestamp. The analysis documents these anomalies and keeps the recorded timestamps.

[`docs/data_quality_report.md`](docs/data_quality_report.md) and [`docs/validation_report.md`](docs/validation_report.md) document the aggregate checks and the reconciliation between SQL Server and Power BI. Reconciliation was performed at the aggregate level.

## Data model and tools

| Object | Grain | Join keys |
| --- | --- | --- |
| `olist_orders` | One row per order | `order_id`, `customer_id` |
| `olist_customers` | One customer record per order in this dataset | `customer_id` |
| `v_olist_order_items_clean` | One item line per order-item ID | `order_id` |

In this dataset, `olist_orders` has a **one-to-many** relationship with the cleaned items, and customers and orders have a **one-to-one** relationship. `customer_id` identifies the customer record associated with an order. Repeat-buyer analysis requires `customer_unique_id`.

**Tools:** Microsoft SQL Server 2022 Express, SQL Server Management Studio (SSMS), Power BI Desktop (Import mode), SQL, DAX, and Markdown.

## Repository contents

```text
Ecommerce-Olist-Analysis/
├── README.md
├── README_VI.md
├── .gitignore
├── docs/
│   ├── project_brief.md
│   ├── data_sources.md
│   ├── data_dictionary.md
│   ├── kpi_dictionary.md
│   ├── data_quality_report.md
│   ├── validation_report.md
│   └── insights_recommendations.md
├── sql/
│   └── olist_analysis.sql
├── powerbi/
│   └── olist_dashboard.pbix
├── images/
│   ├── dashboard_overview.png
│   └── dashboard_delivery.png
└── data/
    └── raw/           # local only; source CSVs are kept outside the repository
```

## How to explore the project

**View the report:** Open [`powerbi/olist_dashboard.pbix`](powerbi/olist_dashboard.pbix) in Power BI Desktop. The file uses **Import mode**. Refreshing it may require access to the SQL Server source and the appropriate credentials.

**Inspect the analysis:** Read [`sql/olist_analysis.sql`](sql/olist_analysis.sql) and the documentation in [`docs/`](docs/). Create the `olist_ecommerce` database and import the three source tables before running the script. Database setup and CSV import are separate steps.

**Reproduce the analysis from the source data:**

1. Download the orders, order items, and customers CSVs from the [Olist dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Create a local `olist_ecommerce` SQL Server database. Import the CSVs into `dbo.olist_orders`, `dbo.olist_order_items`, and `dbo.olist_customers` using suitable column types.
3. **Check monetary values against the source CSV before running the cleaning view.** The included view divides imported amounts by 100 to correct the documented scaling issue. If your imported amounts already match the CSV, keep those values and adjust the import workflow to skip the correction.
4. Run the relevant sections of [`sql/olist_analysis.sql`](sql/olist_analysis.sql) and check the results against [`docs/validation_report.md`](docs/validation_report.md).
5. Open the PBIX file to view the dashboard. Refreshing it against a different SQL Server instance may require updating the connection settings and revalidating the results.

## Limitations

- The 2016–2018 data describes historical activity. Current Olist operations are outside the scope of the analysis.
- State-level comparisons identify areas for follow-up. Establishing the causes of delivery delays would require separate causal analysis.
- Profit, payment settlement, product reviews, and predictive fraud modeling are outside the scope.
- Validation covers aggregate reconciliation and the documented KPI checks. Exhaustive record-level validation and independent testing of Power BI interactions are outside the scope of these checks.

## Source and attribution

[Olist — Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published on Kaggle.

The source CSVs are kept outside this repository. Review the dataset's license and terms on Kaggle before reuse.

---

*Portfolio project covering SQL analysis, data quality checks, business interpretation, and Power BI reporting.*
