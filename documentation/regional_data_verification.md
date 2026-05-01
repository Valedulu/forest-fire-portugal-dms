Verificação Dados Regionais \- dms\_INE  
Data de Exportação: 26 Dezembro 2025  
Base de Dados: dms\_INE  
Tabela: region  
Ficheiro Exportado: original\_data/regions/regions\_dms\_INE.csv

1\. Estrutura dos Dados Exportados  
Colunas Presentes

NutsID (varchar(9)) \- Código NUTS da região  
ParentCodeID (varchar(9)) \- Código NUTS da região pai (hierarquia)  
level\_ID (int(1)) \- Nível hierárquico da região  
region\_name (varchar(255)) \- Nome da região em português

Total de Registos  
3,436 regiões exportadas com sucesso

2\. Contagem por Nível Hierárquico  
level\_IDTotalInterpretação01País (Portugal)13Regiões NUTS I27Regiões NUTS II325Regiões NUTS III (sub-regiões)4308Concelhos (municípios)53,092Freguesias (parishes)  
Total: 3,436 regiões  
Análise da Hierarquia  
Level 0 (País)  
  └─ Level 1 (3 Regiões NUTS I: Continental, Açores, Madeira)  
      └─ Level 2 (7 Regiões NUTS II: Norte, Centro, Lisboa, Alentejo, Algarve, RA Açores, RA Madeira)  
          └─ Level 3 (25 Sub-regiões NUTS III)  
              └─ Level 4 (308 Concelhos)  
                  └─ Level 5 (3,092 Freguesias)  
Hierarquia completa: 6 níveis desde país até freguesia

3\. Verificação de Integridade Hierárquica  
Query de Verificação  
sql  
SELECT COUNT(\*) as registos\_orfaos  
FROM region r1  
WHERE r1.ParentCodeID IS NOT NULL   
  AND r1.ParentCodeID NOT IN (SELECT NutsID FROM region);  
Resultado: 1 registo órfão detectado  
Alerta de Integridade: Existe 1 região cujo ParentCodeID não corresponde a nenhum NutsID válido  
Investigação Necessária  
Para identificar o registo problemático:  
sqlSELECT   
    NutsID,  
    region\_name,  
    level\_ID,  
    ParentCodeID  
FROM region r1  
WHERE r1.ParentCodeID IS NOT NULL   
  AND r1.ParentCodeID NOT IN (SELECT NutsID FROM region);  
Ação recomendada:

Executar query acima para identificar qual região está órfã  
Verificar se é erro de dados ou se ParentCodeID está incorreto  
Pode ser necessário corrigir manualmente ou excluir da importação

Impacto:

Baixo (apenas 1 de 3,436 registos \= 0.03%)  
Não compromete a hierarquia geral  
Deve ser documentado como limitação conhecida

4\. Mapeamento level\_ID → Descrição  
Para uso nos scripts e documentação:  
sqlCASE   
    WHEN level\_ID \= 0 THEN 'País'  
    WHEN level\_ID \= 1 THEN 'NUTS I'  
    WHEN level\_ID \= 2 THEN 'NUTS II'  
    WHEN level\_ID \= 3 THEN 'NUTS III'  
    WHEN level\_ID \= 4 THEN 'Concelho'  
    WHEN level\_ID \= 5 THEN 'Freguesia'  
END AS nivel\_descricao

5\. Amostras de Dados  
Exemplo \- Level 0 (País)  
NutsID: PT  
ParentCodeID: NULL  
region\_name: Portugal  
Exemplo \- Level 2 (NUTS II)  
NutsID: PT11  
ParentCodeID: PT1  
region\_name: Norte  
Exemplo \- Level 4 (Concelho)  
NutsID: PT111XX (exemplo)  
ParentCodeID: PT111  
region\_name: \[Nome do Concelho\]

6\. Campo area\_km2  
PROBLEMA IDENTIFICADO  
Status: Campo area\_km2 NÃO EXISTE na tabela region do dms\_INE  
Impacto no Projeto:

