--Eksplorasi data sumber listrik pada seluruh dunia dari tahun 1985 - 2019 (Fossil, Nuklir,dan Terbarukan)
--SEMUA DATA LISTRIK YG DIBANGKITKAN BERSATUAN TWH(TeraWatt-hour)
-- M Akbar Attallah --
-- data diperoleh dari 
-- raw data
SELECT *
FROM powerData$

-- Raw Data Indonesia
SELECT *
FROM powerData$
WHERE Entity='Indonesia'

-- Melihat Total listrik di indonesia
SELECT *,(Listrik_Fossil +Listrik_Nuklir+Listrik_Terbarukan) AS Total_Listrik
FROM powerData$
WHERE Entity='Indonesia'

-- Melihat persetase penggunaan bahan bakar fossil  dan persentase terbarukan untuk pembangkitan terhadap total listrik yang dibangkitkan di indonesia
SELECT Entity, Year, Listrik_Fossil,Listrik_Terbarukan, (Listrik_Fossil +Listrik_Nuklir+Listrik_Terbarukan) AS Total_Listrik , 
(Listrik_Fossil/(Listrik_Fossil +Listrik_Nuklir+Listrik_Terbarukan)) * 100 AS persentase_fossil, 
(Listrik_Terbarukan/(Listrik_Fossil +Listrik_Nuklir+Listrik_Terbarukan)) * 100 AS persentase_terbarukan
FROM powerData$
WHERE Entity='Indonesia'


-- Melihat raw data negara 
SELECT *
FROM powerData$


--Membuat temp table untuk memudahkan query
CREATE TABLE  #persentase_dayaa
(
Entity nvarchar(255),
Year nvarchar(255),
Listrik_Fossil float,
Listrik_Terbarukan float,
Listrik_Nuklir float,
Total_Listrik float,
persentase_fossil float,
persentase_terbarukan float,
persentase_Nuklir float,
)

INSERT INTO #persentase_dayaa

SELECT Entity, Year, ISNULL(Listrik_Fossil,0) AS Listrik_Fossil ,Listrik_Terbarukan, Listrik_Nuklir, (cast(ISNULL(Listrik_Fossil,0) +Listrik_Nuklir+Listrik_Terbarukan as float)) AS Total_Listrik , 
(ISNULL(Listrik_Fossil,0)/NULLIF((ISNULL(Listrik_Fossil,0) +Listrik_Nuklir+Listrik_Terbarukan),0)) * 100 AS persentase_fossil, 
(Listrik_Terbarukan/NULLIF((ISNULL(Listrik_Fossil,0) +Listrik_Nuklir+Listrik_Terbarukan),0)) * 100 AS persentase_terbarukan,
(Listrik_Nuklir/NULLIF((ISNULL(Listrik_Fossil,0) +Listrik_Nuklir+Listrik_Terbarukan),0)) * 100 AS persentase_Nuklir
FROM powerData$

-- Membuat Temp Table berisikan rata2 pembagian pembangkitan dari setiap negara dalam persentil
 CREATE TABLE  avg_daya1
(
Entity nvarchar(255),
avg_fossil float,
avg_terbarukan float,
avg_Nuklir float,
)

INSERT INTO avg_daya1

SELECT Entity, AVG(persentase_fossil) as avg_fossil ,AVG(persentase_terbarukan) as avg_terbarukan ,AVG(persentase_Nuklir) as avg_nuklir
FROM  #persentase_dayaa
WHERE persentase_fossil is not null AND persentase_Nuklir is not null AND persentase_terbarukan is not null
GROUP BY Entity

-- Melihat negara yang dominan menggunakan bahan bakar fosil
SELECT Entity AS Fossil, avg_fossil as Fossil_Percentage
FROM avg_daya1
WHERE avg_fossil>avg_terbarukan AND avg_fossil>avg_Nuklir
ORDER BY avg_fossil DESC

-- Melihat negara yang dominan menggunakan energi terbarukan
SELECT Entity AS Terbarukan, avg_terbarukan as Terbarukan_Percentage
FROM avg_daya1
WHERE avg_terbarukan>avg_fossil AND avg_terbarukan>avg_Nuklir
ORDER BY avg_terbarukan DESC
-- Melihat negara yang dominan menggunakan energi nuklir

SELECT Entity AS Nuklir, avg_Nuklir as Nuklir_Percentage
FROM avg_daya1
WHERE avg_Nuklir> avg_fossil AND avg_Nuklir > avg_terbarukan
ORDER BY avg_Nuklir DESC 


-- Membuat View untuk visualisasi dari data
CREATE VIEW Negara_Nuklir AS
SELECT Entity AS Nuklir, avg_Nuklir as Nuklir_Percentage
FROM avg_daya1
WHERE avg_Nuklir> avg_fossil AND avg_Nuklir > avg_terbarukan
--ORDER BY avg_Nuklir DESC 

CREATE VIEW Negara_Terbarukan AS
SELECT Entity AS Terbarukan, avg_terbarukan as Terbarukan_Percentage
FROM avg_daya1
WHERE avg_terbarukan>avg_fossil AND avg_terbarukan>avg_Nuklir
--ORDER BY avg_terbarukan DESC

CREATE VIEW Negara_Fossil AS
SELECT Entity AS Fossil, avg_fossil as Fossil_Percentage
FROM avg_daya1
WHERE avg_fossil>avg_terbarukan AND avg_fossil>avg_Nuklir
--ORDER BY avg_fossil DESC

