-- ============================================================================
-- Forest Fire Management System - Portugal
-- Fire-Vegetation Import Script
-- ============================================================================
-- Purpose: Import fire-vegetation relationships (which vegetation types burned)
-- Source: Derived from fires data (area_povoamento_ha, area_mato_ha, area_agricola_ha)
-- Prerequisites: 
--   1. Fires imported (05_import_fires.sql)
--   2. Vegetation types imported (06_import_vegetation.sql)
--   3. Processed fire-vegetation data: processed_data/fire_vegetation.csv
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- DATA PROCESSING NOTES
-- ============================================================================
/*
The fire data contains:
- area_povoamento_ha (forest plantation area)
- area_mato_ha (shrubland area)  
- area_agricola_ha (agricultural area)

These need to be transformed into the incendio_vegetacao junction table:
- Each fire can affect multiple vegetation types
- Link fire_id to vegetation_id
- Store area_afetada_ha for each vegetation type
- Calculate percentagem_area = (area_afetada / area_total) * 100

The vegetation types to map:
- area_povoamento_ha → Multiple types (Pinheiro-bravo, Eucalipto, etc.)
- area_mato_ha → "Mato" vegetation type
- area_agricola_ha → "Pastagem" or "Agricultura" types

Note: We'll use simplified mapping for now. 
TM1 may provide more detailed vegetation breakdown later.
*/

-- ============================================================================
-- PREPARATION
-- ============================================================================

-- Enable local file loading
SET GLOBAL local_infile = 1;

-- Clear existing data (for reimport)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE incendio_vegetacao;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- METHOD 1: Import from Pre-processed CSV
-- ============================================================================
-- If you've already created processed_data/fire_vegetation.csv

LOAD DATA LOCAL INFILE 'processed_data/fire_vegetation.csv'
INTO TABLE incendio_vegetacao
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(fire_id, vegetation_id, area_afetada_ha, @percentagem_area)
SET
    percentagem_area = NULLIF(@percentagem_area, '');

