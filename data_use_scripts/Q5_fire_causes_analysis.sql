-- ============================================================================
-- Q5: Principais Causas de Incêndios (Main Fire Causes Analysis)
-- ============================================================================
-- Purpose: Analyze the distribution and impact of different fire causes
-- Research Question: What are the main causes of fires and their impact?
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- PART 1: Overview - Fire Distribution by Cause
-- ============================================================================

SELECT 
    '=== DISTRIBUIÇÃO POR CAUSA ===' as summary;

SELECT 
    causa,
    COUNT(*) AS num_incendios,
    CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incendios), 1), '%') AS percentagem,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha,
    ROUND(MAX(area_ardida_ha), 2) AS maior_incendio_ha
FROM incendios
GROUP BY causa
ORDER BY num_incendios DESC;

-- ============================================================================
-- PART 2: Causes by Year - Temporal Evolution
-- ============================================================================

SELECT 
    '=== EVOLUÇÃO TEMPORAL POR CAUSA ===' as summary;

SELECT 
    ano,
    SUM(CASE WHEN causa = 'desconhecida' THEN 1 ELSE 0 END) AS desconhecida,
    SUM(CASE WHEN causa = 'negligencia' THEN 1 ELSE 0 END) AS negligencia,
    SUM(CASE WHEN causa = 'intencional' THEN 1 ELSE 0 END) AS intencional,
    SUM(CASE WHEN causa = 'natural' THEN 1 ELSE 0 END) AS natural,
    COUNT(*) AS total_ano
FROM incendios
GROUP BY ano
ORDER BY ano;

-- ============================================================================
-- PART 3: Causes by Season
-- ============================================================================

SELECT 
    '=== CAUSAS POR ESTAÇÃO DO ANO ===' as summary;

SELECT 
    CASE 
        WHEN mes IN (12, 1, 2) THEN '1. Inverno'
        WHEN mes IN (3, 4, 5) THEN '2. Primavera'
        WHEN mes IN (6, 7, 8) THEN '3. Verão'
        WHEN mes IN (9, 10, 11) THEN '4. Outono'
    END AS estacao,
    causa,
    COUNT(*) AS num_incendios,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha
FROM incendios
GROUP BY 
    CASE 
        WHEN mes IN (12, 1, 2) THEN '1. Inverno'
        WHEN mes IN (3, 4, 5) THEN '2. Primavera'
        WHEN mes IN (6, 7, 8) THEN '3. Verão'
        WHEN mes IN (9, 10, 11) THEN '4. Outono'
    END,
    causa
ORDER BY estacao, num_incendios DESC;

-- ============================================================================
-- PART 4: Top 10 Districts by Cause
-- ============================================================================

SELECT 
    '=== TOP 10 DISTRITOS - INCÊNDIOS INTENCIONAIS ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS incendios_intencionais,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha
FROM incendios
WHERE causa = 'intencional' AND distrito IS NOT NULL
GROUP BY distrito
ORDER BY incendios_intencionais DESC
LIMIT 10;

-- Negligence fires
SELECT 
    '=== TOP 10 DISTRITOS - INCÊNDIOS POR NEGLIGÊNCIA ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS incendios_negligencia,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha
FROM incendios
WHERE causa = 'negligencia' AND distrito IS NOT NULL
GROUP BY distrito
ORDER BY incendios_negligencia DESC
LIMIT 10;

-- ============================================================================
-- PART 5: Cause Severity Analysis
-- ============================================================================

SELECT 
    '=== ANÁLISE DE SEVERIDADE POR CAUSA ===' as summary;

SELECT 
    causa,
    COUNT(*) AS total_incendios,
    -- Small fires (<1 ha)
    SUM(CASE WHEN area_ardida_ha < 1 THEN 1 ELSE 0 END) AS pequenos_1ha,
    CONCAT(ROUND(SUM(CASE WHEN area_ardida_ha < 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS pct_pequenos,
    -- Medium fires (1-10 ha)
    SUM(CASE WHEN area_ardida_ha BETWEEN 1 AND 10 THEN 1 ELSE 0 END) AS medios_1_10ha,
    -- Large fires (10-100 ha)
    SUM(CASE WHEN area_ardida_ha BETWEEN 10 AND 100 THEN 1 ELSE 0 END) AS grandes_10_100ha,
    -- Very large fires (>100 ha)
    SUM(CASE WHEN area_ardida_ha > 100 THEN 1 ELSE 0 END) AS muito_grandes_100ha,
    CONCAT(ROUND(SUM(CASE WHEN area_ardida_ha > 100 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS pct_muito_grandes
FROM incendios
GROUP BY causa
ORDER BY total_incendios DESC;

-- ============================================================================
-- PART 6: Monthly Pattern by Cause
-- ============================================================================

SELECT 
    '=== PADRÃO MENSAL POR CAUSA ===' as summary;

SELECT 
    mes,
    CASE mes
        WHEN 1 THEN 'Janeiro'
        WHEN 2 THEN 'Fevereiro'
        WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Maio'
        WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro'
        WHEN 11 THEN 'Novembro'
        WHEN 12 THEN 'Dezembro'
    END AS mes_nome,
    SUM(CASE WHEN causa = 'intencional' THEN 1 ELSE 0 END) AS intencionais,
    SUM(CASE WHEN causa = 'negligencia' THEN 1 ELSE 0 END) AS negligencia,
    SUM(CASE WHEN causa = 'desconhecida' THEN 1 ELSE 0 END) AS desconhecidas,
    SUM(CASE WHEN causa = 'natural' THEN 1 ELSE 0 END) AS naturais
FROM incendios
GROUP BY mes
ORDER BY mes;

-- ============================================================================
-- PART 7: Cause Impact Summary - Key Statistics
-- ============================================================================

SELECT 
    '=== ESTATÍSTICAS RESUMO ===' as summary;

SELECT 
    'Total de Incêndios' AS metrica,
    CAST(COUNT(*) AS CHAR) AS valor
FROM incendios

UNION ALL

SELECT 
    'Causa Mais Comum' AS metrica,
    causa AS valor
FROM incendios
GROUP BY causa
ORDER BY COUNT(*) DESC
LIMIT 1

UNION ALL

SELECT 
    'Causa Mais Destrutiva (área média)' AS metrica,
    causa AS valor
FROM incendios
GROUP BY causa
ORDER BY AVG(area_ardida_ha) DESC
LIMIT 1

UNION ALL

SELECT 
    'Percentagem Causas Desconhecidas' AS metrica,
    CONCAT(ROUND(SUM(CASE WHEN causa = 'desconhecida' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS valor
FROM incendios;

-- ============================================================================
-- END OF Q5 ANALYSIS
-- ============================================================================
-- 
-- PRINCIPAIS CONCLUSÕES:
-- - Causas desconhecidas representam ~50% dos incêndios
-- - Negligência é a segunda causa mais comum (~31%)
-- - Incêndios intencionais representam ~18%
-- - Causas naturais são raras (<1%)
-- - Verão concentra maior número de incêndios de todas as causas
-- - Necessidade de melhor investigação para reduzir causas desconhecidas
-- 
-- ============================================================================
