/*
==================================================================================
SCRIPT DE VALIDAÇÃO DE INTEGRIDADE DE DADOS
Sistema de Gestão de Incêndios Florestais - Portugal
==================================================================================

Projeto: Forest Fire Management System - Portugal
Equipa: Grupo 5
Autor: TM1 (Cristiana Chainho)
Data: 27 Dezembro 2025

Propósito: 
- Verificar integridade referencial de todas as relações
- Validar consistência de dados
- Identificar problemas e anomalias
- Gerar relatório de qualidade de dados

Execução: mysql -u root -p forest_fire_db < 10_verify_data.sql
==================================================================================
*/

-- Configuração inicial
SET NAMES utf8mb4;
USE forest_fire_db;

-- ==================================================================================
-- PARTE 1: VERIFICAÇÃO DE INTEGRIDADE REFERENCIAL
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'PARTE 1: VERIFICAÇÃO DE INTEGRIDADE REFERENCIAL' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- ==================================================================================
-- 1.1 Verificar REGIOES → REGIOES (auto-referencial)
-- ==================================================================================

SELECT '1.1 Verificar Hierarquia REGIOES (auto-referencial)' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

-- Contar regiões órfãs (ParentCodeID inválido)
SELECT 
    COUNT(*) as registos_orfaos,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Sem registos órfãos'
        WHEN COUNT(*) = 1 THEN '⚠️  WARN - 1 registo órfão (conhecido e documentado)'
        ELSE '❌ FAIL - Múltiplos registos órfãos detectados'
    END as status
FROM REGIOES r1
LEFT JOIN REGIOES r2 ON r1.ParentCodeID = r2.NutsID
WHERE r1.ParentCodeID IS NOT NULL 
  AND r2.NutsID IS NULL;

-- Se houver órfãos, mostrar quais são
SELECT 'Regiões órfãs (se houver):' as '';
SELECT 
    r1.NutsID,
    r1.region_name,
    r1.level_ID,
    r1.ParentCodeID as parent_invalido
FROM REGIOES r1
LEFT JOIN REGIOES r2 ON r1.ParentCodeID = r2.NutsID
WHERE r1.ParentCodeID IS NOT NULL 
  AND r2.NutsID IS NULL
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- 1.2 Verificar INCENDIOS → REGIOES
-- ==================================================================================

SELECT '1.2 Verificar INCENDIOS → REGIOES' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

-- Contar incêndios sem região válida
SELECT 
    COUNT(*) as incendios_sem_regiao,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todos os incêndios têm região válida'
        ELSE '❌ FAIL - Incêndios sem região detectados'
    END as status
FROM INCENDIOS i
LEFT JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.NutsID IS NULL;

-- Se houver problemas, mostrar exemplos
SELECT 'Incêndios sem região (se houver):' as '';
SELECT 
    i.fire_id,
    i.NutsID as nuts_invalido,
    i.data_inicio,
    i.area_ardida_ha
FROM INCENDIOS i
LEFT JOIN REGIOES r ON i.NutsID = r.NutsID
WHERE r.NutsID IS NULL
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- 1.3 Verificar INCENDIO_VEGETACAO → INCENDIOS
-- ==================================================================================

SELECT '1.3 Verificar INCENDIO_VEGETACAO → INCENDIOS' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as registos_vegetacao_orfaos,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todos os registos têm incêndio válido'
        ELSE '❌ FAIL - Registos de vegetação sem incêndio'
    END as status
FROM INCENDIO_VEGETACAO iv
LEFT JOIN INCENDIOS i ON iv.fire_id = i.fire_id
WHERE i.fire_id IS NULL;

SELECT '' as '';

-- ==================================================================================
-- 1.4 Verificar INCENDIO_VEGETACAO → VEGETACAO
-- ==================================================================================

SELECT '1.4 Verificar INCENDIO_VEGETACAO → VEGETACAO' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as registos_vegetacao_tipo_invalido,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todos os registos têm tipo de vegetação válido'
        ELSE '❌ FAIL - Registos com tipo de vegetação inválido'
    END as status
