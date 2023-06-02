/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4



-- Total Cases vs Total Deaths as Percentage

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'Bang%' and continent is not NULL
Order By 1,2


-- Total Cases vs Population

-- Shows what percentage of population infected with Covid

Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not NULL
Order By 1,2


--Looking at Countries with Highest Infection Rate compared to population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not NULL
group by Location, population
Order By PercentPopulationInfected DESC


-- Showing countries with Highest Death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not NULL
group by Location
Order By TotalDeathCount DESC


-- Breaking Things Down by Continent

-- Showing contintents with the highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is NULL
group by location
Order By TotalDeathCount DESC



-- Global Numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location
	, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location
	, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
from PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location
	, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null


select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location
	, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where death.continent is not null


select * 
from PercentPopulationVaccinated




