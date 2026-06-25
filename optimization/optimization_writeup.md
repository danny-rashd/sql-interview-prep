# Query Optimization: Orders Date Filter

## Problem
Sequential scan on 500,000-row orders table for date-filtered aggregation.
Query time before optimization: **87.776ms**

## Root Cause
No index on `order_date`. PostgreSQL performs a full sequential scan to evaluate
the WHERE clause, reading every row in the table before filtering. With 500,000
rows, this forces PostgreSQL to spin up parallel workers just to make the scan
tolerable — but it still reads all ~500,000 rows regardless.

## EXPLAIN ANALYZE — Before

```
Parallel Seq Scan on orders
  Filter: ((order_date >= '2026-01-01') AND (order_date < '2026-04-01'))
  Rows Removed by Filter: 139,283 (per worker)
  Workers Planned: 2 | Workers Launched: 2
Planning Time:  0.751ms
Execution Time: 87.776ms
```

**Key observations:**
- Node type: `Parallel Seq Scan` — full table read across all ~500,000 rows
- Rows removed by filter: 139,283 per worker (3 loops × 27,384 = ~82,152 matching rows)
- PostgreSQL needed 2 parallel workers to make the scan fast enough
- `Gather Merge` node shows worker results being merged back to the main process
- Aggregation done as `Partial GroupAggregate` per worker before merging

---

## Fix Applied

Created a B-tree index on `order_date`:

```sql
CREATE INDEX idx_orders_order_date ON orders(order_date);
```

B-tree is PostgreSQL's default index type and the correct choice for range
queries (`>=`, `<`, `BETWEEN`) on date columns. It allows the planner to
jump directly to the matching date range rather than scanning every row.

---

## EXPLAIN ANALYZE — After

```
Bitmap Index Scan on idx_orders_order_date
  Index Cond: ((order_date >= '2026-01-01') AND (order_date < '2026-04-01'))
  Rows fetched via index: 82,152
Bitmap Heap Scan on orders
  Heap Blocks: exact=3,185
Planning Time:  0.446ms
Execution Time: 42.411ms
```

**Key observations:**
- Node type: `Bitmap Index Scan` — index identifies matching rows first, then
  fetches only those heap blocks
- Heap blocks read: 3,185 (vs full table scan before)
- No parallel workers needed — index made single-threaded execution fast enough
- Aggregation strategy changed from `GroupAggregate` to `HashAggregate` —
  PostgreSQL chose a more memory-efficient strategy given the smaller working set

---

## Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Execution time | 87.776ms | 42.411ms | **~2x faster** |
| Planning time | 0.751ms | 0.446ms | 40% faster |
| Scan type | Parallel Seq Scan | Bitmap Index Scan | Sequential → Index |
| Rows scanned | ~500,000 | ~82,152 | **84% fewer rows** |
| Parallel workers | 2 | 0 | Eliminated by index |

**Most important takeaway:** The scan type changed from `Seq Scan` (scales
linearly with table size) to `Bitmap Index Scan` (scales with result set size).
As the orders table grows to 5M or 50M rows, the indexed query stays fast
while the unindexed version gets proportionally slower.

---

## Trade-offs

**Reads vs writes:** Indexes speed up reads but add overhead to every `INSERT`,
`UPDATE`, and `DELETE` since PostgreSQL must keep the index in sync with the
table. For a read-heavy analytics table like `orders`, this is the correct
trade-off.

**For write-heavy tables:** A partial index on recent dates only would reduce
index maintenance cost significantly:

```sql
-- Only index orders from the last 2 years — reduces index size and write overhead
CREATE INDEX idx_orders_recent ON orders(order_date)
WHERE order_date >= '2024-01-01';
```

**Index bloat:** Over time, deleted rows leave dead entries in the index.
`VACUUM` (runs automatically in PostgreSQL) reclaims this space, but on
high-churn tables periodic `REINDEX` may be needed.