# Database Setup Guide

## Forest Fire Management System - Portugal

This guide provides step-by-step instructions for setting up the forest fire management database from scratch.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [MariaDB Installation](#mariadb-installation)
3. [DBeaver Installation](#dbeaver-installation)
4. [Database Creation](#database-creation)
5. [Data Import](#data-import)
6. [Creating Views](#creating-views)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)
9. [Backup and Restore](#backup-and-restore)

---

## Prerequisites

Before starting, ensure you have:

- **Operating System:** Windows 10/11, macOS, or Linux
- **Disk Space:** At least 500 MB for database and data files
- **Memory:** Minimum 4 GB RAM recommended
- **Files:** All project files downloaded from GitHub or Google Drive

---

## MariaDB Installation

### Windows Installation

1. **Download MariaDB**
   - Go to: https://mariadb.org/download/
   - Select: MariaDB Server 10.11 or later
   - Choose: Windows installer (MSI)

2. **Run the installer**
   - Double-click the downloaded `.msi` file
   - Click "Next" through the welcome screens

3. **Configuration settings**
   - **Root password:** Set a strong password (remember this!)
   - **Default character set:** UTF8MB4 (important for Portuguese characters)
   - **Port:** 3306 (default)
   - **Install as service:** Yes (recommended)

4. **Complete installation**
   - Click "Install"
   - Wait for installation to complete
   - Click "Finish"

5. **Verify installation**
   - Open Command Prompt (CMD)
   - Run: `mysql --version`
   - Should show: `mysql Ver 15.1 Distrib 10.11.x-MariaDB`

### macOS Installation

```bash
# Using Homebrew
brew install mariadb

# Start MariaDB
brew services start mariadb

# Secure installation
mysql_secure_installation
```

### Linux Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mariadb-server

# Start service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure installation
sudo mysql_secure_installation
```

---

## DBeaver Installation

DBeaver is a universal database client that makes working with databases easier.

1. **Download DBeaver**
   - Go to: https://dbeaver.io/download/
   - Select: Community Edition (free)
   - Choose your operating system

2. **Install DBeaver**
   - Run the installer
   - Follow default installation options
   - Launch DBeaver when complete

3. **Create MariaDB connection**
   - Click "New Database Connection" (plug icon)
   - Select "MariaDB"
   - Click "Next"
   
4. **Configure connection**
   - **Host:** localhost
   - **Port:** 3306
   - **Database:** (leave empty for now)
   - **Username:** root
   - **Password:** (your MariaDB root password)
   - Click "Test Connection"
   - Click "Finish"

---

## Database Creation

### Step 1: Create the Database

1. **Open DBeaver**
2. **Connect to MariaDB** (double-click your connection)
3. **Open SQL Editor** (SQL icon or Ctrl+])
4. **Run script:** `sql_scripts/01_create_database.sql`

```sql
-- Copy and paste this or run the file directly:
DROP DATABASE IF EXISTS forest_fire_mgmt;
CREATE DATABASE forest_fire_mgmt
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE forest_fire_mgmt;
```

5. **Execute:** Click "Execute" (▶ button) or press Ctrl+Enter
6. **Verify:** You should see "Database forest_fire_mgmt created successfully!"

### Step 2: Create Tables

1. **Open:** `sql_scripts/02_create_tables_clean.sql` in DBeaver
2. **Execute the entire script**
3. **Verify tables created:**

```sql
SHOW TABLES;
```

You should see 5 tables:
- `incendio_vegetacao`
- `incendios`
- `meteorologia`
- `regioes`
- `vegetacao`

---

## Data Import

Import data in this specific order (respects foreign key dependencies):

### Step 1: Import Vegetation Types

**File:** `sql_scripts/06_import_vegetation.sql`

**Important:** Update the file path to your absolute path:

```sql
-- Change this line:
LOAD DATA LOCAL INFILE 'C:/path/to/your/project/processed_data/vegetation_types.csv'
```

**To your actual path:**
```sql
-- Windows example:
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Desktop/Mestrado/1_semestre/Gestao e Armazenamento de Dados/DMS_Forest_Fires_Project/forest_fire_project/processed_data/vegetation_types.csv'
```

**Execute the script**

**Verify:**
```sql
SELECT COUNT(*) FROM vegetacao;
-- Should return: 12
```

### Step 2: Import Sample Regions

**File:** `sql_scripts/04_import_sample_regions.sql`

**Update file path** (same as above)

**Execute the script**

**Verify:**
```sql
SELECT COUNT(*) FROM regioes;
-- Should return: 18
```

### Step 3: Import Fire Data

**File:** `sql_scripts/05_import_fires.sql`

**Update file path** for `fires_cleaned.csv`

**Execute the script** (this may take 30-60 seconds - 121,550 records!)

**Verify:**
```sql
SELECT COUNT(*) FROM incendios;
-- Should return: ~121,550

SELECT ano, COUNT(*) as fires
FROM incendios
GROUP BY ano
ORDER BY ano;
-- Should show fires from 2015-2024
```

### Step 4: Import Weather Data (Optional - when available)

**File:** `sql_scripts/07_import_weather.sql`

**Note:** This requires weather data from TM3 (Duarte)
- Wait until `processed_data/weather_data.csv` is available
- Then update file path and execute

### Step 5: Import Full Regions (Optional - when available)

**File:** `sql_scripts/04_import_regions.sql`

**Note:** This requires complete regions data from TM1 (Cristiana)
- Wait until `processed_data/regions_complete.csv` is available
- Then update file path and execute

---

## Creating Views

Views make complex queries reusable and easier to work with.

**File:** `sql_scripts/10_create_views.sql`

**Execute the script**

**Verify views created:**
```sql
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

You should see 8 views:
- `v_annual_fire_summary`
- `v_critical_period_fires`
- `v_fire_cause_summary`
- `v_fire_severity`
- `v_fire_weather_conditions`
- `v_monthly_fire_summary`
- `v_regional_fire_summary`
- `v_seasonal_fire_summary`

**Test a view:**
```sql
SELECT * FROM v_monthly_fire_summary;
```

---

## Verification

### Check Data Integrity

**1. Verify record counts:**
```sql
SELECT 'vegetacao' as table_name, COUNT(*) as records FROM vegetacao
UNION ALL
SELECT 'regioes', COUNT(*) FROM regioes
UNION ALL
SELECT 'incendios', COUNT(*) FROM incendios
UNION ALL
SELECT 'meteorologia', COUNT(*) FROM meteorologia;
```

**2. Check foreign key relationships:**
```sql
-- Check fires have valid regions
SELECT COUNT(*) as orphan_fires
FROM incendios
WHERE region_id NOT IN (SELECT region_id FROM regioes);
-- Should return: 0
```

**3. Run analysis queries:**
```sql
-- Q3: Monthly fire analysis
SELECT mes, COUNT(*) as fires
FROM incendios
GROUP BY mes
ORDER BY fires DESC;

-- Should show August with most fires (~26,325)
```

---

## Troubleshooting

### Problem: "Cannot connect to database"

**Solution:**
- Check MariaDB service is running
- Verify password is correct
- Try: `mysql -u root -p` in command line

### Problem: "LOAD DATA LOCAL INFILE not allowed"

**Solution:**
```sql
-- Run this first:
SET GLOBAL local_infile = 1;
```

### Problem: "File not found" during import

**Solution:**
- Use absolute file paths (full path from C:/ or /)
- Use forward slashes `/` even on Windows
- Example: `C:/Users/Name/Desktop/project/processed_data/fires_cleaned.csv`

### Problem: "Incorrect string value" or encoding errors

**Solution:**
- Ensure database uses UTF8MB4: `SHOW CREATE DATABASE forest_fire_mgmt;`
- Re-run `01_create_database.sql` if needed

### Problem: "Duplicate entry" during import

**Solution:**
```sql
-- Clear the table first:
DELETE FROM table_name;
ALTER TABLE table_name AUTO_INCREMENT = 1;

-- Then re-run the import
```

### Problem: CSV import shows ### symbols in dates

**Solution:**
- These are handled as NULL in the import script
- The script uses `STR_TO_DATE()` to parse valid dates
- Invalid dates become NULL (this is expected)

---

## Backup and Restore

### Create Backup

**Method 1: Using DBeaver**
1. Right-click on `forest_fire_mgmt` database
2. Select "Tools" → "Dump Database"
3. Choose location and filename
4. Click "Start"

**Method 2: Using Command Line**
```bash
mysqldump -u root -p forest_fire_mgmt > backup.sql
```

### Restore from Backup

**Method 1: Using DBeaver**
1. Right-click on database connection
2. Select "Tools" → "Restore Database"
3. Choose backup file
4. Click "Start"

**Method 2: Using Command Line**
```bash
mysql -u root -p forest_fire_mgmt < backup.sql
```

---

## Database Structure Summary

### Tables

| Table | Records | Description |
|-------|---------|-------------|
| `regioes` | 18 | Portuguese districts (sample) |
| `vegetacao` | 12 | Vegetation types |
| `incendios` | 121,550 | Fire records (2015-2024) |
| `meteorologia` | 0 | Weather data (pending) |
| `incendio_vegetacao` | 0 | Fire-vegetation relationships |

### Views

| View | Purpose |
|------|---------|
| `v_monthly_fire_summary` | Fires by month |
| `v_seasonal_fire_summary` | Fires by season |
| `v_annual_fire_summary` | Fires by year |
| `v_fire_cause_summary` | Fires by cause |
| `v_regional_fire_summary` | Fires by district |
| `v_fire_severity` | Fire size categories |
| `v_fire_weather_conditions` | Fire + weather data |
| `v_critical_period_fires` | Summer fire analysis |

---

## Next Steps

After completing this setup:

1. **Run analysis queries** (Q3, Q4 in `sql_scripts/`)
2. **Wait for additional data** from team members:
   - Weather data from TM3 (Duarte)
   - Complete regions from TM1 (Cristiana)
3. **Run transformation scripts** (`09_transform_data.sql`)
4. **Create regular backups** of your database
5. **Document your findings** for the project report

---

## Additional Resources

- **MariaDB Documentation:** https://mariadb.com/kb/en/
- **DBeaver Documentation:** https://dbeaver.com/docs/
- **SQL Tutorial:** https://www.w3schools.com/sql/
- **Project Repository:** Check README.md for updates

---

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review error messages carefully
3. Verify file paths are correct
4. Contact your team members for help
5. Check project documentation on GitHub/Google Drive

---

**Last Updated:** December 2025  
**Database Version:** 1.0  
**MariaDB Version:** 10.11+
