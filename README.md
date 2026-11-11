# MercadoLibre | Conversion Funnel & Cohort Retention Analysis

**SQL (SQLite) · Python · Pandas · Data Visualization**

🌐 **English** · [Español](README_ES.md)

An analysis of user behavior in an educational MercadoLibre-themed dataset: purchase funnel progression from January–August 2025 and user activity up to 28 days after registration. The project combines data quality checks, SQL analysis, and business recommendations.

---

## Contents

1. [Executive Summary](#executive-summary)
2. [Business Questions](#business-questions)
3. [Dashboard](#dashboard)
4. [Key Findings](#key-findings)
5. [Data Quality and Validation](#data-quality-and-validation)
6. [Recommendations](#recommendations)
7. [Methodology](#methodology)
8. [Limitations](#limitations)
9. [Repository Structure](#repository-structure)
10. [How to Run](#how-to-run)
11. [About This Project](#about-this-project)

---

## Executive Summary

- **Product selection to cart is the main observed bottleneck.** In the strict chronological funnel, users drop from **845** at `select_item / select_promotion` to **104** at `add_to_cart` (**87.69%** did not progress to the next required step).
- **A strict funnel completion rate of 0.91%.** **11 of 1,204** users with `first_visit` completed all seven required stages in order. This is **not** the platform's overall sales conversion rate.
- **Purchase volume is too small for strong geographic conclusions.** **17 users** recorded a `purchase`; only **11** had a purchase after an observed `first_visit` in the period. Country-level conversion rates are exploratory.
- **The sharpest activity decline occurs immediately after signup.** Among **12,000 registered users**, daily activity drops from **97.88% at D0** to **51.35% at D1** (**−46.53 percentage points**), then reaches **24.23% at D7** and **2.60% at D28**.
- **The decline appears across cohorts and devices.** Monthly cohorts show similar patterns; mobile users have higher observed D7 retention (**25.25%**) than desktop users (**21.23%**), without establishing a causal effect.
- **Data quality matters.** The retention table contains **348,000 distinct rows recorded twice**; event timestamps also require standardization to support chronological analysis.

---

## Business Questions

| # | Question | Answer in |
|---|---|---|
| 1 | Can we trust the data? | [Data Quality and Validation](#data-quality-and-validation) |
| 2 | Where do users stop progressing through the purchase journey? | [Conversion Funnel](#1-conversion-funnel) |
| 3 | How much does conversion vary across countries? | [Geographic Conversion](#2-geographic-conversion) |
| 4 | How does user activity change after signup? | [Overall Retention](#3-overall-user-retention) |
| 5 | Are retention patterns different across cohorts and segments? | [Cohorts and Segments](#4-cohort-and-segment-retention) |

---

## Dashboard

📊 [Interactive HTML Dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)

The published dashboard presents an executive overview, the conversion funnel, and D7–D28 retention. The newly validated daily D0–D28 curve is documented in the retention notebook; it has not yet been added to the HTML dashboard.

*Funnel and retention figures come from different datasets and should not be interpreted as one connected customer journey.*

---

## Key Findings

### 1. Conversion funnel

**Analysis period:** January 1 – August 31, 2025 (inclusive).

| Event | Unique users recording the event | Users reaching the stage in strict chronological order |
|---|---:|---:|
| `first_visit` | 1,204 | 1,204 |
| `select_item / select_promotion` | 1,309 | 845 |
| `add_to_cart` | 174 | 104 |
| `begin_checkout` | 60 | 37 |
| `add_shipping_info` | 40 | 23 |
| `add_payment_info` | 33 | 19 |
| `purchase` | 17 | **11 (0.91%)** |

- **Largest observed step drop-off:** `select_item / select_promotion` → `add_to_cart`: **741 users**, or **87.69%** of the 845 users who had completed the preceding stages.
- **Another important transition:** `add_to_cart` → `begin_checkout`: **64.42%** did not progress to the next required stage.
- **Purchase-path validation:** 17 users recorded `purchase`; 15 had all seven event types recorded (in any order); 11 completed the full chronological sequence. The four users with complete event coverage but without strict completion did not have an `add_to_cart` event *after the qualifying selection* in that sequence.

*The sequential funnel permits events across sessions. Observed non-progression is not proof that users permanently abandoned a purchase.*

### 2. Geographic conversion

The **first-visit-to-purchase rate** counts users who recorded `purchase` after their first observed `first_visit` during the analysis period, assigned to the country of that first visit. Intermediate events are not required.

| Country | Users with `first_visit` | Converted users | Conversion rate |
|---|---:|---:|---:|
| Uruguay | 22 | 1 | 4.55% |
| Bolivia | 31 | 1 | 3.23% |
| Peru | 110 | 2 | 1.82% |
| Mexico | 245 | 4 | 1.63% |
| Brazil | 292 | 2 | 0.68% |
| Argentina | 160 | 1 | 0.63% |
| Paraguay | 21 | 0 | 0.00% |
| Ecuador | 59 | 0 | 0.00% |
| Colombia | 166 | 0 | 0.00% |
| Chile | 98 | 0 | 0.00% |

**11 of 1,204** users converted under this definition (**0.91%** in total). This happens to equal the strict funnel completion percentage, but the two metrics have different definitions and should not be treated as interchangeable.

Uruguay has the highest *observed* rate, but it reflects only **one purchaser**. These small counts do not support firm rankings or major market-level decisions.

### 3. Overall user retention

**Signup period:** January 1 – August 25, 2025. **Observation window:** D0–D28.

| Day after signup | Active users | Retention rate |
|---|---:|---:|
| D0 | 11,746 | **97.88%** |
| D1 | 6,162 | **51.35%** |
| D3 | 4,739 | **39.49%** |
| D7 | 2,908 | **24.23%** |
| D14 | 1,389 | **11.57%** |
| D21 | 606 | **5.05%** |
| D28 | 312 | **2.60%** |

Across the full D0–D28 daily curve, the largest consecutive-day decrease occurs from **D0 to D1 (−46.53 percentage points)**. This highlights early engagement as an area for investigation, but does not establish why activity decreases. Retention measures activity **on each specific day**, not uninterrupted activity or permanent churn.

### 4. Cohort and segment retention

- **Monthly signup cohorts:** D7 retention ranges from **22.48% to 26.07%**; D28 retention ranges from **2.02% to 3.04%**. No sustained improvement appears across the eight monthly cohorts.
- **Country:** Mexico has the highest observed D28 retention (**3.32%**); Colombia has the lowest (**1.83%**). All countries show low D28 activity.
- **Device:** Mobile users account for **8,963 of 12,000** registered users (about **74.7%**) and show higher observed retention at D7 and D28.

| Device | Users | D7 | D28 |
|---|---:|---:|---:|
| Mobile | 8,963 | 25.25% | 2.76% |
| Desktop | 2,421 | 21.23% | 2.11% |
| Tablet | 616 | 21.27% | 2.27% |

These are descriptive comparisons, not evidence that country or device causes retention differences.

---

## Data Quality and Validation

**Checks and analytical decisions**

- **Funnel:** 61,235 source rows, 2,901 unique users across the full source history; **6 exact duplicate rows** identified. The funnel analysis uses **26,695 events and 1,755 unique users** in the selected 2025 period.
- **Retention:** 696,000 source rows, **348,000 distinct rows**, 12,000 users. Every distinct row appears exactly twice. Retention calculations exclude the extra exact copies without changing the original database.
- **Key fields:** No NULL or empty values were found in the identifiers, country and other key fields checked.
- **Follow-up:** All 12,000 retention users have daily observations from D0 to D28; `active` contains valid 0/1 values.
- **Time fields:** `event_times` is in microseconds and has limited precision. **25,684** `event_date` values initially failed SQLite parsing because of single-digit hour formatting; standardization resolved these parsing failures.

The source SQLite database is kept unchanged. The analysis applies relevant deduplication and date standardization within SQL queries.

---

## Recommendations

1. **Investigate the product selection-to-cart transition.** Review product information, pricing clarity, shipping expectations, and usability before deciding what to change.
2. **Review cart-to-checkout progression.** Investigate possible friction and validate event tracking before attributing missing stages to abandonment.
3. **Investigate first-day engagement.** Examine the registration-to-D1 experience, onboarding, and early product discovery. Test potential improvements using D1 and D7 activity as outcome metrics; the observed drop does not identify its cause.
4. **Track retention by cohort and segment.** Monitor changes over time rather than making decisions based on small descriptive differences.
5. **Collect more conversion observations.** A larger purchase sample is needed before drawing confident conclusions about country performance.

---

## Methodology

| Step | Question | Tools | Notebook / SQL |
|---|---|---|---|
| 1 | Can we trust the data? | Python, SQLite, Pandas | [01_data_exploration](notebooks/01_data_exploration.ipynb) |
| 2 | Where do users stop progressing? | SQL (CTEs, joins, window functions), Python | [02_funnel_analysis](notebooks/02_funnel_analysis.ipynb) · [Funnel SQL](sql/01_funnel_analysis.sql) |
| 3 | Do users remain active after signup? | SQL, Pandas, Matplotlib | [03_retention_analysis](notebooks/03_retention_analysis.ipynb) · [Retention SQL](sql/02_retention_analysis.sql) |
| 4 | How do we communicate the findings? | HTML, interactive visualizations | [Dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) |

The notebooks and SQL scripts use a local SQLite source. SQL results were cross-checked between the notebooks and standalone queries.

---

## Limitations

- **Educational data:** This is an educational, MercadoLibre-themed case study, **not an official analysis commissioned by MercadoLibre**.
- **Small purchase counts:** Only 17 users recorded `purchase` during the selected funnel period. Geographic conversion results are exploratory.
- **Strict funnel definition:** Full completion requires all seven stages in order, across potentially different sessions. Missing or out-of-order events reduce the count even when a purchase was recorded.
- **Time quality:** `event_date` required formatting corrections, and the separate `event_times` field has limited precision. The recorded order is therefore subject to tracking limitations.
- **Separate populations:** Funnel and retention are different source tables with different user counts and periods; their user-level relationship was not validated.
- **Retention meaning:** D0–D28 percentages measure activity on individual days, not continuous engagement, permanent churn, or repeat purchases. Inactive users on D1 may return later.
- **Causality:** Observed differences and declines do not identify their underlying causes; suggested interventions would require further investigation and testing.

---

## Repository Structure

```text
mercadolibre-funnel-retention-analysis/
├── dashboard/
│   └── mercadolibre_dashboard_ejecutivo.html
├── data/
│   └── raw/           # Local SQLite database (excluded from Git)
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_funnel_analysis.ipynb
│   └── 03_retention_analysis.ipynb
├── sql/
│   ├── 01_funnel_analysis.sql
│   └── 02_retention_analysis.sql
├── .gitignore
├── requirements.txt
├── README.md          # English version
└── README_ES.md       # Spanish version
```

---

## How to Run

<details>
<summary>Setup instructions</summary>

### 1. Set up the environment

Clone the repository and install the dependencies:

```bash
python -m pip install -r requirements.txt
```

### 2. Prepare the database

The original SQLite database (`tripleten.db`) is not included in this repository. To reproduce the analysis, create `data/raw/` if necessary and place an authorized copy containing the `mercadolibre_funnel` and `mercadolibre_retention` tables at `data/raw/tripleten.db`.

### 3. Explore the analysis

Run the notebooks in numerical order (with `notebooks/` as the working directory), or review their saved outputs:

- [Data Exploration](notebooks/01_data_exploration.ipynb)
- [Funnel Analysis](notebooks/02_funnel_analysis.ipynb)
- [Retention Analysis](notebooks/03_retention_analysis.ipynb)

The [SQL queries](sql/) can be run separately with SQLite, one statement at a time. The [interactive dashboard](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) can be opened in a browser without the database.

</details>

---

## About This Project

Developed by **Camila Leal Ledesma** as an educational Data Analytics portfolio project based on a TripleTen exercise, with additional data validation, chronological funnel analysis, and reporting.

[LinkedIn](https://www.linkedin.com/in/camila-leal-ledesma/) · [GitHub](https://github.com/camilalealle)
