-- ============================================================
-- Projekt 5 — Analiza sprzedaży e-commerce
-- Dataset: bigquery-public-data.thelook_ecommerce
-- Moduł 3 — Trendy sezonowe
-- ============================================================

-- 3a. Sprzedaż wg miesiąca roku (agregat wszystkich lat)
SELECT
  EXTRACT(MONTH FROM o.created_at)          AS nr_miesiaca,
  FORMAT_DATE('%B', DATE(o.created_at))     AS nazwa_miesiaca,
  COUNT(DISTINCT o.order_id)                AS liczba_zamowien,
  ROUND(SUM(oi.sale_price), 2)              AS przychod_total,
  ROUND(AVG(oi.sale_price), 2)              AS avg_cena_produktu
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY nr_miesiaca, nazwa_miesiaca
ORDER BY nr_miesiaca;


-- 3b. Sprzedaż wg dnia tygodnia
SELECT
  EXTRACT(DAYOFWEEK FROM o.created_at)      AS nr_dnia,
  FORMAT_DATE('%A', DATE(o.created_at))     AS dzien_tygodnia,
  COUNT(DISTINCT o.order_id)                AS liczba_zamowien,
  ROUND(SUM(oi.sale_price), 2)              AS przychod_total,
  ROUND(AVG(oi.sale_price), 2)              AS avg_cena_produktu
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
WHERE o.status NOT IN ('Cancelled', 'Returned')
GROUP BY nr_dnia, dzien_tygodnia
ORDER BY nr_dnia;


-- 3c. Wzrost MoM (Month over Month) z użyciem LAG
WITH miesieczne AS (
  SELECT
    DATE_TRUNC(o.created_at, MONTH)         AS miesiac,
    COUNT(DISTINCT o.order_id)              AS zamowienia,
    ROUND(SUM(oi.sale_price), 2)            AS przychod
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status NOT IN ('Cancelled', 'Returned')
    AND o.created_at >= '2022-01-01'
  GROUP BY miesiac
)
SELECT
  miesiac,
  zamowienia,
  przychod,
  LAG(przychod) OVER (ORDER BY miesiac)             AS przychod_poprzedni_miesiac,
  ROUND(
    (przychod - LAG(przychod) OVER (ORDER BY miesiac))
    / LAG(przychod) OVER (ORDER BY miesiac) * 100
  , 1)                                              AS zmiana_mom_procent
FROM miesieczne
ORDER BY miesiac;


-- 3d. Porównanie YoY (Year over Year)
WITH miesieczne AS (
  SELECT
    EXTRACT(YEAR  FROM o.created_at)        AS rok,
    EXTRACT(MONTH FROM o.created_at)        AS miesiac,
    FORMAT_DATE('%B', DATE(o.created_at))   AS nazwa_miesiaca,
    COUNT(DISTINCT o.order_id)              AS zamowienia,
    ROUND(SUM(oi.sale_price), 2)            AS przychod
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  WHERE o.status NOT IN ('Cancelled', 'Returned')
    AND EXTRACT(YEAR FROM o.created_at) BETWEEN 2022 AND 2025
  GROUP BY rok, miesiac, nazwa_miesiaca
)
SELECT
  rok,
  miesiac,
  nazwa_miesiaca,
  zamowienia,
  przychod,
  LAG(przychod) OVER (PARTITION BY miesiac ORDER BY rok)   AS przychod_rok_wczesniej,
  ROUND(
    (przychod - LAG(przychod) OVER (PARTITION BY miesiac ORDER BY rok))
    / LAG(przychod) OVER (PARTITION BY miesiac ORDER BY rok) * 100
  , 1)                                                     AS wzrost_yoy_procent
FROM miesieczne
ORDER BY miesiac, rok;
