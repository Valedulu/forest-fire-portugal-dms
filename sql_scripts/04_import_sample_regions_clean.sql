-- ============================================================================
-- Forest Fire Management System - Portugal
-- Sample Regions Import Script
-- ============================================================================
-- Purpose: Import sample Portuguese district data for testing
-- Note: This is TEMPORARY sample data. Will be replaced with full hierarchy
--       from TM1 (Cristiana) which includes distrito→concelho→freguesia
-- Prerequisites: 
--   1. Database created (01_create_database.sql)
--   2. Tables created (02_create_tables.sql)
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PREPARATION
-- ============================================================================

-- Enable local file loading
SET GLOBAL local_infile = 1;

-- Clear existing data (for testing/reimport)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE regioes;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- IMPORT SAMPLE REGIONS DATA
-- ============================================================================
-- This imports the 18 Portuguese districts as a starting point
-- TM1 will provide the complete hierarchy later

LOAD DATA LOCAL INFILE 'processed_data/sample_regions.csv'
INTO TABLE regioes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(region_id, nuts_id, region_name, region_level, @parent_region_id, @area_km2)
SET
    parent_region_id = NULLIF(@parent_region_id, ''),
    area_km2 = NULLIF(@area_km2, '');

-- ============================================================================
-- VERIFY IMPORT
-- ============================================================================

SELECT 'Sample regions imported' AS Status;

SELECT COUNT(*) AS total_districts FROM regioes;

-- Show all districts
SELECT 
    region_id,
    nuts_id,
    region_name,
    region_level,
    area_km2
FROM regioes
ORDER BY region_name;

-- ============================================================================
-- VALIDATION CHECKS
-- ============================================================================

-- Check for missing critical data
SELECT 
    'Missing region names' AS check_type,
    COUNT(*) AS count
FROM regioes
WHERE region_name IS NULL OR region_name = '';

-- Check region level distribution
SELECT 
    region_level,
    COUNT(*) AS count
FROM regioes
GROUP BY region_level;

-- ============================================================================
-- NOTES FOR TM1 (CRISTIANA)
-- ============================================================================
/*
This is SAMPLE DATA with only 18 districts for testing.

When you (TM1) export the complete data from dms_INE, please include:
1. Full hierarchy: distrito → concelho → freguesia
2. All fields: region_id, nuts_id, region_name, region_level, parent_region_id, area_km2
3. Save as: processed_data/regions_complete.csv

Then we'll run 04_import_regions.sql instead of this sample script.

The complete data should have approximately:
- 18 districts (distrito)
- 308 municipalities (concelho)
- 3,091 parishes (freguesia)
Total: ~3,400 regions

NUTS codes reference:
- PT11 = Norte
- PT15 = Algarve
- PT16 = Centro
- PT17 = Área Metropolitana de Lisboa
- PT18 = Alentejo
*/

SELECT 'Sample regions import completed!' AS Status;
