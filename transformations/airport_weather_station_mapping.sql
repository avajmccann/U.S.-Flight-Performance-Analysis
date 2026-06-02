/*
  Query Name: airport_weather_station_mapping
  Purpose: Takes all airports and their geometries and maps them to the closest weather station

  Source Tables:
    airline-delays-analytics.silver_refined.stg_flights_2025
    bigquery-public-data.faa.us_airports
    airline-delays-analytics.silver_refined.stg_weather_stations
  Output:
    airline-delays-analytics.silver_refined.airport_weather_mapping
*/

CREATE OR REPLACE TABLE `airline-delays-analytics.silver_refined.airport_weather_mapping` AS
WITH base_airports AS (
  -- 1. Get ONLY your relevant airports and ensure they have valid coordinates
  SELECT 
    faa_identifier AS airport_code,
    SAFE.ST_GEOGPOINT(longitude, latitude) AS airport_geom
  FROM `bigquery-public-data.faa.us_airports`
  WHERE faa_identifier IN (
      SELECT DISTINCT origin_airport FROM `airline-delays-analytics.silver_refined.stg_flights_2025`
      UNION DISTINCT
      SELECT DISTINCT dest_airport FROM `airline-delays-analytics.silver_refined.stg_flights_2025`
  )
)
SELECT 
  a.airport_code,
  s.wban AS closest_station_wban,
  s.stn_wban_id AS stn_wban_id,
  s.state AS state,
  s.station_name AS station_name,
  ST_DISTANCE(a.airport_geom, s.station_geom) AS distance_meters
FROM base_airports a
CROSS JOIN `airline-delays-analytics.silver_refined.stg_weather_stations` s
WHERE a.airport_geom IS NOT NULL 
  AND s.station_geom IS NOT NULL
-- This ensures the rank resets for every airport
QUALIFY ROW_NUMBER() OVER(PARTITION BY a.airport_code ORDER BY ST_DISTANCE(a.airport_geom, s.station_geom) ASC) = 1;
