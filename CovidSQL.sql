Select *
From Portfolio..CovidDeath
Where continent is not null
order by 3,4

Select *
From Portfolio..CovidVacc
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeath
order by 1, 2

-- Total cases vs total deaths in world

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeath
order by 1, 2

-- Total cases vs total deaths in the US
-- Percantage of deaths in the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeath
Where location like '%states%'
order by 1, 2

-- Total cases vs population
-- Percantage of population that got covid in the US

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From Portfolio..CovidDeath
Where location like '%states%'
order by 1, 2

-- Total cases vs population
-- Percantage of population that got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeath
order by 1, 2

--- Countries with highest covid cases

Select Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeath
Group by Location, population
order by PercentPopulationInfected desc

-- countries with the highest death rate per population
-- US is number 1
Select Location, MAX(cast(total_deaths as int)) as TotalDeathRate
From Portfolio..CovidDeath
Where continent is not null
Group by Location
order by TotalDeathRate desc

-- Continents
-- continents with the highest deat rate per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathRate
From Portfolio..CovidDeath
Where continent is not null
Group by continent
order by TotalDeathRate desc

-- Global 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeath
where continent is not null
Group by date
order by 1,2

--Total cases global

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeath
where continent is not null
-- Group by date
order by 1,2

-- joining vaccs vs deaths

Select * 
From Portfolio..CovidDeath dea
Join Portfolio..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date

-- total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatons
From Portfolio..CovidDeath dea
Join Portfolio..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingVaccinatons) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatons
From Portfolio..CovidDeath dea
Join Portfolio..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

)
Select *, (RollingVaccinatons/population)*100 
From PopvsVac

-- temp table
Drop Table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingVaccinatons numeric

)
insert into #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatons
From Portfolio..CovidDeath dea
Join Portfolio..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinatons/population)*100 
From #PercentPopulationVacinated

-- CREATE VIEW TO STORE DATA

Create view PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatons
From Portfolio..CovidDeath dea
Join Portfolio..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVacinated

