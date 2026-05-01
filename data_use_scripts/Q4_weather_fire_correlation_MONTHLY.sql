-- ============================================================================
-- Q4: Weather and Fire Severity Analysis - MONTHLY WEATHER VERSION
-- ============================================================================
-- Purpose: Analyze relationship between meteorological conditions and fire patterns
-- Research Question: How do weather conditions affect fire activity in Portugal?
-- Data: Monthly aggregated weather (2015-2020) matched to fires by distrito+year+month
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PART 1: Weather Data Coverage Summary
-- ============================================================================

SELECT 
    '=== WEATHER DATA COVERAGE ===' as summary;

SELECT 
    COUNT(*) AS total_fires_2015_2024,
    SUM(CASE WHEN ano BETWEEN 2015 AND 2020 THEN 1 ELSE 0 END) AS fires_2015_2020,
    SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) AS fires_with_weather,
    CONCAT(ROUND(SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS overall_coverage,
    CONCAT(ROUND(SUM(CASE WHEN temperatura_media IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / 
                 SUM(CASE WHEN ano BETWEEN 2015 AND 2020 THEN 1 ELSE 0 END), 1), '%') AS coverage_2015_2020
FROM v_fires_with_weather;

-- ============================================================================
-- PART 2: Average Weather Conditions Summary
-- ============================================================================

SELECT 
    '=== AVERAGE WEATHER CONDITIONS (2015-2020) ===' as summary;

SELECT 
    COUNT(*) AS fires_analyzed,
    ROUND(AVG(temperatura_media), 1) AS avg_temperature_c,
    ROUND(AVG(temperatura_max), 1) AS avg_max_temperature_c,
    ROUND(AVG(temperatura_min), 1) AS avg_min_temperature_c,
    ROUND(AVG(precipitacao_total_mm), 1) AS avg_monthly_precip_mm
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL;

-- ============================================================================
-- PART 3: Fire Activity by Temperature Ranges
-- ============================================================================

SELECT 
    '=== FIRE ACTIVITY BY TEMPERATURE ===' as summary;

SELECT 
    CASE 
        WHEN temperatura_media < 10 THEN '1. Very Cold (<10°C)'
        WHEN temperatura_media BETWEEN 10 AND 15 THEN '2. Cold (10-15°C)'
        WHEN temperatura_media BETWEEN 15 AND 20 THEN '3. Moderate (15-20°C)'
        WHEN temperatura_media BETWEEN 20 AND 25 THEN '4. Warm (20-25°C)'
        WHEN temperatura_media >= 25 THEN '5. Hot (≥25°C)'
    END AS temperature_range,
    COUNT(*) AS num_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(MAX(area_ardida_ha), 2) AS max_fire_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL
GROUP BY 
    CASE 
        WHEN temperatura_media < 10 THEN '1. Very Cold (<10°C)'
        WHEN temperatura_media BETWEEN 10 AND 15 THEN '2. Cold (10-15°C)'
        WHEN temperatura_media BETWEEN 15 AND 20 THEN '3. Moderate (15-20°C)'
        WHEN temperatura_media BETWEEN 20 AND 25 THEN '4. Warm (20-25°C)'
        WHEN temperatura_media >= 25 THEN '5. Hot (≥25°C)'
    END
ORDER BY temperature_range;

-- ============================================================================
-- PART 4: Fire Activity by Precipitation Ranges
-- ============================================================================

SELECT 
    '=== FIRE ACTIVITY BY PRECIPITATION ===' as summary;

SELECT 
    CASE 
        WHEN precipitacao_total_mm = 0 THEN '1. No Rain (0 mm)'
        WHEN precipitacao_total_mm BETWEEN 0.1 AND 25 THEN '2. Very Dry (0-25 mm)'
        WHEN precipitacao_total_mm BETWEEN 25 AND 50 THEN '3. Dry (25-50 mm)'
        WHEN precipitacao_total_mm BETWEEN 50 AND 100 THEN '4. Moderate (50-100 mm)'
        WHEN precipitacao_total_mm >= 100 THEN '5. Wet (≥100 mm)'
    END AS precipitation_range,
    COUNT(*) AS num_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM v_fires_with_weather
WHERE precipitacao_total_mm IS NOT NULL
GROUP BY 
    CASE 
        WHEN precipitacao_total_mm = 0 THEN '1. No Rain (0 mm)'
        WHEN precipitacao_total_mm BETWEEN 0.1 AND 25 THEN '2. Very Dry (0-25 mm)'
        WHEN precipitacao_total_mm BETWEEN 25 AND 50 THEN '3. Dry (25-50 mm)'
        WHEN precipitacao_total_mm BETWEEN 50 AND 100 THEN '4. Moderate (50-100 mm)'
        WHEN precipitacao_total_mm >= 100 THEN '5. Wet (≥100 mm)'
    END
ORDER BY precipitation_range;

-- ============================================================================
-- PART 5: Seasonal Weather and Fire Patterns
-- ============================================================================

SELECT 
    '=== SEASONAL PATTERNS ===' as summary;

SELECT 
    CASE 
        WHEN mes IN (12, 1, 2) THEN '1. Winter'
        WHEN mes IN (3, 4, 5) THEN '2. Spring'
        WHEN mes IN (6, 7, 8) THEN '3. Summer'
        WHEN mes IN (9, 10, 11) THEN '4. Autumn'
    END AS season,
    COUNT(*) AS num_fires,
    ROUND(AVG(temperatura_media), 1) AS avg_temp_c,
    ROUND(AVG(precipitacao_total_mm), 1) AS avg_precip_mm,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL
GROUP BY 
    CASE 
        WHEN mes IN (12, 1, 2) THEN '1. Winter'
        WHEN mes IN (3, 4, 5) THEN '2. Spring'
        WHEN mes IN (6, 7, 8) THEN '3. Summer'
        WHEN mes IN (9, 10, 11) THEN '4. Autumn'
    END
ORDER BY season;

-- ============================================================================
-- PART 6: Monthly Fire-Weather Patterns
-- ============================================================================

SELECT 
    '=== MONTHLY PATTERNS ===' as summary;

SELECT 
    mes_nome AS month,
    COUNT(*) AS num_fires,
    ROUND(AVG(temperatura_media), 1) AS avg_temp_c,
    ROUND(AVG(temperatura_max), 1) AS avg_max_temp_c,
    ROUND(AVG(precipitacao_total_mm), 1) AS avg_precip_mm,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL
GROUP BY mes, mes_nome
ORDER BY mes;

-- ============================================================================
-- PART 7: Extreme Weather Conditions Analysis
-- ============================================================================

SELECT 
    '=== EXTREME CONDITIONS ANALYSIS ===' as summary;

SELECT 
    CASE 
        WHEN temperatura_media >= 25 AND precipitacao_total_mm < 25 
        THEN 'Hot & Dry (High Risk)'
        WHEN temperatura_media >= 20 AND precipitacao_total_mm < 50
        THEN 'Warm & Dry (Moderate Risk)'
        WHEN precipitacao_total_mm >= 100
        THEN 'Wet (Low Risk)'
        ELSE 'Normal Conditions'
    END AS weather_category,
    COUNT(*) AS num_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(MAX(area_ardida_ha), 2) AS max_fire_ha,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM v_fires_with_weather WHERE temperatura_media IS NOT NULL), 1), '%') AS pct_of_fires
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL AND precipitacao_total_mm IS NOT NULL
GROUP BY 
    CASE 
        WHEN temperatura_media >= 25 AND precipitacao_total_mm < 25 
        THEN 'Hot & Dry (High Risk)'
        WHEN temperatura_media >= 20 AND precipitacao_total_mm < 50
        THEN 'Warm & Dry (Moderate Risk)'
        WHEN precipitacao_total_mm >= 100
        THEN 'Wet (Low Risk)'
        ELSE 'Normal Conditions'
    END
