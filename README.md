# MercadoLibre | Conversion Funnel & Cohort Retention

**SQL (SQLite) · Python · Pandas · Matplotlib · HTML**

🌐 **English** · [Español](README_ES.md)

An educational MercadoLibre-themed case study of purchase-funnel progression (January–August 2025) and user activity during the first 28 days after signup. The goal is to identify where users stop progressing, describe retention patterns, and suggest areas for investigation.

**[Explore the live interactive dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)**

---

## Executive Summary

- **Main conversion bottleneck:** only **104 of 845 users (12.31%)** progressed from product selection to cart in the strict chronological funnel—a drop of **87.69%**.
- **Funnel completion:** **11 of 1,204 users (0.91%)** with a recorded `first_visit` completed all seven stages in sequence. This is *not* the platform-wide purchase conversion rate.
- **Early retention is low:** among **12,000 registered users**, day-specific activity fell from **24.23% at D7** to **2.60% at D28**.

**Business priority:** investigate selection-to-cart friction and event tracking, while testing early-engagement initiatives. These are investigation priorities, not proven causes or predicted sales gains.

## Business Questions

1. Where do users stop progressing through the purchase journey?
2. How do observed purchase paths differ from overall event counts?
3. How does activity retention change after signup, across cohorts and devices?

## Dashboard

**[Open the interactive executive dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)** · [HTML source](dashboard/mercadolibre_dashboard_ejecutivo.html)

*The funnel and retention datasets represent separate populations; their results should not be combined into a single customer journey.*

## Key Findings

### 1. Conversion funnel

**Period:** January 1–August 31, 2025. The two views below measure different things: users recording each event at any point versus users reaching every preceding step in chronological order (possibly across sessions).

| Stage | Users recording event (any order) | Strict-sequence users | Step conversion |
|---|---:|---:|---:|
| `first_visit` | 1,204 | 1,204 | — |
| `select_item / select_promotion` | 1,309 | 845 | 70.18% |
| `add_to_cart` | 174 | 104 | **12.31%** |
| `begin_checkout` | 60 | 37 | 35.58% |
| `add_shipping_info` | 40 | 23 | 62.16% |
| `add_payment_info` | 33 | 19 | 82.61% |
| `purchase` | 17 | **11** | 57.89% |

- **Largest observed drop:** product selection → cart (**741 users; 87.69%** of users at the previous strict-sequence stage).
- **Next notable drop:** cart → checkout (**64.42%**).
- **Purchase-event distinction:** **17 users** recorded `purchase`; **11** completed the full strict sequence. Out-of-order or unobserved events can affect the sequential count. Observed non-progression is not proof of abandonment.
- Country conversion is **exploratory**: only 11 first-visit-to-purchase conversions were observed, and country samples are small. Do not use these rates to rank markets conclusively.

### 2. Retention

**Population:** 12,000 registered users; January–August 2025 signup cohorts, observed on D0–D28.

| Day after signup | D7 | D14 | D21 | D28 |
|---|---:|---:|---:|---:|
| Users active on that day | 2,908 | 1,389 | 606 | 312 |
| Retention | **24.23%** | **11.57%** | **5.05%** | **2.60%** |

- D7 retention ranged from **22.48% to 26.07%** across eight monthly cohorts, with no sustained upward trend.
- At D7, **mobile: 25.25%** (8,963 users) versus **desktop: 21.23%** (2,421 users); this is a descriptive difference, not evidence of device effects.
- These rates measure **activity on a specific day**, not continuous use or repeat purchases.

## Data Quality and Validation

- **Funnel:** 61,235 source events with **6 exact duplicates**; the selected period contains **26,695 events** from **1,755 unique users**.
- **Retention:** **696,000 source rows** reduce to **348,000 distinct records**; each distinct record appeared twice. The 12,000 users have complete D0–D28 observation coverage.
- **Timestamp validation:** **25,684** `event_date` entries required normalization of single-digit hours before SQLite could parse them; the separate `event_times` field was unsuitable for precise ordering.
- Deduplication and timestamp normalization were applied in the analysis; the source database was not modified.

## Recommendations

1. **Investigate selection → cart:** examine product-page clarity, prices, delivery information and usability, and test specific hypotheses rather than assuming a cause.
2. **Audit funnel instrumentation and cart → checkout:** confirm that events are captured consistently before treating missing stages as customer abandonment.
3. **Test early-engagement initiatives:** evaluate onboarding or re-engagement experiments and monitor D7, D14 and D28 by cohort.

## Methodology

| Step | Focus | Evidence |
|---|---|---|
| 1 | Data exploration and validation | [Notebook 01](notebooks/01_data_exploration.ipynb) |
| 2 | Event reach and chronological funnel (SQL CTEs) | [Notebook 02](notebooks/02_funnel_analysis.ipynb) · [SQL](sql/01_funnel_analysis.sql) |
| 3 | Cohort, country and device retention | [Notebook 03](notebooks/03_retention_analysis.ipynb) · [SQL](sql/02_retention_analysis.sql) |
| 4 | Business communication | [Live dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) |

Standalone SQL query results were checked against the notebook results.

## Limitations

- **Educational dataset:** this is not an official MercadoLibre analysis.
- **Small purchase sample:** 17 purchase-event users in the funnel period limit conversion and country-level conclusions.
- **Strict path definition:** stages must occur in order; events may span sessions, and missing or misordered tracking can reduce completion counts.
- **Separate populations:** funnel and retention use different source tables and periods; no user-level connection was established.
- **Observational evidence:** device differences and drop-offs do not establish why users behaved that way.

## Repository Structure

```text
mercadolibre-funnel-retention-analysis/
├── dashboard/    # Interactive HTML dashboard
├── data/raw/     # Local SQLite database; excluded from Git
├── notebooks/    # Data exploration, funnel, retention
├── sql/          # Standalone SQLite queries
├── .gitignore
├── requirements.txt
├── README.md
└── README_ES.md
```

## How to Run

<details>
<summary>Setup instructions</summary>

1. Install dependencies: `python -m pip install -r requirements.txt`.
2. Place an authorized copy of `tripleten.db` containing `mercadolibre_funnel` and `mercadolibre_retention` in `data/raw/`. **The database is not included in this repository.**
3. Run the notebooks in numerical order from the `notebooks/` directory, or review their saved outputs. The `.sql` files can be executed separately with SQLite. The [live dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) does not require the database.

</details>

## About This Project

Developed by **Camila Leal Ledesma** as a Data Analytics portfolio project based on a TripleTen exercise, extended with data validation, chronological funnel analysis and executive reporting.

[LinkedIn](https://www.linkedin.com/in/camila-leal-ledesma/) · [GitHub](https://github.com/camilalealle)
