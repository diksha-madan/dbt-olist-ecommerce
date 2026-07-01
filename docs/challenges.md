# Challenges & Lessons Learned

## Overview

Building a production-inspired analytics platform involved significantly more than writing SQL transformations.

Several implementation challenges required architectural decisions, experimentation with alternative approaches, and a deeper understanding of how dbt, Delta Lake, and Databricks execute incremental workloads.

This document summarizes the major engineering challenges encountered during development, the alternatives that were evaluated, and the final solutions adopted.

---

# Challenge 1: Designing a Robust CDC Strategy

## Problem

The original Olist dataset is static.

Without continuously changing source data, it is impossible to design and validate incremental pipelines that behave like production systems.

---

## Options Considered

- Full refresh every run
- Manually editing source tables
- Simulate CDC using Python
- Simulate CDC using PySpark and Delta Lake

---

## Final Solution

A dedicated PySpark notebook was developed to simulate Change Data Capture by performing:

- Record inserts
- Record updates

Each modified record receives an updated `record_updated_at` timestamp, allowing dbt incremental models to process only recently changed data.

---

## Lessons Learned

Incremental pipelines should always be validated using realistic change patterns rather than static datasets.

---

# Challenge 2: Selecting the Correct Incremental Strategy

## Problem

Initially, it was tempting to use a single incremental strategy across every model.

However, different datasets exhibited very different update patterns.

For example:

- Customers can receive attribute updates.
- Orders change status throughout their lifecycle.
- Payments rarely change after creation.
- Reviews are effectively immutable.

Applying the same strategy everywhere would either introduce unnecessary compute or fail to capture updates correctly.

---

## Alternatives Evaluated

### Append

Pros

- Very fast

Cons

- Cannot update existing records

---

### Merge

Pros

- Handles mutable records

Cons

- Performs row-level matching
- More computationally expensive

---

### Insert Overwrite

Pros

- Efficient partition rewrites
- Simpler implementation for immutable datasets

Cons

- Requires partitioning
- Rewrites entire partitions

---

## Final Solution

Different strategies were selected based on dataset characteristics.

| Dataset | Strategy |
|----------|----------|
| Customers | Merge |
| Orders | Merge |
| Payments | Insert Overwrite |
| Order Items | Insert Overwrite |
| Reviews | Insert Overwrite |
| Customer 360 | Full Refresh |

---

## Lessons Learned

Incremental strategy should be driven by data behaviour rather than applying a single approach across the warehouse.

---

# Challenge 3: Handling Late-Arriving Data

## Problem

A straightforward watermark approach using

```sql
record_updated_at >
MAX(record_updated_at)
```

can permanently miss records that arrive late with older timestamps.

This issue becomes increasingly important in production systems where ingestion delays are common.

---

## Alternatives Evaluated

- Watermark using MAX()
- Current timestamp
- Lookback window

---

## Final Solution

A configurable **3-day lookback window** was implemented.

Instead of reading only records newer than the latest processed timestamp, the pipeline reprocesses the most recent three days of data and removes duplicates.

---

## Lessons Learned

Reprocessing a small amount of recent data is often preferable to risking permanent data loss.

---

# Challenge 4: Databricks Incremental Query Limitation

## Problem

The original incremental filter relied on:

```sql
WHERE record_updated_at >
(
SELECT MAX(record_updated_at)
FROM {{ this }}
)
```

During implementation, Databricks produced an error similar to:

```
INVALID_WHERE_CONDITION
```

because aggregate scalar subqueries were not supported in that execution context.

---

## Alternatives Evaluated

- Scalar subqueries
- dbt run_query()
- Merge
- Insert Overwrite
- Lookback windows

---

## Final Solution

Transactional datasets were redesigned using:

- Insert Overwrite
- Partitioning
- Deduplication
- Lookback window

This removed the dependency on unsupported query patterns while maintaining incremental behaviour.

---

## Lessons Learned

Execution engine behaviour can directly influence architectural decisions.

Understanding platform-specific limitations is as important as understanding dbt itself.

---

# Challenge 5: Designing Idempotent Incremental Loads

## Problem

The lookback window intentionally reprocesses recent records.

Without additional safeguards, repeated executions could create duplicate business records.

---

## Final Solution

Window functions were used for deduplication.

```sql
ROW_NUMBER()

PARTITION BY Business Key

ORDER BY record_updated_at DESC
```

Only

```sql
WHERE rn = 1
```

is retained.

---

## Lessons Learned

Idempotency is a critical property of production data pipelines.

Pipelines should produce identical outputs even when the same data is processed multiple times.

---

# Challenge 6: Choosing a Partitioning Strategy

## Problem

Insert Overwrite rewrites partitions.

Selecting an inappropriate partition column would unnecessarily increase compute costs.

---

## Alternatives Evaluated

- Business keys
- Event dates
- record_updated_at

---

## Final Solution

Transactional tables were partitioned using

```
CAST(record_updated_at AS DATE)
```

which aligns naturally with incremental processing and minimizes partition rewrites.

---

## Lessons Learned

Partitioning should align with access patterns rather than arbitrary business columns.

---

# Challenge 7: Maintaining Referential Integrity During CDC Simulation

## Problem

Synthetic inserts generated child records whose parent records did not yet exist.

Relationship tests failed because foreign keys referenced missing records.

---

## Final Solution

The data generation notebook was redesigned so related entities are inserted together.

For example:

- Orders
- Order Items
- Payments
- Reviews

are generated using the same newly created order identifiers.

This preserves referential integrity throughout the warehouse.

---

## Lessons Learned

Synthetic data generation should preserve the same integrity constraints expected from production systems.

---

# Challenge 8: Automating Production Deployments

## Problem

Manually triggering dbt Cloud jobs after every change is repetitive and increases the possibility of inconsistent deployments.

---

## Final Solution

GitHub Actions was integrated with the dbt Cloud Administrative API.

Production deployments are automatically triggered after changes are merged into the main branch.

Sensitive credentials are securely managed using GitHub Secrets.

---

## Lessons Learned

Automating deployments improves consistency, repeatability, and operational efficiency while reducing manual intervention.

---

# Overall Lessons

This project reinforced several important engineering principles.

- Data architecture should be driven by data characteristics.
- Incremental processing requires careful consideration of late-arriving data and idempotency.
- Platform-specific limitations can significantly influence implementation choices.
- Data quality should be validated throughout the pipeline rather than only at the reporting layer.
- Automation is an essential part of modern analytics engineering.
- Engineering decisions are often trade-offs rather than universally correct answers.

Many of the final design choices evolved through experimentation, debugging, and evaluating multiple alternatives rather than selecting the first working solution.
