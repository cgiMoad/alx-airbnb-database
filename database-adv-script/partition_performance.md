# Booking Table Partitioning Performance Report

## Objective
The `bookings` table had slow performance due to high row volume. To optimize, we partitioned the table by `start_date` into yearly partitions (2023 and 2024).

## Changes Made
- Renamed the original `bookings` table to `bookings_old`.
- Created a new partitioned `bookings` table.
- Defined two partitions: `bookings_2023` and `bookings_2024`.
- Indexed the `start_date` column in each partition.

## Performance Improvement
We ran this query before and after partitioning:

```sql
EXPLAIN ANALYZE
SELECT * FROM bookings
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';
