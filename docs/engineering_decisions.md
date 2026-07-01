# Engineering Decisions

## Overview

Building a production-ready analytics platform involves much more than writing SQL transformations. Every architectural decision influences scalability, maintainability, performance, and operational complexity.

Rather than applying the same design pattern throughout the project, each component was evaluated independently based on data characteristics, expected workloads, and long-term maintainability.

This document captures the major engineering decisions made during the implementation of this project, the alternatives that were considered, and the reasoning behind the final design choices.

---

# Decision 1: Medallion Architecture

## Problem

As analytical platforms grow, embedding ingestion, business logic, and reporting transformations into a single layer becomes difficult to maintain.

Changes in one business process often impact unrelated pipelines, making debugging and development increasingly complex.

---

## Alternatives Considered

| Option | Pros | Cons |
|---------|------|------|
| Single transformation layer | Simple for small projects | Difficult to scale and maintain |
| Medallion Architecture | Modular, reusable, scalable | Requires additional models |

---

## Final Decision

Adopt a Medallion Architecture consisting of:

- Bronze
- Silver
- Gold
- Analytics Mart

---

## Why?

The layered architecture separates concerns, improves maintainability, enables incremental processing, and allows each layer to evolve independently.

---

# Decision 2: Incremental Processing

## Problem

Rebuilding every model during every execution is computationally expensive and does not scale as datasets grow.

---

## Alternatives Considered

| Option | Pros | Cons |
|---------|------|------|
| Full Refresh | Simple | High compute cost |
| Incremental Models | Faster execution | Additional implementation complexity |

---

## Final Decision

Use incremental processing for Bronze, Silver, and Gold models whenever appropriate.

Retain full refresh only for analytical marts containing aggregated metrics.

---

## Why?

Incremental models reduce compute by processing only newly arrived or modified records while preserving correctness.

---

# Decision 3: Multiple Incremental Strategies

## Problem

Different datasets behave differently.

Some records continue to change over time, while others become immutable after creation.

Using a single incremental strategy for every table would either introduce unnecessary compute or fail to capture updates correctly.

---

## Alternatives Considered

| Strategy | Suitable For | Limitations |
|----------|--------------|-------------|
| Append | Append-only datasets | Cannot update existing records |
| Merge | Mutable datasets | Row-level matching is expensive |
| Insert Overwrite | Immutable partitioned datasets | Rewrites entire partitions |

---

## Final Decision

Different strategies were selected based on table characteristics.

| Dataset | Strategy |
|----------|----------|
| Customers | Merge |
| Orders | Merge |
| Payments | Insert Overwrite |
| Order Items | Insert Overwrite |
| Reviews | Insert Overwrite |
| Customer 360 | Full Refresh |

---

## Why?

Choosing the strategy based on data behavior improves both correctness and performance.

---

# Decision 4: Insert Overwrite for Transactional Tables

## Problem

Transactional datasets such as Payments and Order Items receive a large number of inserts but relatively few updates.

Performing row-level merge operations introduces unnecessary overhead.

---

## Alternatives Considered

### Merge

Pros

- Updates individual rows
- Supports mutable records

Cons

- Expensive row matching
- Additional compute

---

### Insert Overwrite

Pros

- Partition rewrite
- Simpler implementation
- Efficient for immutable datasets

Cons

- Rewrites affected partitions

---

## Final Decision

Use Insert Overwrite with partitioning and deduplication.

---

## Why?

Transactional datasets are effectively immutable.

Rewriting only affected partitions avoids row-level merge costs while maintaining data consistency.

---

# Decision 5: Lookback Window

## Problem

Late-arriving records may be missed when incremental filters rely exclusively on the maximum processed timestamp.

---

## Alternatives Considered

| Option | Pros | Cons |
|---------|------|------|
| MAX(record_updated_at) | Fast | Can miss delayed records |
| Current Timestamp | Simple | Not deterministic |
| Lookback Window | Handles delayed ingestion | Small amount of data reprocessing |

---

## Final Decision

Implement a configurable 3-day lookback window.

---

## Why?

The lookback window improves resilience to delayed ingestion while only reprocessing a small amount of recent data.

Combined with deduplication, repeated processing remains safe.

---

# Decision 6: Partitioning

## Problem

Insert Overwrite rewrites partitions.

Poor partition selection can unnecessarily increase compute.

---

## Alternatives Considered

| Partition Column | Evaluation |
|------------------|------------|
| Business Key | Poor partition pruning |
| Event Date | Good analytical partition |
| record_updated_at (Date) | Best alignment with CDC |

---

## Final Decision

Partition transactional datasets using

```
partition_date = CAST(record_updated_at AS DATE)
```

---

## Why?

Since incremental processing is driven by record updates, partitioning on the ingestion date minimizes rewritten data and improves query pruning.

---

# Decision 7: Deduplication

## Problem

A lookback window intentionally reprocesses recent data.

Without deduplication, duplicate business records could appear after repeated executions.

---

## Final Decision

Deduplicate using

```sql
ROW_NUMBER()

PARTITION BY Business Key

ORDER BY record_updated_at DESC
```

keeping only

```sql
WHERE rn = 1
```

---

## Why?

This makes incremental processing idempotent.

Repeated executions produce identical results without duplicate business entities.

---

# Decision 8: Full Refresh for Customer 360

## Problem

The Customer 360 mart contains aggregated metrics derived from multiple upstream datasets.

Incrementally updating these aggregates would significantly increase implementation complexity.

---

## Alternatives Considered

| Option | Pros | Cons |
|---------|------|------|
| Incremental | Lower compute | Complex dependency tracking |
| Full Refresh | Simpler and consistent | Higher compute |

---

## Final Decision

Perform a full refresh.

---

## Why?

The mart is relatively small compared to raw transactional datasets.

Recomputing aggregate metrics guarantees consistency while keeping implementation straightforward.

---

# Decision 9: Data Quality

## Problem

Incorrect analytical data often originates much earlier in the pipeline.

Waiting until dashboard validation makes debugging difficult.

---

## Final Decision

Implement data quality checks directly within dbt.

Tests include:

- Unique
- Not Null
- Relationships
- Accepted Values

---

## Why?

Early validation prevents invalid data from propagating into downstream analytical models.

---

# Decision 10: CI/CD

## Problem

Manual deployments increase the likelihood of human error and inconsistent production releases.

---

## Final Decision

Implement automated deployment using:

- GitHub Actions
- dbt Cloud Deployment Jobs

---

## Why?

Every merge into the main branch automatically triggers a production deployment, providing a repeatable and auditable release process.

---

# Key Takeaways

Several themes influenced the design of this project.

- Separate responsibilities into independent layers.
- Choose incremental strategies based on data characteristics rather than using a single approach everywhere.
- Prefer deterministic and idempotent processing.
- Validate data quality as early as possible.
- Automate deployments to reduce manual intervention.
- Optimize for maintainability before optimization for complexity.

Many of these decisions represent trade-offs rather than universally correct answers. The selected approaches were chosen based on the characteristics of the datasets, the scale of the project, and production-inspired engineering practices.
