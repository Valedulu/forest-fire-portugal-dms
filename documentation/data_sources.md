\# Fontes de Dados \- Sistema de Gestão de Incêndios Florestais  
\*\*Projeto:\*\* Sistema de Gestão de Incêndios Florestais \- Portugal    
\*\*Equipa:\*\* Grupo 5    
\*\*Criado:\*\* 24 Dezembro 2025    
\*\*Última Atualização:\*\* 26 Dezembro 2025

\---

\#\# Visão Geral  
Este documento cataloga todas as fontes de dados utilizadas na base de dados do Sistema de Gestão de Incêndios Florestais. Cada fonte está documentada com a sua origem, método de acesso, informação de licença e especificações técnicas.

Todas as fontes de dados utilizam dados abertos com licenças apropriadas para investigação académica.

\---

\#\# 1\. Dados de Incêndios

\#\#\# 1.1 Central de Dados Portugal  
\*\*Organização:\*\* Central de Dados Portugal    
\*\*URL:\*\* http://centraldedados.pt/incendios/    
\*\*Tipo de Dados:\*\* Ficheiros CSV    
\*\*Licença:\*\* Dados Abertos    
\*\*Cobertura Temporal:\*\* 1980 \- 2024 (projeto utiliza 2015-2024)    
\*\*Frequência de Atualização:\*\* Anual    
\*\*Cobertura Geográfica:\*\* Portugal Continental    
\*\*Estado:\*\* Descarregado por TM2

\*\*Descrição:\*\*    
Dados históricos de incêndios do ICNF (Instituto da Conservação da Natureza e das Florestas). Contém registos detalhados de incêndios florestais incluindo localização, datas, área ardida e causas.

\*\*Campos Principais:\*\*  
\- Número de identificação do incêndio  
\- Município (concelho) e distrito  
\- Datas e horas de início e fim  
\- Área ardida (hectares)  
\- Classificação da causa (natural, negligência, intencional, desconhecida)  
\- Duração do combate (horas)  
\- Tempos de alerta e extinção

\*\*Qualidade dos Dados:\*\*  
\- Total de registos: 121.000+ incêndios (2015-2024)  
\- Valores em falta: \<0,01% (verificado por TM2 em 21 Dez 2025\)  
\- Formatos de data: Padronizados para AAAA-MM-DD  
\- Cobertura geográfica: Todos os 308 municípios

