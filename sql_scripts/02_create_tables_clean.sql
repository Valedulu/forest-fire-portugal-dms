-- ============================================================================
-- Forest Fire Management System - Portugal
-- Tables Creation Script
-- ============================================================================
-- Purpose: Create all tables for the forest fire management database
-- Database: forest_fire_mgmt
-- Normal Form: Third Normal Form (3NF)
-- ============================================================================

USE forest_fire_mgmt;

-- ============================================================================
-- TABLE 1: REGIOES (Regions)
-- ============================================================================
-- Description: Stores Portuguese administrative regions with hierarchical structure
-- Hierarchy: Distrito (District) -> Concelho (Municipality) -> Freguesia (Parish)
-- ============================================================================

CREATE TABLE regioes (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    nuts_id VARCHAR(10),
    region_name VARCHAR(100) NOT NULL,
    region_level ENUM('distrito', 'concelho', 'freguesia') NOT NULL,
    parent_region_id INT,
    area_km2 DECIMAL(10, 2),
    
    -- Self-referencing foreign key for hierarchical structure
    FOREIGN KEY (parent_region_id) REFERENCES regioes(region_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 2: VEGETACAO (Vegetation Types)
-- ============================================================================
-- Description: Reference table for Portuguese vegetation types and flammability
-- Used to classify forest types affected by fires
-- ============================================================================

CREATE TABLE vegetacao (
    vegetation_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_vegetacao VARCHAR(100) NOT NULL UNIQUE,
    inflamabilidade ENUM('baixa', 'media', 'alta') NOT NULL,
    descricao TEXT,
    
    -- Indexes for frequent queries
    INDEX idx_tipo (tipo_vegetacao),
    INDEX idx_inflamabilidade (inflamabilidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 3: INCENDIOS (Fires)
-- ============================================================================
-- Description: Main table storing fire incident data
-- Contains temporal, spatial, and impact information for each fire
-- ============================================================================

CREATE TABLE incendios (
    fire_id INT AUTO_INCREMENT PRIMARY KEY,
    region_id INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    duracao_horas DECIMAL(8, 2),
    area_ardida_ha DECIMAL(12, 2) NOT NULL,
    causa ENUM('natural', 'negligencia', 'intencional', 'desconhecida') NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    
    -- Foreign key to regions
    FOREIGN KEY (region_id) REFERENCES regioes(region_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Indexes for analysis queries
    INDEX idx_region (region_id),
    INDEX idx_data_inicio (data_inicio),
    INDEX idx_ano (ano),
    INDEX idx_mes (mes),
    INDEX idx_causa (causa),
    INDEX idx_area_ardida (area_ardida_ha),
    
    -- Constraints
    CONSTRAINT chk_data_fim CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT chk_duracao CHECK (duracao_horas IS NULL OR duracao_horas >= 0),
    CONSTRAINT chk_area CHECK (area_ardida_ha >= 0),
    CONSTRAINT chk_ano CHECK (ano BETWEEN 1900 AND 2100),
    CONSTRAINT chk_mes CHECK (mes BETWEEN 1 AND 12)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 4: METEOROLOGIA (Weather Conditions)
-- ============================================================================
-- Description: Weather data associated with each fire incident
-- Used to analyze correlation between weather and fire severity
-- ============================================================================

CREATE TABLE meteorologia (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    fire_id INT NOT NULL UNIQUE,
    temperatura_max DECIMAL(5, 2),
    humidade_relativa DECIMAL(5, 2),
    velocidade_vento_kmh DECIMAL(6, 2),
    precipitacao_mm DECIMAL(8, 2),
    indice_fwi DECIMAL(6, 2),
    
    -- Foreign key to fires (one-to-one relationship)
    FOREIGN KEY (fire_id) REFERENCES incendios(fire_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Indexes for analysis
    INDEX idx_temperatura (temperatura_max),
    INDEX idx_humidade (humidade_relativa),
    INDEX idx_vento (velocidade_vento_kmh),
    INDEX idx_fwi (indice_fwi),
    
    -- Constraints for data validity
    CONSTRAINT chk_temperatura CHECK (temperatura_max BETWEEN -50 AND 60),
    CONSTRAINT chk_humidade CHECK (humidade_relativa BETWEEN 0 AND 100),
    CONSTRAINT chk_vento CHECK (velocidade_vento_kmh >= 0),
    CONSTRAINT chk_precipitacao CHECK (precipitacao_mm >= 0),
    CONSTRAINT chk_fwi CHECK (indice_fwi >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 5: INCENDIO_VEGETACAO (Fire-Vegetation Junction Table)
-- ============================================================================
-- Description: Many-to-many relationship between fires and vegetation types
-- Tracks which vegetation types were affected in each fire and to what extent
-- ============================================================================

CREATE TABLE incendio_vegetacao (
    fire_veg_id INT AUTO_INCREMENT PRIMARY KEY,
    fire_id INT NOT NULL,
    vegetation_id INT NOT NULL,
    area_afetada_ha DECIMAL(12, 2) NOT NULL,
    percentagem_area DECIMAL(5, 2),
    
    -- Foreign keys
    FOREIGN KEY (fire_id) REFERENCES incendios(fire_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (vegetation_id) REFERENCES vegetacao(vegetation_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Unique constraint: one entry per fire-vegetation combination
    UNIQUE KEY unique_fire_vegetation (fire_id, vegetation_id),
    
    -- Indexes
    INDEX idx_fire (fire_id),
    INDEX idx_vegetation (vegetation_id),
    
    -- Constraints
    CONSTRAINT chk_area_afetada CHECK (area_afetada_ha >= 0),
    CONSTRAINT chk_percentagem CHECK (percentagem_area IS NULL OR 
                                      (percentagem_area >= 0 AND percentagem_area <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Display table creation summary
-- ============================================================================
SELECT 'All tables created successfully!' AS Status;

SHOW TABLES;
