/*
  Query Name: analysis_airline_dominance
  Business Question: Do top carriers at an airport perform better (delay wise) than other airlines to a noticeable degree?
  Purpose: Identifies the top carrier at an airport and compares the carrier's average delay to the airport's average.
*/

WITH base_metrics AS (
  SELECT 
    origin_airport,
    carrier_code,
    COUNT(*) AS carrier_flight_volume,
    #carrier delay rate (not cancelled)
    ROUND(AVG(CASE WHEN is_cancelled = 0 THEN dep_delay END), 2) AS avg_carrier_delay,
    #carrier cancellation rate
    ROUND(AVG(is_cancelled) * 100, 2) AS carrier_cancellation_raate
  FROM `airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
  GROUP BY 1, 2
)

SELECT DISTINCT
  origin_airport,
  FIRST_VALUE(carrier_code) OVER(PARTITION BY origin_airport ORDER BY carrier_flight_volume DESC) AS top_carrier,
  carrier_flight_volume,
  avg_carrier_delay,
  ROUND(AVG(avg_carrier_delay) OVER(PARTITION BY origin_airport), 2) AS avg_airport_delay
FROM base_metrics 
ORDER BY carrier_flight_volume DESC
LIMIT 50