-- Step 1: Rename original bookings table
ALTER TABLE bookings RENAME TO bookings_old;

-- Step 2: Create partitioned parent table
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY,
    user_id UUID,
    property_id UUID,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- Step 3: Create partitions for each year (example: 2023 and 2024)
CREATE TABLE bookings_2023 PARTITION OF bookings
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE bookings_2024 PARTITION OF bookings
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Step 4: Optionally migrate data from old table
-- INSERT INTO bookings SELECT * FROM bookings_old;

-- Step 5: Add indexes to improve performance
CREATE INDEX idx_bookings_2023_start_date ON bookings_2023(start_date);
CREATE INDEX idx_bookings_2024_start_date ON bookings_2024(start_date);
