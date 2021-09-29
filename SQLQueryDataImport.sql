SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortofolioProject..CovidVaccinate
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2


--	Looking at total Cases vs Total Death
-- Show likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths 
WHERE location like '%states%' and continent is not null
ORDER BY 1,2  

-- Looking at Total Cases vs Population
-- Show what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100 AS CaseRasio
FROM PortofolioProject..CovidDeaths 
--WHERE location like '%states%'
ORDER BY 1,2  

-- Looking at country with highest infectione rate compared to population
SELECT Location, population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT, MAX((total_cases/population))* 100 AS PercentagePopulationInfected
FROM PortofolioProject..CovidDeaths 
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

--LETS BREAK THINGS DOWN BY CONTINENT 
-- Showing Countries With Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TOTALDEATHCOUNT 
FROM PortofolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TOTALDEATHCOUNT DESC

SELECT location, MAX(CAST(total_deaths AS int)) AS TOTALDEATHCOUNT 
FROM PortofolioProject..CovidDeaths 
WHERE continent is null
GROUP BY location
ORDER BY TOTALDEATHCOUNT DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths AS int)) as Total_Death, SUM(cast(new_deaths AS int)) / 
SUM(new_cases) * 100 AS Death_Percentage
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2  

-- Looking at Total Population vs Vaccination
--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea 
JOIN PortofolioProject..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea 
JOIN PortofolioProject..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
	dea.Date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea 
JOIN PortofolioProject..CovidVaccinate vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated



















