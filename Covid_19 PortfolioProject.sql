SELECT *
FROM PostfolioProject..CovidDeaths
order by 3,4

--selectint the data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PostfolioProject..CovidDeaths
order by 1,2

--looking at total_cases vs total_deaths,
--shows likelihood of dying when you contract covid in your country
select location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PostfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total_cases vs population,
--shows what percentage of population got covid in USA
select location, continent, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PostfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total_cases vs population,
--shows what percentage of population got covid
select location, continent, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PostfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PostfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--Showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PostfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PostfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- showing continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PostfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers on each day
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PostfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global Numbers of cases and deaths
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PostfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at CovidVaccinations table
select *
from PostfolioProject..CovidVaccinations

--Joining the CovidDeaths(dea) and CovidVaccinations(vac) table on location
-- and date
select *
from PostfolioProject..CovidDeaths dea
join PostfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
from PostfolioProject..CovidDeaths dea
Join PostfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE(because we cant use the newly created colum(RollingPeopleVaccinated)
-- to perform any operation

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
from PostfolioProject..CovidDeaths dea
Join PostfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from popvsvac


--Creating temp table
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PostfolioProject..CovidDeaths dea
Join PostfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PostfolioProject..CovidDeaths dea
Join PostfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