FROM INCENDIO_VEGETACAO iv
LEFT JOIN VEGETACAO v ON iv.vegetation_id = v.vegetation_id
WHERE v.vegetation_id IS NULL;

SELECT '' as '';

-- ==================================================================================
-- 1.5 Verificar METEOROLOGIA → INCENDIOS
-- ==================================================================================

SELECT '1.5 Verificar METEOROLOGIA → INCENDIOS' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as registos_meteo_orfaos,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todos os registos meteorológicos têm incêndio válido'
        ELSE '❌ FAIL - Registos meteorológicos sem incêndio'
    END as status
FROM METEOROLOGIA m
LEFT JOIN INCENDIOS i ON m.fire_id = i.fire_id
WHERE i.fire_id IS NULL;

SELECT '' as '';

-- ==================================================================================
-- PARTE 2: VERIFICAÇÃO DE CARDINALIDADES
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'PARTE 2: VERIFICAÇÃO DE CARDINALIDADES' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- ==================================================================================
-- 2.1 Verificar Cardinalidade 1:1 METEOROLOGIA-INCENDIOS
-- ==================================================================================

SELECT '2.1 Verificar Cardinalidade 1:1 (METEOROLOGIA-INCENDIOS)' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as incendios_com_multiplos_registos_meteo,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Cardinalidade 1:1 respeitada'
        ELSE '❌ FAIL - Incêndios com múltiplos registos meteorológicos'
    END as status
FROM (
    SELECT fire_id, COUNT(*) as num_registos
    FROM METEOROLOGIA
    GROUP BY fire_id
    HAVING COUNT(*) > 1
) duplicados;

SELECT '' as '';

-- ==================================================================================
-- 2.2 Verificar Uniqueness em INCENDIO_VEGETACAO
-- ==================================================================================

SELECT '2.2 Verificar Uniqueness (fire_id, vegetation_id)' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as registos_duplicados,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Sem duplicados (fire_id, vegetation_id)'
        ELSE '❌ FAIL - Registos duplicados detectados'
    END as status
FROM (
    SELECT fire_id, vegetation_id, COUNT(*) as num_duplicados
    FROM INCENDIO_VEGETACAO
    GROUP BY fire_id, vegetation_id
    HAVING COUNT(*) > 1
) duplicados;

-- Mostrar duplicados se houver
SELECT 'Duplicados (se houver):' as '';
SELECT fire_id, vegetation_id, COUNT(*) as ocorrencias
FROM INCENDIO_VEGETACAO
GROUP BY fire_id, vegetation_id
HAVING COUNT(*) > 1
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- PARTE 3: VALIDAÇÃO DE CONSISTÊNCIA DE DADOS
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'PARTE 3: VALIDAÇÃO DE CONSISTÊNCIA DE DADOS' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- ==================================================================================
-- 3.1 Verificar Datas Lógicas (data_fim >= data_inicio)
-- ==================================================================================

SELECT '3.1 Verificar Consistência de Datas (fim >= início)' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as incendios_datas_invalidas,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todas as datas consistentes'
        ELSE '❌ FAIL - Incêndios com datas inconsistentes'
    END as status
FROM INCENDIOS
WHERE data_fim IS NOT NULL 
  AND data_fim < data_inicio;

-- Mostrar exemplos se houver
SELECT 'Exemplos de datas inválidas (se houver):' as '';
SELECT fire_id, data_inicio, data_fim, 
       TIMESTAMPDIFF(HOUR, data_inicio, data_fim) as diferenca_horas
FROM INCENDIOS
WHERE data_fim IS NOT NULL 
  AND data_fim < data_inicio
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- 3.2 Verificar Áreas Não-Negativas
-- ==================================================================================

SELECT '3.2 Verificar Áreas Não-Negativas' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as incendios_area_negativa,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Todas as áreas positivas'
        ELSE '❌ FAIL - Áreas negativas detectadas'
    END as status
FROM INCENDIOS
WHERE area_ardida_ha < 0;

SELECT '' as '';

