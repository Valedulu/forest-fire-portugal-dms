-- ============================================================================
-- Database Views Creation Script
-- ============================================================================
-- Purpose: Create reusable views for common analysis queries
-- Database: forest_fire_mgmt
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- VIEW 1: Monthly Fire Summary
-- ============================================================================
-- Reusable view from Q3 - fires by month

CREATE OR REPLACE VIEW v_monthly_fire_summary AS
SELECT 
    mes AS month,
    COUNT(*) AS total_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage_of_total
FROM incendios
GROUP BY mes
ORDER BY total_fires DESC;

-- ============================================================================
-- VIEW 2: Seasonal Fire Summary
-- ============================================================================
-- Reusable view from Q3 - fires by season

CREATE OR REPLACE VIEW v_seasonal_fire_summary AS
SELECT 
    CASE 
        WHEN mes IN (12, 1, 2) THEN 'Winter'
        WHEN mes IN (3, 4, 5) THEN 'Spring'
        WHEN mes IN (6, 7, 8) THEN 'Summer'
        WHEN mes IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(*) AS total_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage_of_total
FROM incendios
GROUP BY 
    CASE 
        WHEN mes IN (12, 1, 2) THEN 'Winter'
        WHEN mes IN (3, 4, 5) THEN 'Spring'
        WHEN mes IN (6, 7, 8) THEN 'Summer'
        WHEN mes IN (9, 10, 11) THEN 'Fall'
    END
ORDER BY total_fires DESC;

-- ============================================================================
-- VIEW 3: Annual Fire Summary
-- ============================================================================
-- Year-by-year fire statistics

CREATE OR REPLACE VIEW v_annual_fire_summary AS
SELECT 
    ano AS year,
    COUNT(*) AS total_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(MIN(area_ardida_ha), 2) AS min_area_ha,
    ROUND(MAX(area_ardida_ha), 2) AS max_area_ha
FROM incendios
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- VIEW 4: Fire Cause Summary
-- ============================================================================
-- Breakdown by fire cause

CREATE OR REPLACE VIEW v_fire_cause_summary AS
SELECT 
    causa AS cause,
    COUNT(*) AS total_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage_of_total
FROM incendios
GROUP BY causa
ORDER BY total_fires DESC;

-- ============================================================================
-- VIEW 5: Regional Fire Summary
-- ============================================================================
-- Fire statistics by district

CREATE OR REPLACE VIEW v_regional_fire_summary AS
SELECT 
    r.region_name AS district,
    r.nuts_id,
    COUNT(i.fire_id) AS total_fires,
    ROUND(AVG(i.area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(i.area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(r.area_km2, 2) AS district_area_km2,
    ROUND(SUM(i.area_ardida_ha) / r.area_km2 * 100, 2) AS percentage_of_district_burned
FROM incendios i
JOIN regioes r ON i.region_id = r.region_id
WHERE r.region_level = 'distrito'
GROUP BY r.region_id, r.region_name, r.nuts_id, r.area_km2
ORDER BY total_fires DESC;

-- ============================================================================
-- VIEW 6: Fire Severity Classification
-- ============================================================================
-- Categorize fires by size

CREATE OR REPLACE VIEW v_fire_severity AS
SELECT 
    fire_id,
    ano,
    mes,
    area_ardida_ha,
    CASE 
        WHEN area_ardida_ha < 1 THEN 'Very Small (<1 ha)'
        WHEN area_ardida_ha BETWEEN 1 AND 10 THEN 'Small (1-10 ha)'
        WHEN area_ardida_ha BETWEEN 10 AND 100 THEN 'Medium (10-100 ha)'
        WHEN area_ardida_ha BETWEEN 100 AND 500 THEN 'Large (100-500 ha)'
        WHEN area_ardida_ha >= 500 THEN 'Very Large (≥500 ha)'
    END AS severity_category,
    causa
FROM incendios;

-- ============================================================================
-- VIEW 7: Weather Impact (when data available)
-- ============================================================================
-- Combines fire and weather data

CREATE OR REPLACE VIEW v_fire_weather_conditions AS
SELECT 
    i.fire_id,
    i.ano,
    i.mes,
    i.area_ardida_ha,
    i.causa,
    m.temperatura_max,
    m.humidade_relativa,
    m.velocidade_vento_kmh,
    m.precipitacao_mm,
    m.indice_fwi,
    CASE 
        WHEN m.indice_fwi < 5.2 THEN 'Low'
        WHEN m.indice_fwi BETWEEN 5.2 AND 11.2 THEN 'Moderate'
        WHEN m.indice_fwi BETWEEN 11.3 AND 21.3 THEN 'High'
        WHEN m.indice_fwi BETWEEN 21.4 AND 38.0 THEN 'Very High'
        WHEN m.indice_fwi > 38.0 THEN 'Extreme'
    END AS fwi_danger_level
FROM incendios i
LEFT JOIN meteorologia m ON i.fire_id = m.fire_id;

-- ============================================================================
-- VIEW 8: Critical Fire Period Analysis
-- ============================================================================
-- Summer fire season (June-September) statistics

CREATE OR REPLACE VIEW v_critical_period_fires AS
SELECT 
    ano AS year,
    COUNT(*) AS summer_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_per_fire_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios WHERE ano = i.ano), 2) AS percentage_of_annual_fires
FROM incendios i
WHERE mes BETWEEN 6 AND 9
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- VERIFY VIEWS CREATED
-- ============================================================================

SELECT 'All views created successfully!' AS Status;

-- List all views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================

-- Example 1: Query monthly summary
-- SELECT * FROM v_monthly_fire_summary;

-- Example 2: Query seasonal patterns
-- SELECT * FROM v_seasonal_fire_summary;

-- Example 3: Find fires in extreme weather
-- SELECT * FROM v_fire_weather_conditions WHERE fwi_danger_level = 'Extreme';

-- Example 4: Regional analysis
-- SELECT * FROM v_regional_fire_summary ORDER BY total_fires DESC LIMIT 5;

-- Example 5: Large fires only
-- SELECT * FROM v_fire_severity WHERE severity_category = 'Very Large (≥500 ha)';

-- ============================================================================
-- END OF VIEWS CREATION
-- ============================================================================
