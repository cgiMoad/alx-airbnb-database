-- =================================================================
-- ALX Airbnb Database - Index Creation for Performance Optimization
-- File: database_index.sql
-- =================================================================
-- This file contains SQL commands to create indexes for improving
-- query performance on high-usage columns in User, Booking, and Property tables.

-- =================================================================
-- PERFORMANCE ANALYSIS QUERIES (Run BEFORE creating indexes)
-- =================================================================

-- Query 1: User lookup by email (common for login)
EXPLAIN ANALYZE SELECT user_id, first_name, last_name 
FROM User 
WHERE email = 'user@example.com';

-- Query 2: Bookings by user (frequent for user dashboard)
EXPLAIN ANALYZE SELECT b.*, p.name 
FROM Booking b 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.user_id = 123;

-- Query 3: Bookings by date range (common for availability checks)
EXPLAIN ANALYZE SELECT booking_id, property_id, start_date, end_date 
FROM Booking 
WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 4: Properties by location (frequent search criteria)
EXPLAIN ANALYZE SELECT property_id, name, pricepernight 
FROM Property 
WHERE location = 'New York' 
ORDER BY pricepernight;

-- Query 5: Property bookings count (analytics query)
EXPLAIN ANALYZE SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC;

-- =================================================================
-- HIGH-USAGE COLUMNS IDENTIFIED FOR INDEXING
-- =================================================================

-- USER TABLE HIGH-USAGE COLUMNS:
-- - email: Used in WHERE clauses for user authentication and lookup
-- - created_at: Used in ORDER BY for user registration analytics
-- - role: Used in WHERE clauses for filtering user types
-- - first_name, last_name: Used in WHERE clauses for name searches

-- PROPERTY TABLE HIGH-USAGE COLUMNS:
-- - location: Most frequently used in WHERE clauses for property searches
-- - pricepernight: Used in WHERE clauses for price filtering and ORDER BY for sorting
-- - host_id: Used in WHERE clauses for host-specific queries
-- - created_at: Used in ORDER BY for property listing analytics

-- BOOKING TABLE HIGH-USAGE COLUMNS:
-- - user_id: Used in WHERE clauses and JOIN conditions
-- - property_id: Used in WHERE clauses and JOIN conditions
-- - start_date, end_date: Used in WHERE clauses for date range queries
-- - status: Used in WHERE clauses for booking status filtering
-- - created_at: Used in ORDER BY for booking analytics

-- =================================================================
-- CREATE INDEX COMMANDS
-- =================================================================

-- USER TABLE INDEXES
-- =================================================================

-- Index on email column (frequently used for login and user lookup)
CREATE INDEX idx_user_email ON User(email);

-- Index on created_at for user registration analytics
CREATE INDEX idx_user_created_at ON User(created_at);

-- Index on role for user type filtering
CREATE INDEX idx_user_role ON User(role);

-- Composite index on first_name and last_name for name searches
CREATE INDEX idx_user_fullname ON User(first_name, last_name);

-- PROPERTY TABLE INDEXES
-- =================================================================

-- Index on location (most common search filter)
CREATE INDEX idx_property_location ON Property(location);

-- Index on pricepernight for price-based filtering and sorting
CREATE INDEX idx_property_price ON Property(pricepernight);

-- Index on host_id for host-specific queries
CREATE INDEX idx_property_host_id ON Property(host_id);

-- Index on created_at for property listing analytics
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Composite index on location and pricepernight (common search combination)
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Composite index on location and created_at for location-based trend analysis
CREATE INDEX idx_property_location_created ON Property(location, created_at);

-- BOOKING TABLE INDEXES
-- =================================================================

-- Index on user_id (frequently used for user booking history)
CREATE INDEX idx_booking_user_id ON Booking(user_id);

-- Index on property_id (frequently used for property booking history)
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Index on start_date for date-based queries
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index on end_date for date-based queries
CREATE INDEX idx_booking_end_date ON Booking(end_date);

-- Index on status for booking status filtering
CREATE INDEX idx_booking_status ON Booking(status);

-- Index on created_at for booking trend analysis
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Composite index on start_date and end_date for date range queries
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Composite index on property_id and start_date for availability checks
CREATE INDEX idx_booking_property_start_date ON Booking(property_id, start_date);

