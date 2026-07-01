# Performance Optimization

## Overview

A key objective of this project was to design an analytics platform that remains efficient as data volumes grow.

Rather than focusing only on correctness, the implementation also considers execution time, compute cost, storage efficiency, and long-term maintainability.

Several optimization techniques were incorporated throughout the project to reduce unnecessary data processing while maintaining reliable results.

---

# Performance Strategy

The platform combines multiple optimization techniques.

```
                 Raw Data

                     │

                     ▼

        Incremental Processing

                     │

                     ▼

        Partition Pruning

                     │

                     ▼

          Deduplication

                     │

                     ▼

     Efficient Fact & Dimension Models

                     │

                     ▼

      Customer 360 Analytics Mart
```

---

# 1. Incremental Processing

## Problem

Rebuilding every table during every execution is computationally expensive.

As datasets grow, full refreshes become slower and consume significantly more warehouse resources.

---

## Solution

Most models were implemented using dbt incremental materializations.

Instead of rebuilding the complete dataset,

```
1,000,000 rows

↓

Process everything
```

only recently changed records are processed.

```
1,000,000 rows

↓

2,000 changed rows

↓

Process only changes
```

---

## Benefits

- Reduced execution time
- Lower compute cost
- Better scalability
- Faster deployments

---

# 2. Selecting the Appropriate Incremental Strategy

Not every table follows the same update pattern.

Instead of forcing a single incremental strategy across every dataset, strategies were selected according to data characteristics.

| Strategy | Used For | Reason |
|-----------|----------|--------|
| Merge | Customers, Orders | Mutable business entities |
| Insert Overwrite | Payments, Order Items, Reviews | Immutable transactional data |
| Full Refresh | Customer 360 Mart | Aggregated metrics |

Choosing the appropriate strategy reduces unnecessary processing while maintaining data correctness.

---

# Model Strategy Matrix

The project does not apply a single materialization or incremental strategy across all models. Instead, each model was designed based on the characteristics of the underlying data, balancing correctness, performance, and maintainability.

| Layer | Model | Materialization | Incremental Strategy | Partitioned | Reason |
|-------|-------|-----------------|----------------------|-------------|--------|
| Bronze | stg_customers | Incremental | Merge | ❌ | Customer records can receive updates. Merge preserves the latest customer state. |
| Bronze | stg_orders | Incremental | Merge | ❌ | Orders progress through multiple lifecycle stages (processing → approved → shipped → delivered). |
| Bronze | stg_payments | Incremental | Insert Overwrite | ✅ | Payment transactions are immutable. Rewriting affected partitions is more efficient than row-level matching. |
| Bronze | stg_order_items | Incremental | Insert Overwrite | ✅ | Order items are append-heavy transactional data and rarely change after creation. |
| Bronze | stg_reviews | Incremental | Insert Overwrite | ✅ | Reviews are effectively immutable once submitted. |
| Bronze | stg_products | Incremental | Merge | ❌ | Product data is treated as reference data with only new records expected during simulation. |
| Bronze | stg_sellers | Incremental | Merge | ❌ | Seller records are relatively static reference data. |
| Intermediate | int_payments_enriched | Incremental | Insert Overwrite | ✅ | Preserves the strategy of the upstream transactional dataset while adding business logic. |
| Intermediate | int_order_items_enriched | Incremental | Insert Overwrite | ✅ | Maintains partition-level processing while enriching transactional data. |
| Intermediate | int_reviews_enriched | Incremental | Insert Overwrite | ✅ | Mirrors upstream review processing with additional derived metrics. |
| Intermediate | int_payment_agg | Incremental | Merge | ❌ | Aggregations may change when additional payment records arrive for an order. |
| Intermediate | int_review_agg | Incremental | Merge | ❌ | Review aggregates can change as new reviews are received. |
| Gold | dim_customers | Incremental | Merge | ❌ | Customer attributes may change and should always reflect the latest state. |
| Gold | dim_products | Incremental | Merge | ❌ | Product dimension behaves as slowly changing reference data in this project. |
| Gold | dim_sellers | Incremental | Merge | ❌ | Seller dimension is relatively static. |
| Gold | fact_orders | Incremental | Merge | ❌ | Order facts evolve as payment, review, and delivery information changes. |
| Gold | fact_order_items | Incremental | Insert Overwrite | ✅ | Line-item level transactions are immutable and benefit from partition rewrites. |
| Mart | mart_customer_360 | Table | Full Refresh | ❌ | Customer-level metrics depend on multiple upstream aggregates, making a full rebuild simpler and more reliable. |

---

# Why Not Use One Strategy Everywhere?

One of the key design decisions in this project was recognising that different datasets exhibit different behaviours throughout their lifecycle.

| Data Behaviour | Preferred Strategy |
|---------------|--------------------|
| Records frequently updated | Merge |
| Immutable transactional records | Insert Overwrite |
| Reference data with only new records | Append |
| Aggregated business metrics | Full Refresh |

Selecting the appropriate strategy based on data behaviour allows the platform to balance performance, correctness, and implementation complexity rather than applying a one-size-fits-all solution.

--- 
# 3. Partitioning

Tables using Insert Overwrite are partitioned using

```
partition_date = CAST(record_updated_at AS DATE)
```

Instead of rewriting an entire table,

```
Entire Table

↓

Overwrite
```

only affected partitions are rewritten.

