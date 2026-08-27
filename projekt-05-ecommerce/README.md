# Projekt — Analiza sprzedaży e-commerce
**Dataset:** `bigquery-public-data.thelook_ecommerce` (Google BigQuery)  
**Narzędzia:** SQL (BigQuery), Google Data Studio / własne wizualizacje  
**Poziom:** Średniozaawansowany  
**Okres danych:** styczeń 2022 – sierpień 2026

---

## Cel projektu

Kompleksowa analiza sklepu internetowego obejmująca sprzedaż ogólną, zachowania zakupowe klientów, trendy sezonowe oraz segmentację bazy klientów metodą RFM. Projekt odpowiada na cztery pytania biznesowe:

1. Jak rośnie sprzedaż w czasie i które kategorie generują największy przychód?
2. Jak wygląda typowy koszyk zakupowy i które produkty kupowane są razem?
3. Czy sprzedaż wykazuje sezonowość — miesięczną i tygodniową?
4. Kim są klienci sklepu i jak ich posegmentować według wartości?

---

## Moduł 1 — Analiza sprzedaży ogólnej

### Kluczowe wyniki

| Metryka | Wartość |
|---|---|
| Przychód total (2022–2026) | ~7.39M USD |
| Wzrost liczby zamówień | 579/mies. (sty'22) → 4 910/mies. (maj'26), wzrost 8× |
| Średnie AOV | ~87 USD (stabilne przez cały okres) |
| Kategoria #1 wg przychodu | Outerwear & Coats (1.02M USD) |
| Kategoria #1 wg liczby zamówień | Intimates (9 538 zamówień) |

### Wnioski

- Sprzedaż rośnie konsekwentnie przez 4,5 roku bez wyraźnego spowolnienia.
- **AOV jest uderzająco stabilne** (~82–93 USD) przez cały okres. Oznacza to, że wzrost przychodów pochodzi wyłącznie z pozyskiwania nowych klientów, nie ze zwiększania wartości koszyka — to sygnał dla działu marketingu, by skupić się na upsellingu.
- Outerwear generuje najwyższy przychód przy wysokiej średniej cenie (149 USD), podczas gdy Intimates dominuje wolumenem przy niskiej cenie jednostkowej (34 USD) — klasyczny trade-off między marżą a wolumenem.

### Techniki SQL
- `DATE_TRUNC(kolumna, MONTH)` — agregacja czasowa
- `JOIN` między tabelami `orders` i `order_items`
- Filtrowanie statusów zamówień (`NOT IN ('Cancelled', 'Returned')`)
- Window function: `AVG(...) OVER (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)` — 7-dniowa średnia krocząca

---

## Moduł 2 — Analiza koszyka

### Kluczowe wyniki

| Metryka | Wartość |
|---|---|
| Zamówienia z 1 produktem | 65 449 (69.7% wszystkich) |
| Zamówienia z 2 produktami | 18 668 (20.3%) |
| AOV przy 1 produkcie | 59.61 USD |
| AOV przy 2 produktach | 118.64 USD |
| AOV przy 4 produktach | 238.68 USD |
| Top para cross-sell | Jeans + Tops & Tees (586 współwystąpień) |

### Wnioski

- **70% zamówień to single-item** — ogromna przestrzeń do cross-sellingu. Każdy dodatkowy produkt w koszyku zwiększa AOV o ~60 USD (wartość liniowa).
- AOV rośnie proporcjonalnie do liczby produktów: 1 szt. → 60 USD, 2 szt. → 120 USD, 3 szt. → 180 USD, 4 szt. → 238 USD. Liniowość sugeruje, że klienci wielopozycyjni nie wybierają tańszych produktów — kupują z całego asortymentu.
- **Jeans to hub cross-sellowy** — pojawia się w 5 z 15 najczęstszych par kategorii. Naturalne miejsce na rekomendacje produktowe.

