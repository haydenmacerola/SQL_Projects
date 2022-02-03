Select * 
from CovidDeaths
order by 3, 4;


--- Select releavent data 

Select Location, date , total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2;

-- looking at total cases v total deaths
-- shows likelihood of dying if you contract Covid in your country and conversly across the world

Select Location, date , total_cases, total_deaths, (total_deaths/CAST (total_cases as REAL))*100 as DeathPercentage
from CovidDeaths
---where location = 'Australia'
order by 1, 2;

Select sum(new_cases) as totalcases, sum (new_deaths) as totaldeaths, sum(new_deaths)/sum(cast(new_cases as REAL))*100 as DeathPercentage
from CovidDeaths
order by 1, 2;

--- looking at Total Cases v Population 
--- percentage of pop contracted covid 

Select Location, CAST(population as INT) as Pop , max(total_cases) as HighestInfectionCount, (CAST (total_cases as REAL)/population)*100 as PercentPopInfected
from CovidDeaths
---where location = 'Australia'
where continent is not NULL
group by 1, 2
order by 4 DESC

--- same as above but for given date 

Select Location, CAST(population as INT) as Pop ,[date] ,max(total_cases) as HighestInfectionCount, (CAST (total_cases as REAL)/population)*100 as PercentPopInfected
from CovidDeaths
---where location = 'Australia'
where continent is not NULL
group by 1, 2, 3
order by 5 DESC


--- countries with highest infection rates compared to Pop

Select Location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PopulaitonInfectedPercentage
from CovidDeaths
Group by 1, 3
Order by PopulaitonInfectedPercentage DESC;

--- Countries with highest death count per population
--- and then by continents // simply replace is null with is not null on line 47 to switch 

Select Location, sum(new_deaths) as TotalDeathCount
from CovidDeaths
where continent is NULL
and location not in ('World', 'European Union', 'International')
Group by 1
Order by 2 DESC;

--- Global Death Percentage

Select, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths , (sum(CAST(new_deaths as REAL))/sum(new_cases))*100 as GlobalDeathPercentage
from CovidDeaths
where continent is not NULL
---group by date
order by 1;

--- total pop vs vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVac as vac
on dea.location = vac.location AND dea.[date] = vac.[date]
where dea.continent is not NULL
order by 2,3;

--- CTE to return the total people vaccinated of each country 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVac as vac
on dea.location = vac.location AND dea.[date] = vac.[date]
where dea.continent is not NULL )
select *, (RollingPeopleVaccinated/population)*100 as VaccinePercentagePop
From PopvsVac 
where location = 'Australia'

--- creating view to store data for visualisation 

Create View PerecentPopulatonVaxxed as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
Join CovidVac as vac
on dea.location = vac.location AND dea.[date] = vac.[date]
where dea.continent is not NULL;

Select * 
From PerecentPopulatonVaxxed