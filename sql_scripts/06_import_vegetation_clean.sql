-- ============================================================================
-- Forest Fire Management System - Portugal
-- Vegetation Data Import Script
-- ============================================================================
-- Purpose: Import Portuguese vegetation types into the database
-- Source: ICNF IFN6 classification and forest fire literature
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- IMPORT VEGETATION TYPES
-- ============================================================================
-- Note: Adjust file path to match your system
-- For Windows: 'C:/path/to/processed_data/vegetation_types.csv'
-- For Linux/Mac: '/path/to/processed_data/vegetation_types.csv'
-- ============================================================================

-- Enable local file loading (if needed)
SET GLOBAL local_infile = 1;

-- Load vegetation data from CSV
LOAD DATA LOCAL INFILE 'processed_data/vegetation_types.csv'
INTO TABLE vegetacao
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(vegetation_id, tipo_vegetacao, inflamabilidade, descricao);

-- ============================================================================
-- VERIFY IMPORT
-- ============================================================================
SELECT COUNT(*) AS total_vegetation_types FROM vegetacao;

SELECT * FROM vegetacao ORDER BY vegetation_id;

-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================
SELECT 
    inflamabilidade,
    COUNT(*) AS count,
    GROUP_CONCAT(tipo_vegetacao SEPARATOR ', ') AS tipos
FROM vegetacao
GROUP BY inflamabilidade
ORDER BY FIELD(inflamabilidade, 'alta', 'media', 'baixa');

SELECT 'Vegetation data imported successfully!' AS Status;
