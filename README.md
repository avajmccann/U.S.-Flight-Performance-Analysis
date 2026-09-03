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
- The top 5 airports by volume have a correlation rate of **0.791** between flight volume and delay length. The correlation rate gets lower as more airports with less flight volume are included, with **0.448** for the top 50, and **0.315** for the top 100 airports in the country by volume.
- Of the top 50 airports, the top five have a 5% higher delay rate (23.96%) than the bottom five (19.05%).
- The top 10 airports share **20.0%** of the total flight volume across all airports. The top 20 share **33.84%**

## Airline Performance
- Across **14 carriers and 168 months**, the correlation between flight volume and delays is **0.027**, proving there is no correlation.
- Do airlines handle delays better in their 'home airport'? [analysis_airline_dominance](analysis_airline_dominance.sql)
- What percent of an airline's delays originate at the top 5 & 10 most delayed airports?
- The top 3 carriers (by volume) share **48.58%** of the total flight volume. The top 5 share **72.01%**. The difference from the 5th to 6th carrier is extreme, with a difference of **450k yearly flights** and drop of 56%.

<img width="2620" height="1050" alt="image" src="https://github.com/user-attachments/assets/b3d03f10-4c2b-4999-89f2-a37132f41aaf" />

### Hourly Trends
- The length of delays increases steadily throughout the day, at an average of **1.08 minutes per hour** until 9pm. Across all airports, the average delay starts at **2.84 minutes at 5am** and the peak ends at **22.84 minutes at 9pm**. [analysis_hourly_running_delay.sql](analysis/analysis_hourly_running_delay.sql)
- Across all airports, flight volume peaks at 7 and 8am with **6.31k** and **6.48k** flights. The rest of the day stays steady between **5k** and **4.9k** hourly flights until 8pm, when it drops from **4.3k** to **1.3k** flights at 11pm. [analysis_hourly_flight_volume.sql](analysis/analysis_hourly_flight_volume.sql)

### Daily Trends
- Across all flights, Sunday and Monday have the most delays, at an average of **25.98% of flights** having delay times longer than 15 minutes.
- Tuesday and Wednesday see the fewest delays with a delay rate of **17.69 and 17.05** respectively.
  
### Monthly Trends
- June, July and December have the highest delay rates. 
- The average flights per month is **575k**. July peaks at **9.74% higher** than the average, and February sits at **12.17%** lower.
- How much higher are holiday flight volumes & delays than the average for that month?

## Recomendations
Based on the uncovered insights, the following recomendations have been provided:
- With a +0.8 association between volume and delays at top 5 airports, handling delays at high-volume locations is crucial. Airlines experiencing dissatisfaction from delays should introduce more personnel to high-volume airports at the origin of the flight.

