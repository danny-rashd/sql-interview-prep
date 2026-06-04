/*
Leetcode 584: Find Customer Referee
Problem: Find the names of the customer that are either:
    referred by any customer with id != 2.
    not referred by any customer.
/*
SELECT name
FROM Customer
WHERE id != 2 or referee_id is NULL;