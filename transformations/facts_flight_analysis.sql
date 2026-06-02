/*
  Query Name: facts_flight_analysis
  Purpose: Creates final obt for flight analysis.

  Source Tables:
    airline-delays-analytics.silver_refined.stg_weather_2025
    airline-delays-analytics.silver_refined.airport_weather_mapping
    airline-delays-analytics.bronze_raw.airport_runways
    airline-delays-analytics.silver_refined.stg_flights_2025
    bigquery-public-data.faa.us_airports
  Output: 
    airline-delays-analytics.gold_analytics.fact_flight_delay_analysis
*/

-- 1. DEFINE THE TABLE SETTINGS
CREATE OR REPLACE TABLE `airline-delays-analytics.gold_analytics.fact_flight_delay_analysis`
PARTITION BY fl_date
CLUSTER BY carrier_code, origin_airport
AS

-- Map weather to airport
WITH weather_base AS (
  SELECT 
    m.airport_code,
    w.*
  FROM `airline-delays-analytics.silver_refined.stg_weather_2025` w
  JOIN `airline-delays-analytics.silver_refined.airport_weather_mapping` m
    ON w.stn_wban_id = m.stn_wban_id
),

runways AS (
SELECT
  r.ARPT_ID,
  r.ARPT_NAME,
  COUNT(*) AS num_runways,
  ROUND(AVG(RWY_LEN)) AS avg_runway_len,
FROM `airline-delays-analytics.bronze_raw.airport_runways` r
JOIN airline-delays-analytics.silver_refined.airport_weather_mapping a 
ON a.airport_code = r.ARPT_ID
GROUP BY 1, 2
)

SELECT 
  -- Flight data
  f.*,
  EXTRACT(HOUR FROM f.scheduled_dep_time) AS scheduled_dep_hour,
  EXTRACT(HOUR FROM f.actual_dep_time) AS actual_dep_hour,
  -- Airport data & location
  a.name,
  a.service_city,
  a.state_abbreviation,
  a.latitude,
  a.longitude,
  r.num_runways,
  r.avg_runway_len,
  -- Weather data
  w.avg_temp_f,
  w.visibility_miles,
  w.wind_speed_knots,
  w.precipitation_inches,
  w.snow_depth_inches

FROM `airline-delays-analytics.silver_refined.stg_flights_2025` f
-- Join the Airport Geography
LEFT JOIN `bigquery-public-data.faa.us_airports` a 
  ON f.origin_airport = a.faa_identifier
LEFT JOIN runways r
  ON r.ARPT_ID = f.origin_airport
-- Join the Weather based on Date and Airport
LEFT JOIN weather_base w 
  ON f.fl_date = w.date
  AND f.origin_airport = w.airport_code;
