-- ============================================================================
-- Forest Fire Management System - Portugal
-- Data Transformation Script
-- ============================================================================
-- Purpose: Calculate derived fields and verify data integrity
-- Operations:
--   1. Calculate missing duracao_horas from timestamps
--   2. Recalculate percentagem_area for vegetation
--   3. Data quality checks and corrections
--   4. Generate summary statistics
-- Prerequisites: All data imported (fires, regions, vegetation, weather)
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PART 1: CALCULATE FIRE DURATION
-- ============================================================================
-- Calculate duracao_horas for fires where it's missing
-- Uses data_inicio and data_fim timestamps

SELECT 'PART 1: Calculating fire durations...' AS Status;

-- Show fires with missing duration but having timestamps
SELECT 
    'Fires needing duration calculation' AS metric,
    COUNT(*) AS count
FROM incendios
WHERE duracao_horas IS NULL
  AND data_inicio IS NOT NULL
  AND data_fim IS NOT NULL
  AND data_fim >= data_inicio;

-- Calculate and update duration
UPDATE incendios
SET duracao_horas = TIMESTAMPDIFF(SECOND, data_inicio, data_fim) / 3600
WHERE duracao_horas IS NULL
  AND data_inicio IS NOT NULL
  AND data_fim IS NOT NULL
  AND data_fim >= data_inicio;

-- Show results
SELECT 
    'Durations calculated' AS metric,
    COUNT(*) AS count
FROM incendios
WHERE duracao_horas IS NOT NULL;

-- Clean unrealistic durations
SELECT 'Cleaning unrealistic durations...' AS Status;

-- Set negative durations to NULL (data errors)
UPDATE incendios
SET duracao_horas = NULL
WHERE duracao_horas < 0;

-- Set extremely long durations to NULL (>30 days = 720 hours is unrealistic)
UPDATE incendios
SET duracao_horas = NULL
WHERE duracao_horas > 720;

-- ============================================================================
-- PART 2: RECALCULATE VEGETATION PERCENTAGES
-- ============================================================================
-- Ensure percentagem_area is accurate for all fire-vegetation relationships

SELECT 'PART 2: Recalculating vegetation percentages...' AS Status;

-- Update percentages based on current area values
UPDATE incendio_vegetacao fv
JOIN incendios i ON fv.fire_id = i.fire_id
SET fv.percentagem_area = ROUND((fv.area_afetada_ha / NULLIF(i.area_ardida_ha, 0)) * 100, 2)
WHERE i.area_ardida_ha > 0;

