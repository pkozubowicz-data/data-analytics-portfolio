-- Projekt 6: Segmentacja klientów RFM
-- Krok 2: Obliczenie wartości Recency, Frequency, Monetary per klient

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
)

SELECT
  customer_id,
  GREATEST(DATE_DIFF(DATE '2017-08-01', MAX(visit_date), DAY), 0) AS recency_days,
  COUNT(*)                                                          AS frequency,
  ROUND(SUM(revenue), 2)                                           AS monetary
FROM raw_data
GROUP BY customer_id
ORDER BY monetary DESC