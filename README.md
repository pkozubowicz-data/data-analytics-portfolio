# 📊 Data Analytics Portfolio

**Autor:** Przemysław Kozubowicz  
**Narzędzia:** SQL (Google BigQuery) · Power BI · Python *(wkrótce)*  
**Kontakt:** [LinkedIn](https://linkedin.com/in/TWOJ-PROFIL) · [GitHub](https://github.com/pkozubowicz-data)

---

## O portfolio

Projekty analityczne realizowane na publicznych datasetach w Google BigQuery.  
Każdy projekt zawiera zapytania SQL, dashboard Power BI oraz opis wniosków biznesowych.

---

## Projekty

| # | Projekt | Technologie | Dataset | Status |
|---|---------|-------------|---------|--------|
| 01 | [🔜 Projekt 1](#) | SQL, Power BI | - | Wkrótce |
| 02 | [🔜 Projekt 2](#) | SQL, Power BI | - | Wkrótce |
| 03 | [🔜 Projekt 3](#) | SQL, Power BI | - | Wkrótce |
| 04 | [🔜 Projekt 4](#) | SQL, Power BI | - | Wkrótce |
| 05 | [🛒 Analiza sprzedaży e-commerce](./projekt-05-ecommerce/README.md) | SQL · Power BI · BigQuery | thelook_ecommerce | ✅ Gotowy |

---

## Projekt 05 — Analiza sprzedaży e-commerce

**Dataset:** `bigquery-public-data.thelook_ecommerce`  
**Okres danych:** styczeń 2022 – sierpień 2026

### Zakres analizy
- 📈 Sprzedaż miesięczna, AOV, wzrost zamówień 8× w 4 latach
- 🛒 Analiza koszyka — cross-sell, rozkład liczby produktów
- 📅 Trendy sezonowe — MoM, YoY, sezonowość miesięczna
- 👥 Segmentacja klientów RFM — 8 segmentów, 62K klientów

### Kluczowe wyniki
- Przychód total: **~7.39M USD**
- AOV stabilne na poziomie **~87 USD** przez cały okres
- **69.9%** zamówień to single-item — potencjał cross-sell
- Segment **At Risk** (avg wydatki 203 USD) — priorytet win-back

### Pliki
```
projekt-05-ecommerce/
├── sql/
│   ├── modul1_sprzedaz.sql
│   ├── modul2_koszyk.sql
│   ├── modul3_sezonowosc.sql
│   └── modul4_rfm.sql
├── dashboard/
│   └── projekt5_ecommerce.pbix
└── README.md
```

---

## Umiejętności SQL zaprezentowane w projektach

`DATE_TRUNC` · `EXTRACT` · `FORMAT_DATE` · `LAG() OVER` · `PARTITION BY` · `NTILE()` · `SUM(COUNT(*)) OVER` · `ROWS BETWEEN` · `Self-JOIN` · `CTE` · `CROSS JOIN` · `DATE_DIFF`

---

*Portfolio w trakcie rozbudowy — nowe projekty dodawane regularnie.*
