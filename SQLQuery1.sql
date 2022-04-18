SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT NULL
ORDER BY 1,2

--Looking At Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking At Total Cases vs Population

SELECT location, date, total_cases, total_deaths,(total_cases /population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking At Highest Infection Rate Compared To Population
SELECT location, population, MAX(total_cases) AS TotalCases,MAX(total_cases /population)*100 AS ParcentInfection
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY ParcentInfection DESC

--Looking At Highest Death Count Per Population
SELECT location, population, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathCount DESC


--Showing Continets With Highest Death Count Per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS ContinentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY ContinentDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS GlobalCase, SUM(CAST(total_deaths AS int)) AS GlobalDeath, 
SUM(CAST(total_deaths AS int)/total_cases)*100 AS WorldDeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination  vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking At Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.population,dea.Date,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.Date) AS RollingPopVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.Date = vac.Date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

--USE CTE

With PopsVac (Continent, location, population, date, new_vaccinations, RollingPopVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.population,dea.date,vac.new_vaccinations
,SUM(CONVERT( bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPopVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPopVaccinated/population)*100 AS PercentVaccinated
FROM PopsVac

--TEPM TABLE
DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPopVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY vac.new_vaccinations
SELECT *, (RollingPopVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization
Create View PercentpopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPopVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentpopulationVaccinated

