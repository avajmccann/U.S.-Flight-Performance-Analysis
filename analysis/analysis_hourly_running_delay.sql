/*
  Query Name: analysis_hourly_running_delay
  Business Question: How do delays accumulate during the day at high volume airports? Do they get worse as the day goes on or only during busy hours?
  Purpose: Return all high volume airports' average delay and running average for each hour of flights.
  Notes: Exclude cancelled flights
*/

# Hourly stats for each airport
WITH hourly_stats AS (
  SELECT
    origin_airport,
    scheduled_dep_hour,
    ROUND(AVG(dep_delay), 2) AS avg_hourly_delay,
    COUNT(*) AS num_flights
  FROM `airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
  WHERE is_cancelled = 0
  GROUP BY 1, 2
),

# total volume of each airport, filter out low volume airports
airport_volume AS (
  SELECT
    origin_airport,
    SUM(num_flights) AS total_airport_flights
  FROM hourly_stats
  GROUP BY 1
  HAVING total_airport_flights > 20000
)

SELECT
  h.origin_airport,
  h.scheduled_dep_hour,
  h.avg_hourly_delay,
  # Running average
  ROUND(AVG(h.avg_hourly_delay) OVER ( 
    PARTITION BY h.origin_airport
    ORDER BY h.scheduled_dep_hour
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)
    AS cumulative_running_avg_delay
FROM hourly_stats h
JOIN airport_volume a ON a.origin_airport = h.origin_airport
ORDER BY 1, 2