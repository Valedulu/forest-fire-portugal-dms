# Forest Fire Management System — Portugal 

> Relational database and data pipeline for forest fire risk analysis in Portugal  
> **DMS Project · MSc Green Data Science · ISA, Lisbon**

---

## Overview

This project develops a comprehensive database management system to analyse forest fire patterns across Portugal. Using historical fire records, meteorological data, and regional vegetation information, the system enables structured querying and analysis of fire risk factors across Portuguese districts.

---

## Project Structure

```
forest-fire-portugal-dms/
├── sql_scripts/          # Database creation and data import scripts
├── data_use_scripts/     # Analytical SQL queries
├── documentation/        # Project documentation and data sources
├── original_data/        # Raw data (fires, weather, regions, vegetation)
├── processed_data/       # Cleaned and transformed datasets
├── clean_fire_data.py    # Python script for fire data cleaning
└── process_weather_data.py # Python script for weather data processing
```

---

## Data Sources

| Dataset | Source | Period |
|---------|--------|--------|
| Forest fire records | ICNF / SGIF | 2001–2024 |
| Meteorological data | IPMA weather stations | Historical |
| Regional boundaries | INE | 2022 |
| Vegetation types | National classification | — |

---

## Key Analyses

- **Q1** — Most affected districts by fire frequency and area burned
- **Q2** — Average burned area by region and vegetation type
- **Q3** — Monthly fire pattern analysis
- **Q4** — Weather and fire correlation (monthly)
- **Q5** — Fire causes analysis by region

---

## Tech Stack

<p>
  <a href="https://www.mysql.com"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg" height="40"/></a>
  &nbsp;&nbsp;
  <a href="https://mariadb.org"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mariadb/mariadb-original.svg" height="40"/></a>
  &nbsp;&nbsp;
  <a href="https://www.python.org"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" height="40"/></a>
  &nbsp;&nbsp;
  <a href="https://dbeaver.io"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dbeaver/dbeaver-original.svg" height="40"/></a>
</p>

---

## Author

- **Luís Vale** — [@Valedulu](https://github.com/Valedulu)

---

*MSc Green Data Science · ISA – Instituto Superior de Agronomia · Lisbon, Portugal*  
*Last updated: December 2025*