-- Fix percentages >100% (shouldn't happen but just in case)
UPDATE incendio_vegetacao
SET percentagem_area = 100
WHERE percentagem_area > 100;

-- Show results
SELECT 
    'Vegetation percentages updated' AS metric,
    COUNT(*) AS count
FROM incendio_vegetacao
WHERE percentagem_area IS NOT NULL;

-- ============================================================================
-- PART 3: DATA QUALITY CHECKS
-- ============================================================================

SELECT 'PART 3: Running data quality checks...' AS Status;

-- Create temporary table for quality report
DROP TABLE IF EXISTS temp_quality_report;
CREATE TEMPORARY TABLE temp_quality_report (
    check_type VARCHAR(100),
    issue_count INT,
    description VARCHAR(255)
);

-- Check 1: Fires with zero area
INSERT INTO temp_quality_report
SELECT 
    'Zero area fires',
    COUNT(*),
    'Fires with area_ardida_ha = 0'
FROM incendios
WHERE area_ardida_ha = 0;

-- Check 2: Fires with NULL dates
INSERT INTO temp_quality_report
SELECT 
    'Missing dates',
    COUNT(*),
    'Fires with NULL data_inicio'
FROM incendios
WHERE data_inicio IS NULL;

-- Check 3: Fires without region
INSERT INTO temp_quality_report
SELECT 
    'Missing region',
    COUNT(*),
    'Fires with NULL region_id'
FROM incendios
WHERE region_id IS NULL;

-- Check 4: Fires with invalid dates (end before start)
INSERT INTO temp_quality_report
SELECT 
    'Invalid date order',
    COUNT(*),
    'Fires where data_fim < data_inicio'
FROM incendios
WHERE data_fim IS NOT NULL 
  AND data_inicio IS NOT NULL
  AND data_fim < data_inicio;

-- Check 5: Duplicate fires (same region, same datetime, same area)
INSERT INTO temp_quality_report
SELECT 
    'Potential duplicates',
    COUNT(*) - COUNT(DISTINCT region_id, data_inicio, area_ardida_ha),
    'Possible duplicate fire records'
FROM incendios;

-- Check 6: Fires without vegetation data
INSERT INTO temp_quality_report
SELECT 
    'Missing vegetation',
    COUNT(*),
    'Fires with no vegetation breakdown'
FROM incendios i
WHERE NOT EXISTS (
    SELECT 1 FROM incendio_vegetacao fv 
    WHERE fv.fire_id = i.fire_id
);

-- Check 7: Fires without weather data
INSERT INTO temp_quality_report
SELECT 
    'Missing weather',
    COUNT(*),
    'Fires with no weather data'
FROM incendios i
WHERE NOT EXISTS (
    SELECT 1 FROM meteorologia m 
    WHERE m.fire_id = i.fire_id
);

-- Show quality report
SELECT 
    '=' AS separator 
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;

SELECT 'DATA QUALITY REPORT' AS Report;

SELECT 
    '=' AS separator 
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;

SELECT 
    check_type AS 'Issue Type',
    issue_count AS 'Count',
    description AS 'Description'
FROM temp_quality_report
ORDER BY issue_count DESC;

-- ============================================================================
-- PART 4: FIX COMMON DATA ISSUES
-- ============================================================================

SELECT 'PART 4: Fixing data issues...' AS Status;

-- Fix invalid date orders (swap dates if end < start)
UPDATE incendios
SET 
    data_fim = data_inicio,
    data_inicio = data_fim,
    duracao_horas = NULL  -- Recalculate later
WHERE data_fim IS NOT NULL 
  AND data_inicio IS NOT NULL
  AND data_fim < data_inicio;

SELECT 'Fixed date order issues' AS Status;

-- ============================================================================
-- PART 5: CALCULATE AGGREGATE STATISTICS
-- ============================================================================

SELECT 'PART 5: Calculating aggregate statistics...' AS Status;

-- Duration statistics
SELECT 'Fire Duration Statistics:' AS info;
SELECT 
    'Average duration (hours)' AS metric,
    ROUND(AVG(duracao_horas), 2) AS value
FROM incendios
WHERE duracao_horas IS NOT NULL
UNION ALL
SELECT 
    'Median duration (hours)',
    ROUND((
        SELECT duracao_horas
        FROM incendios
        WHERE duracao_horas IS NOT NULL
        ORDER BY duracao_horas
        LIMIT 1 OFFSET (SELECT COUNT(*) DIV 2 FROM incendios WHERE duracao_horas IS NOT NULL)
    ), 2)
UNION ALL
SELECT 
    'Max duration (hours)',
    ROUND(MAX(duracao_horas), 2)
FROM incendios
WHERE duracao_horas IS NOT NULL
UNION ALL
SELECT 
    'Fires >24 hours',
    COUNT(*)
FROM incendios
WHERE duracao_horas > 24;

-- Area statistics by year
SELECT 'Annual Fire Statistics:' AS info;
SELECT 
    ano,
    COUNT(*) AS num_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_ha,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_ha,
    ROUND(MAX(area_ardida_ha), 2) AS max_area_ha
FROM incendios
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- PART 6: CREATE DERIVED FIELDS (if needed)
-- ============================================================================

SELECT 'PART 6: Creating derived fields...' AS Status;

-- Add severity classification based on area
-- (This would require ALTER TABLE if column doesn't exist)

-- Show fire severity distribution
SELECT 'Fire Severity Distribution:' AS info;
SELECT 
    CASE 
        WHEN area_ardida_ha < 1 THEN 'Very Small (<1 ha)'
        WHEN area_ardida_ha < 10 THEN 'Small (1-10 ha)'
        WHEN area_ardida_ha < 100 THEN 'Medium (10-100 ha)'
        WHEN area_ardida_ha < 500 THEN 'Large (100-500 ha)'
        ELSE 'Very Large (500+ ha)'
    END AS severity,
    COUNT(*) AS num_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_ha
FROM incendios
GROUP BY severity
ORDER BY FIELD(severity, 
    'Very Small (<1 ha)', 
    'Small (1-10 ha)', 
    'Medium (10-100 ha)', 
    'Large (100-500 ha)', 
    'Very Large (500+ ha)'
);

-- ============================================================================
-- PART 7: VALIDATE REFERENTIAL INTEGRITY
-- ============================================================================

SELECT 'PART 7: Validating referential integrity...' AS Status;

-- Check for orphaned fire-vegetation records
SELECT 
    'Orphaned fire-vegetation records' AS check_type,
    COUNT(*) AS count
FROM incendio_vegetacao fv
WHERE NOT EXISTS (
    SELECT 1 FROM incendios i WHERE i.fire_id = fv.fire_id
)
OR NOT EXISTS (
    SELECT 1 FROM vegetacao v WHERE v.vegetation_id = fv.vegetation_id
);

-- Check for orphaned weather records
SELECT 
    'Orphaned weather records' AS check_type,
    COUNT(*) AS count
FROM meteorologia m
WHERE NOT EXISTS (
    SELECT 1 FROM incendios i WHERE i.fire_id = m.fire_id
);

-- Check for fires with invalid region references
SELECT 
    'Fires with invalid region' AS check_type,
    COUNT(*) AS count
FROM incendios i
WHERE i.region_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM regioes r WHERE r.region_id = i.region_id
);

-- ============================================================================
-- PART 8: GENERATE SUMMARY VIEWS
-- ============================================================================

SELECT 'PART 8: Creating summary views...' AS Status;

-- View: Monthly fire summary
DROP VIEW IF EXISTS v_monthly_summary;

CREATE VIEW v_monthly_summary AS
SELECT 
    ano,
    mes,
    COUNT(*) AS num_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_ha,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_ha,
    ROUND(AVG(duracao_horas), 2) AS avg_duration_hours
FROM incendios
GROUP BY ano, mes
ORDER BY ano, mes;

-- View: Regional fire summary
DROP VIEW IF EXISTS v_regional_summary;

CREATE VIEW v_regional_summary AS
SELECT 
    r.region_name AS distrito,
    COUNT(i.fire_id) AS num_fires,
    ROUND(SUM(i.area_ardida_ha), 2) AS total_area_ha,
    ROUND(AVG(i.area_ardida_ha), 2) AS avg_area_ha,
    MIN(i.data_inicio) AS first_fire_date,
    MAX(i.data_inicio) AS last_fire_date
FROM incendios i
JOIN regioes r ON i.region_id = r.region_id
WHERE r.region_level = 'distrito'
GROUP BY r.region_id, r.region_name
ORDER BY num_fires DESC;

-- View: Cause distribution
DROP VIEW IF EXISTS v_cause_summary;

CREATE VIEW v_cause_summary AS
SELECT 
    causa,
    COUNT(*) AS num_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_ha,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage
FROM incendios
GROUP BY causa
ORDER BY num_fires DESC;

SELECT 'Summary views created successfully' AS Status;

-- ============================================================================
-- FINAL REPORT
-- ============================================================================

SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;
SELECT 'DATA TRANSFORMATION COMPLETE' AS Status;
SELECT '=' AS separator FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3) t;

