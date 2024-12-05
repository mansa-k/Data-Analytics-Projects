/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Take a look at Total cases VS Total Death

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_per_cases
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Turkey'
ORDER BY 1,2


-- Take a look at Total cases vs popultaion
-- shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentpopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Turkey'
ORDER BY 1,2


--countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HIGHESTInfectionCount, MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY LOCATION, POPULATION 
ORDER BY PercentPopulationInfected desc


--Countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount desc



-- let's analysis by continent
SELECT LOCATION, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount desc

--Global numbers
select date, sum(new_cases) AS Total_case, sum(cast(new_deaths as int)) AS Total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) AS Total_cases, sum(cast(new_deaths as int)) AS Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Population vs vaccinations
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over 
(partition by dth.location order by dth.location, dth.date) VacinatedRollingCount
from PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3

---CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over 
(partition by dth.location order by dth.location, dth.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinnations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over 
(partition by dth.location order by dth.location, dth.date) VacinatedRollingCount
from PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
