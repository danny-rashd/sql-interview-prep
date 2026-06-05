/*
Problem 1141: User Activity for the Past 30 Days I
Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. 
A user was active on someday if they made at least one activity on that day.
Return the result table in any order.
The result format is in the following example.
Note: Any activity from ('open_session', 'end_session', 'scroll_down', 'send_message') will be considered valid activity for a user to be considered active on a day.
*/
SELECT 
    activity_date AS day, 
    COUNT(DISTINCT(user_id)) AS active_users
FROM Activity
WHERE activity_date BETWEEN ('2019-07-27'::date - INTERVAL '29 days')
    AND '2019-07-27'::date
GROUP BY activity_date;