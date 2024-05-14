
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Turkey%'
ORDER BY 1, 2


SELECT Location, population, MAX(total_cases) AS HighInfectionAmount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathAmount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathAmount desc


SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathAmount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathAmount desc


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathAmount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathAmount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--TOTAL POPULATION VS VACCINATIONS

Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths AS deat
Join PortfolioProject..CovidVaccinations AS vac
     On deat.location = vac.location
     and deat.date = vac.date
where deat.continent is not null
order by 2,3




With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deat.Location Order by deat.location,deat.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS deat
Join PortfolioProject..CovidVaccinations AS vac
     On deat.location = vac.location
     and deat.date = vac.date
where deat.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 AS Percentage
From PopvsVac






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
Insert Into #PercentPopulationVaccinated
Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deat.Location Order by deat.location,deat.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS deat
Join PortfolioProject..CovidVaccinations AS vac
     On deat.location = vac.location
     and deat.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating view to store data for visualization

Create View PercentPopulationVaccinated as
Select deat.continent, deat.location, deat.date, deat.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by deat.Location Order by deat.location,deat.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS deat
Join PortfolioProject..CovidVaccinations AS vac
     On deat.location = vac.location
     and deat.date = vac.date
	 where deat.continent is not null


Select * 
From PercentPopulationVaccinated