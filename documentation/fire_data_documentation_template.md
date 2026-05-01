# Fire Data Structure Documentation

**Author:** TM2 - Luis Vale  
**Date:** 2025-12-21  
**Task:** Document fire data structure after download

---

## Data Source Information

**Primary Source:** 
- [ ] centraldedados.pt
- [ ] dados.gov.pt (Cross-Forest)
- [ ] ICNF website
- [ ] fogos.pt
- [ ] Other: _______________

**Download Date:** _____________

**File Format:** 
- [ ] CSV
- [ ] Excel
- [ ] JSON
- [ ] Other: _______________

**Encoding:** 
- [ ] UTF-8
- [ ] Latin-1 (ISO-8859-1)
- [ ] Other: _______________

---

## File Structure

### Files Downloaded:
| Filename | Year(s) | Size | Rows | Columns |
|----------|---------|------|------|---------|
| incendios_2015.csv | 2015 | ___ KB | ___ | ___ |
| incendios_2016.csv | 2016 | ___ KB | ___ | ___ |
| incendios_2017.csv | 2017 | ___ KB | ___ | ___ |
| incendios_2018.csv | 2018 | ___ KB | ___ | ___ |
| incendios_2019.csv | 2019 | ___ KB | ___ | ___ |
| incendios_2020.csv | 2020 | ___ KB | ___ | ___ |
| incendios_2021.csv | 2021 | ___ KB | ___ | ___ |
| incendios_2022.csv | 2022 | ___ KB | ___ | ___ |
| incendios_2023.csv | 2023 | ___ KB | ___ | ___ |
| incendios_2024.csv | 2024 | ___ KB | ___ | ___ |

**Total Records (all years):** _______________

---

## Column Structure

**Instructions:** Run this Python script to analyze the data:

```python
import pandas as pd

# Load one file to see structure
df = pd.read_csv('original_data/fires/incendios_2015.csv')

# Print basic info
print("Columns:", df.columns.tolist())
print("\nData types:")
print(df.dtypes)
print("\nFirst few rows:")
print(df.head())
print("\nMissing values:")
print(df.isnull().sum())
```

### Identified Columns:

Fill this out after examining the data:

| Column Name (Original) | Data Type | Description | Example Values | Notes |
|------------------------|-----------|-------------|----------------|-------|
| _______________ | string/int/date | _______________ | _______________ | _______________ |
| _______________ | string/int/date | _______________ | _______________ | _______________ |
| _______________ | string/int/date | _______________ | _______________ | _______________ |

---

## Field Mapping to Database

Map original column names to our database fields:

| Original Column | Database Table | Database Column | Transformation Needed |
|-----------------|----------------|-----------------|----------------------|
| ??? | incendios | region_id | Match with regions table |
| ??? | incendios | data_inicio | Parse date format |
| ??? | incendios | data_fim | Parse date format |
| ??? | incendios | area_ardida_ha | Check units (ha vs m²) |
| ??? | incendios | causa | Standardize categories |
| ??? | incendios | ano | Extract from date |
| ??? | incendios | mes | Extract from date |

---

## Data Quality Issues

Check for these common issues:

### Missing Values:
- [ ] **Region/Location:** ___% missing
- [ ] **Dates:** ___% missing
- [ ] **Area burned:** ___% missing
- [ ] **Cause:** ___% missing

### Date Format Issues:
- [ ] Format pattern: DD/MM/YYYY, YYYY-MM-DD, or other?
- [ ] Inconsistent formats across years?
- [ ] Invalid dates found?

### Duplicates:
- [ ] Checked for duplicate fire records
- [ ] Criteria for identifying duplicates: _______________

### Data Errors:
- [ ] Negative burned areas?
- [ ] Area = 0?
- [ ] End date before start date?
- [ ] Unrealistic values (e.g., area > 10,000 ha)?

### Region/Location Issues:
- [ ] Region names consistent across years?
- [ ] Need mapping to dms_INE regions?
- [ ] NUTS codes available?
- [ ] Missing regions?

### Cause Categories:
Available cause categories in data:
- [ ] Natural
- [ ] Negligência
- [ ] Intencional
- [ ] Desconhecida
- [ ] Other: _______________

Need standardization? Yes / No

---

## Sample Data (First 5 Rows)

Paste or describe the first few rows here:

```
[Paste sample data here after examining files]
```

---

## Data Cleaning Plan

Based on issues found above, list required cleaning steps:

1. **Date standardization:**
   - Action: _______________
   - Script: clean_fire_data.py

2. **Missing values:**
   - Action: _______________
   - Script: clean_fire_data.py

3. **Region mapping:**
   - Action: _______________
   - Script: clean_fire_data.py

4. **Cause standardization:**
   - Action: _______________
   - Script: clean_fire_data.py

5. **Duplicate removal:**
   - Action: _______________
   - Script: clean_fire_data.py

---

## Next Steps

- [ ] Complete this documentation
- [ ] Share findings with TM1 (regions) and TM3 (weather)
- [ ] Create clean_fire_data.py script
- [ ] Generate processed_data/fires_cleaned.csv
- [ ] Create 05_import_fires.sql script

---

**Status:** 🔴 To Do / 🟡 In Progress / 🟢 Done

**Last Updated:** _______________
