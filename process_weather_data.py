#!/usr/bin/env python3
"""
Weather Data Processing Script

This script processes Duarte's weather data files (temperature and precipitation)
and creates a single clean CSV ready for database import.

Input:
    - Multiple temperature CSV files (one per district)
    - Multiple precipitation CSV files (one per district)
    
Output:
    - weather_data_clean.csv (combined data for 2015-2020)

Usage:
    python process_weather_data.py
"""

import pandas as pd
import glob
from pathlib import Path
import re

# Configuration
INPUT_FOLDER = "original_data/weather"  # Folder with all weather CSV files
OUTPUT_FILE = "processed_data/weather_data_clean.csv"

print("="*70)
print("WEATHER DATA PROCESSING SCRIPT")
print("="*70)

# ============================================================================
# STEP 1: Find all weather files
# ============================================================================
print("\nSTEP 1: Finding weather files...")

temp_files = glob.glob(f"{INPUT_FOLDER}/Monthly average air temperature*.csv")
precip_files = glob.glob(f"{INPUT_FOLDER}/Monthly total precipitation*.csv")

print(f"  Found {len(temp_files)} temperature files")
print(f"  Found {len(precip_files)} precipitation files")

if len(temp_files) == 0 or len(precip_files) == 0:
    print("\n  ERROR: No files found!")
    print(f"  Make sure files are in: {INPUT_FOLDER}/")
    exit(1)

# ============================================================================
# STEP 2: Extract district name from filename
# ============================================================================

def extract_district(filename):
    """
    Extract district name from filename.
    Examples:
        'Monthly total precipitation - Bragança.csv' -> 'Bragança'
        'Monthly total precipitation - Porto - Pedras Rubras.csv' -> 'Porto'
    """
    # Get just the filename without path
    name = Path(filename).name
    
    # Remove the prefix
    if "Monthly average air temperature - " in name:
        name = name.replace("Monthly average air temperature - ", "")
    elif "Monthly total precipitation - " in name:
        name = name.replace("Monthly total precipitation - ", "")
    
    # Remove .csv
    name = name.replace(".csv", "")
    
    # Take everything before first " - " (if exists)
    if " - " in name:
        district = name.split(" - ")[0].strip()
    else:
        district = name.strip()
    
    return district

# ============================================================================
# STEP 3: Process temperature files
# ============================================================================
print("\nSTEP 2: Processing temperature files...")

temp_data_list = []

for file in temp_files:
    district = extract_district(file)
    
    try:
        # Read CSV
        df = pd.read_csv(file)
        
        # Parse date column
        df['Date'] = pd.to_datetime(df['Date'], format='%m/%d/%Y', errors='coerce')
        
        # Extract year and month
        df['year'] = df['Date'].dt.year
        df['month'] = df['Date'].dt.month
        
        # Filter for 2015-2020
        df = df[(df['year'] >= 2015) & (df['year'] <= 2020)]
        
        if len(df) == 0:
            print(f"  WARNING: No data for 2015-2020 in {district}")
            continue
        
        # Select relevant columns - use "Average of average" as main temperature
        df_clean = pd.DataFrame({
            'distrito': district,
            'year': df['year'],
            'month': df['month'],
            'temperatura_media': df['Average of average'],
            'temperatura_max': df['Average of maximum'],
            'temperatura_min': df['Average of minimum']
        })
        
        temp_data_list.append(df_clean)
        print(f"  ✓ {district}: {len(df_clean)} months (2015-2020)")
        
    except Exception as e:
        print(f"  ✗ Error processing {district}: {e}")

if len(temp_data_list) == 0:
    print("\n  ERROR: No temperature data processed!")
    exit(1)

# Combine all temperature data
temp_combined = pd.concat(temp_data_list, ignore_index=True)
print(f"\n  Total temperature records: {len(temp_combined)}")

# ============================================================================
# STEP 4: Process precipitation files
# ============================================================================
print("\nSTEP 3: Processing precipitation files...")

precip_data_list = []

