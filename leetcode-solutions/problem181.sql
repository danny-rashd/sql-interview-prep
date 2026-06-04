/* 
LeetCode 181:Employees Earning More Than Their Managers
Problem: Write a solution to find the employees who earn more than their managers.
*/
SELECT e2.name as "Employee"
FROM Employee e1
JOIN Employee e2
ON e1.id = e2.managerId
WHERE e1.salary < e2.salary;