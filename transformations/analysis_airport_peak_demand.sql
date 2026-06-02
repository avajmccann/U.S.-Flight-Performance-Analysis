/*
  Query Name: analysis_airport_peak_demand
  Business Question: Do peak volume and delay months correlate?
  Purpose: Display airports with their peak volume and delay months, and average delay for each.
*/

WITH airport_monthly_stats AS (
  -- Get each airport with monthly delay data
  SELECT
    origin_airport,
    EXTRACT(MONTH FROM fl_date) AS fl_month,
    COUNT(*) AS flight_volume,
    ROUND(AVG(dep_delay)) as avg_delay_min,
    ROUND(COUNTIF(dep_delay > 15) / COUNT(*), 2) AS delay_probability
  FROM `airline-delays-analytics.silver_refined.stg_flights_2025`
  WHERE is_cancelled = 0
  GROUP BY 1, 2
  HAVING flight_volume > 1000

)

SELECT DISTINCT
  origin_airport,
  -- Peak volume month
  FIRST_VALUE(fl_month) OVER(PARTITION BY origin_airport ORDER BY flight_volume DESC) AS peak_volume_month,
  FIRST_VALUE(avg_delay_min) OVER(PARTITION BY origin_airport ORDER BY flight_volume DESC) AS peak_volume_month_avg_delay,
  -- Peak delay month
  FIRST_VALUE(fl_month) OVER(PARTITION BY origin_airport ORDER BY avg_delay_min DESC) AS peak_delay_month,
  FIRST_VALUE(avg_delay_min) OVER(PARTITION BY origin_airport ORDER BY avg_delay_min DESC) AS peak_delay_month_avg_delay

FROM airport_monthly_stats
GROUP BY origin_airport, flight_volume, avg_delay_min, fl_month, delay_probability
ORDER BY 3 DESC
