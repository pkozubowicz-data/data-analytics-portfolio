-- ============================================================
-- Projekt 5 — Analiza sprzedaży e-commerce
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Moduł 2 — Analiza koszyka
-- ============================================================

-- 2a + 2d. Rozkład liczby produktów w zamówieniu + AOV per liczba produktów
WITH pozycje AS (
  SELECT
    order_id,
    COUNT(id)       AS items_per_order,
    SUM(sale_price) AS order_value
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status NOT IN ('Cancelled', 'Returned')
  GROUP BY order_id
),

rozklad AS (
  SELECT
    items_per_order,
    COUNT(*)                                             AS liczba_zamowien,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)  AS procent
  FROM pozycje
  GROUP BY items_per_order
),

aov_per_items AS (
  SELECT
    items_per_order,
    ROUND(AVG(order_value), 2) AS avg_wartosc,
    ROUND(MIN(order_value), 2) AS min_wartosc,
    ROUND(MAX(order_value), 2) AS max_wartosc
  FROM pozycje
  GROUP BY items_per_order
)

SELECT
  r.items_per_order,
  r.liczba_zamowien,
  r.procent,
  a.avg_wartosc,
  a.min_wartosc,
  a.max_wartosc
FROM rozklad r
JOIN aov_per_items a USING (items_per_order)
ORDER BY items_per_order;


-- 2b. Średnia wartość koszyka i liczba produktów per kategoria
SELECT
  p.category                                   AS kategoria,
  COUNT(DISTINCT oi.order_id)                  AS liczba_zamowien,
  ROUND(AVG(items_in_order), 1)                AS avg_produktow_w_zamowieniu,
  ROUND(AVG(order_value), 2)                   AS avg_wartosc_zamowienia
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
JOIN (
  SELECT
    order_id,
    COUNT(id)           AS items_in_order,
    SUM(sale_price)     AS order_value
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status NOT IN ('Cancelled', 'Returned')
  GROUP BY order_id
) order_summary
  ON oi.order_id = order_summary.order_id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY kategoria
ORDER BY avg_wartosc_zamowienia DESC;


-- 2c. Top 15 par kategorii współwystępujących w jednym zamówieniu
WITH order_categories AS (
  SELECT DISTINCT
    oi.order_id,
    p.category
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
)
SELECT
  a.category   AS kategoria_a,
  b.category   AS kategoria_b,
  COUNT(*)     AS wspolwystapienia
FROM order_categories a
JOIN order_categories b
  ON a.order_id = b.order_id
 AND a.category < b.category
GROUP BY kategoria_a, kategoria_b
ORDER BY wspolwystapienia DESC
LIMIT 15;
