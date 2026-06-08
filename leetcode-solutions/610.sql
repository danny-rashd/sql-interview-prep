/*
Triangle Judgement 
Report for every three line segments whether they can form a triangle.
*/
SELECT x,y,z,
    CASE
        WHEN x + y > z AND x + z > y AND y + z > x then 'Yes'
        ELSE 'No'
    END AS triangle
FROM Triangle;