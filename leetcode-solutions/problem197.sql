-- LeetCode 197: Rising Temperature
-- Problem: Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).
SELECT w1.id
FROM Weather w1
JOIN Weather w2
ON w1.recordDate = w2.recordDate + INTERVAL '1 day'
WHERE w1.temperature > w2.temperature;