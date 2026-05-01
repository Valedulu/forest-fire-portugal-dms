-- ============================================================================
-- Q3: Monthly and Seasonal Fire Analysis
-- ============================================================================
-- Purpose: Analyze which months and periods have the most fires
-- Research Question: When do most forest fires occur in Portugal?
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PART 1: Fires by Month (All Years Combined)
-- ============================================================================

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
-- PART 2: Fires by Month and Year
-- ============================================================================

SELECT 
    ano AS year,
    mes AS month,
    COUNT(*) AS fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha
FROM incendios
GROUP BY ano, mes
ORDER BY ano, mes;

-- ============================================================================
-- PART 3: Fires by Season
-- ============================================================================
-- Seasons in Portugal:
-- Winter (Inverno): December, January, February
-- Spring (Primavera): March, April, May
-- Summer (Verão): June, July, August
-- Fall (Outono): September, October, November

SELECT 
    CASE 
        WHEN mes IN (12, 1, 2) THEN 'Winter (Inverno)'
        WHEN mes IN (3, 4, 5) THEN 'Spring (Primavera)'
        WHEN mes IN (6, 7, 8) THEN 'Summer (Verão)'
        WHEN mes IN (9, 10, 11) THEN 'Fall (Outono)'
    END AS season,
    COUNT(*) AS total_fires,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_burned_ha,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage_of_total
FROM incendios
GROUP BY 
    CASE 
        WHEN mes IN (12, 1, 2) THEN 'Winter (Inverno)'
        WHEN mes IN (3, 4, 5) THEN 'Spring (Primavera)'
        WHEN mes IN (6, 7, 8) THEN 'Summer (Verão)'
        WHEN mes IN (9, 10, 11) THEN 'Fall (Outono)'
    END
ORDER BY total_fires DESC;

-- ============================================================================
-- PART 4: Peak Fire Months (Top 5)
-- ============================================================================

SELECT 
    CASE mes
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name,
    COUNT(*) AS total_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(AVG(area_ardida_ha), 2) AS avg_area_per_fire_ha
FROM incendios
GROUP BY mes
ORDER BY total_fires DESC
LIMIT 5;

-- ============================================================================
-- PART 5: Monthly Fire Trends Over Years
-- ============================================================================
-- Shows how monthly patterns changed over the 2015-2024 period

SELECT 
    mes AS month,
    SUM(CASE WHEN ano BETWEEN 2015 AND 2017 THEN 1 ELSE 0 END) AS fires_2015_2017,
    SUM(CASE WHEN ano BETWEEN 2018 AND 2020 THEN 1 ELSE 0 END) AS fires_2018_2020,
    SUM(CASE WHEN ano BETWEEN 2021 AND 2024 THEN 1 ELSE 0 END) AS fires_2021_2024
FROM incendios
GROUP BY mes
ORDER BY mes;

-- ============================================================================
-- PART 6: Critical Fire Period Analysis
-- ============================================================================
-- Identifies the most dangerous consecutive months

SELECT 
    'June-September' AS critical_period,
    COUNT(*) AS total_fires,
    ROUND(SUM(area_ardida_ha), 2) AS total_area_burned_ha,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 2) AS percentage_of_annual_fires
FROM incendios
WHERE mes BETWEEN 6 AND 9;

-- ============================================================================
-- END OF Q3 ANALYSIS
-- ============================================================================
