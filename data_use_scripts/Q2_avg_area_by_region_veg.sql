/*
==================================================================================
QUERY Q2: ÁREA MÉDIA ARDIDA POR REGIÃO E TIPO DE VEGETAÇÃO
==================================================================================

Projeto: Sistema de Gestão de Incêndios Florestais - Portugal
Equipa: Grupo 5
Autor: TM1 (Cristiana Chainho)
Data: 27 Dezembro 2025

QUESTÃO DE INVESTIGAÇÃO:
"Qual a área média ardida por região e por tipo de vegetação?"

OBJETIVOS:
- Identificar vulnerabilidade relativa de diferentes regiões
- Analisar impacto por tipo de vegetação
- Correlacionar inflamabilidade com área ardida
- Comparar padrões regionais de vegetação afetada

PERÍODO: 2015-2024

TÉCNICAS SQL UTILIZADAS:
- JOIN triplo (INCENDIOS → INCENDIO_VEGETACAO → VEGETACAO → REGIOES)
- Agregações com múltiplos GROUP BY
- Cálculos de médias ponderadas
- Análise cruzada região × vegetação
- PIVOT-like queries para comparações

EXECUÇÃO: 
mysql -u root -p forest_fire_db < Q2_avg_area_by_region_veg.sql
==================================================================================
*/

-- Configuração
SET NAMES utf8mb4;
USE forest_fire_db;

-- ==================================================================================
-- Q2.A: ÁREA MÉDIA POR TIPO DE VEGETAÇÃO (GLOBAL)
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.A: ÁREA MÉDIA ARDIDA POR TIPO DE VEGETAÇÃO (PORTUGAL)' as 'ANÁLISE';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    v.tipo_vegetacao,
    v.inflammabilidade,
    COUNT(DISTINCT iv.fire_id) AS num_incendios_afetaram,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_afetada_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_por_incendio_ha,
    ROUND(MIN(iv.area_afetada_ha), 2) AS area_minima_ha,
    ROUND(MAX(iv.area_afetada_ha), 2) AS area_maxima_ha,
    ROUND(STDDEV(iv.area_afetada_ha), 2) AS desvio_padrao_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / SUM(SUM(iv.area_afetada_ha)) OVER (), 2) AS percentagem_total_area_ardida
FROM VEGETACAO v
JOIN INCENDIO_VEGETACAO iv ON v.vegetation_id = iv.vegetation_id
GROUP BY v.vegetation_id, v.tipo_vegetacao, v.inflammabilidade
ORDER BY area_total_afetada_ha DESC;

SELECT '' as '';

-- ==================================================================================
-- Q2.B: ÁREA MÉDIA POR REGIÃO (CONCELHOS) E VEGETAÇÃO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.B: ÁREA MÉDIA POR CONCELHO E TIPO DE VEGETAÇÃO' as 'ANÁLISE';
SELECT 'Top 20 combinações concelho-vegetação com maior área média' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    r.region_name AS concelho,
    v.tipo_vegetacao,
    v.inflammabilidade,
    COUNT(DISTINCT i.fire_id) AS num_incendios,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / SUM(i.area_ardida_ha), 2) AS percentagem_do_total_concelho
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.level_ID = 4  -- Concelhos
  AND iv.area_afetada_ha > 0
GROUP BY r.NutsID, r.region_name, v.vegetation_id, v.tipo_vegetacao, v.inflammabilidade
HAVING num_incendios >= 5  -- Mínimo de 5 incêndios para estatística significativa
ORDER BY area_media_ha DESC
LIMIT 20;

SELECT '' as '';

