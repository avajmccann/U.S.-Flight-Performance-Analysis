/*
  Query Name: analysis_delay_probability
  Business Question: What are the top airports by probability of a delay?
  Purpose: Rank airports by their delay probability
*/

SELECT
  origin_airport,
  COUNT(*) as flight_volume,
  ROUND(AVG(dep_delay)) as avg_delay_min,
  --probability of being delayed
  ROUND(COUNTIF(dep_delay > 15) / COUNT(*), 2) AS delay_probability
FROM `airline-delays-analytics.silver_refined.stg_flights_2025` 
WHERE 
  is_cancelled = 0
  AND scheduled_dep_time IS NOT NULL
GROUP BY 1
HAVING flight_volume >10000
ORDER BY 4 DESC