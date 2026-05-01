-- ============================================================================
-- Forest Fire Management System - Portugal
-- Fire Data Import Script
-- ============================================================================
-- Purpose: Import cleaned fire data into the incendios table
-- Source: processed_data/fires_cleaned.csv
-- Prerequisites: 
--   1. Tables created (02_create_tables.sql)
--   2. Regions data loaded (04_import_regions.sql)
--   3. Fire data cleaned (clean_fire_data.py)
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PREPARATION
-- ============================================================================

-- Enable local file loading if needed
SET GLOBAL local_infile = 1;

-- Disable foreign key checks temporarily for faster import
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- CREATE TEMPORARY TABLE FOR INITIAL IMPORT
-- ============================================================================
-- We'll import to a temp table first, then process and insert to main table
-- This allows us to handle region matching and data validation

DROP TABLE IF EXISTS temp_fires_import;

CREATE TABLE temp_fires_import (
    fire_code VARCHAR(20),
    ano INT,
    mes INT,
    distrito VARCHAR(100),
    concelho VARCHAR(100),
    freguesia VARCHAR(100),
    local VARCHAR(255),
    data_inicio DATETIME,
    data_fim DATETIME,
    duracao_horas DECIMAL(8,2),
    area_ardida_ha DECIMAL(12,2),
    area_povoamento_ha DECIMAL(12,2),
    area_mato_ha DECIMAL(12,2),
    area_agricola_ha DECIMAL(12,2),
    causa VARCHAR(50),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- IMPORT DATA FROM CSV
-- ============================================================================
-- Adjust the file path to match your system
-- For Windows: 'C:/path/to/processed_data/fires_cleaned.csv'
-- For Linux/Mac: '/path/to/processed_data/fires_cleaned.csv'

LOAD DATA LOCAL INFILE 'processed_data/fires_cleaned.csv'
INTO TABLE temp_fires_import
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @fire_code,
    ano,
    mes,
    distrito,
    concelho,
    @freguesia,
    @local,
    @data_inicio,
    @data_fim,
    @duracao_horas,
    area_ardida_ha,
    @area_povoamento_ha,
    @area_mato_ha,
    @area_agricola_ha,
    causa,
    @latitude,
    @longitude
)
SET
    fire_code = NULLIF(@fire_code, ''),
    freguesia = NULLIF(@freguesia, ''),
    local = NULLIF(@local, ''),
    data_inicio = NULLIF(@data_inicio, ''),
    data_fim = NULLIF(@data_fim, ''),
    duracao_horas = NULLIF(@duracao_horas, ''),
    area_povoamento_ha = NULLIF(@area_povoamento_ha, ''),
    area_mato_ha = NULLIF(@area_mato_ha, ''),
    area_agricola_ha = NULLIF(@area_agricola_ha, ''),
    latitude = NULLIF(@latitude, ''),
    longitude = NULLIF(@longitude, '');

-- ============================================================================
-- VERIFY IMPORT
-- ============================================================================
SELECT 'Temporary table import completed' AS Status;
SELECT COUNT(*) AS total_records_imported FROM temp_fires_import;

-- Check data distribution
SELECT 
    ano,
    COUNT(*) AS fire_count,
    SUM(area_ardida_ha) AS total_area_ha
FROM temp_fires_import
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- INSERT INTO MAIN INCENDIOS TABLE
-- ============================================================================
-- Match regions and insert fires
-- Note: This assumes regions table has distrito-level entries
-- If your regions table is different, adjust the JOIN accordingly

INSERT INTO incendios (
    region_id,
    data_inicio,
    data_fim,
    duracao_horas,
    area_ardida_ha,
    causa,
    ano,
    mes
)
SELECT 
    -- Match region_id from regioes table by distrito name
    (SELECT region_id 
     FROM regioes 
     WHERE region_name = t.distrito 
       AND region_level = 'distrito' 
     LIMIT 1) AS region_id,
    
    -- Date fields
    t.data_inicio,
    t.data_fim,
    t.duracao_horas,
    
    -- Area
    t.area_ardida_ha,
    
    -- Cause
    t.causa,
    
    -- Temporal
    t.ano,
    t.mes
    
FROM temp_fires_import t
WHERE t.distrito IS NOT NULL
  AND t.area_ardida_ha > 0
  AND EXISTS (
      SELECT 1 FROM regioes r 
      WHERE r.region_name = t.distrito 
        AND r.region_level = 'distrito'
  );

-- ============================================================================
-- VERIFY MAIN TABLE INSERT
-- ============================================================================
SELECT 'Main table insert completed' AS Status;

SELECT COUNT(*) AS total_fires FROM incendios;

-- Check fires by year
SELECT 
    ano,
    COUNT(*) AS fire_count,
    SUM(area_ardida_ha) AS total_area_ha,
    AVG(area_ardida_ha) AS avg_area_ha,
    MAX(area_ardida_ha) AS max_area_ha
FROM incendios
GROUP BY ano
ORDER BY ano;

-- Check fires by cause
SELECT 
    causa,
    COUNT(*) AS fire_count,
    SUM(area_ardida_ha) AS total_area_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage
FROM incendios
GROUP BY causa
ORDER BY fire_count DESC;

-- Check fires by region (top 10 districts)
SELECT 
    r.region_name AS distrito,
    COUNT(i.fire_id) AS fire_count,
    SUM(i.area_ardida_ha) AS total_area_ha
FROM incendios i
JOIN regioes r ON i.region_id = r.region_id
WHERE r.region_level = 'distrito'
GROUP BY r.region_name
ORDER BY fire_count DESC
LIMIT 10;

-- ============================================================================
-- HANDLE FIRES WITHOUT REGION MATCH
-- ============================================================================
-- Check how many fires couldn't be matched to regions
SELECT COUNT(*) AS unmatched_fires
FROM temp_fires_import t
WHERE t.distrito IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM regioes r 
      WHERE r.region_name = t.distrito 
        AND r.region_level = 'distrito'
  );

-- Show unique districts that couldn't be matched
SELECT DISTINCT distrito, COUNT(*) AS fire_count
FROM temp_fires_import t
WHERE t.distrito IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM regioes r 
      WHERE r.region_name = t.distrito 
        AND r.region_level = 'distrito'
  )
GROUP BY distrito
ORDER BY fire_count DESC;

-- ============================================================================
-- CLEANUP
-- ============================================================================
-- Drop temporary table
DROP TABLE IF EXISTS temp_fires_import;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;
SELECT 'FIRE DATA IMPORT COMPLETE' AS Status;
SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;

SELECT 
    'Total fires imported' AS metric,
    COUNT(*) AS value
FROM incendios
UNION ALL
SELECT 
    'Year range',
    CONCAT(MIN(ano), ' - ', MAX(ano))
FROM incendios
UNION ALL
SELECT 
    'Total area burned (ha)',
    ROUND(SUM(area_ardida_ha), 2)
FROM incendios
UNION ALL
SELECT 
    'Average fire size (ha)',
    ROUND(AVG(area_ardida_ha), 2)
FROM incendios;

SELECT 'Fire import script completed successfully!' AS Status;
