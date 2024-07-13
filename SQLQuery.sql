--Select Data That we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Triii..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if a person comes positive
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Triii..CovidDeaths
where location like '%India%'
order by 1,2

-- Looking at Total Cases vs Population
-- what percentage got covid
Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PositivePercentage
From Triii..CovidDeaths
--where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate
Select location, population, MAX(total_cases) as HighestInfecionCount,  MAX((total_cases/population)*100) as PositivePercentage
From Triii..CovidDeaths
group by location, population
order by PositivePercentage desc

-- countries with highest deaths per population
Select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount,  MAX((total_deaths/population)*100) as DeathPercentage
From Triii..CovidDeaths
where continent is not null
group by location, population
order by HighestDeathCount desc

-- continent wise stats
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount,  MAX((total_deaths/population)*100) as DeathPercentage
From Triii..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

-- Global DeathPercentage
Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths , (Sum(cast(new_deaths as int))/Sum(new_cases))*100  as DeathPercentage                          
From Triii..CovidDeaths
where continent is not null
order by 1,2

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int) ) over (Partition by dea.location order by dea.location,dea.date) as TotalVaccinations_tillDate

From Triii..CovidDeaths dea
Join Triii..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations_tillDate)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int) ) over (Partition by dea.location order by dea.location,dea.date) as TotalVaccinations_tillDate

From Triii..CovidDeaths dea
Join Triii..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select *,(TotalVaccinations_tillDate/population)*100
From PopvsVac

--using TEMP Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinationa numeric,
TotalVaccinations_tillDate numeric
)
INsert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int) ) over (Partition by dea.location order by dea.location,dea.date) as TotalVaccinations_tillDate

From Triii..CovidDeaths dea
Join Triii..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
Select *,(TotalVaccinations_tillDate/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for visualisation later
USE Triii
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int) ) over (Partition by dea.location order by dea.location,dea.date) as TotalVaccinations_tillDate

From Triii..CovidDeaths dea
Join Triii..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

drop view [PercentPopulationVaccinated]