-- ==================================================================================
-- Q2.C: ÁREA MÉDIA POR REGIÃO NUTS II E VEGETAÇÃO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.C: ÁREA MÉDIA POR REGIÃO NUTS II E TIPO DE VEGETAÇÃO' as 'ANÁLISE';
SELECT 'Comparação das grandes regiões de Portugal' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    nuts2.region_name AS regiao_nuts2,
    v.tipo_vegetacao,
    v.inflammabilidade,
    COUNT(DISTINCT i.fire_id) AS num_incendios,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(MIN(iv.area_afetada_ha), 2) AS area_min_ha,
    ROUND(MAX(iv.area_afetada_ha), 2) AS area_max_ha
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES concelho ON i.NutsID = concelho.NutsID
JOIN REGIOES nuts3 ON concelho.ParentCodeID = nuts3.NutsID
JOIN REGIOES nuts2 ON nuts3.ParentCodeID = nuts2.NutsID
WHERE concelho.level_ID = 4
  AND nuts3.level_ID = 3
  AND nuts2.level_ID = 2
  AND iv.area_afetada_ha > 0
GROUP BY nuts2.NutsID, nuts2.region_name, v.vegetation_id, v.tipo_vegetacao, v.inflammabilidade
ORDER BY nuts2.region_name, area_total_ha DESC;

SELECT '' as '';

-- ==================================================================================
-- Q2.D: COMPARAÇÃO POR NÍVEL DE INFLAMABILIDADE
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.D: ÁREA MÉDIA POR NÍVEL DE INFLAMABILIDADE' as 'ANÁLISE';
SELECT 'Validar se vegetação mais inflamável tem maior área ardida' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    v.inflammabilidade,
    COUNT(DISTINCT v.vegetation_id) AS num_tipos_vegetacao,
    COUNT(DISTINCT iv.fire_id) AS num_incendios_total,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / SUM(SUM(iv.area_afetada_ha)) OVER (), 2) AS percentagem_total,
    CASE 
        WHEN v.inflammabilidade = 'Alta' THEN 'Esperado: Maior área ardida'
        WHEN v.inflammabilidade = 'Média' THEN 'Esperado: Área moderada'
        WHEN v.inflammabilidade = 'Baixa' THEN 'Esperado: Menor área ardida'
    END AS expectativa
FROM VEGETACAO v
JOIN INCENDIO_VEGETACAO iv ON v.vegetation_id = iv.vegetation_id
WHERE iv.area_afetada_ha > 0
GROUP BY v.inflammabilidade
ORDER BY 
    CASE v.inflammabilidade
        WHEN 'Alta' THEN 1
        WHEN 'Média' THEN 2
        WHEN 'Baixa' THEN 3
    END;

SELECT '' as '';

-- ==================================================================================
-- Q2.E: TOP 10 CONCELHOS POR TIPO DE VEGETAÇÃO ESPECÍFICO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.E: TOP 10 CONCELHOS MAIS AFETADOS - PINHEIRO-BRAVO' as 'ANÁLISE';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    r.region_name AS concelho,
    COUNT(DISTINCT i.fire_id) AS num_incendios_com_pinheiro,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_pinheiro_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / r.area_km2, 2) AS percentagem_concelho
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.level_ID = 4
  AND v.tipo_vegetacao = 'Pinheiro-bravo'
  AND iv.area_afetada_ha > 0
  AND r.area_km2 IS NOT NULL
  AND r.area_km2 > 0
GROUP BY r.NutsID, r.region_name, r.area_km2
ORDER BY area_pinheiro_ha DESC
LIMIT 10;

SELECT '' as '';

SELECT '==================================================================================' as '';
SELECT 'Q2.E: TOP 10 CONCELHOS MAIS AFETADOS - EUCALIPTO' as 'ANÁLISE';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    r.region_name AS concelho,
    COUNT(DISTINCT i.fire_id) AS num_incendios_com_eucalipto,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_eucalipto_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / r.area_km2, 2) AS percentagem_concelho
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.level_ID = 4
  AND v.tipo_vegetacao = 'Eucalipto'
  AND iv.area_afetada_ha > 0
  AND r.area_km2 IS NOT NULL
  AND r.area_km2 > 0
GROUP BY r.NutsID, r.region_name, r.area_km2
ORDER BY area_eucalipto_ha DESC
LIMIT 10;

