\# RESUMO EXECUTIVO  
\#\# Sistema de Gestão de Incêndios Florestais em Portugal

\*\*Projeto:\*\* Base de Dados Relacional para Análise de Incêndios Florestais    
\*\*Equipa:\*\* Grupo 5 \- Cristiana Chainho (27260), Luis Vale (25952), Duarte Campina (25962)    
\*\*Instituição:\*\* \[Nome da Universidade\]    
\*\*Disciplina:\*\* Sistemas de Gestão de Bases de Dados    
\*\*Data:\*\* 31 Dezembro 2025

\---

\#\# O Problema

Portugal enfrenta anualmente milhares de incêndios florestais que destroem vastas áreas de floresta, ameaçam vidas humanas, e causam danos ambientais e económicos significativos. Os dados relativos a estas ocorrências encontram-se dispersos por múltiplas entidades (ICNF, IPMA, INE), em formatos heterogéneos, dificultando análises integradas e a tomada de decisão baseada em evidências. A ausência de um sistema centralizado que relacione dados geográficos, meteorológicos, de vegetação e histórico de incêndios limita a capacidade de identificar padrões, zonas de risco, e desenvolver estratégias eficazes de prevenção e combate.

\#\# A Solução

Desenvolvemos um \*\*sistema de base de dados relacional completo\*\* que integra dados históricos de incêndios florestais em Portugal (2015-2024) numa estrutura normalizada, permitindo análises complexas e multidimensionais. O sistema consolida:

\- \*\*121.000+ registos de incêndios\*\* do ICNF/Central de Dados  
\- \*\*3.436 unidades territoriais\*\* da hierarquia NUTS portuguesa (INE)  
\- \*\*308 áreas municipais\*\* com dados de superfície territorial  
\- \*\*Classificação de vegetação\*\* por níveis de inflamabilidade (IFN6/ICNF)  
\- \*\*Dados meteorológicos\*\* do IPMA (temperatura, humidade, vento, precipitação)

A base de dados, implementada em MySQL e normalizada em \*\*Terceira Forma Normal (3NF)\*\*, é composta por 5 entidades inter-relacionadas (REGIOES, INCENDIOS, VEGETACAO, INCENDIO\_VEGETACAO, METEOROLOGIA) com integridade referencial totalmente garantida através de chaves estrangeiras e constraints de validação.

\#\# Metodologia

O projeto seguiu uma abordagem estruturada em 8 fases: (1) identificação do problema e definição de questões de investigação, (2) recolha de dados de múltiplas fontes oficiais, (3) limpeza e padronização de dados, (4) design do schema em 3NF, (5) implementação da base de dados com scripts SQL documentados, (6) desenvolvimento de queries analíticas para responder às 7 questões fundamentais, (7) documentação técnica exaustiva, e (8) organização final do projeto para submissão.

Todos os processos de transformação de dados foram documentados, scripts SQL foram extensivamente comentados, e a qualidade dos dados foi validada através de queries de verificação de integridade que confirmaram \>99% de completude e consistência.

\#\# Resultados Principais

\#\#\# Capacidades Analíticas Implementadas

O sistema permite responder a 7 questões fundamentais através de queries SQL complexas:

\*\*Q1-Q2 (Desenvolvidas por TM1):\*\* Identificação de concelhos/distritos mais afetados e análise de área média ardida por região e tipo de vegetação, revelando que:  
\- Regiões Norte e Centro concentram \>75% dos incêndios  
\- Pinheiro-bravo e Eucalipto representam \~85% da área ardida (confirmando literatura)  
\- Concelhos com monocultura apresentam vulnerabilidade 3-4x superior  
\- Densidade de incêndios varia de 0.1 a \>1.5 ocorrências/km²

\*\*Q3-Q7 (Desenvolvidas por TM2/TM3):\*\* Análise de padrões sazonais, correlação meteorológica, principais causas, tempo de combate, e evolução temporal.

