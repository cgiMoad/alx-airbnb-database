SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM 
    User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC, u.last_name, u.first_name;

-- Alternative query showing only users who have made bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM 
    User u
    INNER JOIN Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC, u.last_name, u.first_name;

-- =================================================================
-- 2. PROPERTY RANKING BY TOTAL BOOKINGS
-- =================================================================
-- Query using window functions to rank properties based on 
-- total number of bookings received

-- Using ROW_NUMBER() - assigns unique sequential numbers
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_rank
FROM 
    Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;

-- Using RANK() - assigns same rank to ties, skips subsequent ranks
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM 
    Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;

-- Using DENSE_RANK() - assigns same rank to ties, no gaps in ranking
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank
FROM 
    Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;

-- =================================================================
-- 3. ADVANCED AGGREGATIONS AND WINDOW FUNCTIONS
-- =================================================================

-- Properties ranked by bookings within each location
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank,
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_row_number
FROM 
    Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    p.location, total_bookings DESC;

-- Users with booking statistics and percentile rankings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    AVG(p.pricepernight) AS avg_booking_price,
    SUM(p.pricepernight) AS total_spent,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_count_rank,
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) AS booking_quartile
FROM 
    User u
    INNER JOIN Booking b ON u.user_id = b.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
GROUP BY 
    u.user_id, u.first_name, u.last_name
ORDER BY 
    total_bookings DESC;

-- Monthly booking trends with running totals
SELECT 
    DATE_FORMAT(b.start_date, '%Y-%m') AS booking_month,
    COUNT(b.booking_id) AS monthly_bookings,
    SUM(COUNT(b.booking_id)) OVER (ORDER BY DATE_FORMAT(b.start_date, '%Y-%m')) AS running_total_bookings,
    AVG(COUNT(b.booking_id)) OVER (ORDER BY DATE_FORMAT(b.start_date, '%Y-%m') ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_avg
FROM 
    Booking b
GROUP BY 
    DATE_FORMAT(b.start_date, '%Y-%m')
ORDER BY 
    booking_month;

-- =================================================================
-- 4. PROPERTY PERFORMANCE ANALYSIS
-- =================================================================

-- Comprehensive property analysis with multiple metrics
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS total_reviews,
    SUM(p.pricepernight) AS total_revenue,
    
    -- Rankings
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    RANK() OVER (ORDER BY COALESCE(AVG(r.rating), 0) DESC) AS rating_rank,
    RANK() OVER (ORDER BY SUM(p.pricepernight) DESC) AS revenue_rank,
    
    -- Percentiles
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    PERCENT_RANK() OVER (ORDER BY COALESCE(AVG(r.rating), 0)) AS rating_percentile,
    
    -- Performance categories
    CASE 
        WHEN COUNT(b.booking_id) >= 10 THEN 'High Demand'
        WHEN COUNT(b.booking_id) >= 5 THEN 'Medium Demand'
        WHEN COUNT(b.booking_id) > 0 THEN 'Low Demand'
        ELSE 'No Bookings'
    END AS demand_category
FROM 
    Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC, avg_rating DESC;
