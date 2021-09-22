 --Select Data that we are going to be using 
 Select location, date, total_cases, new_cases, total_deaths, population
 From covid.dbo.CovidDeaths
 Where continent is not null
 Order by location, date;


 --Looking at Total Case vs Total Deaths
 --Shows likelilood of dying if you contract covid in your country
 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From covid.dbo.CovidDeaths
 Where location like '%states%' 
 Order by location, date;

 --Looking at Total Cases vs Population 
 --Shows what percentage of population got Covid
 Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
 From covid.dbo.CovidDeaths
 Where location like '%states%'
 Order by location, date;


--Looking at Countries with Highest Infection Rate compared to Population
 Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
 From covid.dbo.CovidDeaths
 Where continent is not null
 Group by location, population
 Order by PercentagePopulationInfected desc;


 --Showing Countries with Highest Death Count per Population 
 Select location, Max(cast(total_deaths as int)) as TotalDeathCount
 From covid.dbo.CovidDeaths
 Where continent is not null
 Group by location
 Order by TotalDeathCount desc;

 --Let's break things down by continent
 Select continent, Sum(TotalDeathCount) as ContinentTotalDeathCount
 FROM 
	 (Select continent, location, Max(cast(total_deaths as int)) as TotalDeathCount
	 From covid.dbo.CovidDeaths
	 Where continent is not null
	 Group by continent, location) as Temp
 Group by continent
 Order by ContinentTotalDeathCount desc;

 --Showing continents with the highest death count  
 Select continent, Max(cast(total_deaths as int)) as MaxDeathCount
 From covid.dbo.CovidDeaths
 Where continent is not null
 Group by continent
 Order by MaxDeathCount desc;
 

 --Global Numbers
 Select date, Sum(total_cases) as global_cases, Sum(cast(total_deaths as int)) as global_deaths, (Sum(cast(total_deaths as int))/Sum(total_cases))*100 as GlobalDeathPercentage
 From covid.dbo.CovidDeaths
 Where continent is not null
 Group by date
 Order by 1;



 --Looking at Total Population vs Vaccinations

--Use CTE example 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations, people_fully_vaccinated)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations, vac.people_fully_vaccinated
 From covid.dbo.CovidDeaths dea
 Left Join covid.dbo.CovidVaccinations vac
	On dea.location=vac.location and dea.date=vac.date
 Where dea.continent is not null
)
Select *, (people_fully_vaccinated/population)*100 as PeopleFullyVaccinatedRate
From PopvsVac




--Temp Table
Drop table if exists #PecentPopulationFullyVaccinated
Create Table #PecentPopulationFullyVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric,
People_fully_vaccinated numeric
)

Insert into #PecentPopulationFullyVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations, vac.people_fully_vaccinated
 From covid.dbo.CovidDeaths dea
 Left Join covid.dbo.CovidVaccinations vac
	On dea.location=vac.location and dea.date=vac.date
 Where dea.continent is not null

Select *
From #PecentPopulationFullyVaccinated



--Creating View to store data for later visualizations

Create View PecentPopulationFullyVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations, vac.people_fully_vaccinated
 From covid.dbo.CovidDeaths dea
 Left Join covid.dbo.CovidVaccinations vac
	On dea.location=vac.location and dea.date=vac.date
 Where dea.continent is not null

 Select *
 From PecentPopulationFullyVaccinated