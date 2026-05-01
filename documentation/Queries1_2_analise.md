\# Documentação das Queries de Análise  
\*\*Sistema de Gestão de Incêndios Florestais \- Portugal\*\*

\---

\#\# Informação do Projeto

\*\*Projeto:\*\* Sistema de Gestão de Incêndios Florestais \- Portugal    
\*\*Equipa:\*\* Grupo 5    
\*\*Autor:\*\* TM1 (Cristiana Chainho)    
\*\*Data:\*\* 27 Dezembro 2025

\---

\#\# Índice

1\. \[Visão Geral\](\#1-visão-geral)  
2\. \[Query Q1 \- Concelhos e Distritos Mais Afetados\](\#2-query-q1)  
3\. \[Query Q2 \- Área Média por Região e Vegetação\](\#3-query-q2)  
4\. \[Como Executar as Queries\](\#4-como-executar)  
5\. \[Interpretação de Resultados\](\#5-interpretação-de-resultados)  
6\. \[Aplicações Práticas\](\#6-aplicações-práticas)

\---

\#\# 1\. Visão Geral

\#\#\# 1.1 Propósito das Queries

As queries de análise foram desenvolvidas para responder a questões fundamentais sobre incêndios florestais em Portugal, suportando:

\- \*\*Identificação de zonas de alto risco\*\*  
\- \*\*Priorização de recursos de prevenção e combate\*\*  
\- \*\*Compreensão de padrões geográficos e de vegetação\*\*  
\- \*\*Tomada de decisão baseada em dados\*\*

\#\#\# 1.2 Período de Análise

\*\*Todas as queries analisam dados de 2015 a 2024\*\* (10 anos de histórico)

\#\#\# 1.3 Localização dos Ficheiros

\`\`\`  
data\_use\_scripts/  
├── Q1\_most\_affected\_regions.sql       \# Query 1  
├── Q2\_avg\_area\_by\_region\_veg.sql      \# Query 2  
├── Q3\_seasonal\_patterns.sql           \# (TM2)  
├── Q4\_weather\_correlation.sql         \# (TM2)  
├── Q5\_fire\_causes.sql                 \# (TM3)  
├── Q6\_combat\_duration.sql             \# (TM3)  
├── Q7\_temporal\_trends.sql             \# (TM3)  
└── README.md                            
\`\`\`

\---

\#\# 2\. Query Q1: Concelhos e Distritos Mais Afetados

\#\#\# 2.1 Questão de Investigação

\*\*"Quais os concelhos/distritos mais afetados por incêndios?"\*\*

\#\#\# 2.2 Objetivos

\- Identificar municípios com maior número de incêndios  
\- Calcular área total e média ardida por região  
\- Determinar densidade de incêndios (incêndios por km²)  
\- Calcular percentagem do território afetado  
\- Comparar frequência vs. severidade dos incêndios

\#\#\# 2.3 Estrutura da Query

A query Q1 é composta por \*\*8 sub-análises (Q1.A a Q1.H)\*\*:

\#\#\#\# \*\*Q1.A: Top 10 Concelhos por Número de Incêndios\*\*

\*\*O que faz:\*\*  
\- Lista os 10 concelhos com mais ocorrências de incêndio  
\- Calcula área total e média ardida  
\- Classifica o risco (Muito Alto, Alto, Moderado, Baixo)

\*\*Tabelas utilizadas:\*\*  
\- \`INCENDIOS\` (dados de incêndios)  
\- \`REGIOES\` (informação geográfica)

\*\*Técnicas SQL:\*\*  
\`\`\`sql  
SELECT region\_name, COUNT(\*), SUM(area\_ardida\_ha), AVG(area\_ardida\_ha)  
FROM INCENDIOS JOIN REGIOES  
WHERE level\_ID \= 4  \-- Concelhos  
GROUP BY region\_name  
ORDER BY COUNT(\*) DESC  
LIMIT 10  
\`\`\`

\*\*Output esperado:\*\*  
| Concelho | Nº Incêndios | Área Total (ha) | Área Média (ha) | Classificação |  
|----------|--------------|-----------------|-----------------|---------------|  
| \[Nome\] | 500+ | 10.000+ | 20+ | Risco Muito Alto |

\---

\#\#\#\# \*\*Q1.B: Top 10 Concelhos por Área Total Ardida\*\*

\*\*O que faz:\*\*  
\- Identifica concelhos com maior área total ardida  
\- Calcula percentagem do território do concelho ardido  
\- Classifica impacto (Crítico, Severo, Moderado, Baixo)

\*\*Métrica chave:\*\*  
\`\`\`  
% Área Ardida \= (área\_ardida\_ha × 100\) / (area\_km2 × 100\)  
\`\`\`

\*\*Interpretação:\*\*  
\- \*\*≥50%\*\*:  Crítico \- Mais de metade do concelho ardeu  
\- \*\*25-50%\*\*:  Severo \- Impacto muito significativo  
\- \*\*10-25%\*\*:  Moderado \- Requer atenção  
\- \*\*\<10%\*\*: Baixo impacto relativo

\---

\#\#\#\# \*\*Q1.C: Top 10 Concelhos por Densidade\*\*

\*\*O que faz:\*\*  
\- Calcula densidade de incêndios (incêndios por km²)  
\- Identifica concelhos pequenos mas muito afetados

\*\*Métrica chave:\*\*  
\`\`\`  
Densidade \= número\_incêndios / area\_km2  
\`\`\`

\*\*Importância:\*\*  
Um concelho pequeno com muitos incêndios pode ter densidade alta mesmo com área total moderada.

\---

\#\#\#\# \*\*Q1.D: Top 10 Distritos (NUTS III) Mais Afetados\*\*

\*\*O que faz:\*\*  
\- Agrega dados ao nível distrital  
\- Útil para planeamento regional  
\- Conta quantos concelhos de cada distrito foram afetados

\*\*Técnica SQL:\*\*  
\`\`\`sql  
\-- Navegação hierárquica  
JOIN REGIOES concelho ON i.NutsID \= concelho.NutsID  
JOIN REGIOES distrito ON concelho.ParentCodeID \= distrito.NutsID  
WHERE concelho.level\_ID \= 4 AND distrito.level\_ID \= 3  
\`\`\`

\---

\#\#\#\# \*\*Q1.E: Análise Frequência vs Severidade\*\*

\*\*O que faz:\*\*  
\- Compara número de incêndios (frequência) com área média (severidade)  
\- Identifica perfis distintos:  
  \- \*\*Alto Risco:\*\* Muitos incêndios E grandes  
  \- \*\*Médio:\*\* Poucos mas grandes OU muitos mas pequenos  
  \- \*\*Baixo:\*\* Poucos e pequenos

\*\*Utilidade:\*\*  
Concelhos com perfis diferentes requerem estratégias diferentes:  
\- Muitos pequenos → Focar em prevenção  
\- Poucos grandes → Reforçar capacidade de combate

\---

\#\#\#\# \*\*Q1.F: Evolução Temporal dos Top 5\*\*

\*\*O que faz:\*\*  
\- Mostra como os 5 concelhos mais afetados evoluíram ano a ano  
\- Identifica tendências (aumento/diminuição)  
\- Destaca anos atípicos (ex: 2017\)

\*\*Técnica SQL:\*\*  
\`\`\`sql  
WITH top\_concelhos AS (  
    \-- Identificar top 5  
)  
SELECT concelho, ano, COUNT(\*), SUM(area\_ardida\_ha)  
FROM top\_concelhos  
GROUP BY concelho, ano  
ORDER BY concelho, ano  
\`\`\`

\---

\#\#\#\# \*\*Q1.G: Resumo Estatístico Geral\*\*

\*\*O que faz:\*\*  
\- Estatísticas agregadas de Portugal  
\- Quantos concelhos têm mais de 100 incêndios  
\- Quantos perderam \>10% do território  
\- Média de incêndios por concelho

\---

\#\#\#\# \*\*Q1.H: Distribuição por Região NUTS II\*\*

\*\*O que faz:\*\*  
\- Agrega ao nível das grandes regiões (Norte, Centro, Lisboa, etc.)  
\- Mostra qual região é mais afetada  
\- Calcula percentagem do total nacional

\*\*Output típico:\*\*  
\- \*\*Norte:\*\* \~40% dos incêndios  
\- \*\*Centro:\*\* \~35% dos incêndios  
\- \*\*Lisboa:\*\* \~15% dos incêndios  
\- Outras regiões: \~10%

\---

\#\#\# 2.4 Tabelas e Relações Utilizadas

\`\`\`  
INCENDIOS  
    ↓ (JOIN em NutsID)  
REGIOES (concelho, level\_ID \= 4\)  
    ↓ (JOIN em ParentCodeID)  
REGIOES (distrito, level\_ID \= 3\)  
    ↓ (JOIN em ParentCodeID)  
REGIOES (NUTS II, level\_ID \= 2\)  
\`\`\`

\#\#\# 2.5 Campos Chave

\*\*De INCENDIOS:\*\*  
\- \`fire\_id\` \- Identificador único  
\- \`NutsID\` \- Código da região  
\- \`area\_ardida\_ha\` \- Área ardida em hectares  
\- \`data\_inicio\` \- Data do incêndio  
\- \`ano\`, \`mes\` \- Campos derivados

\*\*De REGIOES:\*\*  
\- \`NutsID\` \- Código NUTS (PK)  
\- \`region\_name\` \- Nome da região  
\- \`level\_ID\` \- Nível hierárquico (4=concelho, 3=distrito, 2=NUTS II)  
\- \`area\_km2\` \- Área da região

\#\#\# 2.6 Exemplo de Interpretação

\*\*Cenário:\*\* Query Q1.B retorna:

| Concelho | Área Total | % Concelho | Impacto |  
|----------|------------|------------|---------|  
| Monchique | 25.000 ha | 63% |  Crítico |

\*\*Interpretação:\*\*  
\- Monchique teve 25.000 hectares ardidos no período 2015-2024  
\- Isto representa 63% da área total do concelho  
\- Classificado como \*\*impacto crítico\*\*  
\- \*\*Ação recomendada:\*\* Prioridade máxima para prevenção e reflorestação

\---

\#\# 3\. Query Q2: Área Média por Região e Vegetação

\#\#\# 3.1 Questão de Investigação

\*\*"Qual a área média ardida por região e por tipo de vegetação?"\*\*

\#\#\# 3.2 Objetivos

\- Identificar vulnerabilidade relativa de diferentes tipos de vegetação  
\- Analisar padrões regionais de vegetação afetada  
\- Correlacionar inflamabilidade com área ardida  
\- Identificar necessidades de gestão florestal específicas

\#\#\# 3.3 Estrutura da Query

A query Q2 é composta por \*\*10 sub-análises (Q2.A a Q2.J)\*\*:

\#\#\#\# \*\*Q2.A: Área Média por Tipo de Vegetação (Global)\*\*

\*\*O que faz:\*\*  
\- Lista todos os tipos de vegetação  
\- Calcula área total e média ardida para cada tipo  
\- Mostra percentagem do total nacional  
\- Valida classificação de inflamabilidade

\*\*Output esperado:\*\*  
| Vegetação | Inflamabilidade | Área Total (ha) | Área Média (ha) | % Total |  
|-----------|-----------------|-----------------|-----------------|---------|  
| Pinheiro-bravo | Alta | 500.000 | 45 | 45% |  
| Eucalipto | Alta | 450.000 | 42 | 40% |

\*\*Validação:\*\*  
Pinheiro-bravo \+ Eucalipto devem representar \~85% do total (conforme literatura)

\---

\#\#\#\# \*\*Q2.B: Área Média por Concelho e Vegetação\*\*

\*\*O que faz:\*\*  
\- Análise cruzada: concelho × tipo de vegetação  
\- Identifica top 20 combinações  
\- Útil para planeamento municipal específico

\*\*Exemplo de uso:\*\*  
\> "Concelho X tem grande área de Eucalipto ardida → Regulamentar plantação"

\*\*Filtro aplicado:\*\*  
Mínimo de 5 incêndios para garantir significância estatística

\---

\#\#\#\# \*\*Q2.C: Área Média por Região NUTS II e Vegetação\*\*

\*\*O que faz:\*\*  
\- Compara grandes regiões (Norte, Centro, Lisboa, etc.)  
\- Mostra qual vegetação predomina em cada região

\*\*Insight típico:\*\*  
\- \*\*Norte:\*\* Pinheiro-bravo dominante  
\- \*\*Centro:\*\* Mix de Pinheiro e Eucalipto  
\- \*\*Alentejo:\*\* Mais Sobreiro e Azinheira (baixa inflamabilidade)

\---

\#\#\#\# \*\*Q2.D: Comparação por Nível de Inflamabilidade\*\*

\*\*O que faz:\*\*  
\- Valida hipótese: "Vegetação mais inflamável \= maior área ardida"  
\- Agrupa por Alta/Média/Baixa inflamabilidade  
\- Compara área média entre grupos

\*\*Técnica SQL:\*\*  
\`\`\`sql  
SELECT inflammabilidade, AVG(area\_afetada\_ha)  
FROM VEGETACAO JOIN INCENDIO\_VEGETACAO  
GROUP BY inflammabilidade  
ORDER BY   
    CASE inflammabilidade  
        WHEN 'Alta' THEN 1  
        WHEN 'Média' THEN 2  
        WHEN 'Baixa' THEN 3  
    END  
\`\`\`

\*\*Resultado esperado:\*\*  
\- Alta: \~45 ha/incêndio  
\- Média: \~25 ha/incêndio  
\- Baixa: \~10 ha/incêndio

\---

\#\#\#\# \*\*Q2.E: Top 10 Concelhos por Vegetação Específica\*\*

\*\*O que faz:\*\*  
\- Duas análises separadas:  
  1\. Top 10 para \*\*Pinheiro-bravo\*\*  
  2\. Top 10 para \*\*Eucalipto\*\*

\*\*Utilidade:\*\*  
\- Identificar onde regular plantação  
\- Priorizar substituição por espécies menos inflamáveis  
\- Focar fiscalização

\---

\#\#\#\# \*\*Q2.F: Matriz Região × Vegetação\*\*

\*\*O que faz:\*\*  
\- Cria uma "tabela cruzada" (matriz)  
\- Linhas: Regiões NUTS II  
\- Colunas: Top 3 vegetações  
\- Valores: Área ardida

\*\*Técnica avançada:\*\*  
Usa CTE (WITH) para identificar top 3 vegetações primeiro:  
\`\`\`sql  
WITH top\_vegetacoes AS (  
    SELECT tipo\_vegetacao  
    FROM VEGETACAO  
    ORDER BY area\_total DESC  
    LIMIT 3  
)  
SELECT regiao, vegetacao, SUM(area)  
FROM ... JOIN top\_vegetacoes  
GROUP BY regiao, vegetacao  
\`\`\`

\---

\#\#\#\# \*\*Q2.G: Diversidade de Vegetação por Região\*\*

\*\*O que faz:\*\*  
\- Conta quantos tipos diferentes de vegetação foram afetados por concelho  
\- Identifica concelhos com:  
  \- \*\*Alta diversidade:\*\* ≥5 tipos  
  \- \*\*Média:\*\* 3-4 tipos  
  \- \*\*Baixa:\*\* 1-2 tipos (monocultura)

\*\*Insight importante:\*\*  
Concelhos com \*\*baixa diversidade\*\* (monocultura) são mais vulneráveis

\*\*Técnica SQL:\*\*  
\`\`\`sql  
SELECT concelho,   
       COUNT(DISTINCT vegetation\_id),  
       GROUP\_CONCAT(tipo\_vegetacao) \-- Lista os tipos  
FROM ...  
GROUP BY concelho  
\`\`\`

\---

\#\#\#\# \*\*Q2.H: Correlação Inflamabilidade × Área por Região\*\*

\*\*O que faz:\*\*  
\- Para cada região NUTS II, mostra distribuição por inflamabilidade  
\- Calcula percentagem de cada nível  
\- Identifica regiões com excesso de vegetação inflamável

\*\*Aplicação:\*\*  
\> "Região Norte: 90% Alta inflamabilidade → Urgente diversificar"

\---

\#\#\#\# \*\*Q2.I: Evolução Temporal\*\*

\*\*O que faz:\*\*  
\- Mostra como área média por vegetação evoluiu 2015-2024  
\- Identifica tendências  
\- Destaca anos críticos (2017, 2020, etc.)

\*\*Formato:\*\*  
| Ano | Vegetação | Área Média |  
|-----|-----------|------------|  
| 2015 | Pinheiro | 35 ha |  
| 2016 | Pinheiro | 40 ha |  
| 2017 | Pinheiro | 120 ha | ← Ano crítico

\---

\#\#\#\# \*\*Q2.J: Resumo Estatístico Final\*\*

\*\*O que faz:\*\*  
\- Compila estatísticas-chave:  
  \- Área média global  
  \- Área média por nível de inflamabilidade  
  \- Concelho com maior área média  
  \- Vegetação mais afetada

\---

\#\#\# 3.4 Tabelas e Relações Utilizadas

\`\`\`  
INCENDIOS  
    ↓ (JOIN em fire\_id)  
INCENDIO\_VEGETACAO (tabela de junção N:M)  
    ↓ (JOIN em vegetation\_id)  
VEGETACAO (tabela de referência)

    \+

INCENDIOS  
    ↓ (JOIN em NutsID)  
REGIOES (hierarquia NUTS)  
\`\`\`

\#\#\# 3.5 Campos Chave

\*\*De INCENDIO\_VEGETACAO:\*\*  
\- \`fire\_veg\_id\` \- ID do registo  
\- \`fire\_id\` \- Referência ao incêndio  
\- \`vegetation\_id\` \- Referência ao tipo de vegetação  
\- \`area\_afetada\_ha\` \- Área de vegetação ardida  
\- \`percentagem\_area\` \- % do incêndio total

\*\*De VEGETACAO:\*\*  
\- \`vegetation\_id\` \- ID do tipo (PK)  
\- \`tipo\_vegetacao\` \- Nome (Pinheiro-bravo, Eucalipto, etc.)  
\- \`inflammabilidade\` \- Alta/Média/Baixa  
\- \`descricao\` \- Informação adicional

\#\#\# 3.6 Exemplo de Interpretação

\*\*Cenário:\*\* Query Q2.D retorna:

| Inflamabilidade | Área Média | % Total |  
|-----------------|------------|---------|  
| Alta | 45 ha | 85% |  
| Média | 20 ha | 12% |  
| Baixa | 8 ha | 3% |

\*\*Interpretação:\*\*  
\- Vegetação de \*\*alta inflamabilidade\*\* representa 85% da área total ardida  
\- Área média por incêndio é \*\*5.6x maior\*\* em vegetação alta vs. baixa  
\- \*\*Validação:\*\* Confirma classificação de inflamabilidade  
\- \*\*Ação recomendada:\*\* Regular plantação de espécies altamente inflamáveis

\---

\#\# 4\. Como Executar as Queries

\#\#\# 4.1 Pré-requisitos

\- MySQL 8.0+ ou MariaDB 10.5+  
\- Base de dados \`forest\_fire\_db\` implementada  
\- Dados importados e validados  
\- Cliente MySQL (linha de comandos, DBeaver, ou Workbench)

\#\#\# 4.2 Execução Via Linha de Comandos

\`\`\`bash  
\# Navegar para pasta do projeto  
cd forest-fire-portugal-dms/

\# Executar Query Q1  
mysql \-u root \-p forest\_fire\_db \< data\_use\_scripts/Q1\_most\_affected\_regions.sql

\# Executar Query Q2  
mysql \-u root \-p forest\_fire\_db \< data\_use\_scripts/Q2\_avg\_area\_by\_region\_veg.sql

\# Salvar output em ficheiro  
mysql \-u root \-p forest\_fire\_db \< data\_use\_scripts/Q1\_most\_affected\_regions.sql \> output\_Q1.txt  
mysql \-u root \-p forest\_fire\_db \< data\_use\_scripts/Q2\_avg\_area\_by\_region\_veg.sql \> output\_Q2.txt  
\`\`\`

\#\#\# 4.3 Execução Via DBeaver/Workbench

1\. Abrir DBeaver/Workbench  
2\. Conectar à base de dados \`forest\_fire\_db\`  
3\. Abrir ficheiro SQL:  
   \- File → Open → Selecionar \`Q1\_most\_affected\_regions.sql\`  
4\. Executar:  
   \- Botão Execute (▶️) ou Ctrl+Enter  
5\. Ver resultados nos painéis de output

\#\#\# 4.4 Executar Apenas Uma Sub-Análise

Se quiser executar apenas Q1.A (por exemplo):

\`\`\`sql  
\-- Copiar apenas a secção Q1.A do ficheiro  
SELECT   
    r.region\_name AS concelho,  
    COUNT(i.fire\_id) AS numero\_incendios,  
    \-- ... resto da query Q1.A  
FROM INCENDIOS i  
JOIN REGIOES r ON i.NutsID \= r.NutsID  
WHERE r.level\_ID \= 4  
GROUP BY r.NutsID, r.region\_name  
ORDER BY numero\_incendios DESC  
LIMIT 10;  
\`\`\`

\#\#\# 4.5 Tempo de Execução

| Query | Sub-análises | Tempo Estimado |  
|-------|--------------|----------------|  
| Q1 | 8 (Q1.A-H) | 5-10 segundos |  
| Q2 | 10 (Q2.A-J) | 10-15 segundos |

\*\*Nota:\*\* Tempo varia com volume de dados e hardware

\---

\#\# 5\. Interpretação de Resultados

\#\#\# 5.1 Formato dos Outputs

Cada sub-análise retorna uma \*\*tabela\*\* com:  
\- \*\*Cabeçalho\*\*: Nome da análise  
\- \*\*Colunas\*\*: Métricas calculadas  
\- \*\*Linhas\*\*: Registos ordenados por relevância  
\- \*\*Rodapé\*\*: Linhas em branco para separação

\*\*Exemplo:\*\*  
\`\`\`  
\==================================================================================  
Q1.A: TOP 10 CONCELHOS POR NÚMERO DE INCÊNDIOS  
\==================================================================================

concelho         | numero\_incendios | area\_total\_ha | area\_media\_ha | classificacao  
\-----------------+------------------+---------------+---------------+------------------  
Monchique        |              687 |      25432.50 |         37.02 | Risco Alto  
Vila Real        |              623 |      18765.30 |         30.12 | Risco Alto  
...  
\`\`\`

\#\#\# 5.2 Métricas Comuns

\*\*Número de Incêndios:\*\*  
\- Indica \*\*frequência\*\* de ocorrências  
\- Alto número \= zona de risco elevado

\*\*Área Total Ardida:\*\*  
\- Indica \*\*impacto absoluto\*\*  
\- Alto valor \= muito território perdido

\*\*Área Média:\*\*  
\- Indica \*\*severidade típica\*\*  
\- Alto valor \= incêndios tendem a ser grandes

\*\*Percentagem:\*\*  
\- Indica \*\*impacto relativo\*\*  
\- 50% \= metade do território ardeu

\*\*Densidade:\*\*  
\- Incêndios por km²  
\- Alto valor \= concentração elevada

\#\#\# 5.3 Classificações e Thresholds

\*\*Risco (Q1.A):\*\*  
\- Muito Alto: ≥500 incêndios  
\- Alto: 300-499  
\- Moderado: 150-299  
\- Baixo: \<150

\*\*Impacto (Q1.B):\*\*  
\-  Crítico: ≥50% do território  
\-  Severo: 25-50%  
\-  Moderado: 10-25%  
\-  Baixo: \<10%

\*\*Densidade (Q1.C):\*\*  
\- Muito Alta: ≥1 incêndio/km²  
\- Alta: 0.5-1  
\- Moderada: 0.2-0.5  
\- Baixa: \<0.2

\*\*Diversidade (Q2.G):\*\*  
\- Alta: ≥5 tipos vegetação  
\- Média: 3-4 tipos  
\- Baixa: 1-2 tipos (monocultura)

\#\#\# 5.4 Bandeiras Vermelhas (Red Flags)

Preste atenção especial a:

 \*\*Concelho com \>50% área ardida\*\* → Crise ambiental    
 \*\*Área média \>100 ha\*\* → Incêndios muito severos    
 \*\*Monocultura \+ Alta inflamabilidade\*\* → Bomba-relógio    
 \*\*Tendência crescente ano após ano\*\* → Situação a piorar    
 \*\*Alta densidade (\>1/km²)\*\* → Vigilância insuficiente  

\---

\#\# 6\. Aplicações Práticas

\#\#\# 6.1 Para Proteção Civil

\*\*Usar Q1 para:\*\*  
\- Alocar recursos de combate (bombeiros, viaturas)  
\- Posicionar estrategicamente meios aéreos  
\- Planear sistema de vigilância (torres, drones)  
\- Definir zonas prioritárias para campanhas de prevenção

\*\*Exemplo:\*\*  
\> "Q1.A identifica top 10 concelhos → Reforçar 50% dos meios nessas zonas"

\#\#\# 6.2 Para Gestão Florestal

\*\*Usar Q2 para:\*\*  
\- Regular plantação de espécies inflamáveis (Eucalipto, Pinheiro)  
\- Incentivar diversificação florestal  
\- Priorizar limpeza de matos em zonas de risco  
\- Planear reflorestação pós-incêndio com espécies adequadas

\*\*Exemplo:\*\*  
\> "Q2.E mostra concelho X com excesso de Eucalipto → Limitar novas plantações"

\#\#\# 6.3 Para Autarquias Locais

\*\*Usar Q1 \+ Q2 para:\*\*  
\- Justificar orçamentos para prevenção  
\- Elaborar Planos Municipais de Defesa da Floresta (PMDFCI)  
\- Identificar áreas para criação de faixas de gestão de combustível  
\- Priorizar investimento em pontos de água

\#\#\# 6.4 Para Investigação Científica

\*\*Usar Q1 \+ Q2 como base para:\*\*  
\- Modelos preditivos de risco (Machine Learning)  
\- Estudos de impacto de mudanças climáticas  
\- Análise de eficácia de políticas públicas  
\- Correlação com dados socioeconómicos

\#\#\# 6.5 Para Comunicação Pública

\*\*Usar resultados para:\*\*  
\- Campanhas de sensibilização direcionadas  
\- Relatórios anuais de incêndios  
\- Infográficos para media  
\- Dashboards interativos

\*\*Exemplo de mensagem:\*\*  
\> "85% da área ardida é Pinheiro e Eucalipto. Diversificar salva florestas\!"

\---

\#\# 7\. Limitações e Notas Importantes

\#\#\# 7.1 Limitações dos Dados

 \*\*Dados meteorológicos:\*\* Podem estar incompletos para incêndios mais antigos    
 \*\*Causa de incêndio:\*\* Nem sempre determinada com precisão    
 \*\*Vegetação:\*\* Classificação simplificada (tipos principais)    
 \*\*Localização:\*\* Município de origem, não propagação exata  

\#\#\# 7.2 Considerações Estatísticas

 \*\*Mínimos aplicados:\*\* Queries filtram por mínimo de incêndios para significância    
 \*\*Outliers:\*\* Anos atípicos (2017) podem distorcer médias    
 \*\*Correlação ≠ Causalidade:\*\* Análises mostram padrões, não causas  

\#\#\# 7.3 Atualizações Necessárias

 \*\*Dados anuais:\*\* Queries devem ser re-executadas com dados de 2025+    
 \*\*NUTS:\*\* Classificação pode mudar (última atualização: 2024\)    
 \*\*Vegetação:\*\* IFN atualiza periodicamente (IFN7 futuro)  

\---

\#\# 8\. Troubleshooting

\#\#\# 8.1 Query Demora Muito

\*\*Problema:\*\* Query Q2 demora \>1 minuto

\*\*Soluções:\*\*  
\`\`\`sql  
\-- Verificar índices  
SHOW INDEX FROM INCENDIOS;  
SHOW INDEX FROM INCENDIO\_VEGETACAO;

\-- Adicionar índices se necessário  
CREATE INDEX idx\_fire\_id ON INCENDIO\_VEGETACAO(fire\_id);  
CREATE INDEX idx\_veg\_id ON INCENDIO\_VEGETACAO(vegetation\_id);  
\`\`\`

\#\#\# 8.2 Resultados Vazios

\*\*Problema:\*\* Query retorna 0 linhas

\*\*Verificar:\*\*  
1\. Dados foram importados? \`SELECT COUNT(\*) FROM INCENDIOS;\`  
2\. Filtros muito restritivos? Remover \`HAVING\` temporariamente  
3\. JOINs corretos? Verificar chaves estrangeiras

\#\#\# 8.3 Erros de Sintaxe

\*\*Erro comum:\*\* \`Unknown column 'level\_ID'\`

\*\*Solução:\*\* Verificar nomes de campos reais:  
\`\`\`sql  
DESCRIBE REGIOES;  \-- Ver campos reais  
\`\`\`

Ajustar query para usar \`level\_ID\` ou \`region\_level\` conforme apropriado.

\---

\#\# 9\. Extensões Futuras

\#\#\# 9.1 Queries Adicionais

Possíveis análises complementares:

\*\*Q8:\*\* Análise de recorrência (mesmo local, múltiplos anos)    
\*\*Q9:\*\* Correlação área ardida vs. investimento em prevenção    
\*\*Q10:\*\* Impacto de faixas de gestão de combustível    
\*\*Q11:\*\* Análise de proximidade a habitações    
\*\*Q12:\*\* Custo estimado por incêndio  

\#\#\# 9.2 Visualizações

Transformar outputs em:  
\- \*\*Mapas de calor\*\* (heatmaps geográficos)  
\- \*\*Gráficos de barras\*\* (rankings)  
\- \*\*Séries temporais\*\* (evolução anual)  
\- \*\*Treemaps\*\* (distribuição hierárquica)  
\- \*\*Scatter plots\*\* (correlações)

\#\#\# 9.3 Automatização

\`\`\`python  
\# Script Python para executar queries e gerar relatórios  
import mysql.connector  
import pandas as pd  
import matplotlib.pyplot as plt

\# Conectar BD  
conn \= mysql.connector.connect(...)

\# Executar Q1.A  
df\_q1a \= pd.read\_sql("SELECT ... FROM ... \-- Q1.A", conn)

\# Gerar gráfico  
df\_q1a.plot(kind='bar', x='concelho', y='numero\_incendios')  
plt.savefig('output\_Q1A.png')  
\`\`\`

\---

\#\# 10\. Checklist de Validação

Antes de usar resultados das queries, verificar:

\-  Base de dados está completa (\>120k incêndios)  
\-  Integridade referencial validada (script 10\_verify\_data.sql)  
\-  Queries executam sem erros  
\-  Resultados fazem sentido (verificar valores extremos)  
\-  Documentação lida e compreendida  
\-  Limitações consideradas na interpretação

\---

\#\# 11\. Contacto e Suporte

\*\*Para questões sobre as queries:\*\*

\*\*Cristiana Chainho (TM1)\*\* \- Autor das queries Q1 e Q2    
\- Responsável: Queries Q1, Q2 e documentação  
\*\*Luis Vale (TM2)\*\* \- Queries Q3-Q4    
\*\*Duarte Campina (TM3)\*\* \- Queries Q5-Q7  

\---

\#\# 12\. Referências

\*\*Dados utilizados:\*\*  
ICNF \- Instituto da Conservação da Natureza e das Florestas  
INE \- Instituto Nacional de Estatística  
Central de Dados Portugal

Documentação adicional:

data\_sources \- Detalhes sobre fontes de dados  
database\_relationships \- Estrutura da base de dados  
data\_dictionary \- Definição de todos os campos

Última Atualização: 27 Dezembro 2025

\-  
