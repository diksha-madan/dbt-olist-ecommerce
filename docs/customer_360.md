# Customer 360 Analytics Mart

## Overview

The final deliverable of this project is a **Customer 360 Analytics Mart**.

Rather than exposing multiple fact and dimension tables to business users, the Customer 360 mart consolidates customer information, purchasing behaviour, payment details, and review metrics into a single analytical dataset.

The objective is to provide a unified view of every customer that supports reporting, customer segmentation, and business decision-making without requiring complex joins across multiple tables.

---

# Why Customer 360?

Business users often need answers to questions such as:

- Who are our highest-value customers?
- Which customers purchase most frequently?
- Who has stopped purchasing?
- What is the average order value for each customer?
- Which customers leave poor reviews?
- How many repeat customers do we have?
- What customer segments contribute the highest revenue?

Answering these questions directly from transactional tables requires joining multiple datasets every time.

The Customer 360 mart centralizes these metrics into a single curated model, making analytics significantly simpler and more consistent.

---

# Data Sources

The Customer 360 mart integrates data from multiple Gold layer models.

```
                    dim_customers
                          │
                          │
                          ▼
                    fact_orders
                          │
        ┌─────────────────┼──────────────────┐
        │                 │                  │
        ▼                 ▼                  ▼
 Payment Metrics    Review Metrics    Order Metrics
        │                 │                  │
        └─────────────────┼──────────────────┘
                          │
                          ▼
                  Customer 360 Mart
```

---

# Data Model

The mart combines descriptive customer attributes with transactional metrics.

## Customer Attributes

From `dim_customers`

- Customer ID
- City
- State
- ZIP Code

These describe who the customer is.

---

## Order Metrics

Derived from `fact_orders`

- Total Orders
- First Order Date
- Last Order Date
- Customer Lifespan
- Average Order Value

These describe purchasing behaviour.

---

## Revenue Metrics

Calculated from payment information.

Examples include:

- Total Revenue
- Average Order Value

These measure customer value.

---

## Review Metrics

Derived from review data.

Examples include:

- Average Review Score

This helps measure customer satisfaction.

---

## Customer Segmentation

Business rules classify customers into segments.

| Segment | Logic |
|----------|-------|
| One-Time | Only one completed order |
| New Repeat | Multiple orders within 30 days |
| Established | Multiple orders within 180 days |
| Loyal | Customer relationship exceeds 180 days |

These segments enable downstream marketing and retention analysis.

---

# Customer Metrics

The mart calculates several key business metrics.

| Metric | Description |
|----------|-------------|
| Total Orders | Number of orders placed by the customer |
| Total Revenue | Total amount spent |
| Average Order Value | Average revenue per order |
| Average Review Score | Mean customer review rating |
| First Order Date | Customer acquisition date |
| Last Order Date | Most recent purchase |
| Customer Lifespan | Number of days between first and latest order |
| Customer Segment | Behaviour-based classification |

---

# Business Questions Answered

The Customer 360 mart supports several common analytical use cases.

### Customer Acquisition

- How many new customers were acquired?
- When was each customer acquired?

---

### Customer Retention

- Which customers returned?
- Which customers purchased only once?
- Which customers have become loyal?

---

### Revenue Analysis

- Which customers generate the highest revenue?
- What is the average order value?

---

### Customer Satisfaction

- Which customers consistently leave poor reviews?
- Is customer satisfaction correlated with repeat purchases?

---

### Marketing

- Identify high-value customers.
- Identify repeat purchasers.
- Build customer segments for targeted campaigns.

---

# Why Build a Mart?

Instead of requiring analysts to write queries such as:

```
Customers

JOIN Orders

JOIN Payments

JOIN Reviews

JOIN Aggregates
```

they simply query

```
mart_customer_360
```

This provides:

- Simpler SQL
- Faster dashboard development
- Consistent business metrics
- Reduced duplication of business logic

---

# Refresh Strategy

Unlike transactional models, the Customer 360 mart is rebuilt using a **Full Refresh**.

## Why?

Customer-level metrics are derived from multiple upstream aggregates.

For example, if:

- a payment changes,
- a review is updated,
- an order status changes,

then customer-level metrics such as:

- Total Revenue
- Average Review Score
- Customer Lifespan
- Customer Segment

may all require recalculation.

A full rebuild guarantees consistency across all derived metrics.

---

# Business Value

The Customer 360 mart provides a business-friendly analytical layer that bridges the gap between operational data and decision-making.

Business users no longer need to understand the underlying warehouse structure.

Instead, they receive a single trusted dataset capable of supporting:

- Executive dashboards
- Customer segmentation
- Revenue reporting
- Marketing campaigns
- Customer retention analysis
- Business intelligence initiatives

---

# Architecture Position

```
                Raw Delta Tables
                        │
                        ▼
                 Bronze Models
                        │
                        ▼
                 Silver Models
                        │
                        ▼
          Gold Facts & Dimensions
                        │
                        ▼
           Customer 360 Analytics Mart
                        │
                        ▼
              Dashboards & BI Reports
```

---

# Future Enhancements

Potential improvements include:

- RFM (Recency, Frequency, Monetary) scoring
- Customer Lifetime Value (CLV) prediction
- Churn prediction
- Product affinity analysis
- Recommendation features
- Customer cohorts
- Machine learning feature store integration

---

# Key Takeaways

The Customer 360 mart represents the final business-facing layer of the analytics platform.

Rather than exposing normalized operational tables, it delivers a curated analytical dataset that combines customer, order, payment, and review information into a single trusted source.

By consolidating business metrics and customer attributes into one model, the mart simplifies reporting, promotes metric consistency, and enables business users to answer common customer analytics questions without complex SQL joins.