\#\#\# Insights para Tomada de Decisão

 \*\*Identificação de Zonas Críticas:\*\* Top 10 concelhos concentram 40% da área total ardida    
 \*\*Padrões de Vegetação:\*\* Vegetação alta inflamabilidade tem área média 5-6x superior a baixa inflamabilidade    
 \*\*Impacto Territorial:\*\* 15+ concelhos perderam \>25% do território no período analisado    
 \*\*Densidade de Risco:\*\* Concelhos pequenos com alta densidade requerem vigilância intensificada  

\#\#\# Estrutura Técnica Robusta

 \*\*Normalização 3NF:\*\* Eliminação completa de redundâncias, atualizações consistentes    
 \*\*Integridade Referencial:\*\* 100% das relações validadas, 0 registos órfãos (exceto 1 conhecido e documentado)    
 \*\*Performance Otimizada:\*\* Índices em todos os campos críticos, queries executam em \<15 segundos    
 \*\*Escalabilidade:\*\* Design permite adição de novos anos, variáveis, ou dimensões analíticas  

\#\# Aplicações Práticas

\*\*Proteção Civil:\*\* Priorização de alocação de recursos de combate (bombeiros, meios aéreos) nas zonas de maior risco identificadas.

\*\*Gestão Florestal:\*\* Regulação de plantação de espécies altamente inflamáveis em concelhos críticos; incentivo à diversificação florestal.

\*\*Autarquias:\*\* Fundamentação baseada em dados para orçamentos de prevenção e elaboração de Planos Municipais de Defesa da Floresta (PMDFCI).

\*\*Investigação:\*\* Base sólida para modelos preditivos (machine learning), estudos de impacto climático, e avaliação de eficácia de políticas.

\#\# Documentação e Reprodutibilidade

O projeto inclui \*\*documentação técnica exaustiva\*\* (\>5.000 linhas) que permite reprodução completa:

 \*\*data\_sources.md:\*\* Catálogo de fontes com URLs, licenças, e avaliação de qualidade    
 \*\*data\_download\_procedures.md:\*\* Instruções passo-a-passo para obter todos os dados    
 \*\*database\_relationships.md:\*\* Explicação detalhada de todas as relações e justificações 3NF    
 \*\*Scripts SQL comentados:\*\* 11 scripts numerados desde criação até validação    
 \*\*Query documentation:\*\* Explicação de lógica, técnicas SQL, e interpretação de outputs  

Backup completo da base de dados (mysqldump) incluído para restauração rápida.

\#\# Limitações e Trabalho Futuro

\*\*Limitações reconhecidas:\*\* Cobertura meteorológica parcial para incêndios históricos; localização por município (não coordenadas GPS exatas); classificação de vegetação simplificada; período limitado a 2015-2024.

\*\*Extensões propostas:\*\* Integração de dados socioeconómicos e de satélite; séries temporais longas (décadas); modelos preditivos de risco; sistema de alertas em tempo real; interface web/dashboard interativo; API REST para acesso programático.

\#\# Conclusão

Este projeto demonstra como uma base de dados relacional bem desenhada transforma dados dispersos em conhecimento estruturado e acionável. Convertemos 121.000+ registos de incêndios de múltiplas fontes numa ferramenta analítica que identifica padrões, quantifica vulnerabilidades, e fundamenta decisões estratégicas com evidências empíricas.

A estrutura normalizada garante integridade e escalabilidade, a documentação exaustiva assegura reprodutibilidade, e as queries desenvolvidas provam a capacidade do sistema para responder a questões complexas críticas para gestão de incêndios florestais.

\*\*Entregáveis:\*\* Base de dados funcional (MySQL), 11 scripts SQL documentados, 7 queries analíticas, 10+ documentos técnicos, relatório completo, diagrama ER, backup completo.

\*\*Impacto esperado:\*\* Contribuir para gestão baseada em dados de um dos maiores desafios ambientais de Portugal, fornecendo ferramenta que pode ser utilizada por decisores, investigadores, e profissionais de proteção civil para salvar vidas, proteger ecossistemas, e otimizar recursos limitados.

\---

\*\*Palavras-chave:\*\* Incêndios Florestais, Base de Dados Relacional, Análise Geoespacial, Gestão de Risco, Normalização 3NF, SQL, Portugal

\*\*Total de Registos:\*\* 121.000+ incêndios | 3.436 regiões | 308 áreas | 10 anos de dados (2015-2024)  
