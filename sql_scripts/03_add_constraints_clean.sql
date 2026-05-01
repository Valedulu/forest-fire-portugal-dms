-- ============================================================================
-- Forest Fire Management System - Portugal
-- Additional Constraints and Indexes Script
-- ============================================================================
-- Purpose: Add performance indexes and additional constraints
-- Database: forest_fire_mgmt
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- ADDITIONAL INDEXES FOR QUERY PERFORMANCE
-- ============================================================================
-- These indexes support the 7 main analysis queries in the project
-- ============================================================================

-- Composite index for temporal analysis (Q3, Q7)
ALTER TABLE incendios 
    ADD INDEX idx_ano_mes (ano, mes);

-- Composite index for region-based analysis (Q1, Q2, Q6)
ALTER TABLE incendios 
    ADD INDEX idx_region_ano (region_id, ano);

-- Index for area-based filtering (Q1, Q2)
ALTER TABLE incendios 
    ADD INDEX idx_region_area (region_id, area_ardida_ha);

-- Composite index for vegetation analysis (Q2)
ALTER TABLE incendio_vegetacao 
    ADD INDEX idx_veg_area (vegetation_id, area_afetada_ha);

-- ============================================================================
-- PERFORMANCE NOTES
-- ============================================================================
-- 1. Primary keys already have implicit indexes
-- 2. Foreign keys automatically create indexes in InnoDB
-- 3. Additional indexes above optimize specific query patterns
-- 4. Trade-off: Faster SELECT queries vs slower INSERT/UPDATE operations
-- ============================================================================

-- ============================================================================
-- VERIFY INDEXES
-- ============================================================================
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS COLUMNS,
    INDEX_TYPE,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'forest_fire_mgmt'
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;

SELECT 'All additional constraints and indexes created successfully!' AS Status;
