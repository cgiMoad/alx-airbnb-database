--1. Total Number of Bookings by Each User (Aggregation)
SELECT user_id, COUNT(*) AS total_bookings
FROM bookings
GROUP BY user_id
ORDER BY total_bookings DESC;

--2. Rank Properties Based on Total Bookings (Window Function)
SELECT property_id, total_bookings,
       ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM (
    SELECT property_id, COUNT(*) AS total_bookings
    FROM bookings
    GROUP BY property_id
) AS property_booking_counts;

