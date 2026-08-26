-- ============================================================
-- Projekt 5 — Analiza sprzedaży e-commerce
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Moduł 4 — Segmentacja klientów RFM
-- ============================================================

-- 4a. Obliczamy R, F, M dla każdego klienta + przypisujemy segmenty
WITH ostatnia_data AS (
  SELECT MAX(DATE(created_at)) AS max_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),

rfm_raw AS (
  SELECT
    o.user_id,
    DATE_DIFF(od.max_date, MAX(DATE(o.created_at)), DAY)  AS recency_days,
    COUNT(DISTINCT o.order_id)                             AS frequency,
    ROUND(SUM(oi.sale_price), 2)                           AS monetary
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  CROSS JOIN ostatnia_data od
  WHERE o.status NOT IN ('Cancelled', 'Returned')
  GROUP BY o.user_id, od.max_date
),

rfm_scores AS (
  SELECT
    user_id,
    recency_days,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC)  AS r_score,
    NTILE(4) OVER (ORDER BY frequency ASC)      AS f_score,
    NTILE(4) OVER (ORDER BY monetary ASC)       AS m_score
  FROM rfm_raw
),

rfm_segmented AS (
  SELECT
    user_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
      WHEN r_score = 4 AND f_score >= 3                        THEN 'Champions'
      WHEN r_score >= 3 AND f_score >= 3                       THEN 'Loyal Customers'
      WHEN r_score = 4 AND f_score <= 2                        THEN 'Recent Customers'
      WHEN r_score >= 3 AND f_score <= 2                       THEN 'Promising'
      WHEN r_score = 2 AND f_score >= 3                        THEN 'At Risk'
      WHEN r_score = 2 AND f_score <= 2                        THEN 'Needs Attention'
      WHEN r_score = 1 AND f_score >= 3                        THEN "Can't Lose Them"
      ELSE 'Lost'
    END AS segment
  FROM rfm_scores
)

SELECT *
FROM rfm_segmented
ORDER BY rfm_total DESC, monetary DESC
LIMIT 100;


-- 4d. Podsumowanie segmentów
WITH ostatnia_data AS (
  SELECT MAX(DATE(created_at)) AS max_date
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),
rfm_raw AS (
  SELECT
    o.user_id,
    DATE_DIFF(od.max_date, MAX(DATE(o.created_at)), DAY)  AS recency_days,
    COUNT(DISTINCT o.order_id)                             AS frequency,
    ROUND(SUM(oi.sale_price), 2)                           AS monetary
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  CROSS JOIN ostatnia_data od
  WHERE o.status NOT IN ('Cancelled', 'Returned')
  GROUP BY o.user_id, od.max_date
),
rfm_scores AS (
  SELECT
    user_id, recency_days, frequency, monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
    NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
  FROM rfm_raw
),
rfm_segmented AS (
  SELECT
    user_id, recency_days, frequency, monetary,
    CASE
      WHEN r_score = 4 AND f_score >= 3  THEN 'Champions'
      WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
      WHEN r_score = 4 AND f_score <= 2  THEN 'Recent Customers'
      WHEN r_score >= 3 AND f_score <= 2 THEN 'Promising'
      WHEN r_score = 2 AND f_score >= 3  THEN 'At Risk'
      WHEN r_score = 2 AND f_score <= 2  THEN 'Needs Attention'
      WHEN r_score = 1 AND f_score >= 3  THEN "Can't Lose Them"
      ELSE 'Lost'
    END AS segment
  FROM rfm_scores
)

SELECT
  segment,
  COUNT(*)                          AS liczba_klientow,
  ROUND(COUNT(*) * 100.0
    / SUM(COUNT(*)) OVER (), 1)     AS procent_bazy,
  ROUND(AVG(recency_days), 0)       AS avg_recency_dni,
  ROUND(AVG(frequency), 1)          AS avg_zamowienia,
  ROUND(AVG(monetary), 2)           AS avg_wydatki,
  ROUND(SUM(monetary), 2)           AS total_przychod_segmentu
FROM rfm_segmented
GROUP BY segment
ORDER BY total_przychod_segmentu DESC;


-- 4e. Nowi klienci miesięcznie + skumulowani
WITH pierwsze_wizyty AS (
  SELECT
    user_id,
    MIN(DATE(created_at)) AS pierwsza_wizyta
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
    AND DATE(created_at) >= '2022-01-01'
  GROUP BY user_id
),

miesieczne AS (
  SELECT
    DATE_TRUNC(pierwsza_wizyta, MONTH) AS miesiac,
    COUNT(*)                           AS nowi_klienci
  FROM pierwsze_wizyty
  GROUP BY miesiac
)

SELECT
  FORMAT_DATE('%Y-%m-%d', miesiac)                          AS miesiac,
  nowi_klienci,
  SUM(nowi_klienci) OVER (ORDER BY miesiac)                 AS klienci_skumulowani
FROM miesieczne
ORDER BY miesiac;
