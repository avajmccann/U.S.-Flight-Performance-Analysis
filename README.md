# U.S. Flight Performance Analysis

## Project Background
The US has tens of thousands of daily flights, and one of the biggest issues is flight delays. This project thoroughly analyzes **7M+ domestic flights** across **14 carriers** and **150+ airports** in 2025 to identify where and why delays happen, and whether they're predictable from airport, volume, route or carrier. It uncovers critical insights that will will improve airport and airline response to flight delays.

Insights and recommendations are provided in the following key areas:
- **Airport Volume Analysis**: Evaluation of how different airports handle flight volume and delays, focusing on OTP (On-Time Performance)
- **Airline Level Performance**: An analysis of how airports with more or less volume are impacted by delays.
- **Monthly Trends**: Evaluation of how peak months affect delays.

An interactive Tableau Public dashboard can be viewed [here](https://public.tableau.com/app/profile/ava.mccann/viz/2025DomesticFlightAnalysis/Airports)

The SQL queries utilized to inspect and analyze trends regarding business questions can be found [here](analysis/)

The SQL queries utilized to clean, organize and transform data can be found [here](transformations/)

## Data Structure & Initial Checks

### ERD
The below ERD displays the silver layer, consisting of a main flights table and various weather tables used to map weather stations/weather data to flights. The final gold layer combines `stg_flights_2025` and `weather_by_airport` into OBT for efficient querying. 

<img width="2176" height="1312" alt="image" src="https://github.com/user-attachments/assets/0efd6c94-149e-4d38-83be-677bad2d0503" />

The pipeline was built on a bronze → silver → gold (medallion) model in BigQuery:
| Layer | Contents | Transformation Queries |
|---|---| --- |
| **Bronze (raw)** | 2025 domestic flight data (BTS), FAA airport runway data | [stg_flights.sql](transformations/stg_flights.sql/) |
| **Silver (refined)** | Type-cleaned flight staging table; cleaned NOAA GSOD weather + station data; airports mapped to their nearest weather station via geospatial join (`ST_GEOGPOINT` / `ST_DISTANCE`) |[stg_weather_2025.sql](transformations/stg_weather_2025.sql) [stg_weather_stations.sql](transformations/stg_weather_stations.sql) [airport_weather_station_mapping.sql](transformations/airport_weather_station_mapping.sql) [facts_flight_analysis.sql](transformations/facts_flight_analysis.sql) |
| **Gold (analytics)** | A single partitioned, clustered fact table (`fact_flight_delay_analysis`) joining flights + airport metadata + runway counts + nearest-station weather, ready for BI tools |  |

**Sources:** Bureau of Transportation Statistics (2025 domestic flights), NOAA GSOD (weather observations + station registry), FAA (airport + runway reference data)

## Executive Summary

### Overview of Findings
(Each insight should contain: quantified value, business metric, simple story about historical trend).

## Airport Performance
- Flight volume strongly correlates with delay rate. Of the top 50 airports, the top 5 have a 7% higher delay rate than the bottom 5. (link to query)
- 

## Airline Performance
- There is a -0.1 association between volume and delays for airlines, proving that there is no correlation.
- Airlines handle higher volume better than individual airports

<img width="2620" height="1050" alt="image" src="https://github.com/user-attachments/assets/b3d03f10-4c2b-4999-89f2-a37132f41aaf" />



### Hourly Trends
- Flight volume peaks at 7am with x average flights. The rest of the day stays steady at x average hourly flights.
- Delay volume builds up throughout the day, peaking at 6pm (x% above the average hourly delay).
- The amount of delays corresponds with volume of flights, but it does not happen at the same time.

### Daily Trends
- Highest delays on thurs/sundays but doesn't correlate with flight volume.
  
### Monthly Trends
- Monthly: Flight volume peaks during holidays and summer months (May-August). Volume and delays are correlated.

## Recomendations
Based on the uncovered insights, the following recomendations have been provided:
- With a +0.8 association between volume and delays at airports, handling delays at high-volume locations is crucial. Airlines experiencing dissatisfaction from delays should introduce more personnel to high-volume airports.

