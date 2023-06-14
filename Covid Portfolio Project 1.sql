-- Analyizing Covid Data 
select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting Data for use
Select Location, date, Total_cases, New_Cases, Total_deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths in Canada
-- Shows probability of Dying if you contracted covid in Canada 

Select Location, date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like 'Canada'
order by 1,2

-- Total Cases vs Population in Canada
-- Shows the Percentage of population that Contracted Covid

Select Location, date, Total_cases, population, (total_cases/population)*100 as Infection_Rate
from PortfolioProject..CovidDeaths
where location like 'Canada'
order by 1,2

-- Countries with highest infection rate compared to Population

Select location, Max(Total_cases) as Highest_Infection_Count, population, Max((total_cases/population))*100 as Population_Infection_Rate
from PortfolioProject..CovidDeaths
group by location,population
order by Population_Infection_Rate desc

-- Countries with the highest death count
Select location, Max(cast( total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

-- Creating Views for Later Visualizations

Create View HighestDeathCount as
Select location, Max(cast( total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by location


-- Continents with the highest death count

Select location, Max(cast( total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is null
group by location 
order by Total_Death_Count desc

-- World Wide Cases Vs Deaths by Day

Select Date, sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- World wide Cases vs Death total to last data Day

Select  sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

-- Total Population vs Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, Vacs.new_vaccinations
,sum(cast(vacs.new_vaccinations as int)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingVaccinationCount
From CovidDeaths Deaths
join CovidVaccinations Vacs
on deaths.location = vacs.location and Deaths.date = vacs.date
where deaths.continent is not null
order by 2,3

-- CTE to find Percentage of Population Vaccinated

With Pop_vs_Vax (Continent,Location,Date,Population,New_Vaccinations,RollingVaccinationCount) as (
Select deaths.continent, deaths.location, deaths.date, deaths.population, Vacs.new_vaccinations
,sum(cast(vacs.new_vaccinations as int)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingVaccinationCount
From CovidDeaths Deaths
join CovidVaccinations Vacs
on deaths.location = vacs.location and Deaths.date = vacs.date
where deaths.continent is not null
)
select *, (RollingVaccinationCount/Population)*100 as PopulationVaccinated
From Pop_vs_Vax


--  Using Temp Table 


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric)

Insert Into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, Vacs.new_vaccinations
,sum(cast(vacs.new_vaccinations as int)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingVaccinationCount
From CovidDeaths Deaths
join CovidVaccinations Vacs
on deaths.location = vacs.location and Deaths.date = vacs.date
where deaths.continent is not null

select *, (RollingVaccinationCount/Population)*100 as PopulationVaccinated
From #PercentPopulationVaccinated

-- Creating Views for Later Visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, Vacs.new_vaccinations
,sum(cast(vacs.new_vaccinations as int)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as RollingVaccinationCount
From CovidDeaths Deaths
join CovidVaccinations Vacs
on deaths.location = vacs.location and Deaths.date = vacs.date
where deaths.continent is not null