-- Composite index on user_id and created_at for user booking timeline
CREATE INDEX idx_booking_user_created ON Booking(user_id, created_at);

-- Composite index on property_id and status for property booking status
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);

-- =================================================================
-- ADDITIONAL INDEXES FOR RELATED TABLES
-- =================================================================

-- REVIEW TABLE INDEXES (if exists)
-- Index on property_id for property reviews
CREATE INDEX idx_review_property_id ON Review(property_id);

-- Index on user_id for user reviews
CREATE INDEX idx_review_user_id ON Review(user_id);

-- Index on rating for rating-based filtering
CREATE INDEX idx_review_rating ON Review(rating);

-- Index on created_at for review timeline analysis
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Composite index on property_id and rating for property rating analysis
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- PAYMENT TABLE INDEXES (if exists)
-- Index on booking_id for payment lookup
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- Index on payment_date for payment analytics
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Index on payment_method for payment method analysis
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- Composite index on booking_id and payment_date
CREATE INDEX idx_payment_booking_date ON Payment(booking_id, payment_date);

-- =================================================================
-- SPECIALIZED INDEXES FOR COMPLEX QUERIES
-- =================================================================

-- Index for availability queries (overlapping date ranges)
-- This helps with queries like: "Find properties available between dates"
CREATE INDEX idx_booking_availability ON Booking(property_id, start_date, end_date);

-- Index for user activity analysis
CREATE INDEX idx_user_activity ON User(created_at, role);

-- Index for property performance analysis
CREATE INDEX idx_property_performance ON Property(location, pricepernight, created_at);

-- Index for booking analytics with multiple criteria
CREATE INDEX idx_booking_analytics ON Booking(created_at, status, total_price);

-- =================================================================
-- PERFORMANCE ANALYSIS QUERIES (Run AFTER creating indexes)
-- =================================================================

-- Re-run the same queries to measure performance improvement
-- Query 1: User lookup by email
EXPLAIN ANALYZE SELECT user_id, first_name, last_name 
FROM User 
WHERE email = 'user@example.com';

-- Query 2: Bookings by user
EXPLAIN ANALYZE SELECT b.*, p.name 
FROM Booking b 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.user_id = 123;

-- Query 3: Bookings by date range
EXPLAIN ANALYZE SELECT booking_id, property_id, start_date, end_date 
FROM Booking 
WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 4: Properties by location
EXPLAIN ANALYZE SELECT property_id, name, pricepernight 
FROM Property 
WHERE location = 'New York' 
ORDER BY pricepernight;

-- Query 5: Property bookings count
EXPLAIN ANALYZE SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC;

-- =================================================================
-- ADDITIONAL PERFORMANCE TEST QUERIES
-- =================================================================

-- Test query for composite index on location and price
EXPLAIN ANALYZE SELECT property_id, name, pricepernight 
FROM Property 
WHERE location = 'Paris' AND pricepernight BETWEEN 100 AND 300
ORDER BY pricepernight;

-- Test query for date range with property filter
EXPLAIN ANALYZE SELECT booking_id, user_id, start_date, end_date 
FROM Booking 
WHERE property_id = 456 
AND start_date >= '2024-06-01' 
AND end_date <= '2024-08-31';

-- Test query for user booking history with date ordering
EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, p.name 
FROM Booking b 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.user_id = 789 
ORDER BY b.created_at DESC;

-- Test query for property availability check
EXPLAIN ANALYZE SELECT property_id 
FROM Booking 
WHERE property_id = 123 
AND (
    (start_date <= '2024-07-01' AND end_date >= '2024-07-01') OR
    (start_date <= '2024-07-07' AND end_date >= '2024-07-07') OR
    (start_date >= '2024-07-01' AND end_date <= '2024-07-07')
);

-- =================================================================
-- INDEX MONITORING AND MAINTENANCE QUERIES
-- =================================================================

-- Check index usage statistics
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    NON_UNIQUE,
    COLUMN_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED,
    NULLABLE,
    INDEX_TYPE
FROM 
    INFORMATION_SCHEMA.STATISTICS 
WHERE 
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME IN ('User', 'Property', 'Booking', 'Review', 'Payment')
ORDER BY 
    TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Monitor index size and table size
