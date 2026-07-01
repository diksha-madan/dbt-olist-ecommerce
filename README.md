Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

# Olist E-Commerce Analytics Engineering Project

## Project Overview

This project demonstrates the design and implementation of a modern end-to-end Analytics Engineering workflow using the Brazilian Olist e-commerce dataset.

The objective of this project is to transform raw transactional data into analytics-ready datasets using industry-standard data modeling practices, data quality frameworks, and dimensional modeling techniques.

The project follows a layered Medallion Architecture using Databricks, dbt, PySpark, and Power BI.

---

## Business Problem

E-commerce organizations generate large volumes of transactional data across multiple business entities such as customers, orders, products, sellers, payments, and reviews.

Business stakeholders require reliable, analytics-ready datasets to answer questions such as:

* Who are our most valuable customers?
* Which products and sellers generate the highest revenue?
* What factors influence customer satisfaction?
* How does revenue evolve over time?
* What percentage of orders are delayed?
* Which products have never been sold?

This project addresses these questions by building a scalable analytics warehouse and reporting layer.

---

## Tech Stack

| Category             | Technology                     |
| -------------------- | ------------------------------ |
| Data Processing      | PySpark                        |
| Data Transformation  | dbt                            |
| Data Warehouse       | Databricks                     |
| Programming Language | SQL, Python                    |
| Data Visualization   | Power BI                       |
| Version Control      | Git & GitHub                   |
| Data Modeling        | Dimensional Modeling (Kimball) |

---

## Dataset

Source: Olist Brazilian E-Commerce Public Dataset

The dataset contains information related to:

* Customers
* Orders
* Order Items
* Payments
* Reviews
* Products
* Sellers
* Geolocation

---

## Project Architecture

The project follows a layered Medallion Architecture.

```text
Raw Layer
    ↓
Clean Layer
    ↓
Staging Layer
    ↓
Intermediate Layer
    ↓
Facts & Dimensions
    ↓
Business Marts
    ↓
Power BI Dashboards
```

---

## Data Warehouse Layers

### 1. Raw Layer

Contains source data ingested without modifications.

Characteristics:

* Immutable source data
* No transformations applied
* Serves as the source of truth

---

### 2. Clean Layer

Implemented using PySpark.

Responsibilities:

* Data profiling
* Data cleansing
* Invalid record removal
* Datatype standardization
* Source anomaly handling

Examples:

* Invalid review scores removed
* Malformed timestamps filtered
* Payment anomalies identified

---

### 3. Staging Layer

Implemented in dbt.

Purpose:

* Standardize source data
* Rename columns
* Cast datatypes
* Perform basic source validation

Characteristics:

* No joins
* No aggregations
* One-to-one mapping with source tables

Models:

* stg_customers
* stg_orders
* stg_order_items
* stg_payments
* stg_reviews
* stg_products
* stg_sellers
* stg_geolocation

---

### 4. Intermediate Layer

Purpose:

Encapsulate reusable business logic and transformations.

Examples:

* Revenue aggregation
* Review aggregation
* Delivery metrics
* Business flags

Models:

* int_payments_enriched
* int_payments_agg
* int_reviews_enriched
* int_reviews_agg
* int_orders_enriched
* int_order_items_enriched

Examples of derived business metrics:

* total_payment_value
* payment_count
* delivery_days
* avg_review_score
* is_delayed

---

### 5. Gold Layer (Facts & Dimensions)

The warehouse follows dimensional modeling principles.

#### Dimensions

* dim_customers
* dim_products
* dim_sellers
* dim_dates

#### Facts

* fact_orders
* fact_order_items
* fact_payments
* fact_reviews

Facts and dimensions provide reusable warehouse entities for downstream analytical consumption.

---

### 6. Business Mart Layer

Reporting-ready datasets optimized for business consumption.

#### mart_customer_360

Business Questions:

* Who are our highest-value customers?
* How many repeat customers do we have?
* What customer segments generate the most revenue?

