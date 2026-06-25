-- =============================================================
-- optimized_query.sql
-- Step 1: Create the index on the bottleneck column
-- Step 2: Re-run the same query — planner now uses index scan
-- =============================================================

-- OPTIMIZATION: B-tree index on order_date
-- Allows PostgreSQL to skip irrelevant rows via bitmap scan
-- instead of reading all 500,000 rows sequentially
DROP INDEX IF EXISTS idx_orders_order_date;
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Same query as slow_query_problem.sql — no SQL changes needed
-- The index alone changes Seq Scan → Bitmap Index Scan
EXPLAIN ANALYZE
SELECT customer_id,
       COUNT(order_id)       AS order_count,
       SUM(order_amount)     AS total_value
FROM orders
WHERE order_date >= '2026-01-01'
  AND order_date < '2026-04-01'
GROUP BY customer_id
HAVING COUNT(order_id) > 5
ORDER BY total_value DESC;