\# Relações da Base de Dados \- Sistema de Gestão de Incêndios Florestais

\*\*Projeto:\*\* Sistema de Gestão de Incêndios Florestais \- Portugal    
\*\*Equipa:\*\* Grupo 5    
\*\*Documento:\*\* Especificação de Relações entre Entidades    
\*\*Data:\*\* 26 Dezembro 2025

\---

\#\# Índice  
1\. \[Visão Geral do Schema\](\#1-visão-geral-do-schema)  
2\. \[Entidades Principais\](\#2-entidades-principais)  
3\. \[Relações Detalhadas\](\#3-relações-detalhadas)  
4\. \[Justificação de Design\](\#4-justificação-de-design)  
5\. \[Regras de Integridade\](\#5-regras-de-integridade)

\---

\#\# 1\. Visão Geral do Schema

\#\#\# 1.1 Arquitetura Geral

O sistema é composto por \*\*5 entidades principais\*\* organizadas numa estrutura relacional que suporta análises multidimensionais:

\`\`\`  
REGIOES (hierárquica, auto-referencial)  
   ↓ (1:N)  
INCENDIOS (entidade central)  
   ↓ (1:1)                    ↓ (1:N)  
METEOROLOGIA          INCENDIO\_VEGETACAO (tabela de junção)  
                              ↓ (N:1)  
                          VEGETACAO (referência)  
\`\`\`

\#\#\# 1.2 Papel de Cada Entidade

| Entidade | Tipo | Função | Registos Esperados |  
|----------|------|--------|-------------------|  
| \*\*REGIOES\*\* | Dimensão | Hierarquia administrativa portuguesa (NUTS) | 3.436 |  
| \*\*INCENDIOS\*\* | Facto | Ocorrências de incêndios florestais | 121.000+ |  
| \*\*VEGETACAO\*\* | Dimensão | Tipos de vegetação e inflamabilidade | \~10 |  
| \*\*INCENDIO\_VEGETACAO\*\* | Junção | Relaciona incêndios com vegetação afetada | 150.000+ |  
| \*\*METEOROLOGIA\*\* | Dimensão | Condições meteorológicas durante incêndios | 121.000+ |

\---

\#\# 2\. Entidades Principais

\#\#\# 2.1 REGIOES

\*\*Propósito:\*\* Representa a hierarquia territorial portuguesa seguindo a classificação NUTS.

\*\*Estrutura:\*\*  
\`\`\`sql  
CREATE TABLE REGIOES (  
    NutsID VARCHAR(9) PRIMARY KEY,  
    region\_name VARCHAR(255) NOT NULL,  
    level\_ID INT NOT NULL,  
    ParentCodeID VARCHAR(9),  
    area\_km2 DECIMAL(10,2),  
      
    FOREIGN KEY (ParentCodeID) REFERENCES REGIOES(NutsID),  
    CHECK (level\_ID BETWEEN 0 AND 5),  
    INDEX idx\_level (level\_ID),  
    INDEX idx\_name (region\_name)  
);  
\`\`\`

\*\*Características Especiais:\*\*  
\- \*\*Auto-referencial:\*\* Uma região pode ser pai de outra região  
\- \*\*Hierárquica:\*\* 6 níveis (País → NUTS I → NUTS II → NUTS III → Concelho → Freguesia)  
\- \*\*Chave textual:\*\* NutsID é código alfanumérico oficial

\*\*Exemplo de Registos:\*\*  
\`\`\`  
NutsID: PT           | level\_ID: 0 | ParentCodeID: NULL    | region\_name: Portugal  
NutsID: PT11         | level\_ID: 2 | ParentCodeID: PT1     | region\_name: Norte  
NutsID: PT111        | level\_ID: 3 | ParentCodeID: PT11    | region\_name: Alto Minho  
NutsID: PT111XX      | level\_ID: 4 | ParentCodeID: PT111   | region\_name: \[Concelho\]  
\`\`\`

\---

\#\#\# 2.2 INCENDIOS

\*\*Propósito:\*\* Registo central de cada ocorrência de incêndio florestal.

\*\*Estrutura:\*\*  
\`\`\`sql  
CREATE TABLE INCENDIOS (  
    fire\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    NutsID VARCHAR(9) NOT NULL,  
    data\_inicio DATETIME NOT NULL,  
    data\_fim DATETIME,  
    duracao\_horas DECIMAL(6,2),  
    area\_ardida\_ha DECIMAL(10,2) NOT NULL,  
    causa ENUM('Natural', 'Negligência', 'Intencional', 'Desconhecida'),  
    ano INT NOT NULL,  
    mes INT NOT NULL,  
      
    FOREIGN KEY (NutsID) REFERENCES REGIOES(NutsID),  
    CHECK (data\_fim IS NULL OR data\_fim \>= data\_inicio),  
    CHECK (area\_ardida\_ha \>= 0),  
    CHECK (mes BETWEEN 1 AND 12),  
    INDEX idx\_data (data\_inicio),  
    INDEX idx\_regiao (NutsID),  
    INDEX idx\_ano\_mes (ano, mes)  
);  
\`\`\`

\*\*Campos Derivados:\*\*  
\- \`duracao\_horas\`: Calculado como \`(data\_fim \- data\_inicio) em horas\`  
\- \`ano\`: Extraído de \`data\_inicio\` para facilitar queries  
\- \`mes\`: Extraído de \`data\_inicio\` para análise sazonal

\*\*Características:\*\*  
\- \*\*Entidade central:\*\* Liga-se a todas as outras entidades  
\- \*\*Granularidade temporal:\*\* Datetime permite análise detalhada  
\- \*\*Causa categorizada:\*\* ENUM garante valores consistentes

\---

\#\#\# 2.3 VEGETACAO

\*\*Propósito:\*\* Tabela de referência de tipos de vegetação com classificação de inflamabilidade.

\*\*Estrutura:\*\*  
\`\`\`sql  
CREATE TABLE VEGETACAO (  
    vegetation\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    tipo\_vegetacao VARCHAR(100) NOT NULL UNIQUE,  
    inflammabilidade ENUM('Baixa', 'Média', 'Alta') NOT NULL,  
    descricao TEXT,  
      
    INDEX idx\_tipo (tipo\_vegetacao),  
    INDEX idx\_inflamm (inflammabilidade)  
);  
\`\`\`

\*\*Registos Típicos:\*\*  
\`\`\`sql  
INSERT INTO VEGETACAO VALUES  
(1, 'Pinheiro-bravo', 'Alta', 'Pinus pinaster \- Pinheiro marítimo, altamente resinoso'),  
(2, 'Eucalipto', 'Alta', 'Eucalyptus globulus, casca inflamável'),  
(3, 'Carvalho', 'Média', 'Quercus spp., folha caduca'),  
(4, 'Sobreiro', 'Baixa', 'Quercus suber, córtex espesso, retenção de humidade'),  
(5, 'Mato', 'Alta', 'Vegetação arbustiva e herbácea densa');  
\`\`\`

\*\*Características:\*\*  
\- \*\*Tabela de lookup:\*\* Pequena, estática, frequentemente referenciada  
\- \*\*Domínio fechado:\*\* Número limitado de tipos de vegetação  
\- \*\*Metadados:\*\* \`inflammabilidade\` permite análises de risco

\---

\#\#\# 2.4 INCENDIO\_VEGETACAO

\*\*Propósito:\*\* Tabela de junção que permite relação N:M entre incêndios e tipos de vegetação.

\*\*Estrutura:\*\*  
\`\`\`sql  
CREATE TABLE INCENDIO\_VEGETACAO (  
    fire\_veg\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    fire\_id INT NOT NULL,  
    vegetation\_id INT NOT NULL,  
    area\_afetada\_ha DECIMAL(10,2) NOT NULL,  
    percentagem\_area DECIMAL(5,2),  
      
    FOREIGN KEY (fire\_id) REFERENCES INCENDIOS(fire\_id) ON DELETE CASCADE,  
    FOREIGN KEY (vegetation\_id) REFERENCES VEGETACAO(vegetation\_id),  
    UNIQUE KEY unique\_fire\_veg (fire\_id, vegetation\_id),  
    CHECK (area\_afetada\_ha \>= 0),  
    CHECK (percentagem\_area BETWEEN 0 AND 100),  
    INDEX idx\_fire (fire\_id),  
    INDEX idx\_veg (vegetation\_id)  
);  
\`\`\`

\*\*Exemplo de Dados:\*\*  
\`\`\`  
Um incêndio de 100 ha pode ter:  
fire\_id: 12345 | vegetation\_id: 1 (Pinheiro) | area\_afetada\_ha: 60  | percentagem: 60%  
fire\_id: 12345 | vegetation\_id: 2 (Eucalipto) | area\_afetada\_ha: 30  | percentagem: 30%  
fire\_id: 12345 | vegetation\_id: 5 (Mato)      | area\_afetada\_ha: 10  | percentagem: 10%  
Total: 100 ha  
\`\`\`

\*\*Características:\*\*  
\- \*\*Permite múltiplas vegetações por incêndio:\*\* Um incêndio raramente afeta apenas um tipo  
\- \*\*Constraint de unicidade:\*\* Um incêndio não pode ter o mesmo tipo de vegetação duas vezes  
\- \*\*Campo calculado:\*\* \`percentagem\_area\` pode ser derivado mas armazenado para performance

\---

\#\#\# 2.5 METEOROLOGIA

\*\*Propósito:\*\* Armazena condições meteorológicas associadas a cada incêndio.

\*\*Estrutura:\*\*  
\`\`\`sql  
CREATE TABLE METEOROLOGIA (  
    weather\_id INT AUTO\_INCREMENT PRIMARY KEY,  
    fire\_id INT NOT NULL UNIQUE,  
    temperatura\_max DECIMAL(4,1),  
    humidade\_relativa DECIMAL(4,1),  
    velocidade\_vento\_kmh DECIMAL(5,1),  
    precipitacao\_mm DECIMAL(6,2),  
    indice\_fwi DECIMAL(5,2),  
      
    FOREIGN KEY (fire\_id) REFERENCES INCENDIOS(fire\_id) ON DELETE CASCADE,  
    CHECK (temperatura\_max BETWEEN \-10 AND 60),  
    CHECK (humidade\_relativa BETWEEN 0 AND 100),  
    CHECK (velocidade\_vento\_kmh \>= 0),  
    CHECK (precipitacao\_mm \>= 0),  
    CHECK (indice\_fwi \>= 0),  
    INDEX idx\_temp (temperatura\_max),  
    INDEX idx\_fwi (indice\_fwi)  
);  
\`\`\`

\*\*Campos Explicados:\*\*  
\- \`temperatura\_max\`: Temperatura máxima no dia do incêndio (°C)  
\- \`humidade\_relativa\`: Humidade média do ar (%)  
\- \`velocidade\_vento\_kmh\`: Velocidade média do vento (km/h)  
\- \`precipitacao\_mm\`: Precipitação acumulada (mm)  
\- \`indice\_fwi\`: Fire Weather Index \- indicador composto de risco

\*\*Características:\*\*  
\- \*\*Relação 1:1 com INCENDIOS:\*\* Cada incêndio tem no máximo um registo meteorológico  
\- \*\*UNIQUE constraint em fire\_id:\*\* Garante a cardinalidade 1:1  
\- \*\*Valores opcionais:\*\* Podem existir incêndios sem dados meteorológicos (especialmente históricos)

\---

\#\# 3\. Relações Detalhadas

\#\#\# 3.1 REGIOES → REGIOES (Auto-Referencial)

\*\*Tipo de Relação:\*\* 1:N hierárquica

\*\*Chaves:\*\*  
\- \*\*Chave Primária:\*\* \`NutsID\` (região filha)  
\- \*\*Chave Estrangeira:\*\* \`ParentCodeID\` → \`REGIOES(NutsID)\` (região pai)

\*\*Propósito:\*\*    
Implementa a estrutura hierárquica NUTS onde cada região (exceto o nível 0 \- País) pertence a uma região de nível superior.

\*\*Cardinalidade:\*\*  
\- Uma região pai pode ter \*\*0 a N\*\* regiões filhas  
\- Uma região filha tem \*\*0 ou 1\*\* região pai (0 apenas para o País)

\*\*Exemplo de Hierarquia:\*\*  
\`\`\`  
Portugal (PT) \- nivel 0 \- ParentCodeID: NULL  
  └─ Norte (PT11) \- nivel 2 \- ParentCodeID: PT1  
      └─ Alto Minho (PT111) \- nivel 3 \- ParentCodeID: PT11  
          └─ Arcos de Valdevez (PT111XX) \- nivel 4 \- ParentCodeID: PT111  
              └─ Arcos de Valdevez (S. Paio) \- nivel 5 \- ParentCodeID: PT111XX  
\`\`\`

\*\*Regra de Integridade:\*\*  
\`\`\`sql  
FOREIGN KEY (ParentCodeID) REFERENCES REGIOES(NutsID)  
ON DELETE RESTRICT  \-- Não permite apagar região com filhas  
ON UPDATE CASCADE   \-- Propaga mudanças de NutsID  
\`\`\`

\*\*Query Exemplo \- Listar Hierarquia:\*\*  
\`\`\`sql  
\-- Obter todos os concelhos de um distrito  
SELECT filho.NutsID, filho.region\_name  
FROM REGIOES pai  
JOIN REGIOES filho ON filho.ParentCodeID \= pai.NutsID  
WHERE pai.region\_name \= 'Aveiro' AND pai.level\_ID \= 3  
  AND filho.level\_ID \= 4;

\-- Caminho completo de uma região até Portugal  
WITH RECURSIVE hierarquia AS (  
    SELECT NutsID, region\_name, ParentCodeID, 1 as nivel  
    FROM REGIOES  
    WHERE NutsID \= 'PT111XX'  \-- Concelho específico  
      
    UNION ALL  
      
    SELECT r.NutsID, r.region\_name, r.ParentCodeID, h.nivel \+ 1  
    FROM REGIOES r  
    JOIN hierarquia h ON r.NutsID \= h.ParentCodeID  
)  
SELECT \* FROM hierarquia ORDER BY nivel DESC;  
\`\`\`

\*\*Justificação:\*\*    
Esta estrutura auto-referencial permite:  
\- Consultas de agregação flexíveis (concelho → distrito → região)  
\- Navegação bidirecional na hierarquia  
\- Manutenção simples quando limites administrativos mudam  
\- Extensibilidade para novos níveis hierárquicos

\---

\#\#\# 3.2 INCENDIOS → REGIOES

\*\*Tipo de Relação:\*\* N:1 (Muitos-para-Um)

\*\*Chaves:\*\*  
\- \*\*Chave Estrangeira:\*\* \`INCENDIOS.NutsID\` → \`REGIOES.NutsID\`

\*\*Propósito:\*\*    
Cada incêndio ocorre numa localização geográfica específica (tipicamente concelho).

\*\*Cardinalidade:\*\*  
\- Uma região pode ter \*\*0 a N\*\* incêndios  
\- Um incêndio ocorre em \*\*exatamente 1\*\* região

\*\*Nota sobre Localização:\*\*    
Embora alguns incêndios grandes possam afetar múltiplos concelhos, para simplificação atribuímos cada incêndio ao concelho de origem/alerta inicial.

\*\*Regra de Integridade:\*\*  
\`\`\`sql  
FOREIGN KEY (NutsID) REFERENCES REGIOES(NutsID)  
ON DELETE RESTRICT  \-- Não permite apagar região com incêndios  
ON UPDATE CASCADE   \-- Propaga mudanças de código NUTS  
\`\`\`

\*\*NOT NULL:\*\* \`INCENDIOS.NutsID\` é obrigatório \- todo incêndio tem localização.

\*\*Query Exemplo \- Análise Regional:\*\*  
\`\`\`sql  
\-- Top 10 concelhos com mais incêndios  
SELECT   
    r.region\_name,  
    COUNT(i.fire\_id) as num\_incendios,  
    SUM(i.area\_ardida\_ha) as area\_total\_ha,  
    AVG(i.area\_ardida\_ha) as area\_media\_ha  
FROM INCENDIOS i  
JOIN REGIOES r ON i.NutsID \= r.NutsID  
WHERE r.level\_ID \= 4  \-- Concelhos  
GROUP BY r.NutsID, r.region\_name  
ORDER BY num\_incendios DESC  
LIMIT 10;

\-- Incêndios por distrito (agregação via hierarquia)  
SELECT   
    distrito.region\_name as distrito,  
    COUNT(i.fire\_id) as total\_incendios,  
    SUM(i.area\_ardida\_ha) as area\_total  
FROM INCENDIOS i  
JOIN REGIOES concelho ON i.NutsID \= concelho.NutsID  
JOIN REGIOES distrito ON concelho.ParentCodeID \= distrito.NutsID  
WHERE concelho.level\_ID \= 4 AND distrito.level\_ID \= 3  
GROUP BY distrito.NutsID, distrito.region\_name;  
\`\`\`

\*\*Justificação:\*\*    
\- Permite análises espaciais (hotspots geográficos)  
\- Facilita agregações multi-nível (freguesia → concelho → distrito)  
\- Suporta cálculos de densidade (incêndios por km²)  
\- Essencial para priorização de recursos de combate

\---

\#\#\# 3.3 INCENDIO\_VEGETACAO → INCENDIOS

\*\*Tipo de Relação:\*\* N:1 (Muitos-para-Um)

\*\*Chaves:\*\*  
\- \*\*Chave Estrangeira:\*\* \`INCENDIO\_VEGETACAO.fire\_id\` → \`INCENDIOS.fire\_id\`

\*\*Propósito:\*\*    
Cada registo de vegetação afetada pertence a um incêndio específico.

\*\*Cardinalidade:\*\*  
\- Um incêndio pode ter \*\*1 a N\*\* registos de vegetação afetada  
\- Cada registo de vegetação afetada pertence a \*\*exatamente 1\*\* incêndio

\*\*Regra de Integridade:\*\*  
\`\`\`sql  
FOREIGN KEY (fire\_id) REFERENCES INCENDIOS(fire\_id)  
ON DELETE CASCADE   \-- Se incêndio é apagado, apagar registos de vegetação  
ON UPDATE CASCADE  
\`\`\`

\*\*NOT NULL:\*\* \`fire\_id\` é obrigatório \- todo registo de vegetação está ligado a um incêndio.

\*\*Constraint Adicional:\*\*  
\`\`\`sql  
UNIQUE KEY unique\_fire\_veg (fire\_id, vegetation\_id)  
\-- Um incêndio não pode ter dois registos para o mesmo tipo de vegetação  
\`\`\`

\*\*Query Exemplo:\*\*  
\`\`\`sql  
\-- Vegetação afetada num incêndio específico  
SELECT   
    v.tipo\_vegetacao,  
    iv.area\_afetada\_ha,  
    iv.percentagem\_area,  
    v.inflammabilidade  
FROM INCENDIO\_VEGETACAO iv  
JOIN VEGETACAO v ON iv.vegetation\_id \= v.vegetation\_id  
WHERE iv.fire\_id \= 12345  
ORDER BY iv.area\_afetada\_ha DESC;

\-- Verificar consistência: soma de áreas \= área total do incêndio  
SELECT   
    i.fire\_id,  
    i.area\_ardida\_ha as area\_total,  
    SUM(iv.area\_afetada\_ha) as soma\_vegetacao,  
    i.area\_ardida\_ha \- SUM(iv.area\_afetada\_ha) as diferenca  
FROM INCENDIOS i  
LEFT JOIN INCENDIO\_VEGETACAO iv ON i.fire\_id \= iv.fire\_id  
GROUP BY i.fire\_id, i.area\_ardida\_ha  
HAVING ABS(diferenca) \> 0.01;  \-- Encontrar inconsistências  
\`\`\`

\*\*Justificação:\*\*  
\- CASCADE DELETE apropriado: registos de vegetação não fazem sentido sem o incêndio pai  
\- Evita dados órfãos na base de dados  
\- Simplifica manutenção (apagar incêndio remove automaticamente todos os detalhes)

\---

\#\#\# 3.4 INCENDIO\_VEGETACAO → VEGETACAO

\*\*Tipo de Relação:\*\* N:1 (Muitos-para-Um)

\*\*Chaves:\*\*  
\- \*\*Chave Estrangeira:\*\* \`INCENDIO\_VEGETACAO.vegetation\_id\` → \`VEGETACAO.vegetation\_id\`

\*\*Propósito:\*\*    
Cada registo de vegetação afetada refere-se a um tipo específico de vegetação da tabela de referência.

\*\*Cardinalidade:\*\*  
\- Um tipo de vegetação pode aparecer em \*\*0 a N\*\* incêndios  
\- Cada registo de vegetação afetada refere \*\*exatamente 1\*\* tipo de vegetação

\*\*Regra de Integridade:\*\*  
\`\`\`sql  
FOREIGN KEY (vegetation\_id) REFERENCES VEGETACAO(vegetation\_id)  
ON DELETE RESTRICT  \-- Não permite apagar tipo usado em incêndios  
ON UPDATE CASCADE  
\`\`\`

\*\*NOT NULL:\*\* \`vegetation\_id\` é obrigatório.

\*\*Query Exemplo:\*\*  
\`\`\`sql  
\-- Tipos de vegetação mais afetados  
SELECT   
    v.tipo\_vegetacao,  
    v.inflammabilidade,  
    COUNT(DISTINCT iv.fire\_id) as num\_incendios\_afetaram,  
    SUM(iv.area\_afetada\_ha) as area\_total\_ha,  
    AVG(iv.area\_afetada\_ha) as area\_media\_ha  
FROM VEGETACAO v  
JOIN INCENDIO\_VEGETACAO iv ON v.vegetation\_id \= iv.vegetation\_id  
GROUP BY v.vegetation\_id, v.tipo\_vegetacao, v.inflammabilidade  
ORDER BY area\_total\_ha DESC;

\-- Relação inflamabilidade vs. área ardida  
SELECT   
    v.inflammabilidade,  
    COUNT(DISTINCT iv.fire\_id) as num\_incendios,  
    AVG(iv.area\_afetada\_ha) as area\_media\_por\_incendio  
FROM VEGETACAO v  
JOIN INCENDIO\_VEGETACAO iv ON v.vegetation\_id \= iv.vegetation\_id  
GROUP BY v.inflammabilidade;  
\`\`\`

\*\*Justificação:\*\*  
\- RESTRICT apropriado: tipos de vegetação são dados de referência, não devem ser apagados se em uso  
\- Preserva integridade histórica  
\- Permite análises de longo prazo sobre mesmos tipos

\---

\#\#\# 3.5 METEOROLOGIA → INCENDIOS

\*\*Tipo de Relação:\*\* 1:1 (Um-para-Um)

\*\*Chaves:\*\*  
\- \*\*Chave Estrangeira:\*\* \`METEOROLOGIA.fire\_id\` → \`INCENDIOS.fire\_id\`  
\- \*\*UNIQUE constraint\*\* em \`METEOROLOGIA.fire\_id\`

\*\*Propósito:\*\*    
Associa condições meteorológicas específicas a cada incêndio.

\*\*Cardinalidade:\*\*  
\- Um incêndio pode ter \*\*0 ou 1\*\* registo meteorológico  
\- Um registo meteorológico pertence a \*\*exatamente 1\*\* incêndio

\*\*Nota:\*\* Relação é opcional (0 ou 1\) porque:  
\- Alguns incêndios históricos podem não ter dados meteorológicos  
\- Estações meteorológicas podem estar offline  
\- Dados ainda por integrar (TM3 em progresso)

\*\*Regra de Integridade:\*\*  
\`\`\`sql  
FOREIGN KEY (fire\_id) REFERENCES INCENDIOS(fire\_id)  
ON DELETE CASCADE   \-- Se incêndio é apagado, apagar dados meteorológicos  
ON UPDATE CASCADE

UNIQUE KEY (fire\_id)  \-- Garante cardinalidade 1:1  
\`\`\`

\*\*Query Exemplo:\*\*  
\`\`\`sql  
\-- Correlação temperatura vs. área ardida  
SELECT   
    CASE   
        WHEN m.temperatura\_max \< 25 THEN 'Baixa (\<25°C)'  
        WHEN m.temperatura\_max \< 35 THEN 'Moderada (25-35°C)'  
        ELSE 'Alta (\>35°C)'  
    END as faixa\_temperatura,  
    COUNT(i.fire\_id) as num\_incendios,  
    AVG(i.area\_ardida\_ha) as area\_media\_ardida,  
    MAX(i.area\_ardida\_ha) as area\_maxima\_ardida  
FROM INCENDIOS i  
JOIN METEOROLOGIA m ON i.fire\_id \= m.fire\_id  
GROUP BY faixa\_temperatura;

\-- Incêndios em condições de alto risco (FWI \> 50\)  
SELECT   
    i.fire\_id,  
    i.data\_inicio,  
    r.region\_name,  
    i.area\_ardida\_ha,  
    m.temperatura\_max,  
    m.humidade\_relativa,  
    m.velocidade\_vento\_kmh,  
    m.indice\_fwi  
FROM INCENDIOS i  
JOIN METEOROLOGIA m ON i.fire\_id \= m.fire\_id  
JOIN REGIOES r ON i.NutsID \= r.NutsID  
WHERE m.indice\_fwi \> 50  
ORDER BY m.indice\_fwi DESC;  
\`\`\`

\*\*Justificação:\*\*  
\- Cardinalidade 1:1 apropriada: condições meteorológicas são específicas a cada incêndio  
\- CASCADE DELETE mantém consistência  
\- Estrutura permite análise de correlação clima-incêndio

\---

\#\# 4\. Justificação de Design

\#\#\# 4.1 Porque 5 Entidades?

\*\*Separação de Responsabilidades:\*\*

1\. \*\*REGIOES\*\* \- Dimensão espacial  
   \- Dados geográficos estáveis  
   \- Reutilizável em múltiplos contextos  
   \- Hierarquia permite agregações flexíveis

2\. \*\*INCENDIOS\*\* \- Facto central  
   \- Eventos que ocorrem no tempo  
   \- Entidade mais dinâmica (novos registos frequentes)  
   \- Hub que liga todas as dimensões

3\. \*\*VEGETACAO\*\* \- Dimensão de classificação  
   \- Dados de referência estáticos  
   \- Pequena tabela de lookup  
   \- Facilita manutenção (e.g., reclassificar inflamabilidade)

4\. \*\*INCENDIO\_VEGETACAO\*\* \- Tabela de factos detalhada  
   \- Resolve relação N:M  
   \- Armazena métricas específicas (área afetada)  
   \- Permite granularidade na análise

5\. \*\*METEOROLOGIA\*\* \- Dimensão contextual  
   \- Dados ambientais associados ao evento  
   \- Separada para permitir ausência de dados  
   \- Facilita análises de correlação

\#\#\# 4.2 Alternativas Rejeitadas

\*\*Alternativa 1: Tudo numa tabela\*\*  
\`\`\`sql  
\--  Design desnormalizado (rejeitado)  
CREATE TABLE TUDO (  
    fire\_id INT,  
    concelho VARCHAR(255),  
    distrito VARCHAR(255),  
    region\_name VARCHAR(255),  \-- Redundante\!  
    data\_inicio DATE,  
    area\_ardida DECIMAL,  
    tipo\_vegetacao1 VARCHAR(100),  \-- E se houver mais tipos?  
    area\_veg1 DECIMAL,  
    tipo\_vegetacao2 VARCHAR(100),  
    area\_veg2 DECIMAL,  
    temperatura DECIMAL,  
    humidade DECIMAL,  
    ...  
);  
\`\`\`

\*\*Problemas:\*\*  
\-  Massive redundância (nomes de regiões repetidos milhares de vezes)  
\-  Anomalias de atualização (mudar nome de concelho \= milhares de updates)  
\-  Limite artificial no número de tipos de vegetação  
\-  Muitos campos NULL quando incêndio afeta só 1-2 tipos  
\-  Não suporta hierarquia regional

\---

\*\*Alternativa 2: Vegetação como campo JSON\*\*  
\`\`\`sql  
\--  Usar JSON para vegetação (rejeitado)  
CREATE TABLE INCENDIOS (  
    fire\_id INT,  
    ...  
    vegetacao\_afetada JSON  \-- {"Pinheiro": 50, "Eucalipto": 30}  
);  
\`\`\`

\*\*Problemas:\*\*  
\-  Difícil fazer queries (WHERE, GROUP BY não funcionam bem)  
\-  Sem validação de tipos de vegetação  
\-  Sem foreign keys (integridade não garantida)  
\-  Performance pobre em agregações

\---

\#\#\# 4.3 Vantagens do Design Escolhido

 \*\*Normalização (3NF):\*\*  
\- Cada facto armazenado uma vez  
\- Sem redundâncias  
\- Atualizações simples e consistentes

 \*\*Flexibilidade:\*\*  
\- Fácil adicionar novos tipos de vegetação  
\- Incêndios podem afetar N tipos de vegetação  
\- Suporta ausência de dados meteorológicos

 \*\*Performance:\*\*  
\- Índices apropriados em chaves estrangeiras  
\- Queries de agregação eficientes  
\- Joins optimizáveis pelo MySQL

 \*\*Integridade:\*\*  
\- Foreign keys garantem consistência  
\- Constraints CHECK validam valores  
\- Cascade deletes mantêm limpeza

 \*\*Manutenibilidade:\*\*  
\- Estrutura clara e intuitiva  
\- Fácil de estender (adicionar campos)  
\- Bem documentada

\---

\#\# 5\. Regras de Integridade

\#\#\# 5.1 Integridade Referencial

\*\*Todas as chaves estrangeiras são obrigatórias (NOT NULL) exceto:\*\*  
\- \`REGIOES.ParentCodeID\` \- NULL para o nível 0 (País)

\*\*Políticas de DELETE:\*\*

| Relação | ON DELETE | Justificação |  
|---------|-----------|--------------|  
| REGIOES → REGIOES (pai) | RESTRICT | Não apagar região com filhas |  
| INCENDIOS → REGIOES | RESTRICT | Preservar histórico regional |  
| INCENDIO\_VEG → INCENDIOS | CASCADE | Dados dependentes do incêndio |  
| INCENDIO\_VEG → VEGETACAO | RESTRICT | Preservar dados de referência |  
| METEOROLOGIA → INCENDIOS | CASCADE | Dados contextuais do incêndio |

\*\*Políticas de UPDATE:\*\*  
\- Todas as relações: \*\*CASCADE\*\* \- propagam mudanças de ID

\---

\#\#\# 5.2 Constraints de Domínio

\*\*REGIOES:\*\*  
\`\`\`sql  
CHECK (level\_ID BETWEEN 0 AND 5\)  \-- Níveis válidos NUTS  
CHECK (area\_km2 IS NULL OR area\_km2 \> 0\)  \-- Área positiva  
\`\`\`

\*\*INCENDIOS:\*\*  
\`\`\`sql  
CHECK (data\_fim IS NULL OR data\_fim \>= data\_inicio)  \-- Fim após início  
CHECK (area\_ardida\_ha \>= 0\)  \-- Área não-negativa  
CHECK (duracao\_horas IS NULL OR duracao\_horas \>= 0\)  \-- Duração positiva  
CHECK (ano BETWEEN 2000 AND 2100\)  \-- Anos razoáveis  
CHECK (mes BETWEEN 1 AND 12\)  \-- Mês válido  
\`\`\`

\*\*INCENDIO\_VEGETACAO:\*\*  
\`\`\`sql  
CHECK (area\_afetada\_ha \>= 0\)  \-- Área não-negativa  
CHECK (percentagem\_area IS NULL OR percentagem\_area BETWEEN 0 AND 100\)  \-- % válida  
UNIQUE (fire\_id, vegetation\_id)  \-- Não duplicar tipo no mesmo incêndio  
\`\`\`

\*\*METEOROLOGIA:\*\*  
\`\`\`sql  
CHECK (temperatura\_max BETWEEN \-10 AND 60\)  \-- Temperaturas realistas para Portugal  
CHECK (humidade\_relativa BETWEEN 0 AND 100\)  \-- Humidade válida  
CHECK (velocidade\_vento\_kmh \>= 0\)  \-- Velocidade não-negativa  
CHECK (precipitacao\_mm \>= 0\)  \-- Precipitação não-negativa  
CHECK (indice\_fwi IS NULL OR indice\_fwi \>= 0\)  \-- FWI positivo  
\`\`\`

\---

\#\#\# 5.3 Regras de Negócio

\*\*Regra 1: Consistência de Área\*\*  
\`\`\`sql  
\-- Área em INCENDIO\_VEGETACAO não deve exceder área total do incêndio  
CREATE TRIGGER check\_area\_veget\</parameter\>  
\<parameter name="new\_str"\>\*\*Regra 1: Consistência de Área\*\*  
\`\`\`sql  
\-- A soma de áreas em INCENDIO\_VEGETACAO deve aproximadamente igualar a área total do incêndio  
\-- Verificação via query (não trigger, para flexibilidade):  
SELECT   
    i.fire\_id,  
    i.area\_ardida\_ha as area\_total,  
    COALESCE(SUM(iv.area\_afetada\_ha), 0\) as soma\_vegetacao,  
    ABS(i.area\_ardida\_ha \- COALESCE(SUM(iv.area\_afetada\_ha), 0)) as diferenca  
FROM INCENDIOS i  
LEFT JOIN INCENDIO\_VEGETACAO iv ON i.fire\_id \= iv.fire\_id  
GROUP BY i.fire\_id  
HAVING diferenca \> 1.0;  \-- Tolerância de 1 ha para erros de arredondamento  
\`\`\`

\*\*Regra 2: Data de Incêndio vs. Ano/Mês\*\*  
\`\`\`sql  
\-- Os campos ano e mes devem corresponder a data\_inicio  
\-- Implementado via trigger ou validação na aplicação:  
DELIMITER //  
CREATE TRIGGER validate\_fire\_date BEFORE INSERT ON INCENDIOS  
FOR EACH ROW  
BEGIN  
    IF NEW.ano \!= YEAR(NEW.data\_inicio) THEN  
        SIGNAL SQLSTATE '45000'   
        SET MESSAGE\_TEXT \= 'Ano não corresponde à data de início';  
    END IF;  
    IF NEW.mes \!= MONTH(NEW.data\_inicio) THEN  
        SIGNAL SQLSTATE '45000'   
        SET MESSAGE\_TEXT \= 'Mês não corresponde à data de início';  
    END IF;  
END //  
DELIMITER ;  
\`\`\`

\*\*Regra 3: Hierarquia Regional Válida\*\*  
\`\`\`sql  
\-- Uma região só pode ter como pai uma região de nível imediatamente superior  
\-- Verificação:  
SELECT r1.NutsID, r1.level\_ID, r2.NutsID, r2.level\_ID  
FROM REGIOES r1  
JOIN REGIOES r2 ON r1.ParentCodeID \= r2.NutsID  
WHERE r2.level\_ID \!= r1.level\_ID \- 1  
  AND r1.level\_ID \> 0;  
\-- Deve retornar 0 linhas  
\`\`\`

\*\*Regra 4: Incêndio em Região de Nível Apropriado\*\*  
\`\`\`sql  
\-- Incêndios devem ser associados preferencialmente a concelhos (level 4\)  
\-- Alerta para revisão se não for o caso:  
SELECT i.fire\_id, r.region\_name, r.level\_ID  
FROM INCENDIOS i  
JOIN REGIOES r ON i.NutsID \= r.NutsID  
WHERE r.level\_ID \!= 4;  
\`\`\`

\---

\#\#\# 5.4 Índices para Performance

\*\*Índices Primários (Chaves Primárias):\*\*  
\- Automaticamente criados em todas as PKs

\*\*Índices Secundários Essenciais:\*\*  
\`\`\`sql  
\-- REGIOES  
CREATE INDEX idx\_regioes\_level ON REGIOES(level\_ID);  
CREATE INDEX idx\_regioes\_parent ON REGIOES(ParentCodeID);  
CREATE INDEX idx\_regioes\_name ON REGIOES(region\_name);

\-- INCENDIOS  
CREATE INDEX idx\_incendios\_nuts ON INCENDIOS(NutsID);  
CREATE INDEX idx\_incendios\_data ON INCENDIOS(data\_inicio);  
CREATE INDEX idx\_incendios\_ano\_mes ON INCENDIOS(ano, mes);  
CREATE INDEX idx\_incendios\_causa ON INCENDIOS(causa);

\-- INCENDIO\_VEGETACAO  
CREATE INDEX idx\_iv\_fire ON INCENDIO\_VEGETACAO(fire\_id);  
CREATE INDEX idx\_iv\_veg ON INCENDIO\_VEGETACAO(vegetation\_id);

\-- METEOROLOGIA  
CREATE INDEX idx\_meteo\_temp ON METEOROLOGIA(temperatura\_max);  
CREATE INDEX idx\_meteo\_fwi ON METEOROLOGIA(indice\_fwi);

\-- VEGETACAO  
CREATE INDEX idx\_veg\_tipo ON VEGETACAO(tipo\_vegetacao);  
CREATE INDEX idx\_veg\_inflamm ON VEGETACAO(inflammabilidade);  
\`\`\`

\*\*Justificação dos Índices:\*\*  
\- Campos em JOINs frequentes (todas as FKs)  
\- Campos em WHERE clauses (data, causa, level\_ID)  
\- Campos em GROUP BY (ano, mes, NutsID)  
\- Campos em ORDER BY (data, área)

\---

\#\# 6\. Diagrama Textual Completo  
\`\`\`  
┌─────────────────────────────────────────────────────────────────────┐  
│                    SISTEMA DE GESTÃO DE INCÊNDIOS                   │  
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐  
│    REGIOES       │◄────────────┐ Auto-referencial  
├──────────────────┤             │ Hierarquia NUTS  
│ NutsID (PK)      │─────────────┘ 1:N (pai:filhos)  
│ region\_name      │  
│ level\_ID         │ 0=País, 1=NUTS I, 2=NUTS II,   
│ ParentCodeID (FK)│ 3=NUTS III, 4=Concelho, 5=Freguesia  
│ area\_km2         │  
└──────────────────┘  
         │  
         │ 1  
         │  
         │ N  
         ▼  
┌──────────────────┐         1:1          ┌────────────────────┐  
│   INCENDIOS      │◄─────────────────────┤  METEOROLOGIA      │  
├──────────────────┤    (opcional)        ├────────────────────┤  
│ fire\_id (PK)     │                      │ weather\_id (PK)    │  
│ NutsID (FK)      │                      │ fire\_id (FK,UNIQUE)│  
│ data\_inicio      │                      │ temperatura\_max    │  
│ data\_fim         │                      │ humidade\_relativa  │  
│ duracao\_horas    │                      │ velocidade\_vento   │  
│ area\_ardida\_ha   │                      │ precipitacao\_mm    │  
│ causa            │                      │ indice\_fwi         │  
│ ano              │                      └────────────────────┘  
│ mes              │  
└──────────────────┘  
         │  
         │ 1  
         │  
         │ N  
         ▼  
┌───────────────────────┐  
│ INCENDIO\_VEGETACAO    │ Tabela de Junção N:M  
├───────────────────────┤  
│ fire\_veg\_id (PK)      │  
│ fire\_id (FK)          │─────┐  
│ vegetation\_id (FK)    │     │  
│ area\_afetada\_ha       │     │  
│ percentagem\_area      │     │  
└───────────────────────┘     │  
                              │  
                              │ N  
                              │  
                              │ 1  
                              ▼  
                    ┌──────────────────┐  
                    │   VEGETACAO      │ Tabela de Referência  
                    ├──────────────────┤  
                    │ vegetation\_id(PK)│  
                    │ tipo\_vegetacao   │  
                    │ inflammabilidade │  
                    │ descricao        │  
                    └──────────────────┘

LEGENDA:  
─── Relação (FK)  
◄── Direção da relação  
PK  Chave Primária  
FK  Chave Estrangeira  
1:N Cardinalidade Um-para-Muitos  
N:M Cardinalidade Muitos-para-Muitos (via tabela de junção)  
\`\`\`

\---

\#\# 7\. Queries de Validação de Integridade

\#\#\# 7.1 Verificar Todas as FKs  
\`\`\`sql  
\-- Verificar integridade INCENDIOS → REGIOES  
SELECT COUNT(\*) as incendios\_orfaos  
FROM INCENDIOS i  
LEFT JOIN REGIOES r ON i.NutsID \= r.NutsID  
WHERE r.NutsID IS NULL;  
\-- Deve retornar 0

\-- Verificar integridade INCENDIO\_VEGETACAO → INCENDIOS  
SELECT COUNT(\*) as registos\_orfaos  
FROM INCENDIO\_VEGETACAO iv  
LEFT JOIN INCENDIOS i ON iv.fire\_id \= i.fire\_id  
WHERE i.fire\_id IS NULL;  
\-- Deve retornar 0

\-- Verificar integridade INCENDIO\_VEGETACAO → VEGETACAO  
SELECT COUNT(\*) as registos\_orfaos  
FROM INCENDIO\_VEGETACAO iv  
LEFT JOIN VEGETACAO v ON iv.vegetation\_id \= v.vegetation\_id  
WHERE v.vegetation\_id IS NULL;  
\-- Deve retornar 0

\-- Verificar integridade METEOROLOGIA → INCENDIOS  
SELECT COUNT(\*) as registos\_orfaos  
FROM METEOROLOGIA m  
LEFT JOIN INCENDIOS i ON m.fire\_id \= i.fire\_id  
WHERE i.fire\_id IS NULL;  
\-- Deve retornar 0

\-- Verificar integridade REGIOES → REGIOES (auto-referencial)  
SELECT COUNT(\*) as regioes\_orfaos  
FROM REGIOES r1  
LEFT JOIN REGIOES r2 ON r1.ParentCodeID \= r2.NutsID  
WHERE r1.ParentCodeID IS NOT NULL   
  AND r2.NutsID IS NULL;  
\-- Deve retornar 0 ou 1 (o 1 órfão conhecido documentado)  
\`\`\`

\#\#\# 7.2 Verificar Cardinalidades  
\`\`\`sql  
\-- Verificar cardinalidade 1:1 METEOROLOGIA-INCENDIOS  
SELECT fire\_id, COUNT(\*) as num\_registos  
FROM METEOROLOGIA  
GROUP BY fire\_id  
HAVING COUNT(\*) \> 1;  
\-- Deve retornar 0 linhas

\-- Verificar uniqueness em INCENDIO\_VEGETACAO  
SELECT fire\_id, vegetation\_id, COUNT(\*) as duplicados  
FROM INCENDIO\_VEGETACAO  
GROUP BY fire\_id, vegetation\_id  
HAVING COUNT(\*) \> 1;  
\-- Deve retornar 0 linhas  
\`\`\`

\#\#\# 7.3 Estatísticas de Relações  
\`\`\`sql  
\-- Estatísticas gerais do sistema  
SELECT   
    'REGIOES' as tabela,  
    COUNT(\*) as total\_registos,  
    COUNT(ParentCodeID) as com\_pai,  
    COUNT(\*) \- COUNT(ParentCodeID) as sem\_pai  
FROM REGIOES

UNION ALL

SELECT   
    'INCENDIOS',  
    COUNT(\*),  
    COUNT(NutsID),  
    COUNT(\*) \- COUNT(NutsID)  
FROM INCENDIOS

UNION ALL

SELECT   
    'METEOROLOGIA',  
    COUNT(\*),  
    COUNT(fire\_id),  
    0  
FROM METEOROLOGIA

UNION ALL

SELECT   
    'INCENDIO\_VEGETACAO',  
    COUNT(\*),  
    COUNT(fire\_id),  
    COUNT(\*) \- COUNT(fire\_id)  
FROM INCENDIO\_VEGETACAO

UNION ALL

SELECT   
    'VEGETACAO',  
    COUNT(\*),  
    COUNT(\*),  
    0  
FROM VEGETACAO;  
\`\`\`

\---

\#\# 8\. Conclusão

\#\#\# 8.1 Resumo das Relações

O sistema implementa \*\*5 relações principais\*\*:

1\. \*\*REGIOES ↔ REGIOES\*\* (1:N, auto-referencial) \- Hierarquia administrativa  
2\. \*\*INCENDIOS → REGIOES\*\* (N:1) \- Localização geográfica  
3\. \*\*INCENDIO\_VEGETACAO → INCENDIOS\*\* (N:1) \- Detalhes de vegetação afetada  
4\. \*\*INCENDIO\_VEGETACAO → VEGETACAO\*\* (N:1) \- Classificação de vegetação  
5\. \*\*METEOROLOGIA → INCENDIOS\*\* (1:1) \- Condições meteorológicas

\#\#\# 8.2 Pontos Fortes do Design

 \*\*Normalização:\*\* 3NF alcançada, sem redundâncias    
 \*\*Integridade:\*\* FKs e constraints garantem consistência    
 \*\*Flexibilidade:\*\* Suporta N vegetações por incêndio    
 \*\*Performance:\*\* Índices apropriados para queries comuns    
 \*\*Manutenibilidade:\*\* Estrutura clara e bem documentada    
 \*\*Escalabilidade:\*\* Fácil adicionar novos dados ou dimensões  

\#\#\# 8.3 Próximos Passos

1\. Implementar schema SQL completo  
2\. Criar triggers para regras de negócio  
3\. Popular com dados reais  
4\. Testar queries de análise (Q1-Q7)  
5\. Otimizar índices baseado em uso real  
6\. Criar views para queries complexas frequentes

\---

\*\*Documento Preparado por:\*\* TM1 (Cristiana Chainho)    
\*\*Data:\*\* 26 Dezembro 2025    
\*\*Versão:\*\* 1.0    
\*\*Status:\*\*  Completo e Pronto para Implementação

CREATE TRIGGER check\_area\_veget  
