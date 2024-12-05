/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Take a look at Total cases VS Total Death
-- Shows likelihood of dying if a person contracts covid in Turkey

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_per_cases
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Turkey'
ORDER BY 1,2


-- Take a look at Total cases vs popultaion
-- shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentpopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Turkey'
ORDER BY 1,2


--Countries with Highest Ifection Rate compared to Population

SELECT location, MAX(total_cases) AS HIGHESTInfectionCount, MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY LOCATION, POPULATION 
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount desc



-- Analysis by continent

SELECT LOCATION, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount desc

--Global Numbers

select date, sum(new_cases) AS Total_case, sum(cast(new_deaths as int)) AS Total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


--Total Population vs Vaccinations
-- Displays Percentage of  Global Population that has recieved at least one Covid Vaccine

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over 
(partition by dth.location order by dth.location, dth.date) VacinatedRollingCount
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVacinnations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

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


-- Using Temp Table to perform Calculation on Partition By in previous query


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
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Create View total_deaths as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



Create View TotalDeathCount as
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Create View HighestInfectionCount as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,
		Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Create View PercentPopulationInfected as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,
			Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
