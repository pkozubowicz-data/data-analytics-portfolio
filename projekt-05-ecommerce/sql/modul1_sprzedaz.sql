-- ============================================================
-- Projekt 5 — Analiza sprzedaży e-commerce
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Moduł 1 — Analiza sprzedaży ogólnej
-- ============================================================

-- 1a. Miesięczne przychody, liczba zamówień i AOV
SELECT
  FORMAT_DATE('%Y-%m-%d', DATE(DATE_TRUNC(o.created_at, MONTH))) AS miesiac,
  COUNT(DISTINCT o.order_id)             AS liczba_zamowien,
  ROUND(SUM(oi.sale_price), 2)           AS przychod_total,
  ROUND(AVG(oi.sale_price), 2)           AS avg_cena_produktu,
  ROUND(SUM(oi.sale_price)
        / COUNT(DISTINCT o.order_id), 2) AS aov
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
  AND o.created_at >= '2022-01-01'
GROUP BY miesiac
ORDER BY miesiac;


-- 1b. Top 10 kategorii produktów wg przychodu
SELECT
  p.category                        AS kategoria,
  COUNT(DISTINCT oi.order_id)       AS liczba_zamowien,
  ROUND(SUM(oi.sale_price), 2)      AS przychod,
  ROUND(AVG(oi.sale_price), 2)      AS avg_cena
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY kategoria
ORDER BY przychod DESC
LIMIT 10;


-- 1c. Przychód dzienny z 7-dniową średnią kroczącą
WITH dzienne AS (
  SELECT
    DATE(o.created_at)              AS dzien,
    ROUND(SUM(oi.sale_price), 2)    AS przychod
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status NOT IN ('Cancelled', 'Returned')
    AND o.created_at >= '2022-01-01'
  GROUP BY dzien
)
SELECT
  dzien,
  przychod,
  ROUND(AVG(przychod) OVER (
    ORDER BY dzien
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ), 2) AS srednia_7d
FROM dzienne
ORDER BY dzien;
