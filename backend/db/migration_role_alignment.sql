-- ============================================================
-- Migration: Role Alignment
-- Purpose  : Align users table with the frontend contract:
--            1. Add full_name column (stored directly in users table)
--            2. Rename ENUM value 'patient' → 'user'
--               so user_type stores 'admin'|'doctor'|'user'
--               matching the API 'role' field exactly.
-- Run once on an existing database.
-- ============================================================

-- STEP 1: Add full_name column (if not already present)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS full_name VARCHAR(255) NOT NULL DEFAULT ''
    AFTER password;

-- STEP 2: Migrate existing 'patient' rows to 'user'
--         Do this BEFORE altering the ENUM so the value is still valid.
UPDATE users SET user_type = 'user' WHERE user_type = 'patient';

-- STEP 3: Recreate the ENUM with updated values
ALTER TABLE users
    MODIFY COLUMN user_type ENUM('admin', 'doctor', 'user') NOT NULL;

-- Verify
SELECT DISTINCT user_type FROM users;
