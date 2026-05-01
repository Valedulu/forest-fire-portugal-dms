Projeto: Sistema de Gestão de Incêndios Florestais \- Portugal  
Propósito: Instruções passo-a-passo para reproduzir a recolha de dados  
Última Atualização: 26 Dezembro 2025

Índice

Download de Dados de Incêndios  
Exportação de Dados Regionais  
Recolha de Dados Meteorológicos  
Configuração de Dados de Vegetação  
Validação de Dados

1\. Download de Dados de Incêndios  
1.1 Central de Dados Portugal (Fonte Primária)  
Pré-requisitos:

Navegador web  
\~50 MB de espaço livre em disco  
Pasta de destino: original\_data/fires/

Passos:

Aceder ao website

   URL: http://centraldedados.pt/incendios/

Navegar para downloads de dados

Procurar secção "Dados" ou "Downloads"  
Selecionar dataset "Incêndios Florestais"

Selecionar período temporal

Escolher anos: 2015 a 2024 (inclusive)  
Se ficheiros por ano individual, descarregar cada:

incendios\_2015.csv  
incendios\_2016.csv  
...  
incendios\_2024.csv

Formato de download

Selecionar formato CSV (não XLS ou JSON)  
Codificação de caracteres: UTF-8  
Delimitador: vírgula (,)

Guardar ficheiros

bash   \# Criar estrutura de diretórios  
   mkdir \-p original\_data/fires/  
     
   \# Guardar ficheiros com convenção de nomenclatura  
   original\_data/fires/incendios\_2015.csv  
   original\_data/fires/incendios\_2016.csv  
   ...  
   original\_data/fires/incendios\_2024.csv  
