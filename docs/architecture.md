# 🥉 Medallion Architecture

This project follows the **Medallion Architecture**, a layered data engineering design pattern that progressively improves data quality, business value, and usability as data moves through the pipeline.

Instead of transforming raw data directly into reporting tables, each layer has a clearly defined responsibility. This separation improves maintainability, simplifies debugging, enables incremental processing, and allows business logic to evolve without affecting upstream ingestion.

```
                   Raw Delta Tables
                          │
                          ▼
                  Bronze Layer
          (Cleaning & Standardization)
                          │
                          ▼
                  Silver Layer
      (Business Logic & Enrichment)
                          │
                          ▼
                   Gold Layer
        (Facts & Dimensions Models)
                          │
                          ▼
              Customer 360 Mart
```

---

## Why Medallion Architecture?

Modern data platforms rarely transform raw source data directly into dashboards.

Instead, transformations are broken into logical layers that each solve a specific problem.

This provides several benefits:

- Separation of ingestion from business logic
- Easier debugging and root cause analysis
- Modular and reusable transformations
- Independent testing at each layer
- Improved scalability as pipelines grow
- Better support for incremental processing
- Clear ownership of responsibilities

This architecture closely resembles patterns used on platforms such as Databricks.

---

# Bronze Layer

### Purpose

The Bronze layer acts as the ingestion and standardization layer.

Its responsibility is to ingest raw source tables while performing only minimal transformations required to make the data usable downstream.

No business logic is introduced at this stage.

Typical operations include:

- Standardizing column names
- Casting data types
- Basic data cleaning
- Removing duplicate CDC events
- Applying incremental loading
- Tracking ingestion timestamps

### Materialization

Most Bronze models are implemented as **incremental table** to avoid repeatedly scanning the entire source dataset.

### Example Tables

- stg_customers
- stg_orders
- stg_order_items
- stg_products
- stg_payments
- stg_reviews
- stg_sellers

---

# Silver Layer

### Purpose

The Silver layer transforms standardized data into business-ready datasets.

Unlike Bronze, this layer introduces business rules and combines multiple source entities into richer analytical datasets.

Typical transformations include:

- Joins across multiple entities
- Derived business attributes
- Feature engineering
- Payment enrichments
- Product enrichments
- Review metrics
- Order metrics

Silver models remain reusable and are intentionally designed to avoid report-specific logic.

### Materialization

Silver models primarily use incremental processing to minimize compute while supporting continuous data updates.

### Example Tables

- int_order_items_enriched
- int_payments_enriched
- int_reviews_enriched
- int_payment_agg
- int_review_agg

---

# Gold Layer

### Purpose

The Gold layer contains dimensional models optimized for analytics and BI consumption.

Rather than exposing normalized transactional data, the Gold layer organizes information into Facts and Dimensions following dimensional modeling principles.

This provides:

- Simpler analytical queries
- Consistent business definitions
- Faster reporting
- Reduced join complexity

### Dimensions

Dimension tables contain descriptive attributes.

Examples include:

- dim_customers
- dim_products
- dim_sellers

### Facts

Fact tables capture measurable business events.

Examples include:

- fact_orders
- fact_order_items

---

# Customer 360 Mart

The final layer combines multiple Gold models into a single business-facing analytical mart.

The Customer 360 mart provides a consolidated customer view by integrating:

- Customer demographics
- Purchase history
- Revenue metrics
- Review behaviour
- Order frequency
- Customer lifetime metrics
- Customer segmentation

Rather than requiring analysts to join multiple fact and dimension tables, the mart provides a single curated dataset optimized for analytics and reporting.

---

# Layer Responsibilities

| Layer | Primary Responsibility | Business Logic | Typical Users |
|--------|-------------------------|---------------|---------------|
| Bronze | Data ingestion & standardization | Minimal | Data Engineers |
| Silver | Business transformations & enrichment | Moderate | Analytics Engineers |
| Gold | Dimensional modeling | High | BI Developers & Analysts |
| Mart | Business reporting | Highest | Business Users |

---

# Why not transform everything in one model?

Although it is technically possible to build reports directly from raw source data, doing so introduces several challenges:

- Business logic becomes duplicated across reports.
- Pipelines become difficult to maintain.
- Debugging failures becomes significantly harder.
- Incremental processing is more difficult to implement.
- Reusing transformations across multiple downstream models becomes nearly impossible.

By separating transformations into logical layers, each model has a single responsibility, making the overall platform easier to maintain and extend.

---

# Data Flow

The complete pipeline implemented in this project follows the flow below:

```
Raw Delta Tables

        │

        ▼

Bronze Models
(Standardization)

        │

        ▼

Silver Models
(Business Transformations)

        │

        ▼

Gold Models
(Facts & Dimensions)

        │

        ▼

Customer 360 Mart

        │

        ▼

Dashboards / Analytics
```

Each downstream layer depends only on the layer immediately above it, creating a modular, maintainable, and production-inspired analytics platform.