Metrics:

* Total Orders
* Total Revenue
* Average Order Value
* Customer Lifespan
* Customer Segmentation

---

#### mart_product_performance

Business Questions:

* Which products generate the highest revenue?
* Which products have never been sold?

Metrics:

* Total Revenue
* Quantity Sold
* Average Selling Price
* Product Sales Indicator

---

#### mart_seller_performance

Business Questions:

* Which sellers generate the highest revenue?
* Which sellers provide the best customer experience?

Metrics:

* Total Revenue
* Total Orders
* Average Review Score
* Distinct Products Sold

---

#### mart_revenue

Business Questions:

* How does business performance evolve over time?
* What percentage of orders are delayed?

Metrics:

* Revenue
* Total Orders
* Average Order Value
* Delayed Order Percentage
* Average Delivery Time

---

## Data Quality Framework

Data quality validation was implemented at multiple layers.

### PySpark Data Quality Notebook

Initial source profiling and validation included:

* Null checks
* Duplicate checks
* Referential integrity validation
* Value range validation
* Date format validation

Examples:

* Review score validation
* Payment value validation
* Foreign key validation

---

## dbt Generic Tests

Generic tests implemented:

* unique
* not_null
* relationships
* accepted_values
* dbt_utils.unique_combination_of_columns

Examples:

* Composite key validation
* Referential integrity checks
* Payment type validation

---

## Custom Business Rule Tests

Custom tests were implemented to validate business assumptions.

Examples:

* Average review score range validation
* Average order value positivity checks
* Customer lifecycle validation
* Delayed order percentage validation

---

## Audit Models

Audit models were implemented to surface source-system anomalies without modifying source records.

Example:

Orders marked as delivered but missing delivery timestamps were identified and surfaced through dedicated audit models.

This approach preserves source-system fidelity while enabling downstream monitoring and remediation.

---

## Design Decisions

### Why Intermediate Models?

Intermediate models encapsulate reusable business logic and prevent transformation duplication across facts and marts.

---

### Why Separate Enriched and Aggregated Models?

Transactional detail was preserved while simultaneously providing reusable aggregated metrics.

Examples:

* int_reviews_enriched
* int_reviews_agg
* int_payments_enriched
* int_payments_agg

---

### Why Composite Keys?

Some datasets do not contain a single unique identifier.

Example:

The payments dataset allows multiple payment transactions per order.

Therefore:

(order_id, payment_sequential)

was implemented as the business key.

---

### Why Audit Instead of Deleting Bad Records?

Source records were not modified or deleted.

Data quality exceptions were surfaced using:

* Data quality flags
* Audit models

This preserves source-system fidelity and supports production-grade observability.

---

## dbt Documentation

dbt documentation and lineage were generated using:

```bash
dbt docs generate
```

The lineage graph provides complete visibility into model dependencies across all warehouse layers.

---

## Repository Structure

```text
models/
│
├── staging/
├── intermediate/
├── dimensions/
├── facts/
├── marts/
├── audit/
│
tests/
├── staging/
├── intermediate/
├── marts/
│
notebooks/
│
macros/
│
seeds/
│
snapshots/
```

---

## Future Enhancements

Potential future enhancements include:

* Incremental Models
* dbt Snapshots (SCD Type 2)
* CI/CD Pipeline Integration
* Data Observability Framework
* Automated Data Quality Alerts
* Semantic Layer Implementation
* Sentiment Analysis on Customer Reviews

---

## Key Learnings

This project demonstrates:

* Modern Analytics Engineering practices
* Dimensional data modeling
* dbt transformation workflows
* Data quality engineering
* Business-oriented data modeling
* Warehouse architecture design
* Production-grade analytics engineering concepts

---

## Author

Diksha Madan

Analytics Engineer | Data Analyst

LinkedIn: <Add LinkedIn URL>

GitHub: <Add GitHub URL>
