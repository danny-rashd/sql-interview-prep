# SQL Interview Flashcards

## Window Functions

### Card 1: ROW_NUMBER for Deduplication
**Q:** How do I keep only the first (or last) occurrence of a duplicate?
**A:**
```sql
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
  FROM events
)
SELECT * FROM ranked WHERE rn = 1;
```
**When:** Dedup by latest timestamp
**Gotcha:** ORDER BY matters; if you don't care about order, add `ORDER BY 1`

---

### Card 2: LAG/LEAD for Gaps
**Q:** How do I find users with >7 day gaps between logins?
**A:**
```sql
WITH logins AS (
  SELECT user_id, login_date,
         LAG(login_date) OVER (PARTITION BY user_id ORDER BY login_date) AS prev_login
  FROM user_events
)
SELECT * FROM logins 
WHERE DATEDIFF(day, prev_login, login_date) > 7;
```
**When:** Detect gaps, consecutive streaks, churn
**Gotcha:** First row per partition is NULL (use COALESCE if needed)

---

## CTEs

### Card 3: CTE for Multi-Step Logic
**Q:** When do I use a CTE vs. subquery?
**A:**
- Use CTE if: Logic has 2+ steps, code is hard to read, need recursion
- Use subquery if: Simple, one-off logic
- CTE is cleaner, subqueries are faster in some cases

**Example (CTE better here):**
```sql
WITH monthly_sales AS (
  SELECT product_id, DATE_TRUNC('month', sale_date) AS month, SUM(amount) AS revenue
  FROM sales
  GROUP BY product_id, DATE_TRUNC('month', sale_date)
),
ranked_by_month AS (
  SELECT *, RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank
  FROM monthly_sales
)
SELECT * FROM ranked_by_month WHERE rank <= 3;
```

---

### Card 4: Recursive CTE (Hierarchies)
**Q:** How do I handle tree structures (org charts, categories)?
**A:**
```sql
WITH RECURSIVE org_hierarchy AS (
  -- Base case: root nodes
  SELECT id, name, parent_id, 1 AS level
  FROM departments
  WHERE parent_id IS NULL
  
  UNION ALL
  
  -- Recursive case: children
  SELECT d.id, d.name, d.parent_id, oh.level + 1
  FROM departments d
  JOIN org_hierarchy oh ON d.parent_id = oh.id
)
SELECT * FROM org_hierarchy ORDER BY level, id;
```
**When:** Org structures, category trees, bill-of-materials
**Gotcha:** Infinite loops possible; add LIMIT or check cycle detection

---

## Optimization

### Card 5: EXPLAIN PLAN Interpretation
**Q:** My query is slow. How do I read EXPLAIN output?
**A:**