ORDER BY avg_area_burned_ha DESC;

-- ============================================================================
-- PART 8: Year-by-Year Weather Trends
-- ============================================================================

SELECT 
    '=== YEARLY TRENDS (2015-2020) ===' as summary;

SELECT 
    ano AS year,
    COUNT(*) AS num_fires,
    ROUND(AVG(temperatura_media), 1) AS avg_temp_c,
    ROUND(AVG(precipitacao_total_mm), 1) AS avg_precip_mm,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL
  AND ano BETWEEN 2015 AND 2020
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- PART 9: District-Level Analysis (Top 10 Districts)
-- ============================================================================

SELECT 
    '=== TOP 10 DISTRICTS WITH WEATHER DATA ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS num_fires,
    ROUND(AVG(temperatura_media), 1) AS avg_temp_c,
    ROUND(AVG(precipitacao_total_mm), 1) AS avg_precip_mm,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL
GROUP BY distrito
ORDER BY num_fires DESC
LIMIT 10;

-- ============================================================================
-- PART 10: Temperature-Precipitation Matrix
-- ============================================================================

SELECT 
    '=== TEMPERATURE-PRECIPITATION MATRIX ===' as summary;

SELECT 
    CASE 
        WHEN temperatura_media < 15 THEN 'Cold'
        WHEN temperatura_media BETWEEN 15 AND 22 THEN 'Moderate'
        WHEN temperatura_media >= 22 THEN 'Hot'
    END AS temp_category,
    CASE 
        WHEN precipitacao_total_mm < 25 THEN 'Dry'
        WHEN precipitacao_total_mm BETWEEN 25 AND 75 THEN 'Moderate'
        WHEN precipitacao_total_mm >= 75 THEN 'Wet'
    END AS precip_category,
    COUNT(*) AS num_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL AND precipitacao_total_mm IS NOT NULL
