SELECT * 
FROM death

;

/* Select Data that we are going to use */

Select location,date, total_cases, new_cases, total_deaths, population_density

from death
ORDER BY 1,2

/* Loooking at total cases vs Total Deaths */
/* Shows likelihood of dying if you contract covid in your country */
SELECT location, date, total_cases, total_deaths,
       CASE
           WHEN total_cases = 0 THEN NULL
           ELSE (total_deaths / total_cases) * 100
       END AS DeathPercentage
FROM death
WHERE location ILIKE '%united kingdom%'
ORDER BY 1,2;


SELECT location, date, total_cases, total_deaths,
       CASE
           WHEN total_cases = 0 THEN NULL
           ELSE (total_deaths / total_cases) * 100
       END AS DeathPercentage
FROM death
WHERE location ILIKE '%ghana%'
ORDER BY 1,2;

/* Looking at Total Cases vs Population */

/* Shows what percentage of population got covid */

SELECT location,date,population,total_cases,
    CASE
      WHEN  total_cases = 0 THEN NULL
      ELSE (total_cases/population) * 100 
    END AS PercentageGotCovid  
from death
WHERE location ILIKE '%united kingdom%'
ORDER BY 1,2

/* Look at countries with Highest Infection Rate Compard to Population */

SELECT location,population,MAX(total_cases) AS HighestInfecttionCount,
    CASE
      WHEN  total_cases = 0 THEN NULL
      ELSE MAX((total_cases/population)) * 100 
    END AS PercentPopulationInfected 
from death
WHERE continent is not NULL
Group BY location, population,total_cases
ORDER BY PercentPopulationInfected desc


/* Showing Countries with Highest Death Count per Population */
SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathCount

from death
WHERE continent is not NULL 
Group BY location
ORDER BY  TotalDeathCount desc

/* LET'S BREAK THINGS DOWN BY CONTINENT */
SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathCount

from death
WHERE continent is  NULL 
Group BY location
ORDER BY  TotalDeathCount desc


/* Global Numbers */
SELECT  date, total_cases, total_deaths,
       CASE
           WHEN total_cases = 0 THEN NULL
           ELSE (total_deaths / total_cases) * 100
       END AS DeathPercentage
FROM death
WHERE continent is not NULL
Group by 
ORDER BY 1,2;


Select SUM(new_cases) total_cases, SUM(new_deaths) total_deaths,
  CASE
    WHEN new_cases = 0 THEN NULL

    ELSE SUM(new_deaths)/ SUM(new_cases)*100 

  END  AS DeathPercentage  
from death
WHERE  continent  is  not NULL
Group by new_cases,new_deaths
ORDER by 1,2

 /* looking at total population vs Vaccinations */
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date ) RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
from death dea
Join vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- USE CTE

with PopvsVac(continent,location,date,population,new_vaccinations)
as
(
  Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location,dea.date ) RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
from death dea
Join vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

)

Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

-- Drop the temp table if it already exists
DROP TABLE IF EXISTS PercentPopulationVaccinated;
-- Create the temp table
CREATE TEMP TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date TIMESTAMP,
    Population NUMERIC,
    NewVaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);


INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    death dea
JOIN 
    vaccinations vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date;



SELECT 
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM 
    PercentPopulationVaccinated;

    -- creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    death dea
JOIN 
    vaccinations vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date;

Select *
from PercentPopulationVaccinated  



CREATE VIEW RollingPeopleVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    death dea
JOIN 
    vaccinations vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date;


SELECT *
FROM RollingPeopleVaccinated