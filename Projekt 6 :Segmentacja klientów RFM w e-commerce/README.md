# Project 6: RFM Customer Segmentation — Google Merchandise Store

## Overview
RFM (Recency, Frequency, Monetary) analysis of the Google Merchandise Store 
using BigQuery public dataset. The goal was to segment ~10,000 customers into 
actionable business groups to support retention and marketing strategies.

## Business Questions
- Which customers are most valuable and should be prioritized for retention?
- Which customers are at risk of churning?
- How does spending differ across customer segments?
- What is the distribution of customer activity over time?

## Tools & Technologies
- **SQL**: Google BigQuery (public dataset: `google_analytics_sample`)
- **Visualization**: Power BI Desktop
- **Methods**: RFM Analysis, NTILE Window Functions, CTE, Conditional Segmentation

## Dataset
- **Source**: `bigquery-public-data.google_analytics_sample.ga_sessions_*`
- **Period**: August 2016 — August 2017
- **Records**: 11,515 transactions → 9,996 unique customers

## Methodology

### RFM Scoring
Each customer was scored 1–4 on three dimensions using `NTILE(4)`:

| Dimension | Definition | Scoring Logic |
|---|---|---|
| **Recency** | Days since last purchase | Lower = better (reversed with `5 - NTILE`) |
| **Frequency** | Number of purchases | Higher = better |
| **Monetary** | Total spend ($) | Higher = better |

### Customer Segments

| Segment | Customers | % of Base | Avg Recency | Avg Orders | Avg Spend |
|---|---|---|---|---|---|
| Need Attention | 3,018 | 30.2% | 193 days | 1.0 | $68.95 |
| At Risk | 2,480 | 24.8% | 274 days | 1.2 | $169.04 |
| Promising | 1,869 | 18.7% | 100 days | 1.0 | $96.93 |
| Loyal | 1,119 | 11.2% | 96 days | 1.4 | $277.55 |
| Lost | 644 | 6.4% | 321 days | 1.0 | $102.77 |
| New Customers | 611 | 6.1% | 40 days | 1.0 | $102.01 |
| Champions | 255 | 2.5% | 38 days | 2.6 | $1,147.08 |

## Key Insights

### 1. Champions drive disproportionate value
Champions represent only **2.5% of the customer base** but spend on average 
**$1,147** — nearly **7.5x more** than the average customer ($154). 
Retaining this segment should be the top priority.

### 2. At Risk segment requires immediate action
**24.8% of all customers** (2,480 people) show signs of churn — they previously 
purchased multiple times but have been inactive for an average of **274 days**. 
A targeted reactivation campaign could recover significant revenue.

### 3. Large untapped middle segment
**Need Attention (30.2%)** is the largest segment with average spend of $69 
and 192 days since last purchase. A well-timed promotion or personalized 
recommendation could convert a portion into Promising or Loyal customers.

### 4. New Customers show healthy acquisition
611 customers made their first purchase recently (avg 40 days), spending ~$102. 
Onboarding campaigns should focus on driving a second purchase within 60 days 
to move them toward the Promising segment.

## SQL Files

| File | Description |
|---|---|
| `01_raw_data.sql` | Extract raw transactions from GA sessions |
| `02_rfm_values.sql` | Calculate R, F, M values per customer |
| `03_rfm_scores.sql` | Assign scores 1–4 using NTILE window function |
| `04_rfm_segments.sql` | Final segmentation with CASE WHEN logic |
| `05_rfm_summary.sql` | Aggregated summary per segment |

## Dashboard

Power BI dashboard includes:
- **KPI Cards**: Total Customers, Champions, At Risk Count, Avg Monetary
- **Treemap**: Customer distribution by segment
- **Bar Chart**: Average spend per segment with conditional formatting
- **Scatter Plot**: Recency vs Monetary colored by segment
- **Matrix Heatmap**: Customer distribution across R and F scores
- **Slicer**: Interactive segment filter

![Dashboard](dashboard/screenshot.png)

## Project Structure
