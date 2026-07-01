# 🚀 End-to-End Analytics Engineering Platform using dbt & Databricks

![dbt](https://img.shields.io/badge/dbt-Analytics%20Engineering-orange)
![Databricks](https://img.shields.io/badge/Databricks-Delta%20Lake-red)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-blue)
![Delta Lake](https://img.shields.io/badge/Delta-Lake-green)
![Python](https://img.shields.io/badge/Python-3.11-blue)
![SQL](https://img.shields.io/badge/SQL-ANSI-lightgrey)

---

## 📖 Project Overview

This project demonstrates the design and implementation of a **production-inspired analytics engineering platform** built using **dbt**, **Databricks**, **Delta Lake**, and **GitHub Actions**.

Instead of simply transforming data, the project focuses on solving real engineering problems encountered in modern data platforms:

- Designing a scalable **Medallion Architecture**
- Building incremental data pipelines using dbt
- Simulating Change Data Capture (CDC)
- Handling late-arriving data
- Implementing different incremental strategies based on data characteristics
- Building production-ready Fact and Dimension models
- Creating an analytical Customer 360 mart
- Enforcing data quality through dbt tests
- Automating deployments using GitHub Actions and dbt Cloud

The project is intentionally designed to resemble a real analytics engineering repository rather than a tutorial, emphasizing architecture, maintainability, testing, deployment, and engineering decision-making.

---

# 🎯 Project Objectives

The primary objective of this project was not just to build dbt models, but to understand how modern analytics platforms are designed in production environments.

Key goals included:

- Designing a modular Medallion Architecture
- Simulating real-world Change Data Capture (CDC)
- Building idempotent incremental pipelines
- Comparing different incremental strategies
- Implementing data quality testing
- Building reusable dbt macros
- Understanding performance and cost trade-offs
- Automating deployments using CI/CD
- Documenting engineering decisions and trade-offs

---

# 🏗️ Overall Architecture

```
                          +-----------------------------+
                          |     CDC Simulation          |
                          |  PySpark + Delta Tables     |
                          +-------------+---------------+
                                        |
                                        |
                                        ▼
                      +----------------------------------+
                      |        Bronze Layer              |
                      |   Raw Cleaning & Standardization |
                      +---------------+------------------+
                                      |
                                      |
                                      ▼
                      +----------------------------------+
                      |        Silver Layer              |
                      | Business Logic & Enrichment      |
                      +---------------+------------------+
                                      |
                                      |
                                      ▼
                      +----------------------------------+
                      |         Gold Layer               |
                      | Facts, Dimensions & Snapshots    |
                      +---------------+------------------+
                                      |
                                      |
                                      ▼
                      +----------------------------------+
                      |     Customer 360 Analytics       |
                      +----------------------------------+
```

---

# 🛠️ Technology Stack

| Category | Technology |
|-----------|------------|
| Data Warehouse | Databricks |
| Storage Format | Delta Lake |
| Transformation Framework | dbt Cloud |
| Language | SQL, Python |
| Data Processing | PySpark |
| Version Control | GitHub |
| CI/CD | GitHub Actions |
| Testing | dbt Generic Tests |
| Data Modeling | Kimball Star Schema |
| Architecture | Medallion Architecture |

---

# ✨ Key Features

✔ Medallion Architecture (Bronze → Silver → Gold)

✔ Incremental dbt Models

✔ Custom Incremental Macros

✔ CDC Simulation using PySpark

✔ Fact & Dimension Modeling

✔ Customer 360 Mart

✔ Slowly Changing Dimension (SCD Type 2) Snapshots

✔ Data Quality Testing

✔ GitHub Actions CI/CD

✔ Automated dbt Cloud Deployments

✔ Production-inspired Folder Structure

✔ Performance Optimization using Incremental Processing

✔ Engineering Documentation

---

# 📂 Repository Structure

```
.
├── models/
│   ├── staging/
│   ├── intermediate/
│   ├── dimensions/
│   ├── facts/
│   ├── marts/
│   └── audit/
│
├── macros/
│
├── snapshots/
│
├── tests/
│
├── seeds/
│
├── analyses/
│
├── docs/
│
├── .github/
│   └── workflows/
│
└── README.md
```

Each layer has a dedicated responsibility, making the project easier to maintain, test, and scale.

# 📚 Documentation

This repository includes detailed engineering documentation for the major architectural components.

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | System architecture and design principles |
| [CDC & Incremental Loading](docs/cdc_strategy.md) | Incremental strategies, partitioning, late-arriving data |
| [Engineering Decisions](docs/engineering_decisions.md) | Design trade-offs and rationale |
| [CI/CD](docs/cicd.md) | GitHub Actions and dbt Cloud deployment |
| [Challenges](docs/challenges.md) | Problems encountered and solutions |
| [Performance Optimization](docs/performance.md) | Incremental processing and cost optimization |
