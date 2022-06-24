/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from CovidDeaths
where continent is not null
order by 3,4 


-- Select Data that we are going to be starting with
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1, 2


-- Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in Egypt.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Egypt%'
and continent is not null
order by 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectionPercentage
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
order by 1, 2


-- Countries with highest infection rate compared to populartin
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PopulationInfectionPercentage
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by location, population
order by PopulationInfectionPercentage desc


-- Countries with highest death count per populartin
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location, Date, Population, New_vaccinations ,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplePercentage
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinate
Create Table #PercentPopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 >> invalid in temp tables


select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplePercentage
from #PercentPopulationVaccinate


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3 >> invalid in views