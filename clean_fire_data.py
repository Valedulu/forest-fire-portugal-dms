#!/usr/bin/env python3
"""
Forest Fire Data Cleaning Script

This script processes raw ICNF SGIF fire data from Excel files and prepares
clean CSV files ready for database import.

Purpose:
    - Load raw fire data from Portuguese ICNF database
    - Clean and standardize data for consistency
    - Filter for 2015-2024 period
    - Export to CSV format for SQL import

Input Files:
    - original_data/fires/Registos_Incendios_SGIF_2011_2020.xlsx (177,129 records)
    - original_data/fires/Registos_Incendios_SGIF_2021_2024.xlsx (32,355 records)

Output Files:
    - processed_data/fires_cleaned.csv (~121,551 records after cleaning)

Data Quality:
    - Removes records with missing critical fields (ano, mes, area)
    - Filters for 2015-2024 time period
    - Removes fires with 0 area (false alarms)
    - Standardizes cause categories
    - Cleans unrealistic duration values

Usage:
    python clean_fire_data.py

Requirements:
    - pandas
    - numpy
    - openpyxl (for Excel file reading)

Notes:
    - Script expects original_data/fires/ folder to exist
    - Creates processed_data/ folder if it doesn't exist
    - Generates detailed console output showing cleaning progress
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================

# Directory paths
INPUT_DIR = Path("original_data/fires")
OUTPUT_DIR = Path("processed_data")

# Create output directory if it doesn't exist
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# File paths for input Excel files
FILE_2011_2020 = INPUT_DIR / "Registos_Incendios_SGIF_2011_2020.xlsx"
FILE_2021_2024 = INPUT_DIR / "Registos_Incendios_SGIF_2021_2024.xlsx"

# Output CSV file
OUTPUT_FILE = OUTPUT_DIR / "fires_cleaned.csv"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def map_causa(tipo_causa):
    """
    Map Portuguese fire cause types to standardized categories.
    
    Maps the original Portuguese cause classifications to four standard
    categories used in our database: negligencia, intencional, natural,
    and desconhecida (unknown).
    
    Args:
        tipo_causa (str): Original cause description from ICNF data
        
    Returns:
        str: Standardized cause category ('negligencia', 'intencional', 
             'natural', or 'desconhecida')
             
    Examples:
        >>> map_causa('Uso do fogo - Negligente')
        'negligencia'
        >>> map_causa('Incendiarismo')
        'intencional'
        >>> map_causa('Raio')
        'natural'
        >>> map_causa(None)
        'desconhecida'
    """
    # Handle missing values
    if pd.isna(tipo_causa):
        return 'desconhecida'
    
    # Convert to lowercase for case-insensitive matching
    tipo_lower = str(tipo_causa).lower()
    
    # Match patterns in cause description
    if 'neglig' in tipo_lower:
        return 'negligencia'
    elif 'intencional' in tipo_lower:
        return 'intencional'
    elif 'natural' in tipo_lower or 'raio' in tipo_lower:
        return 'natural'
    else:
        return 'desconhecida'

# ============================================================================
# MAIN PROCESSING
# ============================================================================

print("="*70)
print("FIRE DATA CLEANING SCRIPT")
print("="*70)

# ============================================================================
# STEP 1: Load the Excel files
# ============================================================================
print("\nSTEP 1: Loading Excel files...")

try:
    # Load 2011-2020 dataset
    print(f"  Loading: {FILE_2011_2020.name}")
    df_2011_2020 = pd.read_excel(FILE_2011_2020)
    print(f"  ✓ Loaded {len(df_2011_2020):,} records from 2011-2020")
    
    # Load 2021-2024 dataset
    print(f"  Loading: {FILE_2021_2024.name}")
    df_2021_2024 = pd.read_excel(FILE_2021_2024)
    print(f"  ✓ Loaded {len(df_2021_2024):,} records from 2021-2024")
    
except FileNotFoundError as e:
    print(f"  ✗ Error: Input file not found - {e}")
    print(f"  Please ensure Excel files are in: {INPUT_DIR}")
    exit(1)
except Exception as e:
    print(f"  ✗ Error loading files: {e}")
    exit(1)

# ============================================================================
# STEP 2: Combine datasets
# ============================================================================
print("\nSTEP 2: Combining datasets...")

# Concatenate both dataframes vertically
# ignore_index=True creates new sequential index starting from 0
df = pd.concat([df_2011_2020, df_2021_2024], ignore_index=True)
print(f"  ✓ Total records: {len(df):,}")

# ============================================================================
# STEP 3: Inspect data structure
# ============================================================================
print("\nSTEP 3: Data inspection...")
print(f"  Columns: {len(df.columns)}")
print(f"  Column names: {list(df.columns[:20])}...")  # Show first 20 columns

# Display data types for first 20 columns
print("\n  Data types:")
print(df.dtypes.head(20))

# Check for missing values in critical columns
print("\n  Missing values in key columns:")
missing_cols = ['Ano', 'Mes', 'Distrito', 'Concelho', 'AreaTotal_ha']
for col in missing_cols:
    if col in df.columns:
        missing_count = df[col].isnull().sum()
        missing_pct = (missing_count / len(df)) * 100
        print(f"    {col}: {missing_count:,} ({missing_pct:.2f}%)")

# ============================================================================
# STEP 4: Select and rename columns for our database
# ============================================================================
print("\nSTEP 4: Selecting and renaming columns...")

# Define mapping from ICNF Excel columns to our database column names
# This ensures consistency with our database schema
column_mapping = {
    'Codigo_SGIF': 'fire_code',              # Unique fire identifier from SGIF
    'Ano': 'ano',                             # Year
    'Mes': 'mes',                             # Month
    'Dia': 'dia',                             # Day
    'Distrito': 'distrito',                   # District (18 regions)
    'Concelho': 'concelho',                   # Municipality
    'Freguesia': 'freguesia',                 # Parish (smallest admin unit)
    'Local': 'local',                         # Specific location name
    'AreaTotal_ha': 'area_ardida_ha',        # Total burned area in hectares
    'AreaPov_ha': 'area_povoamento_ha',      # Forest area burned
    'AreaMato_ha': 'area_mato_ha',           # Shrubland area burned
    'AreaAgric_ha': 'area_agricola_ha',      # Agricultural area burned
    'TipoCausa': 'tipo_causa',                # Fire cause type
    'GrupoCausa': 'grupo_causa',              # Fire cause group
    'DescricaoCausa': 'descricao_causa',      # Fire cause description
    'DataHora_Alerta': 'data_hora_alerta',    # Alert date/time
    'DataHora_PrimeiraIntervencao': 'data_hora_primeira_intervencao',  # First response
    'DataHora_Extincao': 'data_hora_extincao',  # Extinction date/time
    'Latitude': 'latitude',                    # Geographic coordinates
    'Longitude': 'longitude'
}

# Select only columns that exist in the dataframe
# This handles cases where column names might differ between file versions
available_columns = {k: v for k, v in column_mapping.items() if k in df.columns}
df_clean = df[list(available_columns.keys())].copy()
df_clean.rename(columns=available_columns, inplace=True)

print(f"  ✓ Selected {len(df_clean.columns)} columns")

# ============================================================================
# STEP 5: Data cleaning and transformations
# ============================================================================
print("\nSTEP 5: Cleaning data...")

# 5.1 Remove rows with missing critical fields
print("  5.1 Removing rows with missing critical data...")
initial_count = len(df_clean)

# Drop rows where year, month, or area are missing
# These are essential fields for our analysis
df_clean = df_clean.dropna(subset=['ano', 'mes', 'area_ardida_ha'])

removed = initial_count - len(df_clean)
print(f"      Removed {removed:,} rows with missing critical data")

# 5.2 Filter for years 2015-2024
print("  5.2 Filtering for years 2015-2024...")

# Keep only the analysis period we're interested in
df_clean = df_clean[(df_clean['ano'] >= 2015) & (df_clean['ano'] <= 2024)]
print(f"      Kept {len(df_clean):,} records from 2015-2024")

# 5.3 Clean area values
print("  5.3 Cleaning area values...")

# Remove negative areas (data errors)
df_clean['area_ardida_ha'] = df_clean['area_ardida_ha'].clip(lower=0)

# Remove fires with 0 area (likely false alarms or errors)
df_clean = df_clean[df_clean['area_ardida_ha'] > 0]
print(f"      Removed fires with 0 area, {len(df_clean):,} records remain")

# 5.4 Standardize cause categories
print("  5.4 Standardizing cause categories...")

# Apply the causa mapping function to create standardized cause field
if 'tipo_causa' in df_clean.columns:
    df_clean['causa'] = df_clean['tipo_causa'].apply(map_causa)
else:
    # If cause column doesn't exist, mark all as unknown
    df_clean['causa'] = 'desconhecida'

print(f"      Cause distribution:")
print(df_clean['causa'].value_counts())

# 5.5 Create date fields
print("  5.5 Creating date fields...")

# Try to parse alert datetime as fire start
if 'data_hora_alerta' in df_clean.columns:
    # Parse datetime strings, set invalid dates to NaT (Not a Time)
    df_clean['data_inicio'] = pd.to_datetime(df_clean['data_hora_alerta'], errors='coerce')
else:
    # Fallback: construct date from year, month, day columns
    if all(col in df_clean.columns for col in ['ano', 'mes', 'dia']):
        df_clean['data_inicio'] = pd.to_datetime(
            df_clean[['ano', 'mes', 'dia']].rename(
                columns={'ano': 'year', 'mes': 'month', 'dia': 'day'}
            ),
            errors='coerce'
        )

# Parse extinction datetime as fire end
if 'data_hora_extincao' in df_clean.columns:
    df_clean['data_fim'] = pd.to_datetime(df_clean['data_hora_extincao'], errors='coerce')
else:
    df_clean['data_fim'] = None

# Calculate fire duration in hours
if 'data_inicio' in df_clean.columns and 'data_fim' in df_clean.columns:
    # Calculate time difference and convert to hours
    df_clean['duracao_horas'] = (
        (df_clean['data_fim'] - df_clean['data_inicio']).dt.total_seconds() / 3600
    )
    
    # Clean unrealistic durations
    # Negative durations indicate data errors
    df_clean.loc[df_clean['duracao_horas'] < 0, 'duracao_horas'] = None
    
    # Fires lasting more than 1 year (8760 hours) are likely data errors
    df_clean.loc[df_clean['duracao_horas'] > 8760, 'duracao_horas'] = None
else:
    df_clean['duracao_horas'] = None

print(f"      Created date fields")

# 5.6 Clean location names
print("  5.6 Cleaning location names...")

# Standardize location name formatting
for col in ['distrito', 'concelho', 'freguesia']:
    if col in df_clean.columns:
        # Remove leading/trailing whitespace
        df_clean[col] = df_clean[col].str.strip()
        
        # Convert to Title Case for consistency
        df_clean[col] = df_clean[col].str.title()

print(f"      Cleaned location names")

# ============================================================================
# STEP 6: Create final output columns
# ============================================================================
print("\nSTEP 6: Preparing final output...")

# Define the final column order for database import
# This matches the structure expected by our SQL import scripts
final_columns = [
    'fire_code',           # Unique identifier
    'ano',                 # Year
    'mes',                 # Month
    'distrito',            # District
    'concelho',            # Municipality
    'freguesia',           # Parish
    'local',               # Specific location
    'data_inicio',         # Start date/time
    'data_fim',            # End date/time
    'duracao_horas',       # Duration in hours
    'area_ardida_ha',      # Total burned area
    'area_povoamento_ha',  # Forest area
    'area_mato_ha',        # Shrubland area
    'area_agricola_ha',    # Agricultural area
    'causa',               # Standardized cause
    'latitude',            # Coordinates
    'longitude'
]

# Keep only columns that exist (handles missing optional columns)
final_columns = [col for col in final_columns if col in df_clean.columns]
df_final = df_clean[final_columns].copy()

# ============================================================================
# STEP 7: Save cleaned data
# ============================================================================
print("\nSTEP 7: Saving cleaned data...")

try:
    # Export to CSV with UTF-8 encoding
    # index=False prevents pandas from adding a row number column
    df_final.to_csv(OUTPUT_FILE, index=False, encoding='utf-8')
    
    print(f"  ✓ Saved to: {OUTPUT_FILE}")
    print(f"  ✓ Final record count: {len(df_final):,}")
    print(f"  ✓ Columns: {len(df_final.columns)}")
    
except Exception as e:
    print(f"  ✗ Error saving file: {e}")
    exit(1)

# ============================================================================
# STEP 8: Generate summary statistics
# ============================================================================
print("\n" + "="*70)
print("DATA SUMMARY")
print("="*70)

# Show distribution by year
print(f"\nRecords by year:")
print(df_final['ano'].value_counts().sort_index())

# Show distribution by cause
print(f"\nRecords by cause:")
print(df_final['causa'].value_counts())

# Show area statistics
print(f"\nArea statistics (hectares):")
print(df_final['area_ardida_ha'].describe())

# Show top districts
print(f"\nTop 10 districts by number of fires:")
if 'distrito' in df_final.columns:
    print(df_final['distrito'].value_counts().head(10))

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================
print("\n" + "="*70)
print("CLEANING COMPLETE!")
print("="*70)
print(f"\nNext steps:")
print(f"1. Review the cleaned data: {OUTPUT_FILE}")
print(f"2. Import to database: Run sql_scripts/05_import_fires.sql")
print(f"3. Verify data loaded correctly in MariaDB/MySQL")
print("="*70)
