# Forest Fire Management System - Implementation Guide

**Project:** DMS Assignment 01 - Group 5  
**Database:** forest_fire_mgmt  
**Authors:** Cristiana Chainho (TM1), Luis Vale (TM2), Duarte Campina (TM3)  
**Date:** December 2025

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Database Setup](#database-setup)
4. [Data Import](#data-import)
5. [Running Analysis Queries](#running-analysis-queries)
6. [Project Structure](#project-structure)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

This database management system analyzes forest fires in Portugal (2015-2024) to identify patterns and support prevention and firefighting decision-making.

### Research Questions:
1. Which municipalities/districts are most affected by fires?
2. What is the average burned area by region and vegetation type?
3. In which months/periods do most fires occur?
4. What is the relationship between weather conditions and burned area?
5. What are the main causes of fires?
6. What is the average firefighting time per district?
7. How have fires evolved over the years?

### Database Entities:
- **REGIOES** (Regions): Portuguese administrative hierarchy
- **VEGETACAO** (Vegetation): Forest types and flammability
- **INCENDIOS** (Fires): Fire incidents with temporal and spatial data
- **METEOROLOGIA** (Weather): Weather conditions during fires
- **INCENDIO_VEGETACAO** (Fire-Vegetation): Junction table

---

## 🔧 Prerequisites

### Software Requirements:
- **MySQL 8.0+** or **MariaDB 10.5+**
- **Python 3.8+** (for data collection and cleaning)
- **Git** (for version control)

### Python Packages:
```bash
pip install pandas numpy requests mysql-connector-python
```

### MySQL/MariaDB Installation:

**Windows:**
1. Download MySQL Installer from https://dev.mysql.com/downloads/installer/
2. Run installer and select "MySQL Server"
3. Set root password during installation
4. Verify: `mysql --version`

**macOS:**
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

---

## 🗄️ Database Setup

### Step 1: Clone the Repository
```bash
git clone https://github.com/Valedulu/forest-fire-portugal-dms.git
cd forest-fire-portugal-dms
```

### Step 2: Create the Database
```bash
# Login to MySQL
mysql -u root -p

# Run the database creation script
source sql_scripts/01_create_database.sql

# Verify database was created
SHOW DATABASES;
```

### Step 3: Create Tables
```bash
# Still in MySQL prompt
source sql_scripts/02_create_tables.sql

# Verify tables were created
USE forest_fire_mgmt;
SHOW TABLES;
```

### Step 4: Add Constraints and Indexes
```bash
source sql_scripts/03_add_constraints.sql
```

### Alternative: Run all scripts at once
```bash
# From command line (not MySQL prompt)
mysql -u root -p < sql_scripts/01_create_database.sql
mysql -u root -p < sql_scripts/02_create_tables.sql
mysql -u root -p < sql_scripts/03_add_constraints.sql
```

---

## 📊 Data Import

### Step 1: Collect Fire Data
```bash
# Run Python download script
python3 download_fire_data.py

# OR manually download from:
# http://centraldedados.pt/incendios/
# Save CSV files to: original_data/fires/
```

### Step 2: Import Vegetation Data
```bash
# Copy vegetation CSV to processed_data folder
cp vegetation_types.csv processed_data/

# Import into database
mysql -u root -p forest_fire_mgmt < sql_scripts/06_import_vegetation.sql
```

### Step 3: Import Regions Data
```bash
# Export from dms_INE database (if you have it)
# OR TM1 will provide this data

mysql -u root -p forest_fire_mgmt < sql_scripts/04_import_regions.sql
```

### Step 4: Clean and Import Fire Data
```bash
# Run data cleaning script (TM2 to create)
python3 clean_fire_data.py

# Import cleaned data
mysql -u root -p forest_fire_mgmt < sql_scripts/05_import_fires.sql
```

### Step 5: Import Weather Data
```bash
# TM3 will handle weather data collection and import
mysql -u root -p forest_fire_mgmt < sql_scripts/07_import_weather.sql
```

### Step 6: Create Fire-Vegetation Relationships
```bash
mysql -u root -p forest_fire_mgmt < sql_scripts/08_import_fire_vegetation.sql
```

### Step 7: Transform Data
```bash
# Calculate derived fields
mysql -u root -p forest_fire_mgmt < sql_scripts/09_transform_data.sql
```

---

## 🔍 Running Analysis Queries

### Execute Analysis Queries:
```bash
# Run all 7 research question queries
mysql -u root -p forest_fire_mgmt < data_use_scripts/query_all.sql

# Or run individual queries
mysql -u root -p forest_fire_mgmt < data_use_scripts/q1_most_affected_regions.sql
mysql -u root -p forest_fire_mgmt < data_use_scripts/q2_avg_area_by_region_vegetation.sql
# ... and so on
```

### View Results:
Results will be displayed in the terminal. To save to CSV:
```bash
mysql -u root -p forest_fire_mgmt < data_use_scripts/q1_most_affected_regions.sql > results_q1.csv
```

---

## 📁 Project Structure

```
forest-fire-portugal-dms/
│
├── original_data/              # Raw data as downloaded
│   ├── fires/                  # Fire CSV files (2015-2024)
│   ├── weather/                # Weather data from IPMA
│   ├── regions/                # Region data from dms_INE
│   └── vegetation/             # Vegetation classification data
│
├── processed_data/             # Cleaned data ready for import
│   ├── fires_cleaned.csv
│   ├── weather_cleaned.csv
│   └── vegetation_types.csv
│
├── sql_scripts/                # Database creation and import
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_add_constraints.sql
│   ├── 04_import_regions.sql
│   ├── 05_import_fires.sql
│   ├── 06_import_vegetation.sql
│   ├── 07_import_weather.sql
│   ├── 08_import_fire_vegetation.sql
│   └── 09_transform_data.sql
│
├── data_use_scripts/           # Analysis queries
│   ├── q1_most_affected_regions.sql
│   ├── q2_avg_area_by_region_vegetation.sql
│   ├── q3_fires_by_month.sql
│   ├── q4_weather_correlation.sql
│   ├── q5_fire_causes.sql
│   ├── q6_avg_firefighting_time.sql
│   ├── q7_temporal_evolution.sql
│   └── query_all.sql
│
├── documentation/              # Project documentation
│   ├── README.md              # This file
│   ├── data_dictionary.md     # Data field descriptions
│   ├── data_sources.md        # Source attribution
│   └── er_diagram.png         # Entity-Relationship diagram
│
├── database_dump/              # Final database backup
│   └── forest_fire_mgmt_final.sql
│
├── download_fire_data.py       # Data collection script
├── clean_fire_data.py          # Data cleaning script
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

---

## 🔧 Troubleshooting

### Issue: "ERROR 1045 (28000): Access denied for user"
**Solution:**
```bash
# Reset MySQL root password
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'your_new_password';
FLUSH PRIVILEGES;
EXIT;
```

### Issue: "ERROR 1148: The used command is not allowed with this MySQL version"
**Solution:** Enable local file loading
```sql
SET GLOBAL local_infile = 1;
```

### Issue: "Table already exists"
**Solution:** Drop and recreate database
```sql
DROP DATABASE IF EXISTS forest_fire_mgmt;
source sql_scripts/01_create_database.sql;
```

### Issue: Python packages not found
**Solution:**
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Issue: Large CSV files won't import
**Solution:** Increase MySQL packet size
```sql
SET GLOBAL max_allowed_packet=1073741824;  -- 1GB
```

---

## 📝 Data Sources and Licenses

### Fire Data:
- **Source:** Central de Dados (http://centraldedados.pt/incendios/)
- **License:** Open Data
- **Coverage:** 2015-2024
- **Format:** CSV

### Weather Data:
- **Source:** IPMA - Instituto Português do Mar e da Atmosfera
- **API:** https://api.ipma.pt/
- **License:** Open Data
- **Coverage:** Historical data since 1979

### Regional Data:
- **Source:** INE - Instituto Nacional de Estatística
- **Database:** dms_INE
- **License:** Public data
- **Coverage:** All Portuguese administrative regions

### Vegetation Data:
- **Source:** ICNF - Instituto da Conservação da Natureza e das Florestas
- **Reference:** 6º Inventário Florestal Nacional (IFN6)
- **License:** Public domain
- **Classification:** Portuguese forest species

---

## 📧 Contact

For questions or issues:
- **TM1 (Cristiana):** Regional data, documentation
- **TM2 (Luis):** Database design, fire data, SQL scripts
- **TM3 (Duarte):** Weather data, queries, validation

---

## 📄 License

This project is for educational purposes as part of the Master in Green Data Science program at Universidade de Lisboa.

**Last Updated:** 2025-12-21
