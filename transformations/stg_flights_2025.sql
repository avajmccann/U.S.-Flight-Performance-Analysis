# This query will create/replace silver flights table.
# It will partition by FL_DATE, and cluster by carrier & origin
# It will clean FL_DATE to a DATE
# It will clean CRS_DEP_TIME, DEP_TIME, CRS_ARR_TIME, ARR_TIME to TIME
# It will clean DEP_DELAY, ARR_DELAY, CANCELLED, DELAY TYPES to INT
/*
    Query Name: stg_flights_2025.sql
    Purpose: Takes all raw flight data and give fields correct data types.

    Source Tables: airline-delays-analytics.bronze_raw.flights_2025_raw
    Output: airline-delays-analytics.silver_refined.stg_flights_2025

    Notes: Data does not require handling of nulls, only data types need to be cleaned
*/

CREATE OR REPLACE TABLE `airline-delays-analytics.silver_refined.stg_flights_2025`
PARTITION BY fl_date
CLUSTER BY carrier_code, origin_airport
AS
SELECT
  -- Date: Clean MM/DD/YYYY HH:MM:SS AM to YYYY-MM-DD
  DATE(SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', FL_DATE)) AS fl_date,

  -- Carrier
  OP_UNIQUE_CARRIER AS carrier_code,
  ORIGIN AS origin_airport,
  DEST AS dest_airport,

  -- Time Handling. LPAD for single digit hours
  SAFE.PARSE_TIME('%H%M', LPAD(CAST(CAST(CRS_DEP_TIME AS INT64) AS STRING), 4, '0')) AS scheduled_dep_time,
  
  SAFE.PARSE_TIME('%H%M', LPAD(CAST(CAST(CRS_DEP_TIME AS INT64) AS STRING), 4, '0')) AS actual_dep_time,
  -- DEP_DELAY as INT
    SAFE_CAST(DEP_DELAY AS INT64) AS dep_delay,

  -- Time Handling. LPAD for single digit hours
  SAFE.PARSE_TIME('%H%M', LPAD(CAST(CAST(CRS_DEP_TIME AS INT64) AS STRING), 4, '0')) AS scheduled_arr_time,
  SAFE.PARSE_TIME('%H%M', LPAD(CAST(CAST(CRS_DEP_TIME AS INT64) AS STRING), 4, '0')) AS actual_arr_time,
  --ARR_DELAY as INT
    SAFE_CAST(ARR_DELAY AS INT64) AS arr_delay,

  SAFE_CAST(CANCELLED AS INT64) AS is_cancelled,
  CANCELLATION_CODE AS cancellation_code,

  SAFE_CAST(CARRIER_DELAY AS INT64) AS carrier_delay_min,
  SAFE_CAST(WEATHER_DELAY AS INT64) AS weather_delay_min,
  SAFE_CAST(NAS_DELAY AS INT64) AS nas_delay_min,
  SAFE_CAST(SECURITY_DELAY AS INT64) AS security_delay_min,
  SAFE_CAST(LATE_AIRCRAFT_DELAY AS INT64) AS late_aircraft_delay_min

FROM `airline-delays-analytics.bronze_raw.flights_2025_raw`