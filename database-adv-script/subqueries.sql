SELECT property_id, name
FROM properties
WHERE property_id IN (
    SELECT property_id
    FROM reviews
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
)
ORDER BY property_id;


SELECT user_id, first_name, last_name
FROM users
WHERE (
    SELECT COUNT(*)
    FROM bookings
    WHERE bookings.user_id = users.user_id
) > 3
ORDER BY user_id;
