SELECT *
FROM Porto_Project..CovidDeath$
WHERE continent is not null
ORDER BY 3,5


--SELECT *
--FROM Porto_Project..CovidVaxxx$
--ORDER BY 3,4

-- pilih data yang ingin dipakai

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Porto_Project..CovidDeath$
ORDER BY 1,2

-- Cari nilai kasus total(total_cases) terhadap angka kematian total(total_deaths)
-- Menunjukkan persentasi kematian terhadap kasus infeksi di Indonesia
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_rate
FROM Porto_Project..CovidDeath$
WHERE location = 'Indonesia'
ORDER BY 1,2

-- Melihat  kasus total terhadap populasi
-- Menunjukkan persentasi infeksi covid terhadap populasi di Indonesia
SELECT Location, date,  population, total_cases,(total_cases/population)*100 AS Infection_rate
FROM Porto_Project..CovidDeath$
WHERE location = 'Indonesia'
ORDER BY 1,2

-- Melihat negara yang mempunyai infection_rate tertinggi
SELECT Location,  population, MAX(total_cases) AS total_case_Max, MAX((total_cases/population))*100 AS Infection_rate
FROM Porto_Project..CovidDeath$
GROUP BY location, population
ORDER BY MAX((total_cases/population))*100 DESC

-- Melihat Negara dengan angka kematian tertinggi
SELECT Location,  MAX(cast(total_deaths as int)) AS kematian_tertinggi
FROM Porto_Project..CovidDeath$
WHERE continent is not null
GROUP BY Location
ORDER BY kematian_tertinggi DESC

-- Melihat data angka kematian berdasarkan benua
SELECT continent,  MAX(cast(total_deaths as int)) AS kematian_tertinggi
FROM Porto_Project..CovidDeath$
WHERE continent is not null
GROUP BY continent
ORDER BY kematian_tertinggi DESC

--Melihat persentase kematian dari seluruh dunia
SELECT  SUM(new_cases) as Total_Kasus, SUM(cast(new_deaths as int)) as Total_Kematian, SUM(cast(new_deaths as int))/SUM(new_cases)
* 100 as persentase_kematian
FROM Porto_Project..CovidDeath$
where continent is not null
--GROUP BY date
ORDER BY 1




--Melihat populasi total terhadap nilai vaksinasi
With popdVac(continent, location, date , population ,new_vaccination, jumlah_vaksinasi)
as
(
SELECT dea.continent, dea.location, vax.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as jumlah_vaksinasi
FROM Porto_Project..CovidDeath$ dea
LEFT JOIN Porto_Project..CovidVaxxx$ vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
-- Menggunakan CTE


SELECT location, date,new_vaccination, jumlah_vaksinasi
FROM popdVac



--TEMP TABLE

CREATE TABLE #PersentasiPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
jumlah_vaksinasi numeric,
)

Insert into #PersentasiPopulationVaccinated

SELECT dea.continent, dea.location, vax.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as jumlah_vaksinasi
FROM Porto_Project..CovidDeath$ dea
LEFT JOIN Porto_Project..CovidVaxxx$ vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,
FROM #PersentasiPopulationVaccinated

-- Membuat View agar data dapat divisualisasi

CREATE VIEW PersentasiPopulationVaccinated AS
SELECT dea.continent, dea.location, vax.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(bigint, vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)as jumlah_vaksinasi
FROM Porto_Project..CovidDeath$ dea
LEFT JOIN Porto_Project..CovidVaxxx$ vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
--ORDER BY 2,3

CREATE VIEW Perkembangan_InfectionRate AS
SELECT Location, date,  population, total_cases,(total_cases/population)*100 AS Infection_rate
FROM Porto_Project..CovidDeath$
WHERE location = 'Indonesia'

