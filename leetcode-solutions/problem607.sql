/*
Sales Person
Write a solution to find the names of all the salespersons who did not have any orders related to the company with the name "RED".
/*
SELECT s.name
FROM SalesPerson s
WHERE s.sales_id NOT IN (
    SELECT o.order_id
    FROM Orders o
    LEFT JOIN Company c
    ON o.com_id = c.com_id
    WHERE c.name = 'RED'
)