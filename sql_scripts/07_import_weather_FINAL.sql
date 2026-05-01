-- ============================================================================
-- SECTION 1: CREATE MONTHLY WEATHER TABLE
-- ============================================================================
-- Select this entire section and run it (Ctrl+Enter)

USE forest_fire_mgmt;

DROP TABLE IF EXISTS meteorologia_mensal;

CREATE TABLE meteorologia_mensal (
    weather_monthly_id INT AUTO_INCREMENT PRIMARY KEY,
    distrito VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    mes_nome VARCHAR(20),
    temperatura_media DECIMAL(5, 2),
    temperatura_max DECIMAL(5, 2),
    temperatura_min DECIMAL(5, 2),
    precipitacao_total_mm DECIMAL(6, 2),
    
    UNIQUE KEY unique_distrito_mes (distrito, ano, mes),
    INDEX idx_distrito (distrito),
    INDEX idx_ano_mes (ano, mes),
    INDEX idx_distrito_ano_mes (distrito, ano, mes)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- SECTION 2: CREATE TEMPORARY IMPORT TABLE
-- ============================================================================
-- Select this entire section and run it (Ctrl+Enter)

DROP TEMPORARY TABLE IF EXISTS temp_weather_import;

CREATE TEMPORARY TABLE temp_weather_import (
    distrito VARCHAR(100),
    year_val VARCHAR(10),
    month_val VARCHAR(10),
    mes_nome VARCHAR(20),
    temperatura_media_str VARCHAR(20),
    temperatura_max_str VARCHAR(20),
    temperatura_min_str VARCHAR(20),
    precipitacao_str VARCHAR(20)
);

-- ============================================================================
-- SECTION 3: IMPORT CSV FILE
-- ============================================================================
-- IMPORTANT: UPDATE THE FILE PATH BELOW TO YOUR ACTUAL LOCATION!
-- Select this entire section and run it (Ctrl+Enter)

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/luish/Desktop/Mestrado/1_semestre/Gestao e Armazenamento de Dados/DMS_Forest_Fires_Project/forest_fire_project/processed_data/weather_data_clean.csv'
INTO TABLE temp_weather_import
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(distrito, year_val, month_val, @mes_nome, @temp_media, @temp_max, @temp_min, @precip)
SET 
    mes_nome = NULLIF(@mes_nome, ''),
    temperatura_media_str = NULLIF(@temp_media, ''),
    temperatura_max_str = NULLIF(@temp_max, ''),
    temperatura_min_str = NULLIF(@temp_min, ''),
    precipitacao_str = NULLIF(@precip, '');

-- ============================================================================
-- SECTION 4: VERIFY CSV IMPORT
-- ============================================================================
-- Select this query and run it (Ctrl+Enter)

SELECT COUNT(*) as imported_rows FROM temp_weather_import;

-- ============================================================================
-- SECTION 5: INSERT INTO FINAL TABLE
-- ============================================================================
-- Select this entire section and run it (Ctrl+Enter)

INSERT INTO meteorologia_mensal 
    (distrito, ano, mes, mes_nome, temperatura_media, temperatura_max, 
     temperatura_min, precipitacao_total_mm)
SELECT 
    distrito,
    CAST(year_val AS UNSIGNED) as ano,
    CAST(month_val AS UNSIGNED) as mes,
    mes_nome,
    CASE 
        WHEN temperatura_media_str IS NULL OR temperatura_media_str = '' THEN NULL
        ELSE CAST(temperatura_media_str AS DECIMAL(5,2))
    END as temperatura_media,
    CASE 
        WHEN temperatura_max_str IS NULL OR temperatura_max_str = '' THEN NULL
        ELSE CAST(temperatura_max_str AS DECIMAL(5,2))
    END as temperatura_max,
    CASE 
        WHEN temperatura_min_str IS NULL OR temperatura_min_str = '' THEN NULL
        ELSE CAST(temperatura_min_str AS DECIMAL(5,2))
    END as temperatura_min,
    CASE 
        WHEN precipitacao_str IS NULL OR precipitacao_str = '' THEN NULL
        ELSE CAST(precipitacao_str AS DECIMAL(6,2))
    END as precipitacao_total_mm
FROM temp_weather_import;

-- ============================================================================
-- SECTION 6: VERIFY FINAL DATA
-- ============================================================================
-- Select each query separately and run them one by one

-- Total records
SELECT COUNT(*) as total_weather_records FROM meteorologia_mensal;

-- Records by district
SELECT 
    distrito,
    COUNT(*) as months,
    MIN(ano) as first_year,
    MAX(ano) as last_year
FROM meteorologia_mensal
GROUP BY distrito
ORDER BY distrito;

-- Data completeness
SELECT 
    COUNT(*) as total_records,
    SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) as with_temperature,
    SUM(CASE WHEN precipitacao_total_mm IS NOT NULL THEN 1 ELSE 0 END) as with_precipitation
FROM meteorologia_mensal;

-- Missing temperature (should be Évora)
SELECT 
    distrito,
    COUNT(*) as months_missing_temp
FROM meteorologia_mensal
WHERE temperatura_media IS NULL
GROUP BY distrito;

-- Sample Porto data
SELECT * FROM meteorologia_mensal 
WHERE distrito = 'Porto' 
ORDER BY ano, mes 
LIMIT 12;

-- ============================================================================
-- SECTION 7: CREATE VIEW TO JOIN FIRES WITH WEATHER
-- ============================================================================
-- Select this entire section and run it (Ctrl+Enter)

DROP VIEW IF EXISTS v_fires_with_weather;

CREATE VIEW v_fires_with_weather AS
SELECT 
    i.fire_id,
    i.region_id,
    r.region_name as distrito,
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
LEFT JOIN regioes r ON i.region_id = r.region_id
LEFT JOIN meteorologia_mensal w ON 
    LOWER(TRIM(r.region_name)) = LOWER(TRIM(w.distrito))
    AND i.ano = w.ano 
    AND i.mes = w.mes
WHERE r.region_level IN ('nuts2', 'distrito', 'concelho');

-- ============================================================================
-- SECTION 8: TEST THE VIEW
-- ============================================================================
-- Select this query and run it (Ctrl+Enter)

SELECT 
    COUNT(*) as total_fires,
    SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) as fires_with_weather
FROM v_fires_with_weather;

-- ============================================================================
-- SECTION 9: CLEANUP
-- ============================================================================
-- Select this and run it (Ctrl+Enter)

DROP TEMPORARY TABLE IF EXISTS temp_weather_import;

-- ============================================================================
-- DONE! Weather data imported successfully!
-- You can now run Q4_weather_fire_correlation.sql
-- ============================================================================