### Techniki SQL
- Subquery jako źródło JOIN (`order_summary`)
- `SUM(COUNT(*)) OVER ()` — procent bez osobnego podzapytania
- Self-JOIN z warunkiem `a.category < b.category` — znajdowanie par bez duplikatów
- `HAVING` do filtrowania zagregowanych wyników

---

## Moduł 3 — Trendy sezonowe

### Kluczowe wyniki

| Metryka | Wartość |
|---|---|
| Najsilniejszy miesiąc | Lipiec (10 558 zamówień) |
| Najsłabszy miesiąc | Wrzesień (5 957 zamówień) |
| Efekt weekendowy | Brak — różnica min/max między dniami tygodnia: 9.3% |
| Wzrost YoY (średni) | 35–72% rocznie, konsekwentny przez cały okres |
| Strukturalny dołek MoM | Luty — spada w każdym roku |

### Wnioski

- **Anomalia czerwiec→lipiec:** liczba zamówień spada o 46% w jednym miesiącu (11 227 → 6 081). W prawdziwym fashion e-commerce lipiec to szczyt letnich wyprzedaży — tu to artefakt syntetycznego datasetu, który warto oznaczyć w analizie.
- **Brak efektu weekendowego** — wszystkie dni tygodnia są niemal identyczne. W realnych danych e-commerce weekend zazwyczaj wyprzedza środę tygodnia o 15–25%.
- Wrzesień to jedyna konsekwentna sezonowa słabość.
- YoY nie zwalnia po 3 latach wzrostu — 2025 vs 2024 pokazuje wyższe wartości niż 2023 vs 2022. W syntetycznym datasecie brak efektu nasycenia rynku.

### Techniki SQL
- `EXTRACT(MONTH/DAYOFWEEK FROM ...)` — wyodrębnianie składowych daty
- `FORMAT_DATE('%B', ...)` — nazwy miesięcy i dni
- `LAG(...) OVER (ORDER BY miesiac)` — zmiana MoM
- `LAG(...) OVER (PARTITION BY miesiac ORDER BY rok)` — porównanie YoY (kluczowe: `PARTITION BY` izoluje każdy miesiąc kalendarzowy)

---

## Moduł 4 — Segmentacja klientów RFM

### Definicja segmentów

**RFM** = Recency (ile dni temu ostatni zakup) × Frequency (ile zamówień) × Monetary (ile wydał łącznie)  
Każdy wymiar podzielony na 4 kwarty (`NTILE(4)`), score 1–4. Segmenty przypisane regułami `CASE WHEN`.

### Wyniki segmentacji

| Segment | Klientów | % bazy | Avg recency | Avg zamówień | Avg wydatki | Przychód total |
|---|---|---|---|---|---|---|
| Loyal Customers | 16 498 | 25.0% | 259 dni | 1.5 | 130 USD | 2 147K USD |
| Champions | 8 977 | 13.6% | 66 dni | 2.1 | 178 USD | 1 606K USD |
| Lost | 13 778 | 20.9% | 1 467 dni | 1.0 | 86 USD | 1 190K USD |
| Needs Attention | 11 697 | 17.7% | 634 dni | 1.0 | 85 USD | 1 000K USD |
| At Risk | 4 806 | 7.3% | 616 dni | 2.3 | 203 USD | 978K USD |
| Recent Customers | 7 526 | 11.4% | 36 dni | 1.0 | 89 USD | 668K USD |
| Can't Lose Them | 2 725 | 4.1% | 1 316 dni | 2.2 | 192 USD | 523K USD |
| Promising | 5 | ~0% | 362 dni | 1.0 | 102 USD | 512K USD |

### Wnioski

