-- 1. Non-Correlated Subquery Find all properties where the average rating is greater than 4.0:

SELECT property_id, name
FROM properties
WHERE property_id IN (
    SELECT property_id
    FROM reviews
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
)
ORDER BY property_id;

--  2. Correlated Subquery Find all users who have made more than 3 bookings:

SELECT user_id, first_name, last_name
FROM users
WHERE (
    SELECT COUNT(*)
    FROM bookings
    WHERE bookings.user_id = users.user_id
) > 3
ORDER BY user_id;
