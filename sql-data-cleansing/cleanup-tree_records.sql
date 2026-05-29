--I wanted to know what is the % of native trees vs. exotic trees in the city I live in. So after dowloading the dataset from the 
--city hall web site, I started to clean it.

--1) I created a global temporary table with the columns I found relevant:

USE Niteroi_gov
SELECT 
[objectid]      as Object_id
,[tx_bairro]    as Neighborhood 
,[tx_endereco]  as Street_add
,[tx_origem]    as Origin
,[tx_nomepop]   as Name
,[tx_especie]   as Cientific_name
,[tx_conflito]  as Conflict
INTO ##tree_record
FROM .[dbo].['Cadastro_de_Arvores_-$']


-- then I tested it:

SELECT*
FROM [dbo].['Cadastro_de_Arvores_-$']

--2) I did some standardization by I removing empty spaces using LTRIM(RTRIM(column)) for all columns and
-- at a same time stablished Standarized Case with UPPER:


UPDATE ##tree_record
SET 
Object_id         = UPPER(LTRIM(RTRIM(Object_id)))
,Neighborhood     = UPPER(LTRIM(RTRIM(Neighborhood)))
,Street_add       = UPPER(LTRIM(RTRIM(Street_add)))
,Origin           = UPPER(LTRIM(RTRIM(Origin)))
,Name             = UPPER(LTRIM(RTRIM(Name)))
,Cientific_name   = UPPER(LTRIM(RTRIM(Cientific_name)))
,Conflict         = UPPER(LTRIM(RTRIM(Conflict)))


--3) I checked how many unique values I had under the column Origin:

SELECT DISTINCT Origin
FROM ##tree_record
ORDER BY Origin desc

--4) I unified all viariabels into native, exotic, unknown and NULL:

UPDATE ##tree_record
SET Origin = CASE 
    WHEN Origin IN ('NTIVA', 'NATIVO', 'NATIVA') THEN 'NATIVE'
    WHEN Origin IN ('EXOTICA', 'EXÓTICA', 'EXÓTICO') THEN 'EXOTIC'
    WHEN Origin IN ('NI', 'N/I', 'N.I') THEN 'UNKNOWN'
    WHEN Origin IN ('MORTO') THEN NULL
    ELSE Origin
END


--5) Checked how many NULL lines I had:

SELECT *
FROM ##tree_record
WHERE Origin IS NULL

--6) Since those were only 0.004% I removed them from the table:

DELETE FROM ##tree_record
WHERE Origin IS NULL;

--7) Then finally I count those groups (native, exotic and unknown) and did the % calculation for those:

SELECT 
    Origin, 
    COUNT(*) AS Count,
    CAST(ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS DECIMAL(10, 2)) AS Percentage
FROM ##tree_record
GROUP BY Origin;

--8) I check the 100% (61,333) number was correct just to be sure:

SELECT *
FROM ##tree_record
ORDER BY Origin
