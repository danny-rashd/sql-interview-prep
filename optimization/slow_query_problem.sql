-- =============================================================
-- GENERATE TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS orders
(
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER,
    order_date   DATE,
    order_amount NUMERIC(10, 2)
);

INSERT INTO orders
SELECT i,
       (random() * 1000 + 1)::INTEGER,
       ('2025-01-01'::DATE + (random() * 548)::INTEGER),
       (random() * 500 + 10)::NUMERIC(10, 2)
FROM generate_series(1, 500000) i
WHERE NOT EXISTS (SELECT 1 FROM orders);

-- =============================================================
-- RUN EXPLAIN/ANALYZE WITHOUT INDEXING
-- =============================================================
EXPLAIN ANALYZE
SELECT customer_id, COUNT(order_id), SUM(order_amount)
FROM orders
WHERE order_date >= '2026-01-01' AND order_date < '2026-04-01'
GROUP BY customer_id
HAVING COUNT(order_id) > 5
ORDER BY SUM(order_amount) DESC;
