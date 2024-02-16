SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM coviddeaths
ORDER BY 1,2;



--Looking at Total Cases vs Total Deaths
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
--WHERE location LIKE '%States'
ORDER BY 1,2;



--- Looking at Total Cases vs Population
SELECT 
	location,
	date,
	total_cases,
	(total_cases/population)*100 AS percentpopulationinfected
FROM coviddeaths
--WHERE location LIKE '%States'
ORDER BY 1,2;



--- Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	location,
	population,
	MAX(total_cases) AS highestinfectioncounts,
	MAX(total_cases/population)*100 AS percentpopulationinfected
FROM coviddeaths
--WHERE location LIKE '%States'
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;



--- Showing Countries with  highest Dath Count per Population
SELECT 
	location,
	MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE 'World'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;



--- Showing continents with the highest Death Count Per Population
SELECT 
	continent,
	MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE 'World'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;



--- Global Numbers
SELECT --date,
	   SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_deaths, 
	   CASE
	   		WHEN SUM(new_cases) = 0 THEN 0
			ELSE SUM(new_deaths)/SUM(CAST(new_cases AS DECIMAL))*100 
		END AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;



SELECT *
FROM coviddeaths;



SELECT *
FROM covidvaccinations;



--- Looking at Total Population vs Vaccinations
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM 
	coviddeaths AS dea
JOIN 
	covidvaccinations AS vac
ON
	dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



--- Using CTE to calculate (rollingpeoplevaccinated/population)*100
WITH popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
AS
(
SELECT dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM 
	coviddeaths AS dea
JOIN 
	covidvaccinations AS vac
ON
	dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac;

WITH popvsvac AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM 
        coviddeaths AS dea
    JOIN 
        covidvaccinations AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)

SELECT 
    *,
    CASE 
        WHEN population = 0 THEN 0  -- To handle division by zero
        ELSE (rollingpeoplevaccinated / CAST(population AS DECIMAL)) * 100
    END AS percentage_vaccinated
FROM 
    popvsvac;
	
	
	
--- TEMP TABLE
	DROP TABLE IF EXISTS percentpopulationvaccinated;
	
	CREATE TEMPORARY TABLE percentpopulationvaccinated
	(
	continent varchar(255),
	location varchar(255),
	date date,
	population numeric,
	new_vaccinated numeric,
	rollingpeoplevaccinated numeric
	);
	
	INSERT INTO percentpopulationvaccinated
	SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM 
        coviddeaths AS dea
    JOIN 
        covidvaccinations AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    --WHERE 
        --dea.continent IS NOT NULL;
		
	SELECT 
    *,
    CASE 
        WHEN population = 0 THEN 0  -- To handle division by zero
        ELSE (rollingpeoplevaccinated / CAST(population AS DECIMAL)) * 100
    END AS percentage_vaccinated
FROM 
    percentpopulationvaccinated;
	
	
-- Creating View to Store Data for Later Visualizations
CREATE VIEW percentpopulationvaccinated AS
SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM 
        coviddeaths AS dea
    JOIN 
        covidvaccinations AS vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL;
		
SELECT *
FROM percentpopulationvaccinated;