for file in precip_files:
    district = extract_district(file)
    
    try:
        # Read CSV
        df = pd.read_csv(file)
        
        # Parse date column
        df['Date'] = pd.to_datetime(df['Date'], format='%m/%d/%Y', errors='coerce')
        
        # Extract year and month
        df['year'] = df['Date'].dt.year
        df['month'] = df['Date'].dt.month
        
        # Filter for 2015-2020
        df = df[(df['year'] >= 2015) & (df['year'] <= 2020)]
        
        if len(df) == 0:
            print(f"  WARNING: No data for 2015-2020 in {district}")
            continue
        
        # Select relevant columns
        df_clean = pd.DataFrame({
            'distrito': district,
            'year': df['year'],
            'month': df['month'],
            'precipitacao_total_mm': df['Monthly total']
        })
        
        precip_data_list.append(df_clean)
        print(f"  ✓ {district}: {len(df_clean)} months (2015-2020)")
        
    except Exception as e:
        print(f"  ✗ Error processing {district}: {e}")

if len(precip_data_list) == 0:
    print("\n  ERROR: No precipitation data processed!")
    exit(1)

# Combine all precipitation data
precip_combined = pd.concat(precip_data_list, ignore_index=True)
print(f"\n  Total precipitation records: {len(precip_combined)}")

# ============================================================================
# STEP 5: Merge temperature and precipitation
# ============================================================================
print("\nSTEP 4: Merging temperature and precipitation...")

# Merge on district, year, month
weather_combined = pd.merge(
    temp_combined,
    precip_combined,
    on=['distrito', 'year', 'month'],
    how='outer'  # Keep all records even if temp or precip is missing
)

print(f"  Merged records: {len(weather_combined)}")

# Check for missing matches
missing_temp = weather_combined['temperatura_media'].isna().sum()
missing_precip = weather_combined['precipitacao_total_mm'].isna().sum()

if missing_temp > 0:
    print(f"  WARNING: {missing_temp} records missing temperature (e.g., Évora)")
if missing_precip > 0:
    print(f"  WARNING: {missing_precip} records missing precipitation")

# ============================================================================
# STEP 6: Add month name for readability
# ============================================================================

month_names = {
    1: 'Janeiro', 2: 'Fevereiro', 3: 'Março', 4: 'Abril',
    5: 'Maio', 6: 'Junho', 7: 'Julho', 8: 'Agosto',
    9: 'Setembro', 10: 'Outubro', 11: 'Novembro', 12: 'Dezembro'
}

weather_combined['mes_nome'] = weather_combined['month'].map(month_names)

# ============================================================================
# STEP 7: Sort and organize
# ============================================================================
print("\nSTEP 5: Organizing data...")

# Sort by district, year, month
weather_combined = weather_combined.sort_values(['distrito', 'year', 'month'])

# Reorder columns
final_columns = [
    'distrito',
    'year',
    'month',
    'mes_nome',
    'temperatura_media',
    'temperatura_max',
    'temperatura_min',
    'precipitacao_total_mm'
]

weather_final = weather_combined[final_columns].copy()

# ============================================================================
# STEP 8: Save to CSV
# ============================================================================
print("\nSTEP 6: Saving cleaned data...")

# Create output directory if needed
Path("processed_data").mkdir(exist_ok=True)

try:
    weather_final.to_csv(OUTPUT_FILE, index=False, encoding='utf-8')
    print(f"  ✓ Saved to: {OUTPUT_FILE}")
    print(f"  ✓ Total records: {len(weather_final)}")
except Exception as e:
    print(f"  ✗ Error saving file: {e}")
    exit(1)

# ============================================================================
# STEP 9: Generate summary
# ============================================================================
print("\n" + "="*70)
print("DATA SUMMARY")
print("="*70)

print(f"\nDistricts with data:")
districts = weather_final['distrito'].unique()
for district in sorted(districts):
    count = len(weather_final[weather_final['distrito'] == district])
    print(f"  {district}: {count} months")

print(f"\nTotal districts: {len(districts)}")
print(f"Total records: {len(weather_final)}")
print(f"Period: 2015-2020")
print(f"Expected records per district: 72 months (6 years × 12 months)")

# Check completeness
print(f"\nData completeness:")
print(f"  Temperature records: {weather_final['temperatura_media'].notna().sum()} / {len(weather_final)}")
print(f"  Precipitation records: {weather_final['precipitacao_total_mm'].notna().sum()} / {len(weather_final)}")

print("\n" + "="*70)
print("PROCESSING COMPLETE!")
print("="*70)
print(f"\nNext steps:")
print(f"1. Review the cleaned data: {OUTPUT_FILE}")
print(f"2. Import to database using SQL import script")
print(f"3. Run Q4 weather correlation analysis")
print("="*70)
