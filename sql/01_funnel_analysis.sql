-- ============================================================
-- MercadoLibre | Conversion Funnel Analysis
-- ============================================================
--
-- Analysis period: January 1 - August 31, 2025
-- Database: SQLite
-- Source table: mercadolibre_funnel
--
-- Objectives:
-- 1. Measure unique users by funnel event.
-- 2. Analyze chronological funnel progression.
-- 3. Calculate conversion and drop-off rates.
-- 4. Compare conversion across countries.
--
-- Notes:
-- - The original database remains unchanged.
-- - Event dates require hour-format standardization.
-- - Event reach and sequential conversion are different metrics.
-- - The dataset contains a limited number of purchases.
--
-- ============================================================

-- ============================================================
-- 1. EVENT REACH FUNNEL
-- ============================================================
-- Counts unique users who recorded each funnel event.
-- Event order is not considered.
-- Analysis period: January 1 - August 31, 2025.
-- ============================================================

WITH funnel_events AS (
    SELECT
        user_id,
        CASE
            WHEN event_name = 'first_visit'
                THEN '1. first_visit'
            WHEN event_name IN ('select_item', 'select_promotion')
                THEN '2. select_item / select_promotion'
            WHEN event_name = 'add_to_cart'
                THEN '3. add_to_cart'
            WHEN event_name = 'begin_checkout'
                THEN '4. begin_checkout'
            WHEN event_name = 'add_shipping_info'
                THEN '5. add_shipping_info'
            WHEN event_name = 'add_payment_info'
                THEN '6. add_payment_info'
            WHEN event_name = 'purchase'
                THEN '7. purchase'
        END AS funnel_stage

    FROM mercadolibre_funnel

    WHERE event_date >= '2025-01-01'
      AND event_date < '2025-09-01'
)

SELECT
    funnel_stage,
    COUNT(DISTINCT user_id) AS unique_users

FROM funnel_events

WHERE funnel_stage IS NOT NULL

GROUP BY funnel_stage
ORDER BY funnel_stage;


-- ============================================================
-- 2. SEQUENTIAL CONVERSION FUNNEL
-- ============================================================
-- Counts users who complete all preceding funnel stages
-- in chronological order.
-- Progression across multiple sessions is allowed.
-- Events with identical timestamps do not count as
-- chronological progression.
-- ============================================================

WITH events AS (
    SELECT DISTINCT
        user_id,
        datetime(
            CASE
                WHEN substr(event_date, 12, 2) LIKE '%:'
                THEN substr(event_date, 1, 11) || '0' ||
                     substr(event_date, 12)
                ELSE event_date
            END
        ) AS event_time,
        CASE
            WHEN event_name = 'first_visit' THEN 1
            WHEN event_name IN ('select_item', 'select_promotion') THEN 2
            WHEN event_name = 'add_to_cart' THEN 3
            WHEN event_name = 'begin_checkout' THEN 4
            WHEN event_name = 'add_shipping_info' THEN 5
            WHEN event_name = 'add_payment_info' THEN 6
            WHEN event_name = 'purchase' THEN 7
        END AS stage

    FROM mercadolibre_funnel

    WHERE event_date >= '2025-01-01'
      AND event_date < '2025-09-01'
),

step_1 AS (
    SELECT user_id, MIN(event_time) AS step_time
    FROM events
    WHERE stage = 1
    GROUP BY user_id
),

step_2 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_1 s ON e.user_id = s.user_id
    WHERE e.stage = 2
      AND e.event_time > s.step_time
    GROUP BY e.user_id
),

step_3 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_2 s ON e.user_id = s.user_id
    WHERE e.stage = 3
      AND e.event_time > s.step_time
    GROUP BY e.user_id
),

step_4 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_3 s ON e.user_id = s.user_id
    WHERE e.stage = 4
      AND e.event_time > s.step_time
    GROUP BY e.user_id
),

step_5 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_4 s ON e.user_id = s.user_id
    WHERE e.stage = 5
      AND e.event_time > s.step_time
    GROUP BY e.user_id
),

step_6 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_5 s ON e.user_id = s.user_id
    WHERE e.stage = 6
      AND e.event_time > s.step_time
    GROUP BY e.user_id
),

step_7 AS (
    SELECT e.user_id, MIN(e.event_time) AS step_time
    FROM events e
    JOIN step_6 s ON e.user_id = s.user_id
    WHERE e.stage = 7
      AND e.event_time > s.step_time
    GROUP BY e.user_id
)

SELECT
    1 AS stage_order,
    'first_visit' AS event_name,
    COUNT(*) AS unique_users
FROM step_1

UNION ALL
SELECT 2, 'select_item / select_promotion', COUNT(*) FROM step_2

UNION ALL
SELECT 3, 'add_to_cart', COUNT(*) FROM step_3

UNION ALL
SELECT 4, 'begin_checkout', COUNT(*) FROM step_4

UNION ALL
SELECT 5, 'add_shipping_info', COUNT(*) FROM step_5

UNION ALL
SELECT 6, 'add_payment_info', COUNT(*) FROM step_6

UNION ALL
SELECT 7, 'purchase', COUNT(*) FROM step_7

ORDER BY stage_order;



-- ============================================================
-- 3. FIRST-VISIT-TO-PURCHASE CONVERSION BY COUNTRY
-- ============================================================
-- Measures purchases occurring after a user's first visit.
-- Users are assigned to their first recorded visit country.
-- Intermediate funnel stages are not required.
-- ============================================================

WITH events AS (
    SELECT
        user_id,
        country,
        event_name,
        datetime(
            CASE
                WHEN substr(event_date, 12, 2) LIKE '%:'
                THEN substr(event_date, 1, 11) || '0' ||
                     substr(event_date, 12)
                ELSE event_date
            END
        ) AS event_time
    FROM mercadolibre_funnel
    WHERE event_date >= '2025-01-01'
      AND event_date < '2025-09-01'
),

first_visits AS (
    SELECT
        user_id,
        country,
        event_time AS first_visit_time,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY event_time, country
        ) AS visit_order
    FROM events
    WHERE event_name = 'first_visit'
),

visitor_conversion AS (
    SELECT
        fv.user_id,
        fv.country,
        MAX(
            CASE
                WHEN e.event_name = 'purchase'
                 AND e.event_time > fv.first_visit_time
                THEN 1 ELSE 0
            END
        ) AS converted
    FROM first_visits fv
    LEFT JOIN events e
        ON fv.user_id = e.user_id
    WHERE fv.visit_order = 1
    GROUP BY fv.user_id, fv.country
)

SELECT
    country,
    COUNT(*) AS first_visit_users,
    SUM(converted) AS converted_users,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct

FROM visitor_conversion

GROUP BY country
ORDER BY conversion_rate_pct DESC;