```
Table

↓

Partition

↓

Rewrite Only One Partition
```

---

## Benefits

- Reduced storage scans
- Faster writes
- Improved query pruning
- Lower compute cost

---

# 4. Partition Pruning

Partitioning not only improves writes but also improves reads.

When queries filter recent data,

```
WHERE partition_date = '2026-06-01'
```

Databricks reads only the required partitions instead of scanning the complete table.

This significantly reduces I/O and execution time.

---

# 5. Deduplication

Incremental processing intentionally reprocesses recent records through a configurable lookback window.

To prevent duplicate business entities, window functions are used.

```sql
ROW_NUMBER()

PARTITION BY Business Key

ORDER BY record_updated_at DESC
```

Only the latest version is retained.

---

## Benefits

- Idempotent processing
- Consistent analytical results
- Safe repeated execution

---

# 6. Layered Transformations

Instead of embedding every transformation inside a single SQL model, business logic is distributed across:

- Bronze
- Silver
- Gold
- Mart

Benefits include:

- Smaller SQL models
- Easier debugging
- Better model reuse
- Independent testing

This modular approach also reduces development effort when business logic changes.

---

# 7. Dimensional Modeling

Analytical reporting is optimized through Fact and Dimension tables.

Rather than repeatedly joining raw operational tables,

```
Dashboard

↓

Fact Table

+

Dimension Tables
```

provides a simpler analytical model.

---

## Benefits

- Reduced join complexity
- Faster analytical queries
- Consistent business definitions
- Improved report performance

---

# 8. Full Refresh Only Where Necessary

Not every model benefits from incremental processing.

The Customer 360 mart contains aggregated metrics including:

- Total Revenue
- Average Review Score
- Customer Lifetime
- Order Count

Since these metrics may change whenever upstream data changes, the mart is rebuilt during execution.

Although this requires additional compute, it guarantees analytical consistency.

This demonstrates that optimization should never come at the expense of correctness.

---

# 9. Automated Testing

Data quality issues often lead to expensive downstream debugging.

The project performs validation during dbt execution using:

- Unique tests
- Not Null tests
- Relationship tests
- Accepted Values tests

Early validation reduces the operational cost of incorrect analytical data.

---

# 10. Automated Deployments

Production deployments are automated through GitHub Actions and dbt Cloud.

Automation reduces operational overhead by:

- Removing manual deployment steps
- Providing repeatable execution
- Reducing deployment errors

Although this is primarily an operational optimization rather than a query optimization, it significantly improves engineering productivity.

---

# Performance Comparison

The choice of incremental strategy directly impacts the amount of data processed during each pipeline execution.

Consider a table containing **100 million records**, where only **2 million records** have changed.

```
                 100 Million Records
                         │
                         ▼
              Changed Records (2 Million)
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
     Merge                        Insert Overwrite
(Row-level Matching)        (Rewrite Changed Partition)
        │                                 │
        ▼                                 ▼
Updates Existing Rows        Deletes & Rewrites
+ Inserts New Rows           Only Affected Partitions
```

### Merge

- Performs row-level matching between the source and target tables.
- Only changed records are updated or inserted.
- Best suited for mutable datasets such as Customers and Orders.
- More compute is spent comparing source and target records.

### Insert Overwrite

- Identifies affected partitions.
- Deletes only those partitions.
- Rewrites the partition with the latest deduplicated data.
- Avoids expensive row-level comparisons.
- Best suited for immutable transactional datasets such as Payments, Reviews, and Order Items.

The most appropriate strategy depends on the characteristics of the dataset rather than a single performance metric. Merge minimizes rewritten data, while Insert Overwrite minimizes row-level comparison costs by operating at the partition level.

--- 

# Performance Summary

| Optimization | Benefit |
|--------------|---------|
| Incremental Models | Reduced compute |
| Merge Strategy | Efficient mutable updates |
| Insert Overwrite | Efficient partition rewrites |
| Partitioning | Faster reads and writes |
| Partition Pruning | Reduced storage scans |
| Deduplication | Idempotent processing |
| Medallion Architecture | Modular transformations |
| Dimensional Modeling | Faster analytical queries |
| Automated Testing | Earlier error detection |
| CI/CD | Faster and more reliable deployments |

---

# Trade-offs

Performance optimization often involves balancing execution speed, implementation complexity, and analytical correctness.

Examples from this project include:

| Decision | Benefit | Trade-off |
|----------|---------|-----------|
| Incremental Models | Faster execution | More implementation complexity |
| Merge | Supports updates | Higher compute due to row matching |
| Insert Overwrite | Simpler partition rewrites | Entire partition rewritten |
| Lookback Window | Captures late-arriving data | Small amount of reprocessing |
| Full Refresh for Customer 360 | Consistent aggregates | Additional compute |

Rather than maximizing performance at every stage, the platform prioritizes selecting the most appropriate optimization technique based on the characteristics of each dataset.

---

# Key Takeaways

Performance optimization is not achieved through a single technique.

Instead, it is the result of combining multiple complementary practices:

- Process only recently changed data.
- Select incremental strategies based on data behaviour.
- Partition large transactional tables.
- Deduplicate incremental loads.
- Use dimensional modeling for analytics.
- Separate transformations into modular layers.
- Automate testing and deployment.

Collectively, these optimizations improve scalability, reduce warehouse costs, and produce a maintainable analytics platform capable of supporting larger datasets and more frequent deployments.