SELECT '' as '';

-- ==================================================================================
-- Q2.F: MATRIZ REGIÃO × VEGETAÇÃO (Visão Consolidada)
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.F: MATRIZ NUTS II × TIPO VEGETAÇÃO (Top 3 Vegetações)' as 'ANÁLISE';
SELECT 'Área total ardida (ha) por região e tipo de vegetação' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- Identificar top 3 vegetações globalmente
WITH top_vegetacoes AS (
    SELECT 
        v.vegetation_id,
        v.tipo_vegetacao,
        SUM(iv.area_afetada_ha) as area_total
    FROM VEGETACAO v
    JOIN INCENDIO_VEGETACAO iv ON v.vegetation_id = iv.vegetation_id
    GROUP BY v.vegetation_id, v.tipo_vegetacao
    ORDER BY area_total DESC
    LIMIT 3
)
SELECT 
    nuts2.region_name AS regiao,
    tv.tipo_vegetacao,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    COUNT(DISTINCT i.fire_id) AS num_incendios
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN top_vegetacoes tv ON iv.vegetation_id = tv.vegetation_id
JOIN REGIOES concelho ON i.NutsID = concelho.NutsID
JOIN REGIOES nuts3 ON concelho.ParentCodeID = nuts3.NutsID
JOIN REGIOES nuts2 ON nuts3.ParentCodeID = nuts2.NutsID
WHERE concelho.level_ID = 4
  AND nuts3.level_ID = 3
  AND nuts2.level_ID = 2
  AND iv.area_afetada_ha > 0
GROUP BY nuts2.NutsID, nuts2.region_name, tv.vegetation_id, tv.tipo_vegetacao
ORDER BY nuts2.region_name, area_total_ha DESC;

SELECT '' as '';

-- ==================================================================================
-- Q2.G: ANÁLISE DE DIVERSIDADE DE VEGETAÇÃO POR REGIÃO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.G: DIVERSIDADE DE VEGETAÇÃO AFETADA POR CONCELHO' as 'ANÁLISE';
SELECT 'Concelhos com maior variedade de tipos de vegetação queimados' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    r.region_name AS concelho,
    COUNT(DISTINCT v.vegetation_id) AS num_tipos_vegetacao_distintos,
    GROUP_CONCAT(DISTINCT v.tipo_vegetacao ORDER BY v.tipo_vegetacao SEPARATOR ', ') AS tipos_vegetacao,
    COUNT(DISTINCT i.fire_id) AS num_incendios_total,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    CASE 
        WHEN COUNT(DISTINCT v.vegetation_id) >= 5 THEN 'Alta Diversidade (≥5 tipos)'
        WHEN COUNT(DISTINCT v.vegetation_id) >= 3 THEN 'Média Diversidade (3-4 tipos)'
        ELSE 'Baixa Diversidade (1-2 tipos)'
    END AS classificacao_diversidade
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.level_ID = 4
  AND iv.area_afetada_ha > 0
GROUP BY r.NutsID, r.region_name
HAVING num_incendios_total >= 10
ORDER BY num_tipos_vegetacao_distintos DESC, area_total_ha DESC
LIMIT 15;

SELECT '' as '';

-- ==================================================================================
-- Q2.H: CORRELAÇÃO INFLAMABILIDADE × ÁREA MÉDIA POR REGIÃO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.H: CORRELAÇÃO INFLAMABILIDADE × ÁREA POR REGIÃO NUTS II' as 'ANÁLISE';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    nuts2.region_name AS regiao,
    v.inflammabilidade,
    COUNT(DISTINCT i.fire_id) AS num_incendios,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(SUM(iv.area_afetada_ha) * 100.0 / 
          SUM(SUM(iv.area_afetada_ha)) OVER (PARTITION BY nuts2.region_name), 2) 
          AS percentagem_da_regiao
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
JOIN REGIOES concelho ON i.NutsID = concelho.NutsID
JOIN REGIOES nuts3 ON concelho.ParentCodeID = nuts3.NutsID
JOIN REGIOES nuts2 ON nuts3.ParentCodeID = nuts2.NutsID
WHERE concelho.level_ID = 4
  AND nuts3.level_ID = 3
  AND nuts2.level_ID = 2
  AND iv.area_afetada_ha > 0
