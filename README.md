# Covid19DataExploration

**Dataset:** Our World in Data (OWID)  
**Source:** https://ourworldindata.org/covid-deaths  

**Pulled:** September 1, 2025  
**Skills:** Joins, CTEs, Window Functions, Aggregates, Views, Data Type Conversion  
**Scope:** Cases, deaths, and vaccination progress (focus on Indonesia; global cuts included for context)  

---

## How to use

Run the script top-to-bottom in SQL Server (SSMS).  
Tables used: Portfolio..CovidCase and Portfolio..CovidVac.  
All calculations avoid divide-by-zero with NULLIF() and handle daily → cumulative with window functions.  

---

## Query outline

1. **Preview raw deaths table**  
   Explore Portfolio..CovidCase  

2. **Working columns (global)**  
   Select country, date, total_cases, new_cases, total_deaths, population from CovidCase.  

3. **Cases vs Population (Indonesia)**  
   Compute % population infected using total_cases / population * 100.  

4. **Deaths vs Cases (Indonesia)**  
   Case fatality ratio: total_deaths / total_cases * 100.  

5. **Total cases vs population (Indonesia)**  
   Same lens as #3, ordered and re-checked by date.  

6. **Highest infection % by country (global)**  
   Max cases and population per country → max(total_cases)/max(population) * 100.  

7. **Highest death % by country (global)**  
   Rank countries by max(total_deaths)/max(population) * 100.  

8. **Continent with most deaths**  
   max(total_deaths) by continent.  

9. **Global summary**  
   Aggregate sum(new_cases), sum(new_deaths), and death-per-case %.  

10. **Indonesia summary**  
    Same as #9 but filtered to Indonesia.  

11. **Vaccination progress (Indonesia)**  
    Join CovidCase × CovidVac; show new_vaccinations + running total TotalDosesperDate.  

12. **Cumulative infection rate (Indonesia)**  
    total_cases / population * 100 by date.  

13. **CTE: doses as % of population (Indonesia)**  
    TotalDosesperDate / population * 100 → PercentTotalDoses (note: doses, can exceed 100%).  

14. **People vaccinated % of population (Indonesia)**  
    Join CovidCase × CovidVac; compute (people_vaccinated / population) * 100.  

15. **View for visualization — PeopleVaccinatedPercentage**  
    Exposes country, date, population, people_vaccinated, pct_people_vaccinated for easy charting.  

---

## Notes & conventions

- Infection rate here = cumulative cases ÷ population  
- PercentTotalDoses uses cumulative doses, not people (can be >100% due to boosters).  
- people_vaccinated is cumulative people with ≥1 dose (≤ population; may have gaps by date).  
- Window functions use PARTITION BY country ORDER BY date for running totals.  
- View PeopleVaccinatedPercentage is ready for BI tools (Power BI/Tableau/Excel).  
