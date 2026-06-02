/*
  Query Name: airports_by_runway
  Business Question: What airports have the most runways?
  Purpose: Simple query to associate runway number with airports
  Notes: 
    Can be improved to correlate flight volume with runway number & an efficiency ratio to see if it is related to delay risk
*/

SELECT
  r.ARPT_ID,
  r.ARPT_NAME,
  COUNT(*) AS num_runways,
  ROUND(AVG(RWY_LEN)) AS avg_runway_len,
  ROUND(AVG(RWY_WIDTH)) AS avg_runway_width
FROM `airline-delays-analytics.bronze_raw.airport_runways` r
JOIN airline-delays-analytics.silver_refined.airport_weather_mapping a 
ON a.airport_code = r.ARPT_ID
GROUP BY 1, 2
ORDER BY num_runways DESC
LIMIT 1000