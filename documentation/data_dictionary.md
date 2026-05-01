# Data Dictionary - Forest Fire Management System

**Project:** DMS Assignment 01 - Group 5  
**Database:** forest_fire_mgmt  
**Author:** TM2 - Luis Vale  
**Last Updated:** 2025-12-21

---

## Table of Contents
1. [REGIOES (Regions)](#regioes-regions)
2. [VEGETACAO (Vegetation Types)](#vegetacao-vegetation-types)
3. [INCENDIOS (Fires)](#incendios-fires)
4. [METEOROLOGIA (Weather Conditions)](#meteorologia-weather-conditions)
5. [INCENDIO_VEGETACAO (Fire-Vegetation)](#incendio_vegetacao-fire-vegetation)

---

## REGIOES (Regions)

**Description:** Portuguese administrative regions with hierarchical structure (Distrito → Concelho → Freguesia)

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| region_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each region |
| nuts_id | VARCHAR(10) | - | NUTS code (Nomenclature of Territorial Units for Statistics) |
| region_name | VARCHAR(100) | NOT NULL | Name of the region (district, municipality, or parish) |
| region_level | ENUM | NOT NULL | Level in hierarchy: 'distrito', 'concelho', or 'freguesia' |
| parent_region_id | INT | FOREIGN KEY | References parent region (NULL for top-level districts) |
| area_km2 | DECIMAL(10,2) | - | Total area in square kilometers |

**Source:** dms_INE database  
**Relationships:**
- Self-referencing: parent_region_id → region_id (hierarchical structure)
- Referenced by: incendios.region_id

---

## VEGETACAO (Vegetation Types)

**Description:** Reference table for Portuguese vegetation types and their flammability characteristics

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| vegetation_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for vegetation type |
| tipo_vegetacao | VARCHAR(100) | NOT NULL, UNIQUE | Name of vegetation type (e.g., "Pinheiro-bravo", "Eucalipto") |
| inflamabilidade | ENUM | NOT NULL | Flammability level: 'baixa', 'media', or 'alta' |
| descricao | TEXT | - | Detailed description of vegetation type and characteristics |

**Source:** ICNF IFN6 (6º Inventário Florestal Nacional)  
**Common Types:**
- Pinheiro-bravo (Pinus pinaster) - High flammability
- Eucalipto (Eucalyptus globulus) - High flammability
- Sobreiro (Cork oak) - Medium flammability
- Mato (Shrubland) - High flammability

**Relationships:**
- Referenced by: incendio_vegetacao.vegetation_id

---

## INCENDIOS (Fires)

**Description:** Main table storing forest fire incident data with temporal, spatial, and impact information

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| fire_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each fire incident |
| region_id | INT | FOREIGN KEY, NOT NULL | Region where fire occurred |
| data_inicio | DATE | NOT NULL | Fire start date (YYYY-MM-DD) |
| data_fim | DATE | CHECK (>= data_inicio) | Fire end date (NULL if ongoing or unknown) |
| duracao_horas | DECIMAL(8,2) | CHECK (>= 0) | Duration in hours (calculated from dates) |
| area_ardida_ha | DECIMAL(12,2) | NOT NULL, CHECK (>= 0) | Total burned area in hectares |
| causa | ENUM | NOT NULL | Fire cause: 'natural', 'negligencia', 'intencional', 'desconhecida' |
| ano | INT | NOT NULL, CHECK (1900-2100) | Year of fire (extracted from data_inicio) |
| mes | INT | NOT NULL, CHECK (1-12) | Month of fire (extracted from data_inicio) |

**Source:** 
- Primary: http://centraldedados.pt/incendios/
- Secondary: dados.gov.pt (Cross-Forest project), ICNF reports

**Data Period:** 2015-2024 (10 years)

**Relationships:**
- References: regioes.region_id
- Referenced by: meteorologia.fire_id, incendio_vegetacao.fire_id

---

## METEOROLOGIA (Weather Conditions)

**Description:** Weather data associated with each fire incident for correlation analysis

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| weather_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for weather record |
| fire_id | INT | FOREIGN KEY, NOT NULL, UNIQUE | Associated fire (one-to-one relationship) |
| temperatura_max | DECIMAL(5,2) | CHECK (-50 to 60) | Maximum temperature in °C during fire |
| humidade_relativa | DECIMAL(5,2) | CHECK (0-100) | Relative humidity percentage |
| velocidade_vento_kmh | DECIMAL(6,2) | CHECK (>= 0) | Wind speed in km/h |
| precipitacao_mm | DECIMAL(8,2) | CHECK (>= 0) | Precipitation in millimeters |
| indice_fwi | DECIMAL(6,2) | CHECK (>= 0) | Fire Weather Index (FWI) |

**Source:** IPMA (Instituto Português do Mar e da Atmosfera)
- API: https://api.ipma.pt/
- FWI data available since 1979

**FWI (Fire Weather Index):**
- 0-5: Very Low fire danger
- 5-11: Low fire danger
- 12-21: Moderate fire danger
- 22-38: High fire danger
- 38+: Very High/Extreme fire danger

**Relationships:**
- References: incendios.fire_id (one-to-one)

---

## INCENDIO_VEGETACAO (Fire-Vegetation)

**Description:** Junction table implementing many-to-many relationship between fires and vegetation types

| Column Name | Data Type | Constraints | Description |
|-------------|-----------|-------------|-------------|
| fire_veg_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for fire-vegetation record |
| fire_id | INT | FOREIGN KEY, NOT NULL | Associated fire incident |
| vegetation_id | INT | FOREIGN KEY, NOT NULL | Type of vegetation affected |
| area_afetada_ha | DECIMAL(12,2) | NOT NULL, CHECK (>= 0) | Area of this vegetation type burned (hectares) |
| percentagem_area | DECIMAL(5,2) | CHECK (0-100) | Percentage of total fire area |

**Unique Constraint:** (fire_id, vegetation_id) - One entry per fire-vegetation combination

**Business Rules:**
- Sum of area_afetada_ha for a fire should not exceed incendios.area_ardida_ha
- Sum of percentagem_area for a fire should equal 100% (if all vegetation types are recorded)

**Relationships:**
- References: incendios.fire_id
- References: vegetacao.vegetation_id

---

## Data Quality Notes

### Known Issues (To Be Documented After Data Collection):
- [ ] Missing values in fire data (percentage and patterns)
- [ ] Date format inconsistencies
- [ ] Duplicate fire records
- [ ] Region name standardization issues
- [ ] Weather data availability for historical fires

### Data Cleaning Steps Required:
1. Standardize date formats to YYYY-MM-DD
2. Remove duplicate fire records
3. Match region names with dms_INE regions
4. Handle missing weather data (interpolation or nearest station)
5. Validate area_ardida_ha values (remove outliers/errors)
6. Standardize causa categories

---

## Indexes and Performance

### Primary Indexes (Automatic):
- All PRIMARY KEY columns
- All FOREIGN KEY columns (InnoDB)
- UNIQUE constraints

### Additional Performance Indexes:
- incendios.idx_ano_mes (ano, mes) - for temporal analysis
- incendios.idx_region_ano (region_id, ano) - for regional trends
- incendios.idx_region_area (region_id, area_ardida_ha) - for area analysis
- vegetacao.idx_tipo (tipo_vegetacao) - for vegetation lookups
- meteorologia.idx_fwi (indice_fwi) - for fire danger analysis

---

## Database Statistics (To Be Updated After Import)

| Table | Expected Row Count | Storage Size | Notes |
|-------|-------------------|--------------|-------|
| regioes | ~4,000 | Small | All Portuguese regions |
| vegetacao | ~12 | Tiny | Reference table |
| incendios | ~50,000-100,000 | Large | 10 years of data |
| meteorologia | ~50,000-100,000 | Large | 1:1 with fires |
| incendio_vegetacao | ~150,000-300,000 | Large | Multiple vegetation per fire |

**Total Database Size (Estimated):** 100-500 MB

---

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-12-21 | 1.0 | TM2 | Initial data dictionary creation |

