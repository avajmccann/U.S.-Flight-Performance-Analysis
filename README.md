# U.S. Flight Performance Analysis

Business intelligence project analyzing **7M+ domestic flights across 14 carriers and 150+ airports in 2025**, built to identify where and why delays happen, and whether they're predictable from volume, route, carrier, or weather.

[Tableau Public Viz](https://public.tableau.com/app/profile/ava.mccann/viz/2025DomesticFlightAnalysis/Airports)

---

## Business Questions

- Do the top carriers at an airport perform better on delays than the airport average, or does carrier choice not matter much?
- How do delays accumulate through the day at high-volume airports — do they snowball, or reset?
- Which airports have the widest gap between inbound and outbound delay, and what does that say about how well they recover?
- Which airports are most weather-vulnerable, and is there a common thread (region, runway count, station proximity)?
- Do an airport's peak-volume month and peak-delay month actually line up?
- What's the real probability a flight gets delayed 15+ minutes, by airport?

## Key Findings

## Dashboard

**Airports view** — national delay patterns by volume, time of day, day of week, and month, plus a flight-volume-vs-delay-rate scatter to test whether busier airports are structurally more delay-prone.

**Airlines view** — route networks by carrier, on-time performance and cancellation rate by airline, and the highest-delay-rate routes across the network.


## Data & Architecture

Built on a bronze → silver → gold (medallion) model in BigQuery:

| Layer | Contents |
|---|---|
| **Bronze (raw)** | 2025 domestic flight data (BTS), FAA airport runway data — loaded as-is |
| **Silver (refined)** | Type-cleaned flight staging table; cleaned NOAA GSOD weather + station data; airports mapped to their nearest weather station via geospatial join (`ST_GEOGPOINT` / `ST_DISTANCE`) |
| **Gold (analytics)** | A single partitioned, clustered fact table (`fact_flight_delay_analysis`) joining flights + airport metadata + runway counts + nearest-station weather, ready for BI tools |

**Sources:** Bureau of Transportation Statistics (2025 domestic flights), NOAA GSOD (weather observations + station registry), FAA (airport + runway reference data)

## Repo Structure

```
transformations/   # bronze → silver → gold table builds (the pipeline)
analysis/           # exploratory + business-question queries against the gold layer
dashboard/          # dashboard exports and the findings presentation
```

## Future Improvements

- Extend the runway/delay-risk analysis into a full correlation model (started in `airports_by_runway.sql`)
- Add weather station averages (snowfall, wind, precipitation) directly into the weather-vulnerability query, not just cancellation counts
- Move the pipeline from manual `CREATE OR REPLACE TABLE` scripts into dbt for testing, documentation, and lineage
=======
