-- ============================================================================
-- Complete Regions Import Script - SIMPLIFIED VERSION
-- ============================================================================
-- Purpose: Import complete Portuguese administrative hierarchy
-- Data: 3,438 regions across 6 hierarchy levels
-- File: original_data/regions/regions_dms_INE_com_area.csv
-- ============================================================================
-- INSTRUCTIONS:
-- Run this script section by section (select each block and execute)
-- OR enable "Execute current script" in DBeaver preferences
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- SECTION 1: BACKUP FIRE DATA
-- ============================================================================

DROP TABLE IF EXISTS fire_region_backup_temp;

CREATE TABLE fire_region_backup_temp AS
SELECT fire_id, region_id
FROM incendios;

SELECT 'Fire data backed up' as status, COUNT(*) as fires FROM fire_region_backup_temp;

-- ============================================================================
-- SECTION 2: RECREATE REGIONS TABLE WITH NEW ENUM
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS regioes;

CREATE TABLE regioes (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    nuts_id VARCHAR(10),
    region_name VARCHAR(100) NOT NULL,
    region_level ENUM('pais', 'nuts1', 'nuts2', 'nuts3', 'concelho', 'freguesia') NOT NULL,
    parent_region_id INT,
    area_km2 DECIMAL(10, 2),
    
    FOREIGN KEY (parent_region_id) REFERENCES regioes(region_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_nuts_id (nuts_id),
    INDEX idx_region_level (region_level),
    INDEX idx_parent (parent_region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Regions table recreated with 6 hierarchy levels' as status;

-- ============================================================================
-- SECTION 3: CREATE STAGING TABLE AND IMPORT CSV
-- ============================================================================

DROP TEMPORARY TABLE IF EXISTS temp_regions_import;

CREATE TEMPORARY TABLE temp_regions_import (
    nuts_id VARCHAR(20),
    parent_nuts_id VARCHAR(20),
    level_id INT,
    region_name VARCHAR(255),
    area_km2_raw VARCHAR(20)
);

SET GLOBAL local_infile = 1;

-- ============================================================================
-- IMPORTANT: UPDATE THIS PATH TO YOUR ACTUAL FILE LOCATION!
-- ============================================================================
-- Example Windows path:
-- C:/Users/luish/Desktop/Mestrado/1_semestre/Gestao e Armazenamento de Dados/DMS_Forest_Fires_Project/forest_fire_project/original_data/regions/regions_dms_INE_com_area.csv
-- ============================================================================

LOAD DATA LOCAL INFILE 'C:/Users/luish/Desktop/Mestrado/1_semestre/Gestao e Armazenamento de Dados/DMS_Forest_Fires_Project/forest_fire_project/original_data/regions/regions_dms_INE_com_area.csv'
INTO TABLE temp_regions_import
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nuts_id, parent_nuts_id, level_id, region_name, @area_raw)
SET area_km2_raw = NULLIF(@area_raw, '');

SELECT 'CSV imported' as status, COUNT(*) as `rows` FROM temp_regions_import;


-- ============================================================================
-- SECTION 4: INSERT REGIONS (PASS 1 - No parent references)
-- ============================================================================
ALTER TABLE regioes 
MODIFY COLUMN region_name VARCHAR(255) NOT NULL;

INSERT INTO regioes (nuts_id, region_name, region_level, area_km2, parent_region_id)
SELECT 
    nuts_id,
    region_name,
    CASE level_id
        WHEN 0 THEN 'pais'
        WHEN 1 THEN 'nuts1'
        WHEN 2 THEN 'nuts2'
        WHEN 3 THEN 'nuts3'
        WHEN 4 THEN 'concelho'
        WHEN 5 THEN 'freguesia'
        ELSE 'concelho'
    END as region_level,
    CASE 
        WHEN area_km2_raw IS NULL OR area_km2_raw = '' THEN NULL
        ELSE CAST(area_km2_raw AS DECIMAL(10,2))
    END as area_km2,
    NULL
FROM temp_regions_import;

SELECT 'Pass 1 complete' as status, COUNT(*) as regions FROM regioes;

-- ============================================================================
-- SECTION 5: UPDATE PARENT REFERENCES (PASS 2)
-- ============================================================================

UPDATE regioes r
INNER JOIN temp_regions_import t ON r.nuts_id = t.nuts_id
LEFT JOIN regioes parent ON parent.nuts_id = t.parent_nuts_id
SET r.parent_region_id = parent.region_id
WHERE t.parent_nuts_id IS NOT NULL 
  AND t.parent_nuts_id != ''
  AND t.parent_nuts_id != 'NULL';

SELECT 'Pass 2 complete - parent references updated' as status;

-- ============================================================================
-- SECTION 6: RESTORE FIRE DATA
-- ============================================================================

UPDATE incendios i
INNER JOIN fire_region_backup_temp frb ON i.fire_id = frb.fire_id
SET i.region_id = frb.region_id;

SELECT 'Fire data restored' as status;

-- ============================================================================
-- SECTION 7: VERIFICATION
-- ============================================================================

-- Total count
SELECT 'Total Regions' as metric, COUNT(*) as value FROM regioes;

-- By level
SELECT 
    region_level,
    COUNT(*) as count
FROM regioes
GROUP BY region_level
ORDER BY 
    CASE region_level
        WHEN 'pais' THEN 1
        WHEN 'nuts1' THEN 2
        WHEN 'nuts2' THEN 3
        WHEN 'nuts3' THEN 4
        WHEN 'concelho' THEN 5
        WHEN 'freguesia' THEN 6
    END;

-- Concelhos with area
SELECT 
    'Concelhos with area' as metric,
    COUNT(*) as count
FROM regioes
WHERE region_level = 'concelho' AND area_km2 IS NOT NULL;

-- Largest concelhos
SELECT 
    region_name,
    area_km2,
    nuts_id
FROM regioes
WHERE region_level = 'concelho'
ORDER BY area_km2 DESC
LIMIT 5;

-- ============================================================================
-- SECTION 8: CLEANUP
-- ============================================================================

DROP TEMPORARY TABLE IF EXISTS temp_regions_import;
DROP TABLE IF EXISTS fire_region_backup_temp;

-- ============================================================================
-- COMPLETION
-- ============================================================================

SELECT '================================================' as line
UNION ALL SELECT 'IMPORT COMPLETE!' 
UNION ALL SELECT '================================================'
UNION ALL SELECT CONCAT('Total regions: ', COUNT(*)) FROM regioes
UNION ALL SELECT '================================================';

SELECT 
    region_level,
    COUNT(*) as count,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM regioes), 1), '%') as percentage
FROM regioes
GROUP BY region_level
ORDER BY 
    CASE region_level
        WHEN 'pais' THEN 1
        WHEN 'nuts1' THEN 2
        WHEN 'nuts2' THEN 3
        WHEN 'nuts3' THEN 4
        WHEN 'concelho' THEN 5
        WHEN 'freguesia' THEN 6
    END;
