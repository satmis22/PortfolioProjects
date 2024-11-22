Select *
From CovidDeaths
WHERE continent is not NULL
order by 3,4

--Select *
--From CovidVaccinations

-- Select Data that we are going to be using

Select Location, date , total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Death

Select Location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
WHERE Location like '%India%'
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date , total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--WHERE Location like '%India%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
--WHERE Location like '%India%'
order by PercentPopulationInfected DESC

-- Showing Countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
WHERE continent is not NULL
Group by location
--WHERE Location like '%India%'
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount DESC

-- Showing the continents with highest DeathCount

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
--Group by date
order by 1, 2

-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

With Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From Popvsvac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RolllingPeopleVaccinated
From CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated

