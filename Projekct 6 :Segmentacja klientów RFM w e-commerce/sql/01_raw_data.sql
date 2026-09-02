-- Projekt 6: Segmentacja klientów RFM
-- Krok 1: Surowe dane transakcyjne
-- Dataset: bigquery-public-data.google_analytics_sample

SELECT
  fullVisitorId                                    AS customer_id,
  DATE(TIMESTAMP_SECONDS(visitStartTime))          AS visit_date,
  totals.transactions                              AS transactions,
  ROUND(totals.transactionRevenue / 1000000, 2)   AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
  AND totals.transactions IS NOT NULL
  AND totals.transactionRevenue IS NOT NULL
ORDER BY
  customer_id, visit_date
