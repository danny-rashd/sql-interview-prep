/*
Leetcode 596: Classes With at Least 5 Students
Problem: Write a solution to find all the classes that have at least five students.
/*
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT (student) >= 5