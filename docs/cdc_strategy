# Change Data Capture (CDC) & Incremental Processing

## Overview

One of the primary goals of this project was to simulate how modern data platforms process continuously changing datasets without rebuilding the entire warehouse on every execution.

Instead of performing full refreshes, the platform implements **Change Data Capture (CDC)** and **incremental processing** to identify and process only newly arrived or modified records. This significantly reduces compute, improves execution time, and better reflects production data engineering practices.

Although the source data is based on the Olist dataset, additional PySpark notebooks were developed to simulate real-world data changes, including inserts and updates, enabling realistic incremental pipeline development.

---

# What is Change Data Capture (CDC)?

Change Data Capture (CDC) is the process of identifying changes made to source systems and propagating only those changes to downstream datasets.

Instead of reprocessing every record:

```
1 Billion Records

↓

Process everything
```

CDC processes only the changed records.

```
1 Billion Records

↓

2,500 Changed Records

↓

Process only those records
```

This dramatically improves scalability and reduces warehouse compute.

---

# CDC Simulation

Since the source dataset is static, CDC was simulated using PySpark notebooks.

The simulation performs two types of operations:

- Inserts
- Updates

Each modified record receives an updated ingestion timestamp (`record_updated_at`), allowing downstream dbt models to identify new or modified data.

```
Raw Table

Customer A

Customer B

Customer C

↓

Update Customer B

↓

record_updated_at updated

↓

dbt Incremental Model processes only Customer B
```

---

# Incremental Processing

Most Bronze, Silver, and Gold models are materialized as incremental tables.

Instead of rebuilding an entire table during every run:

```
Raw

↓

Rebuild Entire Table
```

only recently modified records are processed.

```
Raw

↓

Incremental Filter

↓

Changed Records Only

↓

Target Table
```

This significantly improves performance for large datasets.

---

# Incremental Strategies

Not every table behaves the same way.

Some entities receive updates throughout their lifecycle, while others are effectively immutable after insertion.

For this reason, multiple incremental strategies were implemented instead of applying a single strategy across the entire warehouse.

---

# Merge Strategy

Used for:

- Customers
- Orders

These datasets contain records that can legitimately change over time.

Examples include:

- Order status progression
- Updated delivery dates
- Customer attribute corrections

The merge strategy updates existing records while inserting newly arrived ones.

```
Incoming Record

↓

Already Exists?

      │

 ┌────┴────┐

 │         │

Yes       No

 │         │

Update   Insert
```

### Advantages

- Preserves current state
- Supports mutable entities
- No duplicate business keys
- Suitable for slowly changing operational data

### Considerations

- Merge performs row-level matching between source and target.
- Large merge operations can become computationally expensive if tables are not partitioned appropriately.

---

# Insert Overwrite Strategy

Used for:

- Payments
- Order Items
- Reviews

These datasets are transactional and generally immutable after creation.

Rather than performing row-level comparisons, the project partitions these tables using `partition_date`.

During execution:

```
Incoming Data

↓

Affected Partitions

↓

Delete Partition

↓

Rewrite Partition
```

Within each partition, duplicate records are removed using:

```
ROW_NUMBER()

PARTITION BY Business Key

ORDER BY record_updated_at DESC
```

Only the latest version of each business key is retained.

### Advantages

- Efficient partition rewrites
- Eliminates expensive row-level merge operations
- Naturally supports deduplication
- Better suited for append-heavy transactional datasets

### Considerations

- Entire partitions are rewritten.
- Performance depends on selecting an appropriate partitioning column.

---

# Full Refresh

Used for:

- Customer 360 Mart

The mart contains aggregated business metrics derived from multiple upstream tables.

Even if only a small number of source records change, aggregate values such as:

- revenue
- average review score
- order count
- customer lifetime

may all require recalculation.

For this reason, rebuilding the mart ensures consistent business metrics.

```
Gold Models

↓

Recompute Aggregations

↓

Customer 360
```

---

# Late Arriving Data

One of the challenges encountered during development was handling late-arriving records.

A simple watermark approach:

```
record_updated_at >
MAX(record_updated_at)
```

can permanently miss delayed records that arrive with older timestamps.

To improve resilience, the project uses a configurable **lookback window** when processing incremental data.

```
Today

↓

Read Previous N Days

↓

Deduplicate

↓

Overwrite Latest Partition
```

This approach allows delayed records to be captured without requiring frequent full refreshes.

---

# Deduplication

Incremental pipelines can reprocess the same business entity multiple times.

To guarantee a single current version of each business record, duplicate rows are removed using window functions.

Example:

```
ROW_NUMBER()

PARTITION BY Business Key

ORDER BY record_updated_at DESC
```

Only

```
WHERE rn = 1
```

is retained.

This makes the pipeline idempotent, meaning rerunning the same incremental load produces consistent results.

---

# Partitioning Strategy

Tables using `insert_overwrite` are partitioned by

```
partition_date = CAST(record_updated_at AS DATE)
```

Partitioning provides several advantages:

- limits rewritten data
- improves query pruning
- reduces storage scans
- minimizes overwrite cost

Instead of rewriting an entire table:

```
Table

↓

Single Partition

↓

Rewrite Only One Partition
```

---

# Incremental Strategy Summary

| Layer | Strategy | Reason |
|--------|----------|--------|
| Bronze Customers | Merge | Customer records can change |
| Bronze Orders | Merge | Order lifecycle changes |
| Bronze Payments | Insert Overwrite | Immutable transactions |
| Bronze Order Items | Insert Overwrite | Immutable line items |
| Bronze Reviews | Insert Overwrite | Immutable review events |
| Silver | Same as upstream model | Preserve source characteristics |
| Gold Facts & Dimensions | Incremental | Efficient downstream processing |
| Customer 360 Mart | Full Refresh | Aggregated metrics require recalculation |

---

# Lessons Learned

A key takeaway from this project is that there is no universally correct incremental strategy.

Selecting the appropriate approach depends on several factors:

- Is the data mutable or immutable?
- Are updates frequent?
- Can late-arriving records occur?
- Is deduplication required?
- Is the table aggregated?
- What is the expected data volume?

Rather than applying a single strategy across every table, this project demonstrates how different incremental techniques can be combined to balance correctness, performance, and operational simplicity.
