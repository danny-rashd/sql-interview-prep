-- =============================================================
-- SCAFFOLDING (local testing only — not part of the solution)
-- =============================================================

CREATE TABLE IF NOT EXISTS user_events
(
    user_id    INTEGER,
    event_date DATE,
    event_type VARCHAR(64)
);

-- Only insert if table is empty
INSERT INTO user_events
SELECT (random() * 200 + 1)::INTEGER                                   AS user_id,
       ('2026-01-01'::DATE + (random() * 90)::INTEGER)                 AS event_date,
       (ARRAY ['login', 'purchase', 'click'])[floor(random() * 3 + 1)] AS event_type
FROM generate_series(1, 2000)
WHERE NOT EXISTS (SELECT 1 FROM user_events LIMIT 1);

-- =============================================================
-- SOLUTION
-- =============================================================

WITH ranked_events AS (SELECT user_id,
                              event_date,
                              ROW_NUMBER() OVER (
                                  PARTITION BY user_id
                                  ORDER BY event_date
                                  ) AS rn
                       FROM user_events),

     first_events AS (SELECT user_id,
                             event_date                     AS first_event_date,
                             DATE_TRUNC('week', event_date) AS cohort_week
                      FROM ranked_events
                      WHERE rn = 1),

     retention_flags AS (SELECT f.user_id,
                                f.cohort_week,
                                MAX(CASE
                                        WHEN e.event_date >= f.first_event_date + INTERVAL '7 days'
                                            AND e.event_date < f.first_event_date + INTERVAL '8 days'
                                            THEN 1
                                        ELSE 0
                                    END) AS day_7_flag,
                                MAX(CASE
                                        WHEN e.event_date >= f.first_event_date + INTERVAL '14 days'
                                            AND e.event_date < f.first_event_date + INTERVAL '15 days'
                                            THEN 1
                                        ELSE 0
                                    END) AS day_14_flag,
                                MAX(CASE
                                        WHEN e.event_date >= f.first_event_date + INTERVAL '30 days'
                                            AND e.event_date < f.first_event_date + INTERVAL '31 days'
                                            THEN 1
                                        ELSE 0
                                    END) AS day_30_flag
                         FROM first_events f
                                  LEFT JOIN user_events e
                                            ON f.user_id = e.user_id
                         GROUP BY f.user_id, f.cohort_week)

SELECT cohort_week,
       ROUND(100.0 * AVG(day_7_flag), 2)  AS day_7_retention,
       ROUND(100.0 * AVG(day_14_flag), 2) AS day_14_retention,
       ROUND(100.0 * AVG(day_30_flag), 2) AS day_30_retention
FROM retention_flags
GROUP BY cohort_week
ORDER BY cohort_week;