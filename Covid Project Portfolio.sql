SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3, 4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Total Cases VS Total Deaths	
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%INDONESIA%'
AND continent IS NOT NULL
ORDER BY 1, 2


--Percentage of Population got Covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1, 2


--Countries with highest infection rate compared to population	
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%INDONESIA%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


	
--Countries with highest deaths count per population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY TotalDeathCount DESC


--Countries with highest deaths count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers	
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%INDONESIA%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Total Population VS Vaccinations
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) 
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3


--Use CTE	
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) 
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *
FROM PopvsVac

--Temp Table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) 
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for visualizations	
CREATE View PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) 
AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