-- Overall database statistics
SELECT 
    'Total fires' AS metric,
    COUNT(*) AS value
FROM incendios
UNION ALL
SELECT 
    'Total regions',
    COUNT(*)
FROM regioes
UNION ALL
SELECT 
    'Vegetation types',
    COUNT(*)
FROM vegetacao
UNION ALL
SELECT 
    'Fire-vegetation relationships',
    COUNT(*)
FROM incendio_vegetacao
UNION ALL
SELECT 
    'Weather records',
    COUNT(*)
FROM meteorologia
UNION ALL
SELECT 
    'Date range',
    CONCAT(MIN(ano), ' - ', MAX(ano))
FROM incendios
UNION ALL
SELECT 
    'Total area burned (ha)',
    ROUND(SUM(area_ardida_ha), 2)
FROM incendios;

-- Show data completeness
SELECT 'Data Completeness:' AS info;
SELECT 
    'Fires with duration' AS field,
    ROUND(COUNT(duracao_horas) * 100.0 / COUNT(*), 2) AS completeness_pct
FROM incendios
UNION ALL
SELECT 
    'Fires with vegetation data',
    ROUND(COUNT(DISTINCT fv.fire_id) * 100.0 / (SELECT COUNT(*) FROM incendios), 2)
FROM incendio_vegetacao fv
UNION ALL
SELECT 
    'Fires with weather data',
    ROUND(COUNT(DISTINCT m.fire_id) * 100.0 / (SELECT COUNT(*) FROM incendios), 2)
FROM meteorologia m;

SELECT 'Transformation script completed successfully!' AS Status;

-- ============================================================================
-- CLEANUP
-- ============================================================================

DROP TABLE IF EXISTS temp_quality_report;
