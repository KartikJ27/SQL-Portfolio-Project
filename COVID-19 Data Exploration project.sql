select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


--(data we will be using)
select location, date, total_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--(Looking at the death percentage due to COVID-19)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--(Death percentage in India)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

--(% of population contracting COVID-19 in India)
select location, date, total_cases, population, (total_cases/population)*100 as Population_percentage
from PortfolioProject..CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

--(Highest Infection rate of Countries compared to Population)
select location, population, max(total_cases) as HigestInfectionCase, max((total_cases/population))*100 as HighestInfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by HighestInfectionRate desc;

--(Highest Death count of countries)
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc;

--(and showing the data in continents)
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc;

--Global Numbers

select date, sum(new_cases) as TotalCasesPerDay, sum(cast(new_deaths as int)) as TotalDeathPerDay, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath_PerDay
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

select date, sum(new_cases) as TotalCasesPerDay, sum(cast(new_deaths as int)) as TotalDeathPerDay, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath_PerDay
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;


--(Joining both tables)

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--(Total Population vs Vaccinations)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationSum
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--(Using CTE to find the percentage of rolling vaccination sum as compared to population)

with PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationSum) as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationSum
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingVaccinationSum/Population)*100 as RollingVaccinationPercentage
from PopulationVsVaccination


--(Using Temp Table)

Drop table if exists #PopulationPercentageVaccinated
create table #PopulationPercentageVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationSum numeric
)
Insert into #PopulationPercentageVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationSum
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *, (RollingVaccinationSum/Population)*100 as RollingVaccinationPercentage
from #PopulationPercentageVaccinated


--(Creating Views to store data)
Create view PercentageOfPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationSum
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentageOfPopulationVaccinated