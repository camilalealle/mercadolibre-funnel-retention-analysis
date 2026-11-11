-- ============================================================
-- MercadoLibre | Cohort Retention Analysis
-- ============================================================
--
-- Database: SQLite
-- Source table: mercadolibre_retention
-- Signup period: January 1 - August 25, 2025
-- Observation window: D0 - D28
--
-- Objectives:
-- 1. Calculate overall D7, D14, D21, and D28 retention.
-- 2. Compare retention across monthly signup cohorts.
-- 3. Analyze retention differences by country.
-- 4. Compare retention across device categories.
--
-- Methodology:
-- - Exclude exact duplicate records from calculations.
-- - Define retention as active = 1 on a specific day.
-- - Count each user once within each relevant segment.
-- - Keep the original SQLite database unchanged.
--
-- ============================================================

-- ============================================================
-- 1. OVERALL USER RETENTION
-- ============================================================
-- Calculates D7, D14, D21, and D28 retention rates.
-- Retention measures activity on each specific day.
-- ============================================================

WITH retention_clean AS (
    SELECT DISTINCT
        user_id,
        day_after_signup,
        active
    FROM mercadolibre_retention
)

SELECT
    day_after_signup AS retention_day,

    COUNT(DISTINCT user_id) AS total_users,

    COUNT(DISTINCT CASE
        WHEN active = 1 THEN user_id
    END) AS retained_users,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN active = 1 THEN user_id
        END) / COUNT(DISTINCT user_id),
        2
    ) AS retention_rate_pct

FROM retention_clean

WHERE day_after_signup IN (7, 14, 21, 28)

GROUP BY day_after_signup
ORDER BY day_after_signup;



-- ============================================================
-- 2. MONTHLY COHORT RETENTION
-- ============================================================
-- Groups users by their signup month.
-- Calculates D7, D14, D21, and D28 retention rates.
-- Each user is counted once within their signup cohort.
-- ============================================================

WITH retention_clean AS (
    SELECT DISTINCT
        user_id,
        signup_date,
        day_after_signup,
        active
    FROM mercadolibre_retention
),

monthly_cohorts AS (
    SELECT
        SUBSTR(signup_date, 1, 7) AS cohort_month,
        user_id,

        MAX(CASE WHEN day_after_signup = 7
                 THEN active ELSE 0 END) AS retained_d7,

        MAX(CASE WHEN day_after_signup = 14
                 THEN active ELSE 0 END) AS retained_d14,

        MAX(CASE WHEN day_after_signup = 21
                 THEN active ELSE 0 END) AS retained_d21,

        MAX(CASE WHEN day_after_signup = 28
                 THEN active ELSE 0 END) AS retained_d28

    FROM retention_clean

    GROUP BY cohort_month, user_id
)

SELECT
    cohort_month,
    COUNT(*) AS cohort_size,

    ROUND(100.0 * SUM(retained_d7) / COUNT(*), 2) AS d7_pct,

    ROUND(100.0 * SUM(retained_d14) / COUNT(*), 2) AS d14_pct,

    ROUND(100.0 * SUM(retained_d21) / COUNT(*), 2) AS d21_pct,

    ROUND(100.0 * SUM(retained_d28) / COUNT(*), 2) AS d28_pct

FROM monthly_cohorts

GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================
-- 3. USER RETENTION BY COUNTRY
-- ============================================================
-- Compares D7, D14, D21, and D28 retention across countries.
-- Each user is counted once within their country.
-- ============================================================

WITH retention_clean AS (
    SELECT DISTINCT
        user_id,
        country,
        day_after_signup,
        active
    FROM mercadolibre_retention
),

user_retention AS (
    SELECT
        user_id,
        country,

        MAX(CASE WHEN day_after_signup = 7
                 THEN active ELSE 0 END) AS retained_d7,

        MAX(CASE WHEN day_after_signup = 14
                 THEN active ELSE 0 END) AS retained_d14,

        MAX(CASE WHEN day_after_signup = 21
                 THEN active ELSE 0 END) AS retained_d21,

        MAX(CASE WHEN day_after_signup = 28
                 THEN active ELSE 0 END) AS retained_d28

    FROM retention_clean

    GROUP BY user_id, country
)

SELECT
    country,
    COUNT(*) AS total_users,

    ROUND(100.0 * SUM(retained_d7) / COUNT(*), 2) AS d7_pct,
    ROUND(100.0 * SUM(retained_d14) / COUNT(*), 2) AS d14_pct,
    ROUND(100.0 * SUM(retained_d21) / COUNT(*), 2) AS d21_pct,
    ROUND(100.0 * SUM(retained_d28) / COUNT(*), 2) AS d28_pct

FROM user_retention

GROUP BY country
ORDER BY total_users DESC;


-- ============================================================
-- 4. USER RETENTION BY DEVICE
-- ============================================================
-- Compares D7, D14, D21, and D28 retention by device.
-- Each user has one device category in the source data.
-- ============================================================

WITH retention_clean AS (
    SELECT DISTINCT
        user_id,
        device_category,
        day_after_signup,
        active
    FROM mercadolibre_retention
),

user_retention AS (
    SELECT
        user_id,
        device_category,

        MAX(CASE WHEN day_after_signup = 7
                 THEN active ELSE 0 END) AS retained_d7,

        MAX(CASE WHEN day_after_signup = 14
                 THEN active ELSE 0 END) AS retained_d14,

        MAX(CASE WHEN day_after_signup = 21
                 THEN active ELSE 0 END) AS retained_d21,

        MAX(CASE WHEN day_after_signup = 28
                 THEN active ELSE 0 END) AS retained_d28

    FROM retention_clean

    GROUP BY user_id, device_category
)

SELECT
    device_category,
    COUNT(*) AS total_users,

    ROUND(100.0 * SUM(retained_d7) / COUNT(*), 2) AS d7_pct,

    ROUND(100.0 * SUM(retained_d14) / COUNT(*), 2) AS d14_pct,

    ROUND(100.0 * SUM(retained_d21) / COUNT(*), 2) AS d21_pct,

    ROUND(100.0 * SUM(retained_d28) / COUNT(*), 2) AS d28_pct

FROM user_retention

GROUP BY device_category
ORDER BY total_users DESC;
