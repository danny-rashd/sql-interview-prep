/* 
LeetCode 182: Duplicate emails
Problem: Write a solution to report all the duplicate emails. Note that it's guaranteed that the email field is not NULL.
*/
SELECT email as "EMAIL"
FROM Person 
GROUP BY email 
HAVING COUNT(email) > 1;