- **Champions (13.5% bazy) generują 20.5% przychodu** — nieproporcjonalnie wysoka koncentracja wartości. To segment priorytetowy do programów lojalnościowych.
- **At Risk ma najwyższe avg wydatki (203 USD)** przy recency 616 dni — to byli najlepsi klienci, którzy przestali kupować. Kampania win-back skierowana do tego segmentu ma najwyższy potencjalny ROI.
- **Lost + Needs Attention = 38.5% bazy** — ponad 1/3 klientów nieaktywna. Koszt braku retencji widoczny w ~2.2M USD utopionego przychodu.
- Baza klientów wzrosła ze 570 nowych/miesiąc (sty'22) do 3 504 nowych/miesiąc (cze'26) — łącznie 61 645 unikalnych klientów, z wyraźną akceleracją od początku 2026.
- **"Promising" to anomalia:** tylko 14 klientów. W syntetycznym datasecie `NTILE` rozkłada dane zbyt równomiernie — w realnych danych ten segment byłby znacznie liczniejszy.

### Rekomendacje biznesowe według segmentów

| Segment | Akcja |
|---|---|
| Champions | Program VIP, early access do nowych kolekcji |
| Loyal Customers | Cross-sell, zwiększenie częstotliwości zakupów |
| At Risk | Win-back email z personalizowaną ofertą |
| Can't Lose Them | Agresywna kampania retencyjna z rabatem |
| Recent Customers | Onboarding sequence, drugi zakup w ciągu 30 dni |
| Lost | Wyklucz z aktywnych kampanii, obniż koszt komunikacji |

### Techniki SQL
- Wielopoziomowe CTE (`WITH a AS (...), b AS (...), c AS (...)`)
- `NTILE(4) OVER (ORDER BY ...)` — podział na kwarty
- `CROSS JOIN` z pojedynczą wartością (punkt odniesienia daty)
- `DATE_DIFF(data_a, data_b, DAY)` — różnica dat
- `SUM(nowi_klienci) OVER (ORDER BY miesiac)` — skumulowana suma na zagregowanych danych

---

## Podsumowanie technik SQL użytych w projekcie

| Technika | Moduł | Zastosowanie |
|---|---|---|
| `DATE_TRUNC` | 1, 3, 4 | Agregacja do miesiąca/roku |
| `EXTRACT` | 3 | Wyodrębnienie miesiąca, dnia tygodnia |
| `FORMAT_DATE` | 3 | Czytelne nazwy dat |
| `LAG() OVER` | 3 | Zmiana MoM i YoY |
| `PARTITION BY` w window | 3 | Izolacja grup w analizie YoY |
| `NTILE(4) OVER` | 4 | Podział na kwarty RFM |
| `SUM(COUNT(*)) OVER` | 2, 4 | Procent i skumulowana suma |
| `ROWS BETWEEN` | 1 | Średnia krocząca |
| Self-JOIN | 2 | Pary kategorii cross-sell |
| Wielopoziomowe CTE | 4 | Architektura złożonych zapytań |
| `CROSS JOIN` (scalar) | 4 | Punkt odniesienia daty |
| `DATE_DIFF` | 4 | Recency w dniach |

---

## Obserwacje dotyczące jakości danych (syntetyczny dataset)

Projekt został wykonany na syntetycznym datasecie `thelook_ecommerce`. Poniższe anomalie zostały zidentyfikowane i uwzględnione w interpretacji wyników:

1. **Avg produktów w zamówieniu = 1.9 dla każdej kategorii** — identyczna wartość dla wszystkich 26 kategorii sugeruje losowe generowanie danych, nie prawdziwe wzorce zakupowe.
2. **Cliff czerwiec→lipiec w danych sezonowych** — spadek zamówień o 46% w jednym miesiącu bez uzasadnienia biznesowego.
3. **Brak efektu weekendowego** — rozkład równomierny przez 7 dni tygodnia.
4. **YoY bez efektu nasycenia** — stały wzrost 35–72% przez 4 lata bez spowolnienia.
5. **Segment "Promising" z 14 klientami** — artefakt równomiernego rozkładu danych przez `NTILE`.

Identyfikacja artefaktów w syntetycznych danych jest kluczową kompetencją analityka — pozwala odróżnić prawdziwe wzorce biznesowe od szumu generatora danych.

---

*Projekt zrealizowany jako część portfolio analityka danych. Wszystkie zapytania dostępne w repozytorium.*
