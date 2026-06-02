/*
  Query Name: stg_weather_2025
  Purpose: Clean bigquery noaa weather data

  Source Tables: 
    bigquery-public-data.noaa_gsod.gsod2025
    airline-delays-analytics.silver_refined.stg_weather_stations
  Output: 
    airline-delays-analytics.silver_refined.stg_weather_2025
*/

CREATE OR REPLACE TABLE `airline-delays-analytics.silver_refined.stg_weather_2025`
PARTITION BY date
AS
SELECT
  stn AS station_id,
  wban,
  CONCAT(stn, '-', wban) AS stn_wban_id,
  date,
  # Handle missing data flags as NULLs
  IF(temp = 9999.9, NULL, temp) AS avg_temp_f,
  IF(visib = 999.9, NULL, visib) AS visibility_miles,
  IF(wdsp = '999.9', NULL, CAST(wdsp AS FLOAT64)) AS wind_speed_knots,
  IF(gust = 999.9, NULL, gust) AS max_wind_gust_knots,
  IF(prcp = 99.99, NULL, prcp) AS precipitation_inches,
  IF(sndp = 999.9, NULL, sndp) AS snow_depth_inches
FROM `bigquery-public-data.noaa_gsod.gsod2025`
# Only get stations in already created silver table with US stations
WHERE CONCAT(stn, '-', wban) IN (SELECT stn_wban_id FROM `airline-delays-analytics.silver_refined.stg_weather_stations`);