/*
Biggest Single Number
A single number is a number that appeared only once in the MyNumbers table.
Find the largest single number. If there is no single number, report null.
*/
SELECT MAX(num) as num
FROM(
    SELECT NUM
    FROM MyNumbers
    GROUP BY num
    HAVING COUNT(*) = 1
) AS t;