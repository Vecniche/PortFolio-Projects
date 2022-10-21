
select *
from PortFolioproject..CovidDeaths
where continent is not null
order by 3, 4


--select *
--from PortFolioproject..CovidVaccinations
--order by 3, 4


--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortFolioproject..CovidDeaths
order by 1,2

--Looking at total cases vs Total deaths
--shows the likelihood of dying if yoo contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortFolioproject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs the population
--shows what percentage of population got covid
select Location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from PortFolioproject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with Highest infection rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentpopulationinfected
from PortFolioproject..CovidDeaths
--where location like '%states%'
GROUP BY Location, population
order by percentpopulationinfected desc


--showing the countries with the highest death count by population

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortFolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY Location, population
order by TotalDeathCount desc

-- lets break things by continents
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortFolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--showing the continent with the highest death count per population

--Global numbers 

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from PortFolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--joining the two tables

select *
from PortFolioproject..CovidDeaths dea
join PortFolioproject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date

--Looking at Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativepeopleVaccinated
from PortFolioproject..CovidDeaths dea
join PortFolioproject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVax (Continent, Location, date, population, mew_vacccination, cummulativepeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativepeopleVaccinated
from PortFolioproject..CovidDeaths dea
join PortFolioproject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
select *, (cummulativepeopleVaccinated/population) * 100
from PopvsVax


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cummulativepeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativepeopleVaccinated
from PortFolioproject..CovidDeaths dea
join PortFolioproject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
--where dea.continent is not null
--order by 2,3
select *, (cummulativepeopleVaccinated/population) * 100
from #PercentPopulationVaccinated

-- Creating views to store data for later Visualizations

Create View PercentagePopulatedVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cummulativepeopleVaccinated
from PortFolioproject..CovidDeaths dea
join PortFolioproject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3