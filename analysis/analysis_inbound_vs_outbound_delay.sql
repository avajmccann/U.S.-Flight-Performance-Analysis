/* 
  Query Name: analysis_inbound_vs_outbound_delay
  Business Question: How do airports handle inbound versus outbound delay?
  Purpose: Ranks airports by difference in their inbound and outbound delay to display friction, if any.
  Notes: Data will be averaged for the whole year
*/

# Only get top 100 airports
WITH fl_volume AS (
  SELECT 
    origin_airport,
    COUNT(*) AS fl_volume
  FROM`airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 100
),

# Get the destination airport and arr times
inbound_delay AS (
  SELECT
    dest_airport,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,
  FROM `airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
  GROUP BY 1
),

# Get origin airports and dep times
outbound_delay AS (
  SELECT
    origin_airport,
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay
  FROM `airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
  GROUP BY 1
)

SELECT
  f.origin_airport AS airport,
  f.fl_volume,
  i.avg_arr_delay AS avg_inbound_delay,
  o.avg_dep_delay AS avg_outbound_delay
FROM fl_volume f
LEFT JOIN inbound_delay i
  ON f.origin_airport = i.dest_airport
LEFT JOIN outbound_delay o
  ON f.origin_airport = o.origin_airport
ORDER BY f.fl_volume DESC
LIMIT 1000