GROUP BY 
    CASE 
        WHEN temperatura_media < 15 THEN 'Cold'
        WHEN temperatura_media BETWEEN 15 AND 22 THEN 'Moderate'
        WHEN temperatura_media >= 22 THEN 'Hot'
    END,
    CASE 
        WHEN precipitacao_total_mm < 25 THEN 'Dry'
        WHEN precipitacao_total_mm BETWEEN 25 AND 75 THEN 'Moderate'
        WHEN precipitacao_total_mm >= 75 THEN 'Wet'
    END
ORDER BY temp_category, precip_category;

-- ============================================================================
-- PART 11: Simplified Correlation Analysis
-- ============================================================================

SELECT 
    '=== CORRELATION SUMMARY ===' as summary;

-- Temperature correlation
SELECT 
    'Temperature vs Area' AS metric,
    'Positive correlation expected: Higher temps → Larger fires' AS interpretation,
    COUNT(*) as sample_size
FROM v_fires_with_weather
WHERE temperatura_media IS NOT NULL AND area_ardida_ha > 0

UNION ALL

-- Precipitation correlation
SELECT 
    'Precipitation vs Area' AS metric,
    'Negative correlation expected: More rain → Smaller fires' AS interpretation,
    COUNT(*) as sample_size
FROM v_fires_with_weather
WHERE precipitacao_total_mm IS NOT NULL AND area_ardida_ha > 0;

-- ============================================================================
-- PART 12: Key Findings Summary
-- ============================================================================

SELECT 
    '=== KEY STATISTICS ===' as summary;

SELECT * FROM (
    SELECT 
        'Hottest Month Fires' AS metric,
        mes_nome AS detail,
        COUNT(*) AS value
    FROM v_fires_with_weather
    WHERE temperatura_media = (SELECT MAX(temperatura_media) FROM v_fires_with_weather WHERE temperatura_media IS NOT NULL)
    GROUP BY mes_nome
    LIMIT 1
) AS hottest


SELECT * FROM (
    SELECT 
        'Driest Month Fires' AS metric,
        mes_nome AS detail,
        COUNT(*) AS value
    FROM v_fires_with_weather
    WHERE precipitacao_total_mm = (SELECT MIN(precipitacao_total_mm) FROM v_fires_with_weather WHERE precipitacao_total_mm IS NOT NULL)
    GROUP BY mes_nome
    LIMIT 1
) AS driest


SELECT * FROM (
    SELECT 
        'Largest Fire Area (ha)' AS metric,
        distrito AS detail,
        CAST(MAX(area_ardida_ha) AS UNSIGNED) AS value
    FROM v_fires_with_weather
    WHERE temperatura_media IS NOT NULL
    GROUP BY distrito
    ORDER BY MAX(area_ardida_ha) DESC
    LIMIT 1
) AS largest;

-- ============================================================================
-- END OF Q4 ANALYSIS - MONTHLY WEATHER VERSION
-- ============================================================================
-- 
-- NOTE: This analysis uses monthly aggregated weather data (2015-2020)
-- Each fire is matched to the weather conditions of its distrito+year+month
-- Coverage: ~95% for fires in 2015-2020 period (84,459 fires)
-- 
-- INTERPRETATION GUIDE:
-- - Higher temperatures generally correlate with more fire activity
-- - Lower precipitation correlates with increased fire risk
-- - Summer months (June-August) show highest fire activity and temperatures
-- - "Hot & Dry" conditions represent the highest risk category
-- 
-- ============================================================================