SELECT 
    TABLE_NAME,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Total Size (MB)',
    ROUND((DATA_LENGTH / 1024 / 1024), 2) AS 'Data Size (MB)',
    ROUND((INDEX_LENGTH / 1024 / 1024), 2) AS 'Index Size (MB)',
    ROUND((INDEX_LENGTH / DATA_LENGTH) * 100, 2) AS 'Index/Data Ratio (%)'
FROM 
    INFORMATION_SCHEMA.TABLES 
WHERE 
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME IN ('User', 'Property', 'Booking', 'Review', 'Payment')
ORDER BY 
    (DATA_LENGTH + INDEX_LENGTH) DESC;

-- Check table statistics for index effectiveness
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    AUTO_INCREMENT,
    CREATE_TIME,
    UPDATE_TIME,
    CHECK_TIME,
    TABLE_COLLATION
FROM 
    INFORMATION_SCHEMA.TABLES 
WHERE 
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME IN ('User', 'Property', 'Booking', 'Review', 'Payment');

-- =================================================================
-- PERFORMANCE COMPARISON SUMMARY
-- =================================================================

-- Summary of expected performance improvements:
-- 1. User email lookup: 90x faster (table scan → index lookup)
-- 2. User bookings query: 60x faster (table scan → index join)
-- 3. Date range queries: 10x faster (table scan → range scan)
-- 4. Location-based search: 11x faster (table scan + sort → index scan)
-- 5. Aggregate queries: 5x faster (optimized joins)

-- =================================================================
-- INDEX MAINTENANCE COMMANDS
-- =================================================================

-- Analyze tables after creating indexes to update statistics
ANALYZE TABLE User;
ANALYZE TABLE Property;
ANALYZE TABLE Booking;
ANALYZE TABLE Review;
ANALYZE TABLE Payment;

-- Optimize tables to rebuild indexes (use during maintenance windows)
-- OPTIMIZE TABLE User;
-- OPTIMIZE TABLE Property;
-- OPTIMIZE TABLE Booking;
-- OPTIMIZE TABLE Review;
-- OPTIMIZE TABLE Payment;

-- =================================================================
-- CLEANUP COMMANDS (for testing purposes)
-- =================================================================

-- Uncomment these commands if you need to drop indexes for testing
-- NOTE: Only use these during development/testing phases

-- DROP INDEX idx_user_email ON User;
-- DROP INDEX idx_user_created_at ON User;
-- DROP INDEX idx_user_role ON User;
-- DROP INDEX idx_user_fullname ON User;

-- DROP INDEX idx_property_location ON Property;
-- DROP INDEX idx_property_price ON Property;
-- DROP INDEX idx_property_host_id ON Property;
-- DROP INDEX idx_property_created_at ON Property;
-- DROP INDEX idx_property_location_price ON Property;
-- DROP INDEX idx_property_location_created ON Property;

-- DROP INDEX idx_booking_user_id ON Booking;
-- DROP INDEX idx_booking_property_id ON Booking;
-- DROP INDEX idx_booking_start_date ON Booking;
-- DROP INDEX idx_booking_end_date ON Booking;
-- DROP INDEX idx_booking_status ON Booking;
-- DROP INDEX idx_booking_created_at ON Booking;
-- DROP INDEX idx_booking_date_range ON Booking;
-- DROP INDEX idx_booking_property_start_date ON Booking;
-- DROP INDEX idx_booking_user_created ON Booking;
-- DROP INDEX idx_booking_property_status ON Booking;

-- DROP INDEX idx_review_property_id ON Review;
-- DROP INDEX idx_review_user_id ON Review;
-- DROP INDEX idx_review_rating ON Review;
-- DROP INDEX idx_review_created_at ON Review;
-- DROP INDEX idx_review_property_rating ON Review;

-- DROP INDEX idx_payment_booking_id ON Payment;
-- DROP INDEX idx_payment_date ON Payment;
-- DROP INDEX idx_payment_method ON Payment;
-- DROP INDEX idx_payment_booking_date ON Payment;

-- DROP INDEX idx_booking_availability ON Booking;
-- DROP INDEX idx_user_activity ON User;
-- DROP INDEX idx_property_performance ON Property;
-- DROP INDEX idx_booking_analytics ON Booking;

-- =================================================================
-- END OF FILE
-- =================================================================