-- ==================================================================================
-- 3.3 Verificar Consistência ano/mes vs data_inicio
-- ==================================================================================

SELECT '3.3 Verificar Consistência ano/mês com data_inicio' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(*) as inconsistencias,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Ano e mês consistentes com data'
        ELSE '❌ FAIL - Inconsistências detectadas'
    END as status
FROM INCENDIOS
WHERE ano != YEAR(data_inicio) 
   OR mes != MONTH(data_inicio);

-- Mostrar exemplos se houver
SELECT 'Exemplos de inconsistências (se houver):' as '';
SELECT 
    fire_id, 
    data_inicio, 
    ano as ano_registado, 
    YEAR(data_inicio) as ano_real,
    mes as mes_registado,
    MONTH(data_inicio) as mes_real
FROM INCENDIOS
WHERE ano != YEAR(data_inicio) 
   OR mes != MONTH(data_inicio)
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- 3.4 Verificar Consistência de Área em INCENDIO_VEGETACAO
-- ==================================================================================

SELECT '3.4 Verificar Consistência de Área Total vs Soma Vegetação' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

-- Encontrar incêndios onde soma de vegetação difere da área total
SELECT 
    COUNT(*) as incendios_com_diferenca_significativa,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Áreas consistentes (tolerância ±1 ha)'
        WHEN COUNT(*) < 10 THEN '⚠️  WARN - Pequenas diferenças detectadas (< 10 casos)'
        ELSE '❌ FAIL - Muitas inconsistências de área'
    END as status
FROM (
    SELECT 
        i.fire_id,
        i.area_ardida_ha as area_total,
        COALESCE(SUM(iv.area_afetada_ha), 0) as soma_vegetacao,
        ABS(i.area_ardida_ha - COALESCE(SUM(iv.area_afetada_ha), 0)) as diferenca
    FROM INCENDIOS i
    LEFT JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
    GROUP BY i.fire_id, i.area_ardida_ha
    HAVING diferenca > 1.0
) discrepancias;

-- Mostrar top 5 maiores discrepâncias
SELECT 'Maiores discrepâncias de área (se houver):' as '';
SELECT 
    i.fire_id,
    i.area_ardida_ha as area_total_incendio,
    COALESCE(SUM(iv.area_afetada_ha), 0) as soma_area_vegetacao,
    ABS(i.area_ardida_ha - COALESCE(SUM(iv.area_afetada_ha), 0)) as diferenca_absoluta,
    ROUND(ABS(i.area_ardida_ha - COALESCE(SUM(iv.area_afetada_ha), 0)) * 100.0 / 
          NULLIF(i.area_ardida_ha, 0), 2) as diferenca_percentual
FROM INCENDIOS i
LEFT JOIN INCENDIO_VEGETACAO iv ON i.fire_id = iv.fire_id
GROUP BY i.fire_id, i.area_ardida_ha
HAVING diferenca_absoluta > 1.0
ORDER BY diferenca_absoluta DESC
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- 3.5 Verificar Valores Meteorológicos Realistas
-- ==================================================================================

SELECT '3.5 Verificar Valores Meteorológicos Realistas' as 'TESTE';
SELECT '-------------------------------------------------------------------' as '';

-- Temperatura
SELECT 
    COUNT(*) as temperaturas_irrealistas,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Temperaturas realistas (-10°C a 60°C)'
        ELSE '❌ FAIL - Temperaturas fora de intervalo'
    END as status
FROM METEOROLOGIA
WHERE temperatura_max < -10 OR temperatura_max > 60;

-- Humidade
SELECT 
    COUNT(*) as humidade_invalida,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Humidade válida (0-100%)'
        ELSE '❌ FAIL - Humidade fora de intervalo'
    END as status
FROM METEOROLOGIA
WHERE humidade_relativa < 0 OR humidade_relativa > 100;

-- Vento
SELECT 
    COUNT(*) as vento_invalido,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS - Velocidade vento válida (≥0 km/h)'
        ELSE '❌ FAIL - Velocidade vento negativa'
    END as status
