
Select *
From PortofolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortofolioProject..CovidVaccinations
--Order by 3,4

--Select data that are going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
order by 1,2

--Looking at total_deaths vs total_cases
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where location like '%nesia%'
and continent is not null
order by 1,2

--looking at total cases vs population
--Show percentage population got Covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
where location like '%nesia%'
and continent is not null
order by 1,2

--Looking at countries with Highest Infection rate compare to population
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
--where location like '%nesia%'
where continent is not null
group by location, population
order by PercentPopulationInfected DESC

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --using cast to convert data type as int to get accurate result
From PortofolioProject..CovidDeaths
--where location like '%nesia%'
where continent is not null
group by location
order by TotalDeathCount DESC

--Break things by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount --using cast to convert data type as int to get accurate result
From PortofolioProject..CovidDeaths
--where location like '%nesia%'
where continent is not null
group by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerentage
From PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerentage
From PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Join two datasets
Select *
From PortofolioProject..CovidDeaths death
Join PortofolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
Where death.continent is not null
order by 1,2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths death
Join PortofolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
Where death.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths death
Join PortofolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
Where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp table to perform calculation on partition by in previous query
Drop table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths death
Join PortofolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
--Where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store for visualization
Create View PercentPopulationVaccinated_view as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths death
Join PortofolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
Where death.continent is not null