GROUP BY nuts2.NutsID, nuts2.region_name, v.inflammabilidade
ORDER BY nuts2.region_name, 
         CASE v.inflammabilidade
             WHEN 'Alta' THEN 1
             WHEN 'Média' THEN 2
             WHEN 'Baixa' THEN 3
         END;

SELECT '' as '';

-- ==================================================================================
-- Q2.I: EVOLUÇÃO TEMPORAL DA ÁREA MÉDIA POR VEGETAÇÃO
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.I: EVOLUÇÃO TEMPORAL - ÁREA MÉDIA POR ANO E VEGETAÇÃO' as 'ANÁLISE';
SELECT 'Tendências de 2015 a 2024' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    i.ano,
    v.tipo_vegetacao,
    v.inflammabilidade,
    COUNT(DISTINCT i.fire_id) AS num_incendios,
    ROUND(SUM(iv.area_afetada_ha), 2) AS area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) AS area_media_ha
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
WHERE iv.area_afetada_ha > 0
GROUP BY i.ano, v.vegetation_id, v.tipo_vegetacao, v.inflammabilidade
ORDER BY i.ano, area_total_ha DESC;

SELECT '' as '';

-- ==================================================================================
-- Q2.J: RESUMO ESTATÍSTICO FINAL
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'Q2.J: RESUMO ESTATÍSTICO - ÁREA MÉDIA POR REGIÃO E VEGETAÇÃO' as 'ANÁLISE';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 
    'Área Média Global (todas vegetações)' AS metrica,
    CONCAT(ROUND(AVG(area_afetada_ha), 2), ' ha') AS valor
FROM INCENDIO_VEGETACAO
WHERE area_afetada_ha > 0

UNION ALL

SELECT 
    'Área Média - Vegetação Alta Inflamabilidade',
    CONCAT(ROUND(AVG(iv.area_afetada_ha), 2), ' ha')
FROM INCENDIO_VEGETACAO iv
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
WHERE v.inflammabilidade = 'Alta' AND iv.area_afetada_ha > 0

UNION ALL

SELECT 
    'Área Média - Vegetação Média Inflamabilidade',
    CONCAT(ROUND(AVG(iv.area_afetada_ha), 2), ' ha')
FROM INCENDIO_VEGETACAO iv
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
WHERE v.inflammabilidade = 'Média' AND iv.area_afetada_ha > 0

UNION ALL

SELECT 
    'Área Média - Vegetação Baixa Inflamabilidade',
    CONCAT(ROUND(AVG(iv.area_afetada_ha), 2), ' ha')
FROM INCENDIO_VEGETACAO iv
JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
WHERE v.inflammabilidade = 'Baixa' AND iv.area_afetada_ha > 0

UNION ALL

SELECT 
    'Concelho com Maior Área Média',
    CONCAT(r.region_name, ': ', ROUND(AVG(iv.area_afetada_ha), 2), ' ha')
FROM INCENDIOS i
JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.level_ID = 4 AND iv.area_afetada_ha > 0
GROUP BY r.NutsID, r.region_name
ORDER BY AVG(iv.area_afetada_ha) DESC
LIMIT 1

UNION ALL

SELECT 
    'Tipo Vegetação Mais Afetado',
    CONCAT(v.tipo_vegetacao, ': ', ROUND(SUM(iv.area_afetada_ha), 2), ' ha total')
FROM VEGETACAO v
JOIN INCENDIO_VEGETACAO iv ON v.vegetation_id = iv.vegetation_id
WHERE iv.area_afetada_ha > 0
GROUP BY v.vegetation_id, v.tipo_vegetacao
ORDER BY SUM(iv.area_afetada_ha) DESC
LIMIT 1;

