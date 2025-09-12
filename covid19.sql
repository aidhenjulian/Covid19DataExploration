/*
COVID-19 Data Exploration in Indonesia (2020 – September 2025)
Skills used: Joins, CTEs, Window Functions, Aggregate Functions, Creating Views, Data Type Conversion
Dataset: COVID-19 Data from Our World in Data (OWID)
Source: https://ourworldindata.org/covid-deaths
Data Pulled: September 1, 2025

*/

Select *
From Portfolio..CovidCase
Where continent is not null 
order by 3,4


-- Select Data that ill be using (Including all country accross the world)

Select country, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidCase
Where continent is not null 
order by 1,2


-- Cases vs Population
-- Shows percentage of population infected by Covid-19

Select country, date, Population, total_cases,  (total_cases / NULLIF(population,0)) * 100 as PercentPopulationInfected
From Portfolio..CovidCase
Where country like '%Indonesia%'
order by 2


-- Total Case vs Total Death (ratio)
Select country, date, total_cases, new_cases, total_deaths, population, (total_deaths/NULLIF(total_cases,0)) *100 as DeathPercentage
From Portfolio..CovidCase
Where country like '%Indonesia%'  and continent is not null
Order by 2 desc

-- Total Cases vs Population
-- How much percentage of population infected by covid
Select country, date, total_cases, total_deaths, (total_cases/NULLIF(population,0)) * 100 AS InfectionPercentage
From Portfolio..CovidCase
Where country like '%Indonesia%' and continent is not null 
Order by 1,2


--Country that have highest infection percentage per population
Select 
country,
max(population) AS population,
max(total_cases) AS HighestInfected,
max(total_cases) / NULLIF(max(population), 0) * 100 AS InfectionPercentage
From Portfolio..CovidCase
Group by country
Order by 4 desc;


--Country which have highest death percent per population
Select country,
max(cast(total_deaths as float)) as TotalDeathCount, 
max(total_deaths) / NULLIF(max(population),0) * 100 as DeathPercentage
From Portfolio..CovidCase
Where continent is not null
Group by country
Order by 2 desc

--CONTINENT
--Continent with most deaths case
select continent, max(cast(total_deaths as float)) as TotalDeathCount
From Portfolio..CovidCase
where continent is not null
group by continent
order by 2 desc

-- Global data
select sum(new_cases) as NewCases, 
sum(cast(new_deaths as float)) as NewDeaths, 
sum(cast(new_deaths as float)) / NULLIF(sum(new_cases),0) * 100 as DeathPerCasePercentage
From Portfolio..CovidCase
where continent is not null

--Indonesia data

select country,
sum(new_cases) as NewCases, 
sum(cast(new_deaths as float)) as NewDeaths, 
sum(cast(new_deaths as float)) / NULLIF(sum(new_cases),0) * 100 as DeathPerCasePercentage
From Portfolio..CovidCase
where continent is not null and country like '%Indonesia%'
group by country

-- calculates the daily number of vaccinations and a running total using a window function to show how vaccination progressed over time.
select
cases.country,
cases.date, 
cases.population, 
vacs.new_vaccinations,
sum(vacs.new_vaccinations) OVER (Partition by cases.country Order by cases.Date) as TotalDosesperDate
From Portfolio..CovidCase as cases
join Portfolio..CovidVac as vacs
on cases.country = vacs.country
and cases.date = vacs.date
where cases.continent is not null and cases.country like '%Indonesia%'
order by 2 -- Selecting only date because the data already filtered on where clause

-- Calculating cumulative infection rate (total cases as a percentage of population) for Indonesia by date
select
country,
date,
population,
total_cases,
(total_cases * 100.0 / nullif(population,0)) as InfectionRate
from portfolio..covidcase
where country = 'indonesia'
order by date desc;

-- Using CTE to add aggregation to TotalDosesperDate divided by population
-- Need to put a semicolon (;) before WITH so SQL Server knows this is a CTE
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
order by 2 desc 

-- Joining CovidCase and CovidVac to calculate people_vaccinated as a percentage of population by date
select
cases.date,
vac.people_vaccinated,
(vac.people_vaccinated * 100.0 / cases.population) as VaccinatedPeoplePercent
from portfolio..covidcase as cases
join portfolio..covidvac as vac
  on cases.country = vac.country 
 and cases.date = vac.date  
where cases.country = 'indonesia'
  and vac.people_vaccinated is not null
order by vac.date desc;


-- Drop view if exists
drop view if exists PeopleVaccinatedPercentage;
go

-- Create View for Visualization
create view PeopleVaccinatedPercentage as
select
  cases.continent,
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