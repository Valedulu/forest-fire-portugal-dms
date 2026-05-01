# Precipitation & Temperature Data Structure Documentation

**Author:** TM2 - Luis Vale  
**Date:** 2025-12-27  
**Source:** Climate/Weather Data

---

## Data Source Information

**Primary Source:** [To be confirmed]  
**Dataset:** Precipitation and Temperature Measurements  
**Format:** Excel (.xlsx)  
**Total Records:** 1,296  
**Sheet Name:** Sheet1

---

## Files Downloaded

| Filename | Records | Columns | Format |
|----------|---------|---------|--------|
| prec_temp.xlsx | 1,296 | 11 | Excel |

---

## Column Structure

### All Columns

| Column Name | Data Type | Missing | Unique Values | Description |
|-------------|-----------|---------|---------------|-------------|
| distrito | string | 0 (0.0%) | 18 | [Add description] |
| Date | number | 0 (0.0%) | 72 | [Add description] |
| ano | number | 0 (0.0%) | 6 | [Add description] |
| mes | number | 0 (0.0%) | 12 | [Add description] |
| TotalPrecip (mm) | string | 0 (0.0%) | 797 | [Add description] |
| DailyMaxPrecip (mm) | string | 0 (0.0%) | 482 | [Add description] |
| MaxMaxTemp (ºC) | string | 72 (5.6%) | 307 | [Add description] |
| AvgTempMax (ºC) | string | 72 (5.6%) | 942 | [Add description] |
| AvgTemp (ºC) | string | 72 (5.6%) | 903 | [Add description] |
| AvgTempMin (ºC) | string | 72 (5.6%) | 882 | [Add description] |
| MinMinTemp (ºC) | string | 72 (5.6%) | 240 | [Add description] |

---

## Data Quality Assessment

### Missing Values Summary

| Field | Missing Count | Percentage | Status |
|-------|---------------|------------|--------|
| distrito | 0 | 0.0% | ✅ Complete |
| Date | 0 | 0.0% | ✅ Complete |
| ano | 0 | 0.0% | ✅ Complete |
| mes | 0 | 0.0% | ✅ Complete |
| TotalPrecip (mm) | 0 | 0.0% | ✅ Complete |
| DailyMaxPrecip (mm) | 0 | 0.0% | ✅ Complete |
| MaxMaxTemp (ºC) | 72 | 5.6% | ❌ Poor |
| AvgTempMax (ºC) | 72 | 5.6% | ❌ Poor |
| AvgTemp (ºC) | 72 | 5.6% | ❌ Poor |
| AvgTempMin (ºC) | 72 | 5.6% | ❌ Poor |
| MinMinTemp (ºC) | 72 | 5.6% | ❌ Poor |

**Overall Data Quality:** 6/11 columns complete (54.5%)

---

## Statistical Summary

### Date
- **Minimum:** 42005.00
- **Maximum:** 43842.00
- **Average:** 42923.67
- **Median:** 43101.00

### ano
- **Minimum:** 2015.00
- **Maximum:** 2020.00
- **Average:** 2017.50
- **Median:** 2018.00

### mes
- **Minimum:** 1.00
- **Maximum:** 12.00
- **Average:** 6.50
- **Median:** 7.00

---

## Sample Data (First 3 Rows)

```
distrito: Aveiro, Aveiro, Aveiro
Date: 42005.00, 42006.00, 42007.00
ano: 2015.00, 2015.00, 2015.00
mes: 1.00, 2.00, 3.00
TotalPrecip (mm): 53.20, 6.80, 27.60
DailyMaxPrecip (mm): 22.90, 1.40, 11.00
MaxMaxTemp (ºC): 16.90, 17.60, 21.80
AvgTempMax (ºC): 13.81, 14.21, 17.11
AvgTemp (ºC): 9.25, 10.80, 13.45
AvgTempMin (ºC): 4.69, 7.39, 9.80
MinMinTemp (ºC): 1.00, 1.50, 5.00
```

---

## Data Issues Found

[To be identified during detailed analysis]

### Potential Issues to Check:
- Missing values in key columns
- Outliers in numeric data
- Date/time format consistency
- Duplicate records

---

## Data Cleaning Actions

- [ ] Handle missing values
- [ ] Validate numeric ranges
- [ ] Standardize date formats
- [ ] Remove duplicates (if any)
- [ ] Verify data consistency

---

## Column Mapping to Database

| Excel Column | Database Table | Database Column | Transformation |
|--------------|----------------|-----------------|----------------|
| distrito | [table_name] | [column_name] | [transformation] |
| Date | [table_name] | [column_name] | [transformation] |
| ano | [table_name] | [column_name] | [transformation] |
| mes | [table_name] | [column_name] | [transformation] |
| TotalPrecip (mm) | [table_name] | [column_name] | [transformation] |
| DailyMaxPrecip (mm) | [table_name] | [column_name] | [transformation] |
| MaxMaxTemp (ºC) | [table_name] | [column_name] | [transformation] |
| AvgTempMax (ºC) | [table_name] | [column_name] | [transformation] |
| AvgTemp (ºC) | [table_name] | [column_name] | [transformation] |
| AvgTempMin (ºC) | [table_name] | [column_name] | [transformation] |
| MinMinTemp (ºC) | [table_name] | [column_name] | [transformation] |

---

## Next Steps

- [x] Receive and analyze data file
- [x] Document column structure
- [x] Assess data quality
- [ ] Identify data source and metadata
- [ ] Define cleaning requirements
- [ ] Map to database schema
- [ ] Import and validate data

---

**Status:** ✅ **ANALYZED** - Data structure documented

**Last Updated:** 2025-12-27
