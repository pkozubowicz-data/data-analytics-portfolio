-- Projekt 6: Segmentacja klientów RFM
-- Krok 4: Finalna segmentacja klientów z nazwami segmentów biznesowych

WITH raw_data AS (
  SELECT
    fullVisitorId                                  AS customer_id,
    DATE(TIMESTAMP_SECONDS(visitStartTime))        AS visit_date,
    ROUND(totals.transactionRevenue / 1000000, 2) AS revenue
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
    AND totals.transactions IS NOT NULL
    AND totals.transactionRevenue IS NOT NULL
),

rfm_values AS (
  SELECT
    customer_id,
    GREATEST(DATE_DIFF(DATE '2017-08-01', MAX(visit_date), DAY), 0) AS recency_days,
    COUNT(*)                                                          AS frequency,
    ROUND(SUM(revenue), 2)                                           AS monetary
  FROM raw_data
  GROUP BY customer_id
),

rfm_scores AS (
  SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    5 - NTILE(4) OVER (ORDER BY recency_days ASC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency ASC)         AS f_score,
    NTILE(4) OVER (ORDER BY monetary ASC)          AS m_score
  FROM rfm_values
)

SELECT
  customer_id,
  recency_days,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  CASE
    WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal'
    WHEN r_score = 4 AND f_score = 1                   THEN 'New Customers'
    WHEN r_score >= 3 AND f_score <= 2                 THEN 'Promising'
    WHEN r_score <= 2 AND f_score >= 3                 THEN 'At Risk'
    WHEN r_score = 1 AND f_score = 1                   THEN 'Lost'
    ELSE 'Need Attention'
  END AS segment
FROM rfm_scores
ORDER BY r_score DESC, f_score DESC, m_score DESC