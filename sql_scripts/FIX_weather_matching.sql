-- ============================================================================
-- FIX WEATHER MATCHING - Add Distrito Column to Fires
-- ============================================================================
-- Problem: Fires linked to old region_ids, weather data has distrito names
-- Solution: Add distrito column to fires from original CSV
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- STEP 1: Add distrito column to incendios table
-- ============================================================================

ALTER TABLE incendios 
ADD COLUMN distrito VARCHAR(100) AFTER region_id;

SELECT 'Distrito column added to incendios table' as status;

-- ============================================================================
-- STEP 2: Create temporary table for reimport
-- ============================================================================

DROP TEMPORARY TABLE IF EXISTS temp_fires_with_distrito;

CREATE TEMPORARY TABLE temp_fires_with_distrito (
    fire_code VARCHAR(50),
    ano_str VARCHAR(10),
    mes_str VARCHAR(10),
    distrito VARCHAR(100),
    concelho VARCHAR(100),
    freguesia VARCHAR(100),
    local_txt TEXT,
    data_inicio_str VARCHAR(50),
    data_fim_str VARCHAR(50),
    duracao_str VARCHAR(20),
    area_str VARCHAR(20),
    area_pov_str VARCHAR(20),
    area_mato_str VARCHAR(20),
    area_agr_str VARCHAR(20),
    causa_str VARCHAR(50),
    lat_str VARCHAR(30),
    lon_str VARCHAR(30)
);

-- ============================================================================
-- STEP 3: Import CSV with distrito
-- ============================================================================

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/luish/Desktop/Mestrado/1_semestre/Gestao e Armazenamento de Dados/DMS_Forest_Fires_Project/forest_fire_project/processed_data/fires_cleaned.csv'
INTO TABLE temp_fires_with_distrito
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 'CSV reimported' as status, COUNT(*) as `rows` FROM temp_fires_with_distrito;

-- ============================================================================
-- STEP 4: Update incendios with distrito using ano+mes+area match
-- ============================================================================

UPDATE incendios i
JOIN temp_fires_with_distrito t ON 
    i.ano = CAST(t.ano_str AS UNSIGNED) 
    AND i.mes = CAST(t.mes_str AS UNSIGNED)
    AND ABS(i.area_ardida_ha - CAST(t.area_str AS DECIMAL(12,2))) < 0.01
SET i.distrito = t.distrito;

SELECT 'Distrito values updated' as status;

-- Check how many fires got distrito
SELECT 
    COUNT(*) as total_fires,
    SUM(CASE WHEN distrito IS NOT NULL THEN 1 ELSE 0 END) as with_distrito,
    SUM(CASE WHEN distrito IS NULL THEN 1 ELSE 0 END) as without_distrito
FROM incendios;

-- ============================================================================
-- STEP 5: Normalize distrito names to match weather data
-- ============================================================================

UPDATE incendios 
SET distrito = LOWER(TRIM(distrito));

-- Check distrito distribution
SELECT distrito, COUNT(*) as num_fires
FROM incendios
WHERE distrito IS NOT NULL
GROUP BY distrito
ORDER BY num_fires DESC;

-- ============================================================================
-- STEP 6: Recreate the weather view with distrito matching
-- ============================================================================

DROP VIEW IF EXISTS v_fires_with_weather;

CREATE VIEW v_fires_with_weather AS
SELECT 
    i.fire_id,
    i.distrito,
    i.ano,
    i.mes,
    i.data_inicio,
    i.area_ardida_ha,
    i.causa,
    w.temperatura_media,
    w.temperatura_max,
    w.temperatura_min,
    w.precipitacao_total_mm,
    w.mes_nome
FROM incendios i
LEFT JOIN meteorologia_mensal w ON 
    LOWER(TRIM(i.distrito)) = LOWER(TRIM(w.distrito))
    AND i.ano = w.ano 
    AND i.mes = w.mes
WHERE i.distrito IS NOT NULL;

SELECT 'View v_fires_with_weather recreated' as status;

-- ============================================================================
-- STEP 7: Test the matching
-- ============================================================================

SELECT 
    'Matching test' as test,
    COUNT(*) as total_fires,
    SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) as fires_with_weather,
    CONCAT(ROUND(SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') as coverage
FROM v_fires_with_weather;

-- Show sample matched data
SELECT * FROM v_fires_with_weather 
WHERE temperatura_media IS NOT NULL
LIMIT 10;

-- ============================================================================
-- STEP 8: Check distrito name mismatches
-- ============================================================================

-- Distritos in fires but not in weather
SELECT DISTINCT i.distrito as fire_distrito
FROM incendios i
WHERE i.distrito NOT IN (
    SELECT DISTINCT LOWER(TRIM(distrito)) FROM meteorologia_mensal
)
AND i.distrito IS NOT NULL
ORDER BY fire_distrito;

-- Distritos in weather but not in fires  
SELECT DISTINCT w.distrito as weather_distrito
FROM meteorologia_mensal w
WHERE LOWER(TRIM(w.distrito)) NOT IN (
    SELECT DISTINCT LOWER(TRIM(distrito)) FROM incendios WHERE distrito IS NOT NULL
)
ORDER BY weather_distrito;

-- ============================================================================
-- CLEANUP
-- ============================================================================

DROP TEMPORARY TABLE IF EXISTS temp_fires_with_distrito;

-- ============================================================================
-- DONE!
-- ============================================================================

SELECT '================================================' as summary
UNION ALL SELECT 'WEATHER MATCHING FIXED!'
UNION ALL SELECT '================================================'
UNION ALL SELECT 'Check the test results above to see coverage'
UNION ALL SELECT 'If coverage is low, check distrito name mismatches'
UNION ALL SELECT '================================================';