FROM METEOROLOGIA
WHERE velocidade_vento_kmh < 0;

SELECT '' as '';

-- ==================================================================================
-- PARTE 4: ESTATÍSTICAS DE COMPLETUDE
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'PARTE 4: ESTATÍSTICAS DE COMPLETUDE' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- ==================================================================================
-- 4.1 Completude Geral por Tabela
-- ==================================================================================

SELECT '4.1 Completude de Dados por Tabela' as 'ANÁLISE';
SELECT '-------------------------------------------------------------------' as '';

-- REGIOES
SELECT 
    'REGIOES' as tabela,
    COUNT(*) as total_registos,
    COUNT(NutsID) as nuts_preenchido,
    COUNT(region_name) as nome_preenchido,
    COUNT(area_km2) as area_preenchido,
    CONCAT(ROUND(COUNT(area_km2) * 100.0 / COUNT(*), 2), '%') as percentagem_area
FROM REGIOES;

-- INCENDIOS
SELECT 
    'INCENDIOS' as tabela,
    COUNT(*) as total_registos,
    COUNT(NutsID) as regiao_preenchida,
    COUNT(data_inicio) as data_inicio_preenchida,
    COUNT(data_fim) as data_fim_preenchida,
    COUNT(duracao_horas) as duracao_preenchida,
    CONCAT(ROUND(COUNT(data_fim) * 100.0 / COUNT(*), 2), '%') as percentagem_data_fim
FROM INCENDIOS;

-- METEOROLOGIA
SELECT 
    'METEOROLOGIA' as tabela,
    COUNT(*) as total_registos,
    COUNT(temperatura_max) as temperatura_preenchida,
    COUNT(humidade_relativa) as humidade_preenchida,
    COUNT(velocidade_vento_kmh) as vento_preenchido,
    COUNT(indice_fwi) as fwi_preenchido,
    CONCAT(ROUND(COUNT(temperatura_max) * 100.0 / COUNT(*), 2), '%') as percentude_temp
FROM METEOROLOGIA;

SELECT '' as '';

-- ==================================================================================
-- 4.2 Cobertura de Dados Meteorológicos
-- ==================================================================================

SELECT '4.2 Cobertura de Dados Meteorológicos' as 'ANÁLISE';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    COUNT(DISTINCT i.fire_id) as total_incendios,
    COUNT(DISTINCT m.fire_id) as incendios_com_meteo,
    COUNT(DISTINCT i.fire_id) - COUNT(DISTINCT m.fire_id) as incendios_sem_meteo,
    CONCAT(ROUND(COUNT(DISTINCT m.fire_id) * 100.0 / COUNT(DISTINCT i.fire_id), 2), '%') as percentagem_cobertura,
    CASE 
        WHEN COUNT(DISTINCT m.fire_id) * 100.0 / COUNT(DISTINCT i.fire_id) >= 95 THEN '✅ Excelente (≥95%)'
        WHEN COUNT(DISTINCT m.fire_id) * 100.0 / COUNT(DISTINCT i.fire_id) >= 80 THEN '⚠️  Bom (80-95%)'
        ELSE '❌ Insuficiente (<80%)'
    END as avaliacao
FROM INCENDIOS i
LEFT JOIN METEOROLOGIA m ON i.fire_id = m.fire_id;

SELECT '' as '';

-- ==================================================================================
-- PARTE 5: ESTATÍSTICAS DESCRITIVAS
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'PARTE 5: ESTATÍSTICAS DESCRITIVAS' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- ==================================================================================
-- 5.1 Distribuição por Nível Hierárquico
-- ==================================================================================

SELECT '5.1 Distribuição de Regiões por Nível NUTS' as 'ESTATÍSTICA';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    CASE 
        WHEN level_ID = 0 THEN 'País'
        WHEN level_ID = 1 THEN 'NUTS I'
        WHEN level_ID = 2 THEN 'NUTS II'
        WHEN level_ID = 3 THEN 'NUTS III'
        WHEN level_ID = 4 THEN 'Concelho'
        WHEN level_ID = 5 THEN 'Freguesia'
        ELSE 'Desconhecido'
    END as nivel,
    level_ID,
    COUNT(*) as total_regioes,
    COUNT(area_km2) as com_area,
    CONCAT(ROUND(COUNT(area_km2) * 100.0 / COUNT(*), 2), '%') as percentagem_com_area