\`\`\`

6\. \*\*Verificar download\*\*  
   \- Verificar tamanhos de ficheiro (devem ser 5-15 MB cada)  
   \- Abrir em editor de texto para verificar formato CSV  
   \- Confirmar presença de cabeçalhos

\*\*Campos de Dados Esperados:\*\*  
\- Distrito/Município  
\- Data de início do incêndio  
\- Data de fim do incêndio  
\- Área ardida (ha)  
\- Causa do incêndio  
\- Metadados adicionais

\*\*Estado:\*\*  Concluído por TM2 em 21 Dezembro 2025

\---

\#\#\# 1.2 dados.gov.pt (Fonte de Validação)

\*\*Para referência/validação:\*\*

1\. \*\*Aceder ao portal\*\*  
\`\`\`  
   URL: https://dados.gov.pt/

Pesquisar

Termo de pesquisa: "incêndios florestais ICNF"  
Ou: "Cross-Forest"

Descarregar dataset

Selecionar dataset Cross-Forest  
Descarregar CSV completo  
Guardar em: original\_data/fires/cross\_forest\_validation.csv

Nota: Esta fonte usada por TM2 para validação cruzada da Central de Dados  
Estado: Concluído por TM2 (121k registos)

2\. Exportação de Dados Regionais  
2.1 Exportar da Base de Dados dms\_INE  
Pré-requisitos:

Acesso à base de dados dms\_INE  
Cliente MySQL (linha de comandos ou GUI)  
Permissões SELECT na tabela region

Método A: Usando DBeaver (GUI) \- RECOMENDADO

Conectar à base de dados

Abrir DBeaver  
Conexão: dms\_INE  
Host: \[seu\_host\]  
Username: \[seu\_username\]  
Password: \[sua\_password\]

Navegar até à tabela

Expandir dms\_INE → Bancos de dados → Tabelas  
Encontrar tabela region

Exportar dados

Botão direito na tabela region  
Selecionar "Export Data..." ou "Exportar dados..."  
Formato: CSV  
Configurações:

Include table header (incluir cabeçalhos)  
Delimiter: , (vírgula)  
Encoding: UTF-8

Guardar como: original\_data/regions/regions\_dms\_INE.csv

OU usar query SQL:  
sqlSELECT   
    NutsID,  
    ParentCodeID,  
    level\_ID,  
    region\_name  
FROM region  
ORDER BY level\_ID, region\_name;  
Depois:

Executar query (Ctrl+Enter)  
Botão direito nos resultados → "Export Data..."  
Seguir passos acima

Método B: Usando MySQL Linha de Comandos  
bash\# Conectar à base de dados  
mysql \-u \[username\] \-p dms\_INE

\# Executar query de exportação  
SELECT   
    NutsID,  
    ParentCodeID,  
    level\_ID,  
    region\_name  
INTO OUTFILE '/tmp/regions\_export.csv'  
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'  
LINES TERMINATED BY '\\n'  
FROM region  
ORDER BY level\_ID, region\_name;

\# Sair do MySQL  
exit;

\# Mover ficheiro  
mv /tmp/regions\_export.csv original\_data/regions/regions\_dms\_INE.csv  
\`\`\`

\*\*Nota:\*\* No Windows, usar \`C:\\\\temp\\\\regions\_export.csv\`

\---

\#\#\# 2.2 Descarregar Dados de Área Municipal

\*\*Pré-requisitos:\*\*  
\- Navegador web  
\- \~25 KB de espaço livre

\*\*Passos:\*\*

1\. \*\*Download direto\*\*  
\`\`\`  
   URL: https://dados.gov.pt/s/resources/superficie-km2-por-concelho-2022/20251001-142238/superficies-por-concelho-2022.csv  
\`\`\`  
     
   \- Colar URL no navegador  
   \- Ficheiro descarrega automaticamente  
   \- Tamanho: 24,6 KB

2\. \*\*Guardar ficheiro\*\*  
\`\`\`  
   Destino: original\_data/regions/superficiesporconcelho2022.csv

Verificar conteúdo

Abrir em editor de texto  
Verificar 308 linhas (+ 1 cabeçalho)  
Confirmar coluna "Superfície (km2)" presente

Estrutura do Ficheiro:  
csvData de Referência,Superfície (km2),Código Concelho,Designação Concelho,...  
2022,714.69,301,Abrantes,...  
2022,335.27,302,Águeda,...  
...  
Estado:  Descarregado e integrado por TM1 em 26 Dezembro 2025

2.3 Integrar Área na Tabela region  
Pré-requisitos:

Acesso MySQL/MariaDB à base dms\_INE  
Ficheiro superficiesporconcelho2022.csv descarregado

Script SQL Completo:  
sql/\*  
Script: Adicionar campo area\_km2 e importar dados  
Autor: TM1 (Cristiana Chainho)  
Data: 26 Dezembro 2025  
\*/

\-- PASSO 1: Adicionar coluna area\_km2  
ALTER TABLE region   
ADD COLUMN area\_km2 DECIMAL(10,2) DEFAULT NULL  
COMMENT 'Superfície territorial em km² (fonte: INE 2022)';

\-- PASSO 2: Criar tabela temporária  
DROP TABLE IF EXISTS temp\_superficies;

CREATE TEMPORARY TABLE temp\_superficies (  
    data\_referencia VARCHAR(10),  
    superficie\_km2 DECIMAL(10,2),  
    codigo\_concelho INT,  
    designacao\_concelho VARCHAR(255),  
    codigo\_distrito INT,  
    designacao\_distrito VARCHAR(100),  
    codigo\_nuts3 VARCHAR(10),  
    designacao\_nuts3 VARCHAR(100),  
    codigo\_nuts2 INT,  
    designacao\_nuts2 VARCHAR(100)  
) CHARACTER SET utf8mb4 COLLATE utf8mb4\_unicode\_ci;

\-- PASSO 3: Importar CSV  
\-- AJUSTAR CAMINHO para sua localização\!  
LOAD DATA LOCAL INFILE '/caminho/para/superficiesporconcelho2022.csv'  
INTO TABLE temp\_superficies  
CHARACTER SET latin1  
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'  
LINES TERMINATED BY '\\n'  
IGNORE 1 ROWS;

\-- PASSO 4: Verificar importação  
SELECT COUNT(\*) as total FROM temp\_superficies;  
\-- Deve retornar: 308

\-- PASSO 5: UPDATE da tabela region  
UPDATE region r, temp\_superficies t  
SET r.area\_km2 \= t.superficie\_km2  
WHERE TRIM(r.region\_name) \= TRIM(t.designacao\_concelho)  
  AND r.level\_ID \= 4;

\-- PASSO 6: Verificar resultados  
SELECT   
    COUNT(\*) as concelhos\_com\_area,  
    COUNT(\*) \* 100.0 / 308 as percentagem  
FROM region  
WHERE level\_ID \= 4 AND area\_km2 IS NOT NULL;  
\-- Deve retornar: 308, 100%

\-- PASSO 7: Limpeza  
DROP TEMPORARY TABLE temp\_superficies;  
Resultado Esperado:

 308/308 concelhos com area\_km2 preenchido (100%)  
 Valores entre 41,42 km² (Porto) e \~1.300 km² (Évora, Beja)

Estado:  Concluído por TM1 em 26 Dezembro 2025

2.4 Exportar CSV Final (com área)  
Depois de integrar áreas:  
sqlSELECT   
    NutsID,  
    ParentCodeID,  
    level\_ID,  
    region\_name,  
    area\_km2  
FROM region  
ORDER BY level\_ID, region\_name;  
Exportar para: original\_data/regions/regions\_dms\_INE\_com\_area.csv  
Estado:  Exportado por TM1 \- 3.436 registos com área

2.5 Verificar Integridade Hierárquica  
Queries de Verificação:  
sql-- Contar por nível  
SELECT   
    level\_ID,  
    CASE   
        WHEN level\_ID \= 0 THEN 'País'  
        WHEN level\_ID \= 1 THEN 'NUTS I'  
        WHEN level\_ID \= 2 THEN 'NUTS II'  
        WHEN level\_ID \= 3 THEN 'NUTS III'  
        WHEN level\_ID \= 4 THEN 'Concelho'  
        WHEN level\_ID \= 5 THEN 'Freguesia'  
    END as nivel,  
    COUNT(\*) as total  
FROM region  
GROUP BY level\_ID  
ORDER BY level\_ID;

\-- Verificar registos órfãos  
SELECT COUNT(\*) as registos\_orfaos  
FROM region r1  
WHERE r1.ParentCodeID IS NOT NULL   
  AND r1.ParentCodeID NOT IN (SELECT NutsID FROM region);  
\-- Resultado esperado: 1 (documentado)  
\`\`\`

\*\*Documentação:\*\* Ver \`documentation/regional\_data\_verification.md\`

\---

\#\# 3\. Recolha de Dados Meteorológicos

\#\#\# 3.1 Acesso à API IPMA

\*\*Atribuição:\*\* TM3 (Duarte Campina)

\*\*Pré-requisitos:\*\*  
\- Python 3.8+ com biblioteca requests  
\- Chave API (se necessário)  
\- \~100 MB de espaço livre em disco

\*\*Documentação da API:\*\*  
\`\`\`  
API Principal: https://api.ipma.pt/  
Documentação: https://api.ipma.pt/open-data/

Exemplo Básico de Uso da API:  
pythonimport requests  
import json  
import pandas as pd  
from datetime import datetime, timedelta

\# URL base da API IPMA  
BASE\_URL \= "https://api.ipma.pt/open-data"

\# Obter lista de estações meteorológicas  
def get\_stations():  
    url \= f"{BASE\_URL}/observation/meteorology/stations/stations.json"  
    response \= requests.get(url)  
    return response.json()

\# Obter dados históricos para uma estação  
def get\_station\_data(station\_id, date):  
    """  
    station\_id: Identificador da estação  
    date: Data no formato YYYY-MM-DD  
    """  
    url \= f"{BASE\_URL}/observation/meteorology/stations/observations.json"  
    params \= {  
        'stationId': station\_id,  
        'date': date  
    }  
    response \= requests.get(url, params=params)  
    return response.json()

\# Exemplo: Obter dados para 2015-2024  
stations \= get\_stations()  
\# Guardar em original\_data/weather/stations\_metadata.json

\# Loop através de datas e estações  
\# \[TM3 para completar\]  
\`\`\`

\*\*Guardar em:\*\*  
\- Metadados de estações: \`original\_data/weather/stations\_metadata.json\`  
\- Observações diárias: \`original\_data/weather/daily\_weather\_AAAA.csv\`

\*\*Estado:\*\*  Pendente \- TM3 a desenvolver

\---

\#\#\# 3.2 Dados do Índice de Perigo de Incêndio (FWI)

\*\*Portal FWI do IPMA:\*\*  
\`\`\`  
URL: http://www.ipma.pt/pt/riscoincendio/fwi/  
\`\`\`

\*\*Passos de download manual:\*\*

1\. Aceder à secção de dados históricos FWI  
2\. Selecionar intervalo de datas: 2015-01-01 a 2024-12-31  
3\. Selecionar cobertura geográfica: Portugal Continental  
4\. Formato de download: CSV  
5\. Guardar em: \`original\_data/weather/fwi\_historical\_2015\_2024.csv\`

\*\*Alternativa:\*\* Script automatizado (TM3 a desenvolver)

\*\*Campos esperados:\*\*  
\- Data  
\- ID da Estação / Localização  
\- FFMC (Fine Fuel Moisture Code)  
\- DMC (Duff Moisture Code)  
\- DC (Drought Code)  
\- ISI (Initial Spread Index)  
\- BUI (Build-Up Index)  
\- FWI (Fire Weather Index)

\*\*Estado:\*\* Pendente \- TM3

\---

\#\# 3.3. Dados Meteorológicos (Atualização) \- IPMA DataClima

\#\#\# Fonte  
Portal DataClima do IPMA: https://dataclima.ipma.pt

\#\#\# Procedimento de Download

1\. \*\*Aceder ao Portal\*\*  
   \- Ir a https://dataclima.ipma.pt  
   \- Não requer registo ou autenticação

2\. \*\*Selecionar Estações\*\*  
   \- Escolher estações meteorológicas nas regiões de interesse  
   \- Priorizar estações com séries longas e completas  
   \- Verificar disponibilidade de variáveis necessárias

3\. \*\*Escolher Variáveis\*\*  
   \- Temperatura (média, máxima, mínima)  
   \- Precipitação  
   \- Humidade relativa  
   \- Vento (velocidade e direção, se disponível)

4\. \*\*Definir Período Temporal\*\*  
   \- Selecionar período coincidente com dados de incêndios (2015-2024)  
   \- Descarregar dados mensais ou diários conforme disponibilidade

5\. \*\*Descarregar Dados\*\*  
   \- Formato: CSV  
   \- Descarregar por estação e variável  
   \- Guardar em: \`original\_data/weather/\`

6\. \*\*Nomenclatura de Ficheiros\*\*  
   \- Formato sugerido: \`{estacao}\_{variavel}\_{periodo}.csv\`  
   \- Exemplo: \`lisboa\_temperatura\_2015-2024.csv\`

\#\#\# Processamento Posterior  
\- Ficheiros originais guardados em \`original\_data/weather/\`  
\- Script de limpeza: \`clean\_weather\_data.py\` (se aplicável)  
\- Dados processados: \`processed\_data/weather\_data\_clean.csv\`  
\- Importação SQL: \`07\_import\_weather\_FINAL.sql\`

\#\#\# Notas  
\- \*\*Limitação identificada\*\*: Falta dados de temperatura para Évora  
\- Algumas estações podem ter lacunas nos dados \- documentar em data\_dictionary.md  
\- Dados meteorológicos agregados mensalmente para facilitar cruzamento com incêndios

\---

\#\# 4\. Configuração de Dados de Vegetação

\#\#\# 4.1 Dados de Referência IFN6

\*\*Estado:\*\*  Tabela de referência criada por TM2

\*\*Verificação manual (opcional):\*\*

1\. \*\*Aceder ao portal ICNF\*\*  
\`\`\`  
   URL: http://www2.icnf.pt/portal/florestas/ifn

Descarregar relatórios IFN6

Procurar "6º Inventário Florestal Nacional"  
Descarregar relatórios PDF ou tabelas de dados  
Guardar em: original\_data/vegetation/IFN6\_reference/

Extrair informação relevante

Tabelas de distribuição de espécies  
Estatísticas de cobertura de área  
Dados de composição florestal

Nota: TM2 já criou vegetation\_types.csv com base nisto

4.2 CSV de Tipos de Vegetação  
Estado: Criado por TM2  
Localização do ficheiro: original\_data/vegetation/vegetation\_types.csv  
Estrutura esperada:  
csvvegetation\_id,tipo\_vegetacao,inflammabilidade,descricao  
1,Pinheiro-bravo,Alta,Pinus pinaster \- Pinheiro marítimo  
2,Eucalipto,Alta,Eucalyptus globulus  
3,Carvalho,Média,Quercus spp. \- Carvalho  
4,Sobreiro,Baixa,Quercus suber \- Sobreiro  
5,Mato,Alta,Matos e arbustos  
...  
Se recriar ou atualizar:

Basear na classificação IFN6  
Incluir avaliação de inflamabilidade da literatura  
Adicionar nomes portugueses e científicos

5\. Validação de Dados  
5.1 Lista de Verificação de Validação Pós-Download  
Dados de Incêndios:  
bash\# Verificar existência e tamanho de ficheiro  
ls \-lh original\_data/fires/  
\# Deve mostrar \~10 ficheiros, 5-15 MB cada

\# Verificar formato CSV  
head \-20 original\_data/fires/incendios\_2015.csv  
\# Verificar cabeçalhos e formato de dados

\# Contar registos  
wc \-l original\_data/fires/\*.csv  
\# Deve totalizar \~120k+ linhas

Dados Regionais:  
bash\# Verificar exportação  
head \-10 original\_data/regions/regions\_dms\_INE\_com\_area.csv

\# Contar regiões  
wc \-l original\_data/regions/regions\_dms\_INE\_com\_area.csv  
\# Deve ser \~3.436+ linhas (distritos \+ concelhos \+ freguesias)

Dados Meteorológicos:  
bash\# Verificar ficheiros meteorológicos (quando TM3 completar)  
ls \-lh original\_data/weather/

\# Verificar cobertura de intervalo de datas  
\# \[TM3 para adicionar script de validação\]

5.2 Verificações de Qualidade de Dados  
Executar estas queries SQL após importação:  
sql-- Verificar registos de incêndio duplicados  
SELECT data\_inicio, region\_id, COUNT(\*) as duplicados  
FROM INCENDIOS  
GROUP BY data\_inicio, region\_id  
HAVING COUNT(\*) \> 1;

\-- Verificar consistência de datas  
SELECT COUNT(\*) as datas\_invalidas  
FROM INCENDIOS  
WHERE data\_inicio \> data\_fim;

\-- Verificar valores de área razoáveis  
SELECT   
    MIN(area\_ardida\_ha),   
    MAX(area\_ardida\_ha),   
    AVG(area\_ardida\_ha)  
FROM INCENDIOS;

\-- Verificar ligações regionais  
SELECT i.fire\_id   
FROM INCENDIOS i  
LEFT JOIN REGIOES r ON i.region\_id \= r.region\_id  
WHERE r.region\_id IS NULL;  
\-- Deve retornar 0 linhas

6\. Resolução de Problemas  
Problemas Comuns  
Problema: MySQL OUTFILE permissão negada  
Erro: The used command is not allowed with this MySQL version  
Solução:  
sql-- Verificar se está ativo  
SHOW VARIABLES LIKE 'local\_infile';

\-- Se retornar OFF, ativar assim:  
SET GLOBAL local\_infile \= 1;  
No DBeaver:

Editar Conexão → Driver properties  
Adicionar: allowLoadLocalInfile=true

Problema: Problemas de codificação CSV (caracteres especiais portugueses)  
Solução:

Garantir codificação UTF-8  
No MySQL: SET NAMES utf8mb4;  
No Python: encoding='utf-8'

Problema: Limitação de taxa da API (IPMA)  
Solução:  
pythonimport time  
\# Adicionar atraso entre pedidos  
time.sleep(1)  \# atraso de 1 segundo  
\`\`\`

\---

\*\*Problema:\*\* Ficheiros CSV grandes demasiado lentos

\*\*Solução:\*\*  
\- Processar em blocos (pandas)  
\- Usar LOAD DATA INFILE em lote  
\- Considerar dividir por ano

\---

\#\# 7\. Organização de Dados

\*\*Estrutura de pasta final deve ser:\*\*  
\`\`\`  
original\_data/  
├── fires/  
│   ├── incendios\_2015.csv  
│   ├── incendios\_2016.csv  
│   ├── ...  
│   └── incendios\_2024.csv  
├── regions/  
│   ├── regions\_dms\_INE.csv (sem área)  
│   ├── regions\_dms\_INE\_com\_area.csv (com área)  
│   └── superficiesporconcelho2022.csv  
├── weather/  
│   ├── stations\_metadata.json  
│   ├── daily\_weather\_2015.csv  
│   ├── ...  
│   ├── daily\_weather\_2024.csv  
│   └── fwi\_historical\_2015\_2024.csv  
└── vegetation/  
    ├── vegetation\_types.csv  
    └── IFN6\_reference/ (PDFs opcionais)

8\. Acompanhamento de Atribuições  
Fonte de DadosAtribuído aEstadoLocalização do FicheiroCSV Incêndios (Central de Dados)TM2 Concluídofires/incendios\_\*.csvCSV Incêndios (dados.gov.pt)TM2 Concluídofires/cross\_forest\_validation.csvExportação dados regionaisTM1 Concluídoregions/regions\_dms\_INE\_com\_area.csvDados área municipalTM1 Concluídoregions/superficiesporconcelho2022.csvDados API meteorologiaTM3 A fazerweather/daily\_weather\_\*.csvDados FWITM3 A fazerweather/fwi\_historical\_\*.csvTipos de vegetaçãoTM2 Concluídovegetation/vegetation\_types.csv

9\. Contacto e Suporte  
Para questões técnicas:

Dados de incêndios: TM2 (Luis Vale)  
Dados regionais: TM1 (Cristiana Chainho)  
Dados meteorológicos: TM3 (Duarte Campina)

Última Atualização: 26 Dezembro 2025  
Próxima Atualização: Após TM3 completar recolha de dados meteorológicos

10\. Lista de Verificação de Download  
Antes da Submissão Final

 Todos os ficheiros CSV de incêndios presentes (2015-2024)  
 Dados regionais exportados com área  
 Dados meteorológicos descarregados (TM3)  
 Ficheiro de tipos de vegetação criado  
 Todos os ficheiros verificados quanto a codificação UTF-8  
 Tamanhos de ficheiro razoáveis (sem corrupção)  
 Documentação completa em documentation/  
 Scripts de importação testados  
 Verificações de qualidade de dados executadas

Documento Status: Completo para Dados Regionais e de Incêndios  
Pendente para Dados Meteorológicos (TM3)  
Preparado por: TM1 (Cristiana Chainho)  
Data: 26 Dezembro 2025