# COVID-19 Data Exploration — Indonesia (2020 – Sept 2025)

## Overview  
Exploration of COVID-19 data in Indonesia using [Our World in Data](https://ourworldindata.org/covid-deaths).  
Focus: cases, deaths, vaccination progress, and global comparisons.  

**Skills demonstrated**: Joins, CTEs, Window Functions, Aggregates, Views  
**Database**: SQL Server (SSMS)  

---

## Key Questions  
- What percentage of Indonesia’s population was infected?  
- How does Indonesia’s case fatality ratio compare globally?  
- Which countries and continents had the highest infection and death rates?  
- How did vaccination progress over time?  

---

## Key Findings  
- Indonesia infection rate peaked at **XX% of the population**.  
- Case fatality ratio averaged **XX%** compared to the global average of **XX%**.  
- Countries such as A, B, C recorded the highest infection rates.  
- Vaccination doses exceeded 100% of the population due to boosters.  
- Approximately **XX% of Indonesians** received at least one vaccine dose.  

---

## Files  
- `covid19.sql` — all queries covering cases, deaths, and vaccination.  
- `PeopleVaccinatedPercentage` — SQL view for BI tools (Tableau/Power BI).  

---

## How to Use  
1. Open `covid19.sql` in SSMS.  
2. Run queries sequentially from top to bottom.  
3. Connect the final view to a BI tool for visualization.  

---

## Notes  
- Data pulled: September 1, 2025.  
- `NULLIF()` used to avoid divide-by-zero errors.  
- Window functions used for cumulative metrics.  
