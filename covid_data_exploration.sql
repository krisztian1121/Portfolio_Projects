-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths

-----------------------------------------------------------------------------------------------------------------------
    
-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contracted covid in Hungary
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths * 100.0 / total_cases)
FROM
    CovidDeaths
WHERE location = 'Hungary';

-----------------------------------------------------------------------------------------------------------------------

-- Show what percentage of population got Covid
SELECT location,
       date,
       population,
       total_cases,
       (total_cases * 100.0 / population) as percent_population_infected
FROM
    CovidDeaths
Where location = 'Hungary';

-----------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location,
       population,
       max(total_cases) as highest_infection_count,
       max((total_cases * 100.0 / population)) as percent_population_infected
FROM
    CovidDeaths
GROUP BY location, population
ORDER BY
    percent_population_infected DESC;

-----------------------------------------------------------------------------------------------------------------------

--Show Countries with the Highest Death Count per Population
SELECT location,
       max(total_deaths) as total_death_count
FROM
    CovidDeaths
where continent is not null
GROUP BY location
ORDER BY
    total_deaths DESC;

-----------------------------------------------------------------------------------------------------------------------

-- Showing continents with the highest death count per population
SELECT location,
       max(total_deaths) as total_death_count
FROM
    CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY  total_death_count DESC;

-----------------------------------------------------------------------------------------------------------------------

-- Global numbers
SELECT date,
       SUM(new_cases) as Total_cases,
       SUM(new_deaths) as Total_deaths,
       SUM(new_deaths) * 100.0 / SUM(new_cases) as Death_Percentage
FROM
    CovidDeaths
GROUP BY
    date

-----------------------------------------------------------------------------------------------------------------------
    
-- Looking at Total population vs vaccinations
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER BY dea.location) as Rolling_people_vaccinated
FROM
    CovidDeaths as dea
JOIN Covidvaccinations as vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


