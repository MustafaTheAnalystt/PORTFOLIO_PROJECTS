SHOW DATABASES;

SHOW TABLES; 

DROP TABLE covdeaths, covvacc;


USE project_portfolio;

SET SQL_SAFE_UPDATES = 0;

LOAD DATA LOCAL INFILE "C:/Users/mjnon/Downloads/CovidDeathsCSV.csv" INTO TABLE covdeaths FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;

LOAD DATA LOCAL INFILE "C:/Users/mjnon/Downloads/CovidVaccinationsCSV.csv" INTO TABLE covvacc FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES ;


DESC covdeaths;
SELECT * FROM covdeaths;

SELECT * FROM Covvacc;
DESC Covvacc;



-- Select data that is important and we would be using for our project

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM covdeaths WHERE continent != '' ORDER BY 1, 2;

-- Looking at Death_Percentage per day
-- Shows the likelihood of dying if you contract covid in your country in the given date range.

SELECT LOCATION, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS Death_percentage 
FROM covdeaths WHERE location like '%states%' and continent != '' ORDER BY 1, 2;

-- Looking at total cases vs population for usa / UK

SELECT Location, date, total_cases, population, ((total_cases/population)*100) AS population_percentage_infected
FROM covdeaths WHERE location like '%kingdom%' and continent != '' ORDER BY 1, 2;

-- Looking at countries with highest Infection rate compared to population.

SELECT Location, population, MAX(total_cases) AS Highest_InfectionCount, ((MAX(total_cases))/population)*100 AS Highest_percentage_infection
FROM covdeaths where continent != '' GROUP BY location ORDER BY 4 desc;

-- Showing Countries With Highest death count per population

SELECT location, MAX(CAST((total_deaths) AS decimal)) from covdeaths group by location;

SELECT Location, population, MAX(CAST(total_deaths AS decimal)) AS HighestDeaths, ((MAX(total_deaths))/population)*100 AS Highest_percentage_deaths
FROM covdeaths where continent != '' GROUP BY location ORDER BY location;

-- LETS BREAK THINGS DOWN BY CONTINENT

SELECT continent, population, MAX(CAST(total_deaths AS decimal)) AS HighestDeathCount
FROM covdeaths where continent != '' GROUP BY continent ;

-- Total Cases, Total deaths, Death percentage

SELECT  SUM(CAST(new_cases AS DECIMAL)) AS total_cases, SUM(CAST(new_deaths AS decimal)) AS total_deaths ,SUM(CAST(new_deaths as DECIMAL))/SUM(CAST(New_cases as decimal))*100 AS Death_percentage 
FROM covdeaths 
WHERE continent != '' 
ORDER BY 1, 2;

-- Global Numbers / Death percentages per day globally

SELECT date, SUM(CAST(new_cases AS DECIMAL)) AS total_cases, SUM(CAST(new_deaths AS decimal)) AS total_deaths ,SUM(CAST(new_deaths as DECIMAL))/SUM(CAST(New_cases as decimal))*100 AS Death_percentage 
FROM covdeaths 
WHERE continent != '' 
Group by date
ORDER BY 1, 2;


-- MAKING A GENERAL JOIN STATMENT FOR FURTHER USE
SELECT continent, location, date FROM covdeaths 
JOIN covvacc 
ON  covdeaths.location = covvacc.location
AND covdeaths.date = covvacc.date;

-- -- Looking at total population vs vaccinations

WITH POPvsVAC (contient , location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT covdeaths.continent, covdeaths.location, covdeaths.date, covdeaths.population, covdeaths.new_vaccinations,
SUM(CAST(covvacc.new_vaccinations AS DECIMAL)) OVER(Partition BY covdeaths.location ORDER BY covdeaths.location, covdeaths.date) AS RollingPeopleVaccinated
FROM covdeaths 
JOIN covvacc 
ON  covdeaths.location = covvacc.location
AND covdeaths.date = covvacc.date
WHERE covdeaths.continent != '' 
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM POPvsVAC;





-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(continent VARCHAR(100) , location VARCHAR(222), date VARCHAR(100), population decimal, new_vaccinations decimal,  RollingPeopleVaccinated decimal);

INSERT INTO PercentPopulationVaccinated 
SELECT covdeaths.continent, covdeaths.location, covdeaths.date, covdeaths.population, covdeaths.new_vaccinations,
SUM(CAST(covvacc.new_vaccinations AS DECIMAL)) OVER(Partition BY covdeaths.location ORDER BY covdeaths.location, covdeaths.date) AS RollingPeopleVaccinated
FROM covdeaths 
JOIN covvacc 
ON  covdeaths.location = covvacc.location
AND covdeaths.date = covvacc.date
WHERE covdeaths.continent != '' 
ORDER BY 2,3;


SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PercentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS 

CREATE VIEW POPvsVAC as SELECT covdeaths.continent, covdeaths.location, covdeaths.date, covdeaths.population, covdeaths.new_vaccinations,
SUM(CAST(covvacc.new_vaccinations AS DECIMAL)) OVER(Partition BY covdeaths.location ORDER BY covdeaths.location, covdeaths.date) AS RollingPeopleVaccinated
FROM covdeaths 
JOIN covvacc 
ON  covdeaths.location = covvacc.location
AND covdeaths.date = covvacc.date
WHERE covdeaths.continent != '' 
ORDER BY 2,3;


-- CHECKING VIEW

SELECT * FROM POPvsVAC;













