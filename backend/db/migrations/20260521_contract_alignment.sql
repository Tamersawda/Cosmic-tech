-- ============================================================
-- Migration: Contract Alignment
-- Version: 2026-05-21
-- Purpose: Align schema with Doctor Registration Flow Blueprint
--          - Rename legacy columns to canonical names
--          - Add missing Blueprint fields
--          - Prepare for deprecation of non-Blueprint columns
--
-- This migration ensures 100% Blueprint compliance by:
--   1. Renaming experience columns (company→organization, role_title→role)
--   2. Adding missing fields (institution, terms_consent, session_fee_tier)
--   3. Setting up canonical naming for Phase 3 deprecation
--
-- Note: Deprecated columns are NOT dropped yet (Phase 3 task).
--       They remain for backwards compatibility with legacy code.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ────────────────────────────────────────────────────────────
-- 1. doctor_experiences table:
--    Rename company → organization, role_title → role
--    Drop employment_type (deprecated, replaced by work_type)
-- ────────────────────────────────────────────────────────────

-- Step 1a: Add new canonical columns (if they don't exist)
ALTER TABLE doctor_experiences
    ADD COLUMN IF NOT EXISTS organization   VARCHAR(255)    NULL AFTER doctor_id,
    ADD COLUMN IF NOT EXISTS role           VARCHAR(255)    NULL AFTER organization;

-- Step 1b: Migrate data from legacy columns to canonical
UPDATE doctor_experiences
SET organization = company
WHERE organization IS NULL AND company IS NOT NULL;

UPDATE doctor_experiences
SET role = role_title
WHERE role IS NOT NULL AND role_title IS NOT NULL;

-- Step 1c: Verify work_type is present (from previous migration)
ALTER TABLE doctor_experiences
    ADD COLUMN IF NOT EXISTS work_type          ENUM('hospital','private_practice','ngo','online_platform','other')
                                                NOT NULL DEFAULT 'hospital',
    ADD COLUMN IF NOT EXISTS custom_work_type   VARCHAR(100)    NULL;

-- Note: employment_type is deprecated but kept for now
--       Phase 3: Add migration to DROP employment_type, company, role_title

-- ────────────────────────────────────────────────────────────
-- 2. doctor_qualifications table:
--    Ensure institution column exists (Blueprint requirement)
-- ────────────────────────────────────────────────────────────

ALTER TABLE doctor_qualifications
    ADD COLUMN IF NOT EXISTS qualification_name VARCHAR(255)   NULL AFTER title,
    ADD COLUMN IF NOT EXISTS institution        VARCHAR(255)   NULL AFTER qualification_name,
    ADD COLUMN IF NOT EXISTS specialization     VARCHAR(255)   NULL AFTER institution,
    ADD COLUMN IF NOT EXISTS passing_year       SMALLINT        NULL AFTER specialization,
    ADD COLUMN IF NOT EXISTS certificate_url    VARCHAR(500)    NULL AFTER passing_year,
    ADD COLUMN IF NOT EXISTS verification_status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending' AFTER certificate_url;

-- Migrate data from legacy columns to canonical (if not already populated)
UPDATE doctor_qualifications
SET qualification_name = title
WHERE qualification_name IS NULL AND title IS NOT NULL;

UPDATE doctor_qualifications
SET passing_year = year
WHERE passing_year IS NULL AND year IS NOT NULL;

UPDATE doctor_qualifications
SET certificate_url = document_path
WHERE certificate_url IS NULL AND document_path IS NOT NULL;

-- Note: title, degree, year, document_path are deprecated but kept for now
--       Phase 3: Add migration to DROP these columns

-- ────────────────────────────────────────────────────────────
-- 3. doctor_payout_accounts table:
--    Add terms_consent (Blueprint requirement)
-- ────────────────────────────────────────────────────────────

ALTER TABLE doctor_payout_accounts
    ADD COLUMN IF NOT EXISTS terms_consent      TINYINT(1)      NOT NULL DEFAULT 0 AFTER gst_number;

-- ────────────────────────────────────────────────────────────
-- 4. doctor_profiles table:
--    Add session_fee_tier (Blueprint canonical tier values)
-- ────────────────────────────────────────────────────────────

ALTER TABLE doctor_profiles
    ADD COLUMN IF NOT EXISTS session_fee_tier       ENUM('799','999','1499','1999','2499') NULL AFTER follow_up_rate,
    ADD COLUMN IF NOT EXISTS pricing_justification  TEXT                                   NULL AFTER session_fee_tier;

-- Note: session_price, followup_price, consultation_duration_min are deprecated
--       Phase 3: Migrate logic to use session_fee_tier, then DROP legacy columns

-- ────────────────────────────────────────────────────────────
-- 5. Ensure verification_status values are correct
-- ────────────────────────────────────────────────────────────

-- Update doctor_profiles verification_status enum if needed
-- (Already set in combined_schema.sql, but enforcing here)
ALTER TABLE doctor_profiles
    MODIFY verification_status ENUM('pending','approved','rejected','action_required') NOT NULL DEFAULT 'pending';

-- ────────────────────────────────────────────────────────────
-- VERIFICATION QUERIES (run after migration)
-- ────────────────────────────────────────────────────────────
-- DESCRIBE doctor_experiences;
-- DESCRIBE doctor_qualifications;
-- DESCRIBE doctor_payout_accounts;
-- SHOW CREATE TABLE doctor_profiles;
-- SELECT COUNT(*) FROM doctor_experiences WHERE organization IS NOT NULL;
-- SELECT COUNT(*) FROM doctor_qualifications WHERE qualification_name IS NOT NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- END OF MIGRATION: 20260521_contract_alignment.sql
-- ============================================================
