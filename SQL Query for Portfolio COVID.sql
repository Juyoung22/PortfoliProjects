-- Select data I'm going to be using
-- This data is from 2-20-2022

SELECT *
FROM CovidDeaths
order by 3,4

SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM CovidDeaths 
ORDER BY 1, 2

-- Look at total cases vs total deaths 
-- Shows likelihood of dying(DeathPercentage) if you tested positive covid based on where you live

SELECT Location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS Death_Percentage
FROM CovidDeaths 
WHERE location like '%States%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date,population, total_cases, (total_cases / population) * 100 AS Percent_Population_Infected
FROM CovidDeaths 
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to populations

SELECT Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases / population)) * 100 AS Percent_Population_Infected
FROM CovidDeaths 
GROUP BY location, population 
ORDER BY Percent_Population_Infected DESC

-- Showing coutries with highest death count per population

SELECT Location, MAX(cast(total_deaths as Int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Lets Break things down by CONTINENT
-- Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as Int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;



-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases,SUM(cast (new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths 
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2
 


 -- Looking at Total population vs Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations v --you can also alias without inputting 'AS'
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

-- USING CTE 

WITH PopulationvsVaccination (continent, location, date, population, new_vaccination, Rolling_People_Vaccinated)
as (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations v --you can also alias without inputting 'AS'
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null AND v.continent is not null
)
SELECT *, (Rolling_People_Vaccinated /population) * 100 
FROM PopulationvsVaccination

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_People_Vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations v --you can also alias without inputting 'AS'
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null AND v.continent is not null

SELECT *, (Rolling_People_Vaccinated /population) * 100
FROM #PercentPopulationVaccinated





-- Creating VIEW to store data for later visualizations
-- This view is permanent unlike Temp Table

CREATE VIEW PercentPopulationVaccinated as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations v --you can also alias without inputting 'AS'
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null AND v.continent is not null

SELECT *
FROM PercentPopulationVaccinated