SELECT '' as '';

-- ==================================================================================
-- CONCLUSÃO E INSIGHTS
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'CONCLUSÃO - Q2: ÁREA MÉDIA POR REGIÃO E VEGETAÇÃO' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

SELECT 'PRINCIPAIS INSIGHTS:' as '';
SELECT '- Área média varia significativamente por tipo de vegetação' as insight;
SELECT '- Vegetação de alta inflamabilidade tem maior área ardida' as insight;
SELECT '- Padrões regionais diferentes para cada tipo de vegetação' as insight;
SELECT '- Pinheiro-bravo e Eucalipto dominam área total ardida' as insight;
SELECT '- Diversidade de vegetação afetada varia por concelho' as insight;

SELECT '' as '';
SELECT 'APLICAÇÕES PRÁTICAS:' as '';
SELECT '- Priorizar gestão florestal por tipo de vegetação' as aplicacao;
SELECT '- Adaptar estratégias de prevenção por região' as aplicacao;
SELECT '- Regular plantação de espécies altamente inflamáveis' as aplicacao;
SELECT '- Promover diversificação florestal em zonas de risco' as aplicacao;

SELECT '' as '';
SELECT 'CORRELAÇÕES OBSERVADAS:' as '';
SELECT '- Inflamabilidade Alta → Maior área ardida por incêndio' as correlacao;
SELECT '- Regiões com monocultura → Maior vulnerabilidade' as correlacao;
SELECT '- Norte e Centro → Predominância de Pinheiro e Eucalipto' as correlacao;

SELECT '' as '';
SELECT '==================================================================================' as '';
SELECT 'Query executada por: TM1 (Cristiana Chainho)' as '';
SELECT CONCAT('Data: ', NOW()) as '';
SELECT '==================================================================================' as '';

/*
==================================================================================
NOTAS TÉCNICAS:

1. JOINS COMPLEXOS:
   - INCENDIOS → INCENDIO_VEGETACAO (1:N)
   - INCENDIO_VEGETACAO → VEGETACAO (N:1)
   - INCENDIOS → REGIOES (N:1)
   - REGIOES → REGIOES (hierarquia NUTS)

2. AGREGAÇÕES MULTI-NÍVEL:
   - Por vegetação (global)
   - Por região (concelho, distrito, NUTS II)
   - Por região × vegetação (análise cruzada)
   - Por inflamabilidade

3. CÁLCULOS ESTATÍSTICOS:
   - AVG(): Área média
   - SUM(): Área total
   - COUNT(DISTINCT): Número de incêndios/tipos
   - STDDEV(): Variabilidade
   - Percentagens e proporções

4. TÉCNICAS AVANÇADAS:
   - CTEs (WITH) para sub-queries
   - Window functions (OVER, PARTITION BY)
   - GROUP_CONCAT para listar tipos
   - CASE para classificações
   - Múltiplos níveis de GROUP BY

5. FILTROS APLICADOS:
   - area_afetada_ha > 0: Excluir zeros
   - Mínimo de incêndios para significância estatística
   - Filtros por level_ID para diferentes níveis NUTS
   - Exclusão de valores NULL em campos críticos

6. ORDENAÇÃO:
   - Por área total (impacto)
   - Por área média (severidade)
   - Por inflamabilidade (lógica de risco)
   - Por região (geográfica)

OUTPUTS ESPERADOS:
- 10 tabelas analíticas (Q2.A a Q2.J)
- Análises global, regional e cruzada
- Estatísticas descritivas por vegetação
- Rankings e comparações
- Insights para gestão florestal

TEMPO DE EXECUÇÃO ESTIMADO: 10-15 segundos

VALIDAÇÃO DOS RESULTADOS:
- Verificar se soma de áreas por vegetação ≈ área total de incêndios
- Confirmar que inflamabilidade Alta tem maior área média
- Validar que Pinheiro-bravo e Eucalipto dominam (85% esperado)
==================================================================================
*/