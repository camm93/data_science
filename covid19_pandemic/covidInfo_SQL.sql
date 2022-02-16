
/*
Covid19 Pandemic Data Exploration
*/

-- Data Exploration
SELECT * FROM covidProject..CovidDeaths$ where continent IS NOT NULL order by 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covidProject..CovidDeaths$ order by 1, 2

-- Total cases vs population. Shows what percentage of population has contracted Covid in Colombia (or remove filter).
SELECT location, population, date,  total_cases, (total_cases/population)*100 AS infection_percentage 
FROM covidProject..CovidDeaths$ 
where location like '%colombia%' and continent IS NOT NULL order by 1, 2

-- Total cases vs Total deaths. Likelihood of dying of Covid by contry
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM covidProject..CovidDeaths$ 
where continent IS NOT NULL order by 1, 2

-- Looking at countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) AS HighestDeathCount
FROM covidProject..CovidDeaths$ where continent IS NOT NULL 
Group by location order by HighestDeathCount desc


-- Queries for Tableau Visualization
-- Stats by continent

-- Overall Global cases, deaths and death percentage.
-- 1.
SELECT sum(new_cases) AS Global_total_cases, sum(cast(new_deaths as int)) AS Global_total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 AS Death_percentage 
FROM covidProject..CovidDeaths$ 
WHERE continent IS NOT NULL order by 1, 2

-- Using continent and subquery. Continent vs deaths
-- 2.
SELECT continent, sum(death_per_country) AS deaths_per_continent 
FROM (SELECT continent, max(cast(total_deaths as int)) AS death_per_country 
		from covidProject..CovidDeaths$ where continent IS NOT NULL group by continent, location) t 
		group by continent order by deaths_per_continent desc

-- Looking at countries with highest infection rate compared to population. Accumulated
-- 3.
SELECT dea.continent, dea.location, dea.population,MAX(dea.total_cases) AS Infection_Count, 
(MAX(dea.total_cases)/dea.population)*100 AS PercentPopulationInfected, sum(cast(new_deaths as int)) AS Death_count, 
(sum(cast(new_deaths as int))/dea.population)*100 AS PercentPopulationDead,
sum(cast(vac.new_vaccinations as bigint)) AS Vaccine_doses_administered
FROM covidProject..CovidDeaths$ dea 
JOIN covidProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL Group by dea.location, dea.population, dea.continent order by 2
	

-- Daily Infection rate per Country
-- 4.
SELECT Location, Date, Population, total_cases, ((total_cases)/population)*100 AS PercentPopulationInfected 
FROM covidProject..CovidDeaths$ where continent IS NOT NULL order by PercentPopulationInfected desc


-- Extra for dashboard
-- Daily Global new cases vs global new deaths. Daily Global infection and death rates.
-- 5.
SELECT date, sum(new_cases) AS Daily_cases, sum(cast(new_deaths as int)) AS Daily_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 AS Death_percentage 
FROM covidProject..CovidDeaths$ 
WHERE continent IS NOT NULL Group by date order by 1, 2


-- Looking at Daily Infection vs Deaths vs Vaccinations Per Country
-- 6 Daily Vaccinations, total and percentage per date and location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed_per_million, 
dea.new_cases_per_million, dea.new_deaths_per_million
FROM covidProject..CovidDeaths$ dea JOIN covidProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL order by 2,3




-- Other queries not used in Tableau

-- Looking at Total Population vs Vaccinations

-- New vaccinations per day, total and percentage per date and location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS Vaccination_count
FROM covidProject..CovidDeaths$ dea JOIN covidProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL order by 2,3



-- using CTE to perform calculations on Partition By in previous query
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, Vaccination_count)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS Vaccination_count
FROM covidProject..CovidDeaths$ dea JOIN covidProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL --order by 2,3
)
Select *, (Vaccination_count/Population)*100 AS Vaccination_percentage From PopvsVac order by 2,3



-- TEMP TABLE to carry out operations on Partition By in previous query.
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Vaccination_race numeric
)

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS Vaccination_race
FROM covidProject..CovidDeaths$ dea JOIN covidProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL order by 2,3

Select *, (Vaccination_race/Population)*100 From #PercentPopulationVaccinated





-- Creating view to store data for later visualizations
GO 
Create or Alter View PercentPopulationVaccinated as 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS Vaccination_race
	FROM covidProject..CovidDeaths$ dea JOIN covidProject..CovidVaccinations$ vac
	ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL

GO