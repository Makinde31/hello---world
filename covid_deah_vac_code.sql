SELECT 
    *
FROM
    covid_vaccination.covid_vaccinations
ORDER BY 3 , 4;
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths.covid_deaths
ORDER BY 3 , 4;

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases)
FROM
    covid_deaths.covid_deaths
WHERE
    location LIKE '%Africa%'
ORDER BY 1 , 2;

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS Percent_Popuation_infected
FROM
    covid_deaths.covid_deaths;

# country with Highest infection rate compared to population

SELECT 
    location,
    population,
    MAX(total_cases) AS Highest_infection_count,
    MAX((total_cases / Population)) * 100 AS Percent_Popuation_infected
FROM
    covid_deaths.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY location , Population
ORDER BY Percent_Popuation_infected DESC;

SELECT 
    location, MAX(total_deaths) AS Total_death_count
FROM
    covid_deaths.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC;

SELECT 
    continent, MAX(total_deaths) AS Total_death_count
FROM
    covid_deaths.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC;

SELECT 
    date,
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS Deaths_pecentage
FROM
    covid_deaths.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1 , 2;

SELECT 
    *
FROM
    covid_deaths.covid_deaths dea
        JOIN
    covid_vaccination.covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date;
        
# continent with Highest vaccination rate compared to location

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM
    covid_deaths.covid_deaths dea
        JOIN
    covid_vaccination.covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 2 , 3;


# Percentage of people vaccinated

With Popvsvac (continent, location, date, Population, new_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
from covid_deaths.covid_deaths dea
Join covid_vaccination.covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
SELECT 
    *
FROM
    Popvsvac;

# temp table

DROP TABLE IF exists Percentage_Population_Vaccinated;
create Table Percentage_Population_Vaccinated
(
continent nvarchar(255),
locaion nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
);

Insert into Percentage_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
from covid_deaths.covid_deaths dea
Join covid_vaccination.covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
SELECT 
    *, (Rolling_people_vacccinated / population) * 100
FROM
    Percentage_Population_Vaccinated;
    
    # Global Numbers 
    
    SELECT 
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS Deaths_pecentage
FROM
    covid_deaths.covid_deaths
#WHERE
    #continent IS NOT NULL #
# GROUP BY date
ORDER BY 1 , 2;

# creating views to store for later visualisation 

create view Percentage_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
from covid_deaths.covid_deaths dea
Join covid_vaccination.covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select *
from Percentage_Population_Vaccinated;