Schema original previa: area\_km2 DECIMAL(10,2)  
Queries planejadas usam este campo para cálculos de densidade  
Análises de "percentagem de área ardida" ficam comprometidas

Opções de Resolução  
OPÇÃO A: Obter Dados de Área (Recomendado para análise completa)  
Fontes possíveis:

PORDATA \- https://www.pordata.pt/municipios

Tem área dos 308 concelhos  
Dados oficiais do INE  
Download gratuito

INE Direto \- https://www.ine.pt/

Fonte primária  
Pode ter mais detalhe (freguesias)

Ação necessária:

 Download dados de área  
 Criar original\_data/regions/area\_supplement\_pordata.csv  
 JOIN ou UPDATE na importação

OPÇÃO B: Ajustar Projeto (Mais rápido)  
Mudanças necessárias:

Remover area\_km2 do schema REGIOES  
Ajustar queries que usam área:

Q1: Remover "percentagem\_area\_distrito"  
Q2: Focar em área absoluta, não densidade

7\. Qualidade dos Dados  
Verificações Realizadas  
 Encoding: UTF-8 correto, caracteres portugueses (ç, ã, õ) preservados  
 Completude: 3,436 registos exportados  
 Integridade: 1 órfão detectado (0.03% \- impacto mínimo)  
 Consistência: level\_ID sequencial e lógico (0-5)  
 Hierarquia geral: 99.97% consistente  
Potenciais Issues  
 ParentCodeID NULL:

Apenas no level 0 (País) \- esperado e correto

 Registo Órfão Detectado:

1 região tem ParentCodeID que não existe na tabela (0.03% dos dados)  
Necessita investigação adicional  
Não compromete análise geral mas deve ser documentado

 Valores não verificados:

Identificação específica do registo órfão (query adicional necessária)  
Existência de NutsID duplicados (assumindo PK na BD)  
Completude de region\_name (assumindo NOT NULL)

8 . Recomendações para a Equipa  
Para TM2 (Luis \- Fire Data)

Usar NutsID (não region\_id) no JOIN com INCENDIOS  
Verificar se dados de incêndios têm códigos NUTS compatíveis  
Pode ser necessário mapear nomes de concelho → NutsID

Para TM3 (Duarte \- Weather Data)

Weather pode referenciar NutsID ou ter coordenadas  
Se coordenadas, precisará de geocoding para NutsID

9 . Conclusão  
Sumário  
 Exportação bem-sucedida: 3,436 regiões em 6 níveis hierárquicos  
 Qualidade: Dados completos e consistentes  
 Limitação: Falta campo area\_km2  
 Ação requerida: Ajustar scripts SQL para nomenclatura real  
Estado do Trabalho  
Dados regionais:  Prontos para importação (com ajustes de schema)  
Documentação:  Estrutura verificada e documentada

Verificado e documentado por: TM1 (Cristiana Chainho)  
Data: 26 Dezembro 2025  
Tempo investido: \~45 minutos

\#\# ATUALIZAÇÃO: Campo area\_km2 Adicionado

\*\*Data:\*\* 26 Dezembro 2025, 

\#\#\# Fonte de Dados  
\- \*\*Origem:\*\* dados.gov.pt / INE  
\- \*\*Ficheiro:\*\* superficies-por-concelho-2022.csv  
\- \*\*Ano de referência:\*\* 2022  
\- \*\*Licença:\*\* Creative Commons Attribution 4.0 \- CC BY 4.0

\#\#\# Resultados da Importação  
 \*\*308/308 concelhos\*\* com área importada (100%)  
 \*\*25/25 NUTS III\*\* com área agregada (100%)  
 Sem erros de matching

\#\#\# Valores Verificados  
\- Maior concelho: Odemira  
\- Menor concelho: São João da Madeira  
\- Área média: \~309 km² por concelho  
Status: Tarefa 2 Completa  
