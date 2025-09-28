/*
COVID-19 Data Exploration in Indonesia (2020 – September 2025)
Skills used: Joins, CTEs, Window Functions, Aggregate Functions, Creating Views, Data Type Conversion
Dataset: COVID-19 Data from Our World in Data (OWID)
Source: https://ourworldindata.org/covid-deaths
Data Pulled: September 1, 2025
*/

/* =============================
   1. Data Exploration
   ============================= */

-- Preview raw deaths table
Select *
From Portfolio..CovidCase
Where continent is not null 
order by 3,4;

-- Select working columns (global)
Select country, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidCase
Where continent is not null 
order by 1,2;


/* =============================
   2. Indonesia Case Analysis
   ============================= */

-- Cases vs Population (percentage of population infected)
Select country, date, Population, total_cases,  
       (total_cases / NULLIF(population,0)) * 100 as PercentPopulationInfected
From Portfolio..CovidCase
Where country like '%Indonesia%'
order by 2;

-- Deaths vs Cases (case fatality ratio)
Select country, date, total_cases, new_cases, total_deaths, population, 
       (total_deaths/NULLIF(total_cases,0)) *100 as DeathPercentage
From Portfolio..CovidCase
Where country like '%Indonesia%' and continent is not null
Order by 2 desc;

-- Infection % of population (Indonesia)
Select country, date, total_cases, total_deaths, 
       (total_cases/NULLIF(population,0)) * 100 AS InfectionPercentage
From Portfolio..CovidCase
Where country like '%Indonesia%' and continent is not null 
Order by 1,2;


/* =============================
   3. Global Comparison
   ============================= */

-- Highest infection % by country
select country,
       max(population) as population,
       max(total_cases) as highestinfected,
       cast(round(max(total_cases) * 100.0 / nullif(max(population), 0), 2) as decimal(10,2)) as InfectionPercentage
from portfolio..covidcase
group by country
order by 4 desc;

-- Highest death % by country
Select country,
       max(cast(total_deaths as float)) as TotalDeathCount, 
       cast(max(total_deaths) / NULLIF(max(population),0) * 100 as decimal(10,5)) as DeathPercentage
From Portfolio..CovidCase
Where continent is not null
Group by country
Order by 2 desc;

-- Continent with most deaths (excluding aggregates)
select country, max(cast(total_deaths as float)) as TotalDeathCount
From Portfolio..CovidCase
where continent is null
  and country not in ('World', 'European Union', 'International', 'World excl. China', 'World excl. China and South Korea',
                      'World excl. China, South Korea, Japan and Singapore','High-income countries', 'Upper-middle-income countries', 
                      'Asia excl. China', 'Lower-middle-income countries','Low-income countries','Wales','England','Scotland',
                      'England and Wales','Summer Olympics 2020','Winter Olympics 2022','Northern Ireland','European Union (27)')
group by country
order by 2 desc;


/* =============================
   4. Global & Indonesia Summaries
   ============================= */

-- Global summary
select sum(new_cases) as NewCases, 
       sum(cast(new_deaths as float)) as NewDeaths, 
       sum(cast(new_deaths as float)) / NULLIF(sum(new_cases),0) * 100 as DeathPerCasePercentage
From Portfolio..CovidCase
where continent is not null;

-- Indonesia summary
select country,
       sum(new_cases) as NewCases, 
       sum(cast(new_deaths as float)) as NewDeaths, 
       sum(cast(new_deaths as float)) / NULLIF(sum(new_cases),0) * 100 as DeathPerCasePercentage
From Portfolio..CovidCase
where continent is not null and country like '%Indonesia%'
group by country;


/* =============================
   5. Vaccination Progress (Indonesia)
   ============================= */

-- Daily vaccinations and cumulative doses (window function)
select cases.country,
       cases.date, 
       cases.population, 
       vacs.new_vaccinations,
       sum(vacs.new_vaccinations) OVER (Partition by cases.country Order by cases.Date) as TotalDosesperDate
From Portfolio..CovidCase as cases
join Portfolio..CovidVac as vacs
  on cases.country = vacs.country
 and cases.date = vacs.date
where cases.continent is not null and cases.country like '%Indonesia%'
order by 2;

-- Cumulative infection rate by date (Indonesia)
select country,
       date,
       population,
       total_cases,
       (total_cases * 100.0 / nullif(population,0)) as InfectionRate
from portfolio..covidcase
where country = 'indonesia'
order by date desc;

-- CTE: doses as % of population (Indonesia)
;WITH OverallStat as
(
 Select cases.continent, 
        cases.country, 
        cases.date, 
        cases.population, 
        vacs.new_vaccinations,
        sum(vacs.new_vaccinations) OVER (Partition by cases.country Order by cases.Date) as TotalDosesperDate
 From Portfolio..CovidCase as cases
 join Portfolio..CovidVac as vacs
   on cases.country = vacs.country
  and cases.date = vacs.date
 where cases.continent is not null
)
select *, (TotalDosesperDate/population) * 100 as PercentTotalDoses
from OverallStat
where country = 'Indonesia'
order by 2 desc;

-- People vaccinated % of population (Indonesia)
select cases.date,
       vac.people_vaccinated,
       (vac.people_vaccinated * 100.0 / cases.population) as VaccinatedPeoplePercent
from portfolio..covidcase as cases
join portfolio..covidvac as vac
  on cases.country = vac.country 
 and cases.date = vac.date  
where cases.country = 'indonesia'
  and vac.people_vaccinated is not null
order by vac.date desc;


/* =============================
   6. Final Deliverable View
   ============================= */

-- Drop and recreate view for visualization
drop view if exists PeopleVaccinatedPercentage;
go

create view PeopleVaccinatedPercentage as
select cases.continent,
       cases.country,
       cases.date,
       cases.population,
       vac.people_vaccinated,
       (vac.people_vaccinated * 100.0 / cases.population) as VaccinatedPeoplePercent
from portfolio..covidcase as cases
join portfolio..covidvac as vac
  on cases.country = vac.country
 and cases.date = vac.date
where cases.continent is not null
  and vac.people_vaccinated is not null;
