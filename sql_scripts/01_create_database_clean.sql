-- ============================================================================
-- Forest Fire Management System - Portugal
-- Database Creation Script
-- ============================================================================
-- Purpose: Create the main database for forest fire management system
-- Database: MySQL/MariaDB
-- ============================================================================

-- Drop database if it exists (for clean reinstallation)
DROP DATABASE IF EXISTS forest_fire_mgmt;

-- Create the database
CREATE DATABASE forest_fire_mgmt
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE forest_fire_mgmt;

-- Display confirmation message
SELECT 'Database forest_fire_mgmt created successfully!' AS Status;
