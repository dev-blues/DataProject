/* 
Covid19 Data Exploraiton
Skills used Joins, CTE's, Temp Tables, Windows Function, Aggregate functions, Creating Views, Converting Data types
*/
--Selecting data that we are going to be starting with

Select * from coviddeaths
where continent is not null
order by 3,4;

--Total cases vs Total Deaths In World

Select location,date,total_cases, total_deaths, population from coviddeaths
where continent is not null
order by 1,2;

-- Shows likelihood of dying if you contract in India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where location='India'
and continent is not null 
order by Location,date;

--Total cases vs Population in th World

Select location,date,total_cases,population from coviddeaths
where continent is not null
order by 1,2;

-- Shows what percentage of population infected with Covid In World

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
order by 1,2

-- Shows what percentage of population infected with Covid in India

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
Where location='India'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
--Where location='India'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where location='India'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
--Where location='India'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
--Where location='India'
where continent is not null 
--Group By date
order by 1,2

select * from covidvaccinations;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cv.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cv.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated

From coviddeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percent_
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cv.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated

From coviddeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cv.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated

From coviddeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
