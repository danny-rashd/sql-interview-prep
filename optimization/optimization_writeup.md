# Query Optimization: Orders Date Filter

## Problem
Sequential scan on 500,000-row orders table for date-filtered aggregation.
Query time before optimization: ~Xms

## Root Cause
No index on `order_date`. PostgreSQL performs a full sequential scan
to evaluate the WHERE clause, reading every row before filtering.

## EXPLAIN ANALYZE — Before
[paste key lines from slow_query_explain.txt]
- Node type: Seq Scan
- Actual time: X..Xms
- Rows removed by filter: ~400,000

## Fix Applied
Created a B-tree index on `order_date`:
CREATE INDEX idx_orders_order_date ON orders(order_date);

## EXPLAIN ANALYZE — After
[paste key lines from after explain]
- Node type: Index Scan
- Actual time: X..Xms
- Rows removed by filter: ~0 (index eliminates at scan time)

## Result
Query time reduced from Xms to Xms (~Xx improvement).

## Trade-offs
Indexes speed up reads but slow down writes (INSERT/UPDATE must
maintain the index). Appropriate here since orders is read-heavy.
For a write-heavy table, a partial index on recent dates would
reduce index maintenance cost.