-- ============================================================================
-- METHOD 2: Generate from Fire Data (if CSV doesn't exist yet)
-- ============================================================================
-- This creates the relationships programmatically from the fires data

-- First, let's see what vegetation IDs we have
SELECT vegetation_id, tipo_vegetacao 
FROM vegetacao 
ORDER BY vegetation_id;

-- Simplified mapping approach:
-- - If area_mato_ha > 0, create record for "Mato" (vegetation_id = 4)
-- - If area_povoamento_ha > 0, split between common forest types
-- - If area_agricola_ha > 0, create record for "Pastagem" (vegetation_id = 6)

-- Clean slate for Method 2
DELETE FROM incendio_vegetacao;

-- Insert Mato (Shrubland) records
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    4 AS vegetation_id,  -- Mato
    area_mato_ha AS area_afetada_ha,
    ROUND((area_mato_ha / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_mato_ha > 0;

-- Insert Agriculture/Pasture records
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    6 AS vegetation_id,  -- Pastagem
    area_agricola_ha AS area_afetada_ha,
    ROUND((area_agricola_ha / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_agricola_ha > 0;

-- Insert Forest Plantation records
-- Split area_povoamento_ha across common forest types (simplified)
-- Real distribution would require forest inventory data

-- Pinheiro-bravo (assume 40% of forest area)
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    1 AS vegetation_id,  -- Pinheiro-bravo
    area_povoamento_ha * 0.4 AS area_afetada_ha,
    ROUND((area_povoamento_ha * 0.4 / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_povoamento_ha > 0;

-- Eucalipto (assume 35% of forest area)
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    2 AS vegetation_id,  -- Eucalipto
    area_povoamento_ha * 0.35 AS area_afetada_ha,
    ROUND((area_povoamento_ha * 0.35 / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_povoamento_ha > 0;

-- Sobreiro (assume 15% of forest area)
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    3 AS vegetation_id,  -- Sobreiro
    area_povoamento_ha * 0.15 AS area_afetada_ha,
    ROUND((area_povoamento_ha * 0.15 / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_povoamento_ha > 0;

-- Carvalho (assume 10% of forest area)
INSERT INTO incendio_vegetacao (fire_id, vegetation_id, area_afetada_ha, percentagem_area)
SELECT 
    fire_id,
    5 AS vegetation_id,  -- Carvalho
    area_povoamento_ha * 0.10 AS area_afetada_ha,
    ROUND((area_povoamento_ha * 0.10 / NULLIF(area_ardida_ha, 0)) * 100, 2) AS percentagem_area
FROM incendios
WHERE area_povoamento_ha > 0;

-- ============================================================================
-- VERIFY IMPORT
-- ============================================================================

SELECT 'Fire-vegetation relationships created' AS Status;

SELECT COUNT(*) AS total_relationships FROM incendio_vegetacao;

-- Show how many fires have vegetation data
SELECT 
    'Fires with vegetation data' AS metric,
    COUNT(DISTINCT fire_id) AS value
FROM incendio_vegetacao
UNION ALL
SELECT 
    'Total fires in database',
    COUNT(*)
FROM incendios;

-- Show sample records
SELECT 
    fv.fire_veg_id,
    fv.fire_id,
    v.tipo_vegetacao,
    fv.area_afetada_ha,
    fv.percentagem_area
FROM incendio_vegetacao fv
JOIN vegetacao v ON fv.vegetation_id = v.vegetation_id
LIMIT 10;

-- ============================================================================
-- VALIDATION CHECKS
-- ============================================================================

SELECT 'Validation Checks:' AS info;

-- Check for invalid percentages (should be 0-100)
SELECT 'Invalid percentages (>100%):' AS check_type;
SELECT COUNT(*) AS invalid_count
FROM incendio_vegetacao
WHERE percentagem_area > 100;

-- Check for negative areas
SELECT 'Negative areas:' AS check_type;
SELECT COUNT(*) AS invalid_count
FROM incendio_vegetacao
WHERE area_afetada_ha < 0;

-- Check total percentage per fire (should not exceed 100%)
SELECT 'Fires with total percentage >100%:' AS check_type;
SELECT COUNT(*) AS invalid_count
FROM (
    SELECT fire_id, SUM(percentagem_area) AS total_pct
    FROM incendio_vegetacao
    GROUP BY fire_id
    HAVING total_pct > 100
) AS invalid_fires;

-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================

SELECT 'Vegetation Statistics:' AS info;

-- Total area by vegetation type
SELECT 
    v.tipo_vegetacao,
    COUNT(DISTINCT fv.fire_id) AS num_fires,
    ROUND(SUM(fv.area_afetada_ha), 2) AS total_area_ha,
    ROUND(AVG(fv.area_afetada_ha), 2) AS avg_area_per_fire_ha
FROM incendio_vegetacao fv
JOIN vegetacao v ON fv.vegetation_id = v.vegetation_id
GROUP BY v.vegetation_id, v.tipo_vegetacao
ORDER BY total_area_ha DESC;

-- Vegetation by flammability level
SELECT 
    v.inflamabilidade,
    COUNT(DISTINCT fv.fire_id) AS num_fires,
    ROUND(SUM(fv.area_afetada_ha), 2) AS total_area_ha
FROM incendio_vegetacao fv
JOIN vegetacao v ON fv.vegetation_id = v.vegetation_id
GROUP BY v.inflamabilidade
ORDER BY FIELD(v.inflamabilidade, 'alta', 'media', 'baixa');

-- Average number of vegetation types per fire
SELECT 
    'Average vegetation types per fire' AS metric,
    ROUND(AVG(veg_count), 2) AS value
FROM (
    SELECT fire_id, COUNT(DISTINCT vegetation_id) AS veg_count
    FROM incendio_vegetacao
    GROUP BY fire_id
) AS fire_veg_counts;

-- ============================================================================
-- CREATE USEFUL VIEWS
-- ============================================================================

-- View: Fire details with vegetation breakdown
DROP VIEW IF EXISTS v_fires_vegetation;

CREATE VIEW v_fires_vegetation AS
SELECT 
    i.fire_id,
    i.ano,
    i.mes,
    r.region_name AS distrito,
    i.area_ardida_ha AS total_area,
    v.tipo_vegetacao,
    v.inflamabilidade,
    fv.area_afetada_ha,
    fv.percentagem_area
FROM incendios i
JOIN regioes r ON i.region_id = r.region_id
JOIN incendio_vegetacao fv ON i.fire_id = fv.fire_id
JOIN vegetacao v ON fv.vegetation_id = v.vegetation_id;

-- Test the view
SELECT 'Sample from fires-vegetation view:' AS info;
SELECT * FROM v_fires_vegetation LIMIT 10;

-- View: Most affected vegetation types by year
DROP VIEW IF EXISTS v_vegetation_by_year;

CREATE VIEW v_vegetation_by_year AS
SELECT 
    i.ano,
    v.tipo_vegetacao,
    COUNT(DISTINCT fv.fire_id) AS num_fires,
    ROUND(SUM(fv.area_afetada_ha), 2) AS total_area_ha
FROM incendio_vegetacao fv
JOIN vegetacao v ON fv.vegetation_id = v.vegetation_id
JOIN incendios i ON fv.fire_id = i.fire_id
GROUP BY i.ano, v.tipo_vegetacao
ORDER BY i.ano, total_area_ha DESC;

-- Test the view
SELECT 'Vegetation burned by year:' AS info;
SELECT * FROM v_vegetation_by_year WHERE ano = 2017 LIMIT 5;

-- ============================================================================
-- FINAL STATUS
-- ============================================================================

SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;
SELECT 'FIRE-VEGETATION IMPORT COMPLETE' AS Status;
SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;

SELECT 
    'Vegetation relationships created' AS metric,
    COUNT(*) AS value
FROM incendio_vegetacao
UNION ALL
SELECT 
    'Fires with vegetation data',
    COUNT(DISTINCT fire_id)
FROM incendio_vegetacao
UNION ALL
SELECT 
    'Vegetation types tracked',
    COUNT(DISTINCT vegetation_id)
FROM incendio_vegetacao;

SELECT 'Fire-vegetation import script completed successfully!' AS Status;

-- ============================================================================
-- NOTES
-- ============================================================================
/*
IMPORTANT ASSUMPTIONS:

This script uses a simplified vegetation distribution model:
- Pinheiro-bravo: 40% of forest area
- Eucalipto: 35% of forest area
- Sobreiro: 15% of forest area
- Carvalho: 10% of forest area

These percentages are based on general Portuguese forest composition.
For more accurate data, you would need:
1. IFN6 (6º Inventário Florestal Nacional) data
2. ICNF forest maps
3. COS (Carta de Ocupação do Solo) land use data

If TM1 can provide detailed vegetation data from dms_INE or other sources,
this script can be updated to use actual vegetation distributions by region.

NEXT STEPS:
1. Verify percentages make sense
2. Compare with known forest composition data
3. Update percentages if better data becomes available
4. Run analysis queries (Research Question 2)
*/
