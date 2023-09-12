
SELECT *
From SQLTutorial..[Covid Deaths]
Where continent is not null
order by 3,4

SELECT *
From SQLTutorial..[Covid Vaccinations]
Order by 3,4


--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population	
From SQLTutorial..[Covid Deaths]
Order by 1,2

-- Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths) / NULLIF(CONVERT(float, total_cases),0)) * 100 AS Deathpercentage
From SQLTutorial..[Covid Deaths]
Where location like '%states%'
Order by 1,2

--Looking at total cases vs. population
--Shows what percentage of population got COVID
Select Location, date, population, total_cases, (total_cases/population)* 100 AS Deathpercentage
From SQLTutorial..[Covid Deaths]
Where location like '%states%'
Order by 1,2


--Looking at Countries w/ highest infection rates compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentInfected
From SQLTutorial..[Covid Deaths]
Group By Location, Population
Order by PercentInfected desc

--Showing Countries with highest deaths per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeaths
From SQLTutorial..[Covid Deaths]
Where continent is not null --Leaves out outliers such as "World" and Continents, only includes individual countries
Group By Location, Population
Order by TotalDeaths desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From SQLTutorial..[Covid Deaths]
Where continent is not null --Leaves out outliers such as "World" and Continents, only includes individual countries
Group By continent
Order by TotalDeaths desc


Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From SQLTutorial..[Covid Deaths]
--Where location likes '%states%'
Where continent is not null --Leaves out outliers such as "World" and Continents, only includes individual countries
Group By continent
Order by TotalDeaths desc


--Global Numbers

Select date, SUM(new_cases) as CasesPerDay, SUM(new_deaths) as DeathsPerDay, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage--, total_deaths, (CONVERT(float,total_deaths) / NULLIF(CONVERT(float, total_cases),0)) * 100 AS Deathpercentage
From SQLTutorial..[Covid Deaths]
--Where location like '%states%'
WHERE continent is not null
Group By date
Order by 1,2


Select SUM(new_cases) as CasesPerDay, SUM(new_deaths) as DeathsPerDay, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as DeathPercentage--, total_deaths, (CONVERT(float,total_deaths) / NULLIF(CONVERT(float, total_cases),0)) * 100 AS Deathpercentage
From SQLTutorial..[Covid Deaths]
--Where location like '%states%'
WHERE continent is not null
--Group By date
Order by 1,2


--Looking at Total Population vs. Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From SQLTutorial..[Covid Deaths] dea
Join SQLTutorial..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLTutorial..[Covid Deaths] dea
Join SQLTutorial..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

Select  *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLTutorial..[Covid Deaths] dea
Join SQLTutorial..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select  *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLTutorial..[Covid Deaths] dea
Join SQLTutorial..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated