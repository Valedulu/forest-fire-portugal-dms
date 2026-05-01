-- ============================================================================
-- Q1: Concelhos e Distritos Mais Afetados por Incêndios
-- ============================================================================
-- Versão CORRIGIDA para compatibilidade com a base de dados forest_fire_mgmt
-- Estrutura: incendios tem distrito (não region_id ligado a nomes)
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- Q1.A: TOP 10 DISTRITOS POR NÚMERO DE INCÊNDIOS
-- ============================================================================

SELECT 
    '=== TOP 10 DISTRITOS POR NÚMERO DE INCÊNDIOS ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS num_incendios,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ardida_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_por_incendio_ha,
    ROUND(MAX(area_ardida_ha), 2) AS maior_incendio_ha,
    MIN(ano) AS primeiro_ano,
    MAX(ano) AS ultimo_ano,
    CASE 
        WHEN COUNT(*) >= 15000 THEN 'Risco Muito Alto'
        WHEN COUNT(*) >= 10000 THEN 'Risco Alto'
        WHEN COUNT(*) >= 5000 THEN 'Risco Moderado'
        ELSE 'Risco Baixo'
    END AS classificacao_risco
FROM incendios
WHERE distrito IS NOT NULL
  AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY num_incendios DESC
LIMIT 10;

-- ============================================================================
-- Q1.B: TOP 10 DISTRITOS POR ÁREA TOTAL ARDIDA
-- ============================================================================

SELECT 
    '=== TOP 10 DISTRITOS POR ÁREA TOTAL ARDIDA ===' as summary;

SELECT 
    distrito,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ardida_ha,
    COUNT(*) AS num_incendios,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha,
    ROUND(MAX(area_ardida_ha), 2) AS maior_incendio_ha,
    CASE 
        WHEN SUM(area_ardida_ha) >= 50000 THEN '🔥 Impacto Crítico'
        WHEN SUM(area_ardida_ha) >= 30000 THEN '⚠️  Impacto Severo'
        WHEN SUM(area_ardida_ha) >= 15000 THEN '⚠️  Impacto Moderado'
        ELSE 'Impacto Baixo'
    END AS nivel_impacto
FROM incendios
WHERE distrito IS NOT NULL
  AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY area_total_ardida_ha DESC
LIMIT 10;

-- ============================================================================
-- Q1.C: DISTRIBUIÇÃO DE INCÊNDIOS POR TAMANHO (TODOS OS DISTRITOS)
-- ============================================================================

SELECT 
    '=== DISTRIBUIÇÃO POR TAMANHO DE INCÊNDIO ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS total_incendios,
    SUM(CASE WHEN area_ardida_ha < 1 THEN 1 ELSE 0 END) AS pequenos_menos_1ha,
    SUM(CASE WHEN area_ardida_ha BETWEEN 1 AND 10 THEN 1 ELSE 0 END) AS medios_1_10ha,
    SUM(CASE WHEN area_ardida_ha BETWEEN 10 AND 100 THEN 1 ELSE 0 END) AS grandes_10_100ha,
    SUM(CASE WHEN area_ardida_ha > 100 THEN 1 ELSE 0 END) AS muito_grandes_mais_100ha,
    CONCAT(ROUND(SUM(CASE WHEN area_ardida_ha < 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS pct_pequenos
FROM incendios
WHERE distrito IS NOT NULL
  AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY total_incendios DESC;

-- ============================================================================
-- Q1.D: ANÁLISE TEMPORAL - TOP 5 DISTRITOS
-- ============================================================================

SELECT 
    '=== EVOLUÇÃO TEMPORAL - TOP 5 DISTRITOS ===' as summary;

WITH top_distritos AS (
    SELECT distrito
    FROM incendios
    WHERE distrito IS NOT NULL AND area_ardida_ha > 0
    GROUP BY distrito
    ORDER BY SUM(area_ardida_ha) DESC
    LIMIT 5
)
SELECT 
    i.distrito,
    i.ano,
    COUNT(*) AS num_incendios,
    ROUND(SUM(i.area_ardida_ha), 2) AS area_ardida_ha
FROM incendios i
WHERE i.distrito IN (SELECT distrito FROM top_distritos)
  AND i.area_ardida_ha > 0
GROUP BY i.distrito, i.ano
ORDER BY i.distrito, i.ano;

-- ============================================================================
-- Q1.E: COMPARAÇÃO FREQUÊNCIA vs SEVERIDADE
-- ============================================================================

SELECT 
    '=== FREQUÊNCIA vs SEVERIDADE ===' as summary;

SELECT 
    distrito,
    COUNT(*) AS num_incendios,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha,
    ROUND(MAX(area_ardida_ha), 2) AS maior_incendio_ha,
    CASE 
        WHEN AVG(area_ardida_ha) > 10 AND COUNT(*) >= 10000 THEN '🔥 Alto: Muitos e Grandes'
        WHEN AVG(area_ardida_ha) > 10 AND COUNT(*) < 10000 THEN '⚠️  Médio: Poucos mas Grandes'
        WHEN AVG(area_ardida_ha) <= 10 AND COUNT(*) >= 10000 THEN '⚠️  Médio: Muitos mas Pequenos'
        ELSE 'Baixo: Poucos e Pequenos'
    END AS perfil_risco
FROM incendios
WHERE distrito IS NOT NULL
  AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY area_total_ha DESC;

-- ============================================================================
-- Q1.F: ESTATÍSTICAS POR ESTAÇÃO DO ANO
-- ============================================================================

SELECT 
    '=== DISTRIBUIÇÃO POR ESTAÇÃO - TOP 5 DISTRITOS ===' as summary;

WITH top_distritos AS (
    SELECT distrito
    FROM incendios
    WHERE distrito IS NOT NULL AND area_ardida_ha > 0
    GROUP BY distrito
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
SELECT 
    i.distrito,
    CASE 
        WHEN i.mes IN (12, 1, 2) THEN 'Inverno'
        WHEN i.mes IN (3, 4, 5) THEN 'Primavera'
        WHEN i.mes IN (6, 7, 8) THEN 'Verão'
        WHEN i.mes IN (9, 10, 11) THEN 'Outono'
    END AS estacao,
    COUNT(*) AS num_incendios,
    ROUND(SUM(i.area_ardida_ha), 2) AS area_total_ha
FROM incendios i
WHERE i.distrito IN (SELECT distrito FROM top_distritos)
  AND i.area_ardida_ha > 0
GROUP BY i.distrito, estacao
ORDER BY i.distrito, 
    CASE 
        WHEN i.mes IN (12, 1, 2) THEN 1
        WHEN i.mes IN (3, 4, 5) THEN 2
        WHEN i.mes IN (6, 7, 8) THEN 3
        WHEN i.mes IN (9, 10, 11) THEN 4
    END;

-- ============================================================================
-- Q1.G: RESUMO ESTATÍSTICO GERAL
-- ============================================================================

SELECT 
    '=== RESUMO ESTATÍSTICO GERAL ===' as summary;

SELECT 
    'Total de Distritos Afetados' AS metrica,
    COUNT(DISTINCT distrito) AS valor
FROM incendios
WHERE distrito IS NOT NULL AND area_ardida_ha > 0

UNION ALL

SELECT 
    'Distrito com Mais Incêndios',
    distrito
FROM incendios
WHERE distrito IS NOT NULL AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY COUNT(*) DESC
LIMIT 1

UNION ALL

SELECT 
    'Distrito com Maior Área Ardida',
    distrito
FROM incendios
WHERE distrito IS NOT NULL AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY SUM(area_ardida_ha) DESC
LIMIT 1

UNION ALL

SELECT 
    'Média de Incêndios por Distrito',
    CAST(ROUND(AVG(num_incendios), 1) AS CHAR)
FROM (
    SELECT distrito, COUNT(*) as num_incendios
    FROM incendios
    WHERE distrito IS NOT NULL AND area_ardida_ha > 0
    GROUP BY distrito
) sub;

-- ============================================================================
-- Q1.H: RANKING COMPLETO DE DISTRITOS
-- ============================================================================

SELECT 
    '=== RANKING COMPLETO DE TODOS OS DISTRITOS ===' as summary;

SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS ranking,
    distrito,
    COUNT(*) AS num_incendios,
    ROUND(SUM(area_ardida_ha), 2) AS area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) AS area_media_ha,
    CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1), '%') AS pct_total_incendios,
    CONCAT(ROUND(SUM(area_ardida_ha) * 100.0 / SUM(SUM(area_ardida_ha)) OVER (), 1), '%') AS pct_area_total
FROM incendios
WHERE distrito IS NOT NULL
  AND area_ardida_ha > 0
GROUP BY distrito
ORDER BY num_incendios DESC;

-- ============================================================================
-- CONCLUSÕES E INSIGHTS
-- ============================================================================

SELECT 
    '=== PRINCIPAIS CONCLUSÕES ===' as summary;

SELECT 'INSIGHTS PRINCIPAIS:' as categoria, '' as detalhe
UNION ALL
SELECT '1. Distribuição Geográfica', 'Identificados distritos críticos para intervenção'
UNION ALL
SELECT '2. Padrões de Severidade', 'Alguns distritos têm muitos incêndios pequenos, outros poucos mas grandes'
UNION ALL
SELECT '3. Evolução Temporal', 'Tendências identificadas para os distritos mais afetados'
UNION ALL
SELECT '4. Sazonalidade', 'Verão concentra maior atividade em todos os distritos'
UNION ALL
SELECT '', ''
UNION ALL
SELECT 'APLICAÇÕES PRÁTICAS:', ''
UNION ALL
SELECT '- Priorização de recursos', 'Focar nos distritos de maior risco'
UNION ALL
SELECT '- Prevenção direcionada', 'Campanhas específicas por região'
UNION ALL
SELECT '- Planeamento estratégico', 'Alocação eficiente de meios de combate';

-- ============================================================================
-- END OF Q1 ANALYSIS
-- ============================================================================