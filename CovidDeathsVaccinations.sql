SELECT *
FROM PortfolioProject..['COVID_Deaths$']
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['COVID_Vaccinations$']
--ORDER BY 3,4

-- Select data that we are going to use 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['COVID_Deaths$']
WHERE continent is not null
ORDER BY 1,2

-- Looking at total cases VS total deaths 
-- Highlights the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as numeric))/(cast(total_cases as numeric))*100 AS death_percentage
FROM PortfolioProject..['COVID_Deaths$']
WHERE location like '%states%' AND
	continent is not null
ORDER BY 1,2

-- Looking at total cases vs population 
-- Shows what % of population contracted COVID

SELECT location, date, population, total_cases, (cast(total_cases as numeric))/(cast(population as numeric))*100 AS contracted_percentage
FROM PortfolioProject..['COVID_Deaths$']
WHERE location like '%states%' AND
	continent is not null
ORDER BY 1,2

-- Looking at countries with highest infection rate in relation to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, (cast(MAX(total_cases) as numeric))/(cast(population as numeric))*100 AS percent_population_infected
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing countries with highest death counts per population

SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

-- BREAKING IT DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

-- Showing continents with highest death counts per population

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS 

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..['COVID_Deaths$'] dea
JOIN PortfolioProject..['COVID_Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..['COVID_Deaths$'] dea
JOIN PortfolioProject..['COVID_Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..['COVID_Deaths$'] dea
JOIN PortfolioProject..['COVID_Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

-- 1. Percentage of Vaccinated Population
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..['COVID_Deaths$'] dea
JOIN PortfolioProject..['COVID_Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

-- 2. Continent with Highest Death Caused by COVID
CREATE VIEW HighestCOVIDDeathContinent AS
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
-- ORDER BY total_death_count DESC

-- 3. Global COVID Cases and Death Percentages
CREATE VIEW GlobalCOVIDCases AS
-- SET ARITHABORT OFF
-- SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Collecting Tables for Tableau Visualizations 

-- 1. Global COVID Cases and Death Percentages
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- 2. Total Death Count Based on Continents
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
WHERE continent is null 
	AND location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'Low income', 'High income')
GROUP BY location
ORDER BY total_death_count DESC

-- 3. Global Percent Population Infected 
SELECT location, population, MAX(total_cases) AS highest_infection_count, (cast(MAX(total_cases) as numeric))/(cast(population as numeric))*100 AS percent_population_infected
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- 4. Global Percent Population Infected with Date
SELECT location, population, date, MAX(total_cases) AS highest_infection_count, (cast(MAX(total_cases) as numeric))/(cast(population as numeric))*100 AS percent_population_infected
FROM PortfolioProject..['COVID_Deaths$']
-- WHERE location like '%states%'
GROUP BY location, population, date
ORDER BY percent_population_infected DESC

SELECT continent, location, date, population, total_deaths
FROM PortfolioProject..['COVID_Deaths$']
WHERE continent is null
GROUP BY continent, location, date, population, total_deaths
ORDER BY 2,3