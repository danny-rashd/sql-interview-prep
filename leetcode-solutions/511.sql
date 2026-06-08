/*
Leetcode 511: Game Play Analysis I
Problem: Write a solution to find the first login date for each player.
*/
SELECT player_id, MIN(event_date) as first_login
FROM Activity
GROUP BY player_id; 
