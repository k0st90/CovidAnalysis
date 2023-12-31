/*

Queries used for Tableau Project will be marked with *

*/

-- Total deaths *
Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Countries with highest Illness Rate in comparison to population *
SELECT 
Location, population, MAX(total_cases) HighestInfectionCount, MAX(CASE WHEN population != 0 THEN total_cases / population*100 ELSE NULL END) AS illness_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY illness_rate desc

-- Countries with highest Illness Rate in comparison to population with date*
SELECT 
Location, date, population, MAX(total_cases) HighestInfectionCount, MAX(CASE WHEN population != 0 THEN total_cases / population*100 ELSE NULL END) AS illness_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location, population, date
ORDER BY illness_rate desc

--Global *
SELECT 
SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, CASE WHEN SUM(new_cases) != 0 THEN  SUM(new_deaths) / SUM(new_cases)*100 ELSE NULL END AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2;



======================================




--Checking
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Total Cases vs Total Deaths
SELECT 
Location, date, total_cases, total_deaths, CASE WHEN total_cases != 0 THEN total_deaths / total_cases*100 ELSE NULL END AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2;

-- Total Cases vs Population
SELECT 
Location, date, total_cases, population, CASE WHEN population != 0 THEN total_cases / population*100 ELSE NULL END AS illness_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2;

--Countries with Highest Death Count per Population
SELECT 
Location, MAX(total_deaths) AS Total_deathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY Total_deathsCount desc

-- Continents with the highest deathCount
SELECT 
location, MAX(total_deaths) AS Total_deathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY Total_deathsCount desc

-- Total Population vs Vaccinations
WITH PvsV (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location AND dea.date = vacc.date
where dea.continent IS NOT NULL
)
SELECT *, CASE WHEN population!=0 THEN (RollingPeopleVaccinated/population)*100 ELSE population END AS Vacc_rate
FROM PvsV

-- Total Population vs Vaccinations TEMPTABLE (the same output different query)
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric, 
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--INSERT INTO #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
--SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vacc
--on dea.location = vacc.location AND dea.date = vacc.date
--where dea.continent IS NOT NULL

--SELECT *, CASE WHEN population!=0 THEN (RollingPeopleVaccinated/population)*100 ELSE population END AS Vacc_rate
--FROM #PercentPopulationVaccinated

--VIEWS 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vacc
on dea.location = vacc.location AND dea.date = vacc.date
where dea.continent IS NOT NULL