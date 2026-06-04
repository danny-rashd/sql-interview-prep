/* 
LeetCode 176: Second Highest Salary
Problem: Find second highest salary. If none, return NULL.
*/
SELECT MAX(salary) 
FROM EMPLOYEE
WHERE salary < (SELECT MAX(salary)FROM EMPLOYEE);