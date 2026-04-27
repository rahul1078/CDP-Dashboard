# CDP-Dashboard
Power BI dashboard analyzing CDP employee performance across daily, weekly, and monthly views. Tracks opportunities, quotes, and policy conversions with metrics like conversion rates and time to quote/policy. Built using SQL for data transformation and a star schema based model for analysis.
# CDP Performance Dashboard (Daily / Weekly / Monthly)

## Problem

Track and evaluate the performance of **CDP (College Development Program) employees** by monitoring their ability to generate and convert sales opportunities.

The dashboard answers:

* Who is generating the most opportunities?
* How efficiently are opportunities converted to quotes and policies?
* How does performance vary across daily, weekly, and monthly views?

---

## Business Context

* CDP employees are responsible for generating **insurance sales opportunities**
* Opportunities can result in:

  * Quotes
  * Policies (final conversion)
* This dashboard helps stakeholders **monitor productivity, conversion efficiency, and trends over time**

---

## Dataset & Source

* Data extracted using SQL (see `/sql` folder)
* Source: Internal transactional systems (opportunities, quotes, policies, employee data)

Key entities:

* Opportunities
* Quotes
* Policies
* Employees (CDP)
* Dates

---

## Data Model

* Fact Tables:

  * Opportunities / Policies (aggregated)
* Dimension Tables:

  * Date
  * CDP Employee
  * Opportunity Type

Model follows a **star schema approach** enabling time-based and employee-level analysis.

(Refer to `/images` for semantic model)

---

## Key Metrics

* Opportunities Created
* Quotes Generated
* Policies Converted
* Conversion Rate (Opportunities → Policies)
* Avg Days to Quote
* Avg Days to Policy (Shell)

Metrics are derived using SQL + DAX (including date differences and aggregations).

---

## SQL & Data Engineering Highlights

* Multi-table joins combining opportunities, quotes, policies, and employee data
* Transformation logic to align data at a consistent grain (opportunity-level)
* Date difference calculations to derive **time-to-quote** and **time-to-policy** metrics
* Aggregations to support funnel analysis (Opportunities → Quotes → Policies)
* Pre-processing in SQL to reduce load on Power BI and improve performance

*(Refer to `/sql` folder for full queries)*

---

## Dashboard Pages

### 1. Daily View

* Tracks performance at **daily granularity**
* Helps identify short-term activity and anomalies

### 2. Weekly View

* Aggregated weekly performance
* Useful for trend consistency and workload patterns

### 3. Monthly View

* High-level performance tracking
* Supports management reporting

### 4. CDP Summary

* Trend analysis:

  * Employee count
  * Quotes over time
  * Policies created

### 5. Data Dictionary

* Defines all business metrics and fields used in the dashboard

---

## Key Insights

* Performance varies significantly across employees
* Conversion rates highlight efficiency differences, not just volume
* Time-to-conversion metrics expose operational delays
* Monthly trends show growth and drop-off patterns in activity

---

## Data Refresh

* Data is refreshed **daily** via scheduled refresh in Power BI Service
* Data latency: up to 24 hours
* Dependent on upstream SQL data availability

---

## Tools Used

* Power BI (data modeling, DAX, visualization)
* SQL (data extraction, joins, transformations, date calculations)

---

## Project Structure

* `/pbix` → Power BI file
* `/sql` → SQL queries (data extraction + transformations)
* `/images` → Dashboard screenshots + semantic model

---

## How to Use

1. Open `.pbix` file in Power BI Desktop
2. Navigate between Daily, Weekly, and Monthly views
3. Use filters to analyze employee-level performance
4. Refer to Data Dictionary for metric definitions

---

## Limitations

* Data latency (up to 24 hours)
* Dependency on upstream data quality and availability

---