\*\*Data de Download:\*\* 21 Dezembro 2025    
\*\*Descarregado por:\*\* TM2 (Luis Vale)    
\*\*Script de Limpeza:\*\* \`clean\_fire\_data.py\`    
\*\*Ficheiros Limpos:\*\* \`processed\_data/fires/incendios\_cleaned\_\*.csv\`

\---

\#\#\# 1.2 dados.gov.pt \- Dataset Cross-Forest  
\*\*Organização:\*\* Portal de Dados Abertos Português    
\*\*URL:\*\* https://dados.gov.pt/    
\*\*Tipo de Dados:\*\* CSV (dados ICNF transformados)    
\*\*Licença:\*\* Creative Commons Attribution 4.0 (CC-BY 4.0)    
\*\*Cobertura Temporal:\*\* 2015 \- 2024    
\*\*Estado:\*\* Descarregado por TM2 (fonte de validação)

\*\*Descrição:\*\*    
Fonte alternativa contendo dados de incêndios do ICNF transformados em formato CSV estruturado. Parte da iniciativa Cross-Forest para padronização de dados de incêndios florestais europeus.

\*\*Utilização no Projeto:\*\*    
Usado como fonte de validação/suplemento para verificar registos da Central de Dados. Cruzamento de referências para garantir consistência dos dados.

\*\*Registos:\*\* 121.000+ (corresponde à Central de Dados)    
\*\*Verificação de Qualidade:\*\* Usado para verificar completude da fonte primária

\---

\#\# 2\. Dados Regionais

\#\#\# 2.1 Base de Dados dms\_INE \- Hierarquia Regional  
\*\*Organização:\*\* Instituto Nacional de Estatística (INE)    
\*\*Base de Dados:\*\* dms\_INE (Base de dados académica MySQL/MariaDB)    
\*\*Tabela:\*\* \`region\`    
\*\*Tipo de Dados:\*\* Base de dados relacional    
\*\*Licença:\*\* Uso académico    
\*\*Cobertura Geográfica:\*\* Portugal (hierarquia NUTS \- todos os níveis)    
\*\*Estado:\*\* Exportado por TM1

\*\*Descrição:\*\*    
Base de dados abrangente de hierarquia regional contendo divisões administrativas portuguesas seguindo a classificação NUTS (Nomenclatura de Unidades Territoriais para Fins Estatísticos).

\*\*Estrutura Hierárquica (6 níveis):\*\*  
\- \*\*Nível 0:\*\* País (Portugal) \- 1 registo  
\- \*\*Nível 1:\*\* Regiões NUTS I \- 3 registos (Continental, Açores, Madeira)  
\- \*\*Nível 2:\*\* Regiões NUTS II \- 7 registos (Norte, Centro, Lisboa, Alentejo, Algarve, RA Açores, RA Madeira)  
\- \*\*Nível 3:\*\* Sub-regiões NUTS III \- 25 registos  
\- \*\*Nível 4:\*\* Municípios (Concelhos) \- 308 registos  
\- \*\*Nível 5:\*\* Parishes (Freguesias) \- 3.092 registos  
\- \*\*Total:\*\* 3.436 unidades territoriais

\*\*Campos da Base de Dados (Estrutura Real):\*\*  
\- \`NutsID\` (VARCHAR(9)) \- Chave Primária, código NUTS oficial  
\- \`region\_name\` (VARCHAR(255)) \- Nome português da região  
\- \`level\_ID\` (INT) \- Nível hierárquico (0-5)  
\- \`ParentCodeID\` (VARCHAR(9)) \- Chave Estrangeira para região pai (relação hierárquica)  
\- \`area\_km2\` (DECIMAL(10,2)) \- Área geográfica em quilómetros quadrados

\*\*Notas Importantes:\*\*  
\- Nomes de campos usam \*\*CamelCase\*\* (não snake\_case como planeado inicialmente)  
\- Chave Primária é \`NutsID\` (texto), não inteiro auto-incremento  
\- Hierarquia auto-referencial via \`ParentCodeID\`  
\- Conjunto de caracteres: utf8mb4 para caracteres portugueses (ç, ã, õ, etc.)

\*\*Qualidade dos Dados:\*\*  
\-  Integridade hierárquica: 99,97% (1 registo órfão detetado, documentado)  
\-  Completude: Todos os 3.436 registos presentes  
\-  Códigos NUTS: Válidos e atuais (classificação 2024\)

\*\*Informação de Exportação:\*\*  
\- \*\*Data de Exportação:\*\* 26 Dezembro 2025, 02:36  
\- \*\*Exportado por:\*\* TM1 (Cristiana Chainho)  
\- \*\*Ficheiro de Exportação:\*\* \`original\_data/regions/regions\_dms\_INE\_com\_area.csv\`  
\- \*\*Registos Exportados:\*\* 3.436  
\- \*\*Tamanho do Ficheiro:\*\* \~400 KB  
\- \*\*Codificação:\*\* UTF-8

\*\*Script de Verificação:\*\* \`documentation/regional\_data\_verification.md\`

\---

\#\#\# 2.2 INE \- Dados de Área Municipal (Suplementar)  
\*\*Organização:\*\* Instituto Nacional de Estatística (INE) via dados.gov.pt    
\*\*Dataset:\*\* Superfície (km²) por concelho (2022)    
\*\*URL:\*\* https://dados.gov.pt/pt/datasets/superficie-km2-por-concelho-2022/    
\*\*Download Direto:\*\* https://dados.gov.pt/s/resources/superficie-km2-por-concelho-2022/20251001-142238/superficies-por-concelho-2022.csv    
\*\*Tipo de Dados:\*\* CSV    
\*\*Licença:\*\* Creative Commons Attribution 4.0 (CC-BY 4.0)    
\*\*Ano de Referência:\*\* 2022    
\*\*Estado:\*\* Descarregado e integrado por TM1

\*\*Descrição:\*\*    
Dados oficiais de superfície territorial para todos os 308 municípios portugueses dos Censos 2022\. Publicado pelo INE (Instituto Nacional de Estatística) e disponibilizado através do Portal de Dados Abertos Português.

\*\*Estrutura dos Dados:\*\*  
\- Data de Referência: 2022  
\- Superfície (km²): Área em quilómetros quadrados  
\- Código Concelho: Código do município  
\- Designação Concelho: Nome do município  
\- Código Distrito: Código do distrito  
\- Designação Distrito: Nome do distrito  
\- Código NUTS III: Código NUTS III  
\- Designação NUTS III: Nome NUTS III  
\- Código NUTS II: Código NUTS II  
\- Designação NUTS II: Nome NUTS II

\*\*Detalhes de Integração:\*\*  
\- \*\*Data de Download:\*\* 26 Dezembro 2025  
\- \*\*Registos:\*\* 308 municípios  
\- \*\*Taxa de Sucesso de Correspondência:\*\* 100% (todos os 308 municípios correspondidos)  
\- \*\*Método de Integração:\*\* SQL JOIN pelo nome do município  
\- \*\*Campo Alvo:\*\* \`region.area\_km2\`  
\- \*\*Script de Integração:\*\* \`sql\_scripts/import\_area\_data.sql\`

\*\*Ficheiro Fonte:\*\* \`original\_data/regions/superficiesporconcelho2022.csv\`    
\*\*Tamanho do Ficheiro:\*\* 24,6 KB    
\*\*Codificação:\*\* Windows-1252 (cp1252), convertido para UTF-8 durante importação

\*\*Qualidade dos Dados:\*\*  
\-  Todos os 308 municípios têm dados de área  
\-  Áreas variam de 41,42 km² (Porto) a \~1.300 km² (Évora, Beja)  
\-  Área total de Portugal continental: \~89.000 km²  
\-  Verificação cruzada com estatísticas oficiais do INE

\*\*Fonte CAOP:\*\* Carta Administrativa Oficial de Portugal, edição 2022, mantida pela Direção-Geral do Território (DGT).

\---

\#\#\# 2.3 PORDATA (Referência Alternativa)  
\*\*Organização:\*\* PORDATA \- Base de Dados Portugal Contemporâneo    
\*\*URL:\*\* https://www.pordata.pt/municipios    
\*\*Licença:\*\* Acesso gratuito para investigação    
\*\*Estado:\*\*  Referenciado, não descarregado (dados.gov.pt usado em alternativa)

\*\*Descrição:\*\*    
Fonte alternativa para dados de área municipal. Contém estatísticas oficiais do INE apresentadas em formato amigável. Não usado na implementação final pois dados.gov.pt forneceu dados mais completos e diretamente descarregáveis.

\---

\#\# 3\. Dados Meteorológicos

\#\#\# 3.1 IPMA \- Instituto Português do Mar e da Atmosfera  
\*\*Organização:\*\* Instituto Português do Mar e da Atmosfera    
\*\*Website:\*\* https://www.ipma.pt/    
\*\*URL da API:\*\* https://api.ipma.pt/    
\*\*Tipo de Dados:\*\* JSON (API) / CSV (download em massa)    
\*\*Licença:\*\* Dados públicos \- Gratuitos para investigação e uso educacional    
\*\*Cobertura Temporal:\*\* 1979 \- presente    
\*\*Frequência de Atualização:\*\* Diária (dados históricos disponíveis)    
\*\*Cobertura Geográfica:\*\* Portugal Continental (rede de estações meteorológicas)    
\*\*Estado:\*\* A ser descarregado por TM3

\*\*Descrição:\*\*    
Dados meteorológicos oficiais do serviço meteorológico nacional português. Inclui temperatura, humidade, velocidade do vento, precipitação e índices especializados de risco de incêndio.

\*\*Variáveis Principais Necessárias:\*\*  
\- Temperatura máxima diária (°C)  
\- Humidade relativa (%)  
\- Velocidade do vento (km/h)  
\- Precipitação (mm)  
\- Índice de Perigo de Incêndio (FWI) e componentes

\*\*Endpoints da API:\*\*  
\- Lista de estações: \`https://api.ipma.pt/open-data/observation/meteorology/stations/stations.json\`  
\- Observações históricas: \`https://api.ipma.pt/open-data/observation/meteorology/stations/observations.json\`  
\- Dados FWI: Disponíveis através do portal de dados IPMA (requer pedido específico)

\*\*Atribuição:\*\* TM3 (Duarte Campina) responsável por:  
\- Configuração de acesso à API  
\- Download de dados históricos (2015-2024)  
\- Recolha de metadados de estações meteorológicas  
\- Limpeza e formatação de dados  
\- Documentação de procedimentos de download

\*\*Ficheiros de Saída Esperados:\*\*  
\- \`original\_data/weather/stations\_metadata.json\`  
\- \`original\_data/weather/daily\_weather\_2015-2024.csv\`  
\- \`original\_data/weather/fwi\_historical\_2015-2024.csv\`

\*\*Documentação da Estrutura de Dados:\*\* A criar por TM3 em \`documentation/weather\_data\_structure.md\`

\---

\#\#\# 3.2 Dados do Índice de Perigo de Incêndio (FWI)  
\*\*Organização:\*\* IPMA    
\*\*Cobertura Temporal:\*\* 1979 \- 2024    
\*\*Estado:\*\*  A ser descarregado por TM3

\*\*Descrição:\*\*    
Índice especializado combinando temperatura, humidade, vento e precipitação para avaliar perigo diário de incêndio. Variável crítica para análise de risco de incêndio e estudos de correlação.

\*\*Componentes do Sistema FWI:\*\*  
\- \*\*FFMC\*\* (Fine Fuel Moisture Code) \- Teor de humidade de combustíveis finos  
\- \*\*DMC\*\* (Duff Moisture Code) \- Teor de humidade de camadas orgânicas pouco compactadas  
\- \*\*DC\*\* (Drought Code) \- Teor de humidade de camadas orgânicas profundas e compactas  
\- \*\*ISI\*\* (Initial Spread Index) \- Taxa esperada de propagação do fogo  
\- \*\*BUI\*\* (Build-Up Index) \- Quantidade total de combustível disponível para combustão  
\- \*\*FWI\*\* (Fire Weather Index) \- Indicador geral de intensidade do fogo

\*\*Referência:\*\* Sistema Canadiano de Índice de Perigo de Incêndio Florestal (adaptado às condições portuguesas)

\*\*Ligação Fogo-Meteorologia:\*\*  
Cada registo de incêndio será ligado às condições meteorológicas na data de início do fogo na estação meteorológica mais próxima do centro do município.

\#\# 3.3. Dados Meteorológicos (Atualização) \- IPMA DataClima

\*\*Organização:\*\* Instituto Português do Mar e da Atmosfera (IPMA)    
\*\*Fonte:\*\* https://dataclima.ipma.pt    
\*\*Licença:\*\* Dados Abertos \- Uso livre para fins académicos e científicos    
\*\*Tipo:\*\* Dados meteorológicos históricos (temperatura, precipitação, humidade, vento)    
\*\*Descrição:\*\* Normais climatológicas e séries históricas de estações meteorológicas em Portugal    
\*\*Formato de Download:\*\* CSV (por estação e variável)    
\*\*Frequência de Atualização:\*\* Dados históricos estáticos (não atualizados em tempo real)    
\*\*Cobertura Temporal:\*\* Variável por estação (maioria cobre décadas)    
\*\*Cobertura Geográfica:\*\* Rede de estações meteorológicas em Portugal Continental    
\*\*Notas:\*\* Dados descarregados manualmente por estação. Falta temperatura para Évora (identificado durante processamento).

\---

\#\# 4\. Dados de Vegetação

\#\#\# 4.1 ICNF \- 6º Inventário Florestal Nacional (IFN6)  
\*\*Organização:\*\* Instituto da Conservação da Natureza e das Florestas    
\*\*URL:\*\* http://www2.icnf.pt/portal/florestas/ifn    
\*\*Tipo de Dados:\*\* Relatórios publicados e tabelas estatísticas    
\*\*Licença:\*\* Domínio público (publicação governamental)    
\*\*Cobertura Temporal:\*\* Inventário nacional mais recente    
\*\*Estado:\*\*  Revisto e referenciado por TM2

\*\*Descrição:\*\*    
Inventário florestal nacional fornecendo informação detalhada sobre composição florestal, distribuição de espécies e tipos de vegetação em Portugal. Sexta iteração da avaliação florestal nacional periódica.

\*\*Informação Principal Extraída:\*\*  
\- Classificação e taxonomia de espécies florestais  
\- Distribuição geográfica por região  
\- Área coberta por cada espécie/tipo de vegetação  
\- Dados de densidade e composição florestal  
\- Categorias de uso do solo

\*\*Tipos de Vegetação Classificados (para o projeto):\*\*

| Tipo | Nome Científico | Inflamabilidade | Notas |  
|------|----------------|-----------------|-------|  
| Pinheiro-bravo | \*Pinus pinaster\* | Alta | Pinheiro marítimo, 35% da área ardida |  
| Eucalipto | \*Eucalyptus globulus\* | Alta | 50% da área ardida |  
| Carvalho | \*Quercus robur\* | Média | Espécies de carvalho |  
| Sobreiro | \*Quercus suber\* | Baixa | Sobreiro, espécie protegida |  
| Azinheira | \*Quercus ilex\* | Baixa | Azinheira |  
| Mato/Scrubland | Matos mistos | Alta | Subcoberto altamente inflamável |  
| Floresta Mista | Floresta mista | Variável | Depende da composição |

\*\*Estatística Principal:\*\* Pinheiro-bravo e Eucalipto juntos representam aproximadamente \*\*85% da área total de floresta ardida\*\* em Portugal (fonte: APAMBIENTE, citado em revisão de literatura).

\*\*Critérios de Classificação de Inflamabilidade:\*\*  
\- \*\*Alta:\*\* Combustão rápida, resinoso, combustíveis finos (agulhas de pinheiro, casca de eucalipto)  
\- \*\*Média:\*\* Taxa de combustão moderada, tipos mistos de combustível  
\- \*\*Baixa:\*\* Combustão lenta, alta retenção de humidade, folhas largas

\---

\#\#\# 4.2 Tabela de Referência de Vegetação (Personalizada)  
\*\*Criada por:\*\* TM2 (Luis Vale)    
\*\*Ficheiro:\*\* \`original\_data/vegetation/vegetation\_types.csv\`    
\*\*Estado:\*\*  Criado com base no IFN6 e revisão de literatura    
\*\*Data de Criação:\*\* 21 Dezembro 2025

\*\*Descrição:\*\*    
Tabela de referência personalizada criada a partir de revisão de literatura combinando dados do inventário florestal IFN6 com investigação em ecologia do fogo. Classifica os principais tipos de vegetação portugueses por níveis de inflamabilidade.

\*\*Estrutura da Tabela:\*\*  
\`\`\`csv  
vegetation\_id,tipo\_vegetacao,inflammabilidade,descricao  
1,Pinheiro-bravo,Alta,Pinus pinaster \- Pinheiro marítimo  
2,Eucalipto,Alta,Eucalyptus globulus  
3,Carvalho,Média,Quercus spp. \- Espécies de carvalho  
4,Sobreiro,Baixa,Quercus suber \- Sobreiro  
5,Azinheira,Baixa,Quercus ilex \- Azinheira  
6,Mato,Alta,Matos e arbustos  
7,Floresta Mista,Média,Tipos de floresta mista  
\`\`\`

\*\*Campos:\*\*  
\- \`vegetation\_id\`: Chave primária (inteiro)  
\- \`tipo\_vegetacao\`: Nome comum em português  
\- \`inflammabilidade\`: Classificação (Alta/Média/Baixa)  
\- \`descricao\`: Descrição com nomes científicos

\*\*Utilização:\*\* Tabela de referência para entidade \`VEGETACAO\` na base de dados. Será ligada a incêndios via tabela de junção \`INCENDIO\_VEGETACAO\`.

\---

\#\#\# 4.3 APAMBIENTE \- Agência Portuguesa do Ambiente  
\*\*URL:\*\* https://apambiente.pt/    
\*\*Propósito:\*\* Estatísticas de apoio e citações    
\*\*Licença:\*\* Informação pública  

\*\*Referenciado Para:\*\*  
\- Estatística "85% da área florestal ardida" (Pinheiro-bravo \+ Eucalipto)  
\- Avaliações de impacto de incêndios florestais  
\- Contexto de política ambiental

\*\*Citação no Relatório:\*\* APA (Agência Portuguesa do Ambiente). Estatísticas de incêndios florestais e avaliações de impacto ambiental. Disponível em: https://apambiente.pt/

\---

\#\#\# 4.4 fogos.pt (Suplementar)  
\*\*URL:\*\* https://fogos.pt/    
\*\*Tipo:\*\* Website de monitorização de incêndios em tempo real    
\*\*Estado:\*\*  Apenas referência (TM3 a avaliar se necessário)

\*\*Descrição:\*\*    
Interface web em tempo real para monitorização de incêndios florestais ativos em Portugal. Agrega dados de várias fontes incluindo Proteção Civil.

\*\*Utilização Potencial:\*\*  
\- Fonte de backup/validação para estatísticas de incêndios recentes  
\- Dados de alerta em tempo real (se âmbito do projeto expandir)  
\- Plataforma de consciencialização e comunicação pública

\*\*Nota:\*\* Não é uma fonte primária de dados para análise histórica, mas útil para compreender sistemas atuais de monitorização de incêndios.

\---

\#\# 5\. Resumo de Integração de Dados

\#\#\# Fontes Primárias por Entidade da Base de Dados

| Entidade da BD | Fonte de Dados Primária | Estado | Responsável |  
|----------------|-------------------------|--------|-------------|  
| \*\*REGIOES\*\* | dms\_INE \+ INE/dados.gov.pt |  Completo | TM1 |  
| \*\*INCENDIOS\*\* | Central de Dados |  Descarregado | TM2 |  
| \*\*VEGETACAO\*\* | IFN6 \+ Literatura | Completo | TM2 |  
| \*\*INCENDIO\_VEGETACAO\*\* | Derivado de INCENDIOS |  A processar | TM2 |  
| \*\*METEOROLOGIA\*\* | API IPMA |  A descarregar | TM3 |

\#\#\# Resumo de Volume de Dados

| Tipo de Dados | Registos | Período | Tamanho | Estado |  
|---------------|----------|---------|---------|--------|  
| Incidências de incêndio | 121.000+ | 2015-2024 | \~150 MB |  Descarregado |  
| Regiões | 3.436 | Atual | \~400 KB |  Completo |  
| Área de municípios | 308 | 2022 | 25 KB | Integrado |  
| Tipos de vegetação | \~10 | Referência | \<5 KB |  Criado |  
| Registos meteorológicos | A definir | 2015-2024 | A definir |  Pendente |

\---

\#\# 6\. Padrões de Qualidade de Dados

\#\#\# Critérios de Qualidade Aplicados

Todas as fontes de dados são avaliadas segundo estes critérios:

1\. \*\*Completude:\*\* Percentagem de valores não-nulos em campos críticos  
2\. \*\*Exatidão:\*\* Verificado face a fontes oficiais  
3\. \*\*Atualidade:\*\* Recência dos dados e frequência de atualização  
4\. \*\*Fiabilidade:\*\* Credibilidade da fonte e consistência  
5\. \*\*Acessibilidade:\*\* Facilidade de download e compatibilidade de formato

\#\#\# Avaliação de Qualidade por Fonte

| Fonte | Completude | Exatidão | Atualidade | Fiabilidade | Acessibilidade |  
|-------|------------|----------|------------|-------------|----------------|  
| Central de Dados (Incêndios) | 99,99% | Alta | Anual | Alta | Alta |  
| dms\_INE (Regiões) | 99,97% | Alta | Atual | Alta | Média |  
| INE/dados.gov.pt (Área) | 100% | Alta | 2022 | Alta | Alta |  
| IPMA (Meteorologia) | A definir | Alta | Diária | Alta | Média |  
| IFN6 (Vegetação) | Boa | Alta | Periódica | Alta | Baixa |

\*\*Legenda:\*\*  
\- \*\*Completude:\*\* 95%+ \= Excelente, 90-95% \= Bom, \<90% \= Necessita melhoria  
\- \*\*Alta/Média/Baixa:\*\* Avaliação subjetiva da dimensão de qualidade

\---

\#\# 7\. Licenciamento e Conformidade

\#\#\# Conformidade com Dados Abertos

Todas as fontes de dados cumprem com princípios de dados abertos:  
\-  \*\*Livremente Acessíveis:\*\* Sem pagamento necessário para uso académico  
\-  \*\*Legíveis por Máquina:\*\* Disponíveis em formatos estruturados (CSV, JSON, SQL)  
\-  \*\*Licença Aberta:\*\* CC-BY 4.0 ou licença permissiva equivalente  
\-  \*\*Bem Documentados:\*\* Metadados e descrições de campos disponíveis

\#\#\# Requisitos de Atribuição

\*\*Citações Obrigatórias no Relatório Final:\*\*

1\. \*\*Dados de Incêndios:\*\*    
   "Dados de incidências de incêndios obtidos da Central de Dados Portugal (http://centraldedados.pt/incendios/), provenientes do ICNF \- Instituto da Conservação da Natureza e das Florestas."

2\. \*\*Dados Regionais:\*\*    
   "Dados de hierarquia regional e área do Instituto Nacional de Estatística (INE), Portugal. Disponível via base de dados académica dms\_INE e portal de dados abertos dados.gov.pt."

3\. \*\*Dados Meteorológicos:\*\*    
   "Dados meteorológicos do IPMA \- Instituto Português do Mar e da Atmosfera (https://www.ipma.pt/), serviço meteorológico nacional português."

4\. \*\*Dados de Vegetação:\*\*    
   "Dados de composição florestal baseados no 6º Inventário Florestal Nacional (IFN6), ICNF \- Instituto da Conservação da Natureza e das Florestas."

\#\#\# Conformidade com RGPD

\-  \*\*Sem Dados Pessoais:\*\* Projeto usa apenas dados estatísticos agregados  
\-  \*\*Sem Informação Identificável:\*\* Nenhuma informação pessoalmente identificável recolhida  
\-  \*\*Apenas Fontes Públicas:\*\* Todas as fontes são dados governamentais publicamente disponíveis  
\-  \*\*Propósito Académico:\*\* Dados usados exclusivamente para projeto de investigação educacional

\---

\#\# 8\. Limitações Conhecidas

\#\#\# Lacunas e Constrangimentos de Dados

1\. \*\*Variação de Cobertura Temporal:\*\*  
   \- Dados de incêndios: Completo 2015-2024  
   \- Dados de área: Ponto no tempo (2022)  
   \- Dados meteorológicos: A confirmar (lacunas possíveis)

2\. \*\*Âmbito Geográfico:\*\*  
   \- Foco: Portugal Continental  
   \- Excluído: Açores e Madeira (dados disponíveis mas não prioritários)

3\. \*\*Detalhe de Vegetação:\*\*  
   \- Apenas categorias amplas (não a nível de espécie)  
   \- Inflamabilidade: Classificação qualitativa (Alta/Média/Baixa)  
   \- Ligação fogo-vegetação: Assumida, não diretamente medida

4\. \*\*Ligação Meteorologia-Fogo:\*\*  
   \- Dados meteorológicos: Baseados em estações (não localizações específicas de incêndios)  
   \- Método de correspondência: Estação mais próxima do centróide do município  
   \- Resolução temporal: Diária (não horária durante incêndio)

5\. \*\*Qualidade de Dados Históricos:\*\*  
   \- Registos de incêndios mais antigos (pré-2015) podem ter mais lacunas  
   \- Classificação NUTS: Mudanças ao longo do tempo podem afetar comparações

\---

\#\# 9\. Melhorias Futuras de Dados

\#\#\# Adições Potenciais (Fora do Âmbito do Projeto Atual)

1\. \*\*Dados Socioeconómicos:\*\*  
   \- Densidade populacional por região  
   \- Mudanças de uso do solo ao longo do tempo  
   \- Avaliações de impacto económico

2\. \*\*Dados de Satélite:\*\*  
   \- Deteção remota de incêndios  
   \- Índices de vegetação (NDVI)  
   \- Mapeamento de cicatrizes de queimada

3\. \*\*Integração em Tempo Real:\*\*  
   \- Alertas de incêndio ao vivo da API fogos.pt  
   \- Condições meteorológicas atuais  
   \- Avaliação dinâmica de risco

4\. \*\*Séries Temporais Estendidas:\*\*  
   \- Incêndios históricos até 1980  
   \- Tendências climáticas de longo prazo  
   \- Análise de padrões sazonais

\---

\#\# 10\. Plano de Manutenção de Dados

\#\#\# Calendário de Atualização (Pós-Projeto)

Se o projeto continuar além da submissão inicial:

\- \*\*Atualizações Anuais:\*\*  
  \- Dados de incêndios: Descarregar incidentes do novo ano da Central de Dados  
  \- Atualizações regionais: Verificar mudanças na classificação NUTS  
    
\- \*\*Revisões Semestrais:\*\*  
  \- Dados meteorológicos: Estender séries temporais  
  \- Vegetação: Verificar novos lançamentos do IFN

\- \*\*Conforme Necessário:\*\*  
  \- Dados de área: Atualizar se limites municipais mudarem  
  \- Qualidade dos dados: Reverificar completude e exatidão

\#\#\# Controlo de Versões

Todos os ficheiros de dados são versionados com data de download:  
\- Formato: \`nome\_dataset\_AAAAMMDD.csv\`  
\- Exemplo: \`incendios\_2015\_20251221.csv\`  
\- Ficheiros originais preservados em \`original\_data/\`  
\- Ficheiros processados em \`processed\_data/\`

\---

\#\# 11\. Informação de Contacto

\#\#\# Responsabilidades das Fontes de Dados

\*\*Para questões sobre fontes de dados específicas:\*\*

\- \*\*Dados de Incêndios (Central de Dados, dados.gov.pt):\*\*    
  TM2 \- Luis Vale   
    
\- \*\*Dados Regionais (dms\_INE, INE, dados de área):\*\*    
  TM1 \- Cristiana Chainho   
    
\- \*\*Dados Meteorológicos (IPMA):\*\*    
  TM3 \- Duarte Campina   
    
\- \*\*Dados de Vegetação (IFN6, classificação):\*\*    
  TM2 \- Luis Vale \- 

\#\#\# Organizações Externas

\*\*Para questões sobre fontes de dados:\*\*

\- \*\*ICNF:\*\* icnf@icnf.pt | http://www.icnf.pt/  
\- \*\*INE:\*\* info@ine.pt | https://www.ine.pt/  
\- \*\*IPMA:\*\* informacoes@ipma.pt | https://www.ipma.pt/  
\- \*\*dados.gov.pt:\*\* dados@ama.gov.pt | https://dados.gov.pt/

\---