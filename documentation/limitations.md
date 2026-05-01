\# Limitações do Projeto

\#\# Limitações dos Dados

\#\#\# Dados Meteorológicos  
\- \*\*Cobertura Temporal\*\*: Dados meteorológicos do IPMA limitados ao período disponível no DataClima (dataclima.ipma.pt)  
\- \*\*Cobertura Espacial\*\*: Estações meteorológicas podem não cobrir uniformemente todas as regiões de incêndio  
\- \*\*Dados em Falta\*\*: Falta dados de temperatura para Évora (identificado durante limpeza)  
\- \*\*Granularidade\*\*: Dados meteorológicos agregados mensalmente, sem detalhes horários durante ocorrências específicas

\#\#\# Dados de Incêndios  
\- \*\*Período\*\*: Dados limitados a 2015-2024 (ICNF via centraldedados.pt)  
\- \*\*Qualidade\*\*: \<0.01% de valores em falta (documentado em clean\_fire\_data.py)  
\- \*\*Causas\*\*: Classificação de causas pode conter categorias ambíguas ou "desconhecida"

\#\#\# Dados de Vegetação  
\- \*\*Simulação\*\*: Dados de vegetação parcialmente simulados baseados em literatura (IFN6 não totalmente disponível)  
\- \*\*Inflamabilidade\*\*: Níveis de inflamabilidade (Baixo/Médio/Alto) são categorizações simplificadas

\#\#\# Dados Regionais  
\- \*\*Hierarquia NUTS\*\*: Baseada em dms\_INE, pode ter pequenas inconsistências em mudanças administrativas recentes  
\- \*\*Área\*\*: Valores de area\_km2 podem ter pequenas variações face a fontes oficiais

\#\# Limitações Técnicas

\#\#\# Base de Dados  
\- \*\*Sistema\*\*: MySQL/MariaDB \- funcionalidades avançadas de análise espacial não implementadas  
\- \*\*Normalização\*\*: Terceira Forma Normal garante integridade mas pode requerer múltiplos JOINs para queries complexas  
\- \*\*Performance\*\*: Não foram criados índices avançados além das chaves primárias e estrangeiras

\#\#\# Análise  
\- \*\*Correlações\*\*: Análise de correlação meteorologia vs incêndios é básica (queries SQL simples)  
\- \*\*Modelos Preditivos\*\*: Não foram implementados modelos de machine learning ou previsão  
\- \*\*Visualização\*\*: Sistema não inclui dashboards ou visualizações interativas

\#\# Limitações de Âmbito

\#\#\# Geográfico  
\- \*\*Território\*\*: Apenas Portugal Continental (sem Açores e Madeira explicitamente)  
\- \*\*Resolução\*\*: Análise ao nível de distrito/concelho, sem coordenadas GPS precisas

\#\#\# Temporal  
\- \*\*Histórico\*\*: 10 anos de dados (2015-2024) podem não capturar tendências de longo prazo  
\- \*\*Tempo Real\*\*: Sistema não integra dados em tempo real ou alertas automáticos

\#\#\# Funcional  
\- \*\*Uso\*\*: Sistema focado em análise retrospetiva, não em previsão ou gestão operacional  
\- \*\*Interoperabilidade\*\*: Não há integração com outros sistemas (bombeiros, proteção civil)  
\- \*\*Fatores Socioeconómicos\*\*: Não incluídos (densidade populacional, acessos, recursos de combate)

\#\# Trabalho Futuro

Para superar estas limitações, recomenda-se:  
\- Integração de dados GPS precisos para análise espacial avançada  
\- Dados meteorológicos em tempo real via API IPMA  
\- Modelos preditivos usando machine learning  
\- Dados de recursos de combate (bombeiros, meios aéreos)  
\- Dashboard interativo para visualização e monitorização  
