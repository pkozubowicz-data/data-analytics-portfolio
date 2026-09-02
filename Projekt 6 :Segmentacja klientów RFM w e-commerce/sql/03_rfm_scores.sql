-- Projekt 6: Segmentacja klientów RFM
-- Krok 3: Scoring RFM z NTILE(4) — przypisanie score 1-4 per wymiar

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
)

SELECT
  customer_id,
  recency_days,
  frequency,
  monetary,
  -- Recency: odwrócone — im MNIEJ dni tym LEPSZY score
  5 - NTILE(4) OVER (ORDER BY recency_days ASC)  AS r_score,
  -- Frequency: im WIĘCEJ zakupów tym LEPSZY score
  NTILE(4) OVER (ORDER BY frequency ASC)         AS f_score,
  -- Monetary: im WIĘCEJ wydał tym LEPSZY score
  NTILE(4) OVER (ORDER BY monetary ASC)          AS m_score
FROM rfm_values
ORDER BY r_score DESC, f_score DESC, m_score DESC