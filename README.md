# CDP-Dashboard
Power BI dashboard analyzing CDP employee performance across daily, weekly, and monthly views. Tracks opportunities, quotes, and policy conversions with metrics like conversion rates and time to quote/policy. Built using SQL for data transformation and a star schema based model for analysis.
# CDP Performance Dashboard (Daily / Weekly / Monthly)

## Problem

Evaluate **CDP employee performance** by tracking the full sales funnel:
**Opportunities → Quotes → Policies**, across daily, weekly, and monthly views.

---

## Business Context

CDP (College Development Program) employees generate insurance opportunities (New Business, Renewals, Rewrites).
Stakeholders use this dashboard to monitor:

* Productivity (volume)
* Conversion efficiency
* Time to conversion

---

## Data Model

* **Grain:** One row per *Opportunity–LOB combination*
* Fact: Opportunity funnel (opportunity → quote → policy)
* Dimensions: Employee, Date, LOB, Opportunity Type

Model is **star-like**, optimized for time-series and employee-level analysis.

---

## Key Metrics

* Opportunities Created
* Quotes Generated
* Policies Converted
* Conversion Rate
* Days to Quote
* Days to Policy (Shell)

---

## SQL & Data Engineering Highlights

* **CTE-based pipeline**: `CDPEmp → CDPOpportunities → CDPQuotes → Final`
* **Window Functions (core logic):**

  * `ROW_NUMBER()` to select:

    * First valid quote per opportunity + LOB
    * Closest policy (shell date) to opportunity
* **Fuzzy matching logic:**

  * Policy matched within ±10 days of opportunity creation
  * Ensures realistic linking between opportunity → policy
* **Data shaping:**

  * Opportunity type normalization (New / Renewal / Rewrite)
  * LOB alignment across systems
* **Derived metrics:**

  * `DATEDIFF()` for time-to-quote and time-to-policy
  * Binary flags for quote/policy conversion

→ SQL does **heavy lifting before Power BI**, reducing DAX complexity.

---

## Dashboard Views

* **Daily / Weekly / Monthly** → performance at multiple granularities
* **CDP Summary** → trend + workforce overview
* **Data Dictionary** → metric definitions

---

## Key Insights

* Performance differences are driven more by **conversion efficiency** than volume
* Time-to-conversion highlights operational bottlenecks
* Funnel drop-offs vary significantly across employees

---

## Data Refresh

* Daily scheduled refresh via Power BI Service
* ~24-hour data latency
* Dependent on upstream SQL systems

---

## Tools Used

* Power BI (modeling, DAX, visualization)
* SQL (joins, window functions, transformations)

---

## Project Structure

* `/pbix` → Power BI file
* `/sql` → SQL queries
* `/images` → dashboard + model screenshots

---

## Limitations

* Dependent on upstream data quality
* Matching logic (±10 days) may introduce minor approximation

---
