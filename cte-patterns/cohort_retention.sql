-- CREATE TABLE 
CREATE TABLE user_events(
    user_id INTEGER,
    event_date DATE,
    even_type VARCHAR(64)
)
-- INSERT DATA
INSERT INTO user_events
SELECT 
    (random() * 200 + 1)::INTEGER AS user_id,
    ('2026-01-01'::DATE + (random()* 90)::INTEGER) AS event_date,
    (ARRAY['login','purchase','click'])[floor(random() * 3 + 1)] AS event_type
FROM generate_series(1,2000); 

-- WINDOW FUNCTIONS
/*
CTEs only, no subqueries
Must use ROW_NUMBER() or MIN() to identify each user's first event date
Percentages rounded to 2 decimal places
Output columns: cohort_week, day_7_retention, day_14_retention, day_30_retention
*/
WITH ranked_events AS(
    SELECT
        user_id,
        event_date,
        even_type,
        ROW_NUMBER() OVER(
            PARTITION BY user_id
            ORDER BY event_date
        ) AS row_number
    FROM user_events
),

first_week_events AS (
    SELECT 
        user_id,
        event_date AS first_event_date,
        DATE_TRUNC('week',event_date) AS cohort_week
),

retention_flags AS (
    SELECT 
        f.user_id,
        f.cohort_week,
        MAX(CASE
                WHEN e.event_date >= f.first_event_date + INTERVAL '7 day'
                AND e.event_date < f.first_event_date + INTERVAL '8 day'
                THEN 1 ELSE 0
            END) AS 7_day_flags,
        MAX(CASE
                WHEN e.event_date >= f.first_event_date + INTERVAL '14 day'
                AND e.event_date < f.first_event_date + INTERVAL '15 day'
                THEN 1 ELSE 0
            END) AS 14_day_flags,
        MAX(CASE
                WHEN e.event_date >= f.first_event_date + INTERVAL '30 day'
                AND e.event_date < f.first_event_date + INTERVAL '31 day'
                THEN 1 ELSE 0
            END) AS 30_day_flags,
    FROM first_week_events f
    LEFT JOIN user_events e
    ON f.user_id = e.user_id
    GROUP BY f.user_id, f.cohort_week
)
SELECT 
    cohort_week,
    ROUND(100* AVG(7_day_flags),2) AS day_7_retention,
    ROUND(100* AVG(14_day_flags),2) AS day_14_retention,
    ROUND(100* AVG(30_day_flags),2) AS day_30_retention,
FROM cte
GROUP BY cohort_week
ORDER BY cohort_week;
