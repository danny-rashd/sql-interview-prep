/*
Sales Analysis III
Write a solution to report the products that were only sold in the first quarter of 2019. That is, between 2019-01-01 and 2019-03-31 inclusive.
Return the result table in any order.
*/
SELECT product_id, product_name
FROM Product
JOIN Sales
USING (product_id)
GROUP BY product_id, product_name
HAVING COUNT(*) = COUNT(CASE WHEN sale_date BETWEEN  '2019-01-01' AND '2019-03-31'  THEN 1 END)