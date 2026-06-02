/*
  Query Name: stg_weather_stations
  Purpose: Clean data and take specific rows from noaa station public data

  Source Tables: bigquery-public-data.noaa_gsod.stations
  Output: airline-delays-analytics.silver_refined.stg_weather_stations
*/

CREATE OR REPLACE TABLE `airline-delays-analytics.silver_refined.stg_weather_stations` AS
SELECT
  usaf AS station_id,
  wban,
  CONCAT(usaf, '-', wban) as stn_wban_id,
  name AS station_name,
  country,
  state,
  ST_GEOGPOINT(lon, lat) AS station_geom
FROM `bigquery-public-data.noaa_gsod.stations`
WHERE country = 'US' AND state IS NOT NULL