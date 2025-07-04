# Performance Monitoring Report

## Objective
We used `EXPLAIN ANALYZE` to monitor the performance of our most-used queries and refined the schema and indexes based on the insights.

## Query Monitored
```sql
SELECT * FROM bookings
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';