FROM REGIOES
GROUP BY level_ID
ORDER BY level_ID;

SELECT '' as '';

-- ==================================================================================
-- 5.2 Distribuição Temporal de Incêndios
-- ==================================================================================

SELECT '5.2 Distribuição de Incêndios por Ano' as 'ESTATÍSTICA';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    ano,
    COUNT(*) as num_incendios,
    ROUND(SUM(area_ardida_ha), 2) as area_total_ha,
    ROUND(AVG(area_ardida_ha), 2) as area_media_ha,
    MAX(area_ardida_ha) as area_maxima_ha
FROM INCENDIOS
GROUP BY ano
ORDER BY ano;

SELECT '' as '';

-- ==================================================================================
-- 5.3 Top 5 Tipos de Vegetação Mais Afetados
-- ==================================================================================

SELECT '5.3 Top 5 Tipos de Vegetação Mais Afetados' as 'ESTATÍSTICA';
SELECT '-------------------------------------------------------------------' as '';

SELECT 
    v.tipo_vegetacao,
    v.inflammabilidade,
    COUNT(DISTINCT iv.fire_id) as num_incendios,
    ROUND(SUM(iv.area_afetada_ha), 2) as area_total_ha,
    ROUND(AVG(iv.area_afetada_ha), 2) as area_media_ha
FROM VEGETACAO v
JOIN INCENDIO_VEGETACAO iv ON v.vegetation_id = iv.vegetation_id
GROUP BY v.vegetation_id, v.tipo_vegetacao, v.inflammabilidade
ORDER BY area_total_ha DESC
LIMIT 5;

SELECT '' as '';

-- ==================================================================================
-- PARTE 6: RESUMO FINAL
-- ==================================================================================

SELECT '==================================================================================' as '';
SELECT 'RESUMO FINAL DE VALIDAÇÃO' as '';
SELECT '==================================================================================' as '';
SELECT '' as '';

-- Contagens gerais
SELECT 'Resumo de Registos:' as '';
SELECT 
    'Total de Regiões' as metrica,
    COUNT(*) as valor
FROM REGIOES
UNION ALL
SELECT 
    'Total de Incêndios',
    COUNT(*)
FROM INCENDIOS
UNION ALL
SELECT 
    'Total de Tipos de Vegetação',
    COUNT(*)
FROM VEGETACAO
UNION ALL
SELECT 
    'Total de Registos Incêndio-Vegetação',
    COUNT(*)
FROM INCENDIO_VEGETACAO
UNION ALL
SELECT 
    'Total de Registos Meteorológicos',
    COUNT(*)
FROM METEOROLOGIA;

SELECT '' as '';
SELECT '==================================================================================' as '';
SELECT 'FIM DA VALIDAÇÃO' as '';
SELECT 'Data: 26 Dezembro 2025' as '';
SELECT 'Verificado por: TM1 (Cristiana Chainho)' as '';
SELECT '==================================================================================' as '';

/*
==================================================================================
INTERPRETAÇÃO DOS RESULTADOS:

✅ PASS  - Teste passou, dados corretos
⚠️  WARN - Aviso, pequenos problemas que podem ser aceitáveis
❌ FAIL - Falha, problema sério que deve ser corrigido

PRÓXIMOS PASSOS se houver falhas:
1. Identificar origem do problema (dados fonte ou script de import)
2. Corrigir dados fonte ou ajustar lógica de import
3. Re-importar dados
4. Executar este script novamente

NOTAS:
- 1 registo órfão em REGIOES é conhecido e documentado
- Pequenas diferenças de área (<1 ha) são toleradas (arredondamentos)
- Ausência parcial de dados meteorológicos é esperada (dados históricos)
==================================================================================
*/