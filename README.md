# U.S. Flight Performance Analysis

## Project Background
The US has tens of thousands of daily flights, and one of the biggest issues is flight delays. This project thoroughly analyzes **7M+ domestic flights** across **14 carriers** and **150+ airports** in 2025 to identify where and why delays happen, and whether they're predictable from airport, volume, route or carrier. It uncovers critical insights on a broad scale across all domestic airports and airlines that will improve airport and airline response to flight delays.

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
- Flight volume strongly correlates with delay rate. Of the top 50 airports, the top 5 have a 7% higher delay rate than the bottom 5. (link to query) (query to write: Top 50 airports, with delay rates. Then write another query getting average of top 5, and bottom 5). 
- The top 5 airports by volume have a correlation rate of **0.791** between flight volume and delay length. The correlation rate gets lower as more airports with less flight volume are included, with **0.448** for the top 50, and **0.315** for the top 100 airports in the country by volume.

## Airline Performance
- Across **14 carriers and 168 months**, the correlation between flight volume and delays is **0.027**, proving there is no correlation.
- Do airlines handle delays better in their 'home airport'? [Query](analysis_airline_dominance.sql)
- What percent of an airline's delays originate at the top 5 & 10 most delayed airports?

<img width="2620" height="1050" alt="image" src="https://github.com/user-attachments/assets/b3d03f10-4c2b-4999-89f2-a37132f41aaf" />

### Hourly Trends
- The length of delays increases steadily throughout the day, at an average of **1.08 minutes per hour** until 9pm. Across all airports, the average delay starts at **2.84 minutes at 5am** and the peak ends at **22.84 minutes at 9pm**. [Query](analysis/analysis_hourly_running_delay.sql)
- Across all airports, flight volume peaks at 7 and 8am with **6.31k** and **6.48k** flights. The rest of the day stays steady between **5k** and **4.9k** hourly flights until 8pm, when it drops from **4.3k** to **1.3k** flights at 11pm. [Query](analysis/analysis_hourly_flight_volume.sql)

### Daily Trends
- What weekdays have the most & least delays?
- What weekday have the most & least flights?
  
### Monthly Trends
- What months have the most & least delays?
- What months have the most & least flights?
- How much higher are holiday flight volumes & delays than the average for that month?

## Recomendations
Based on the uncovered insights, the following recomendations have been provided:
- With a +0.8 association between volume and delays at top 5 airports, handling delays at high-volume locations is crucial. Airlines experiencing dissatisfaction from delays should introduce more personnel to high-volume airports at the origin of the flight.

