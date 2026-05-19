-- ============================================================
-- Migration: Onboarding Schema Alignment
-- Version: 2026-05-19
-- Purpose: Add missing columns for new 8-step onboarding flow.
--          All changes are ADD COLUMN IF NOT EXISTS — safe to
--          run on top of the v2.1 combined schema.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ────────────────────────────────────────────────────────────
-- 1. users table:
--    Add onboarding step tracking columns (rename guard via COALESCE)
--    The combined schema already has onboarding_step INT DEFAULT 0.
--    We also need: is_onboarding_submitted, onboarding_submitted_at
-- ────────────────────────────────────────────────────────────
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS registration_step        INT         NOT NULL DEFAULT 0 AFTER onboarding_step,
    ADD COLUMN IF NOT EXISTS onboarding_completed     TINYINT(1)  NOT NULL DEFAULT 0 AFTER registration_step,
    ADD COLUMN IF NOT EXISTS onboarding_submitted_at  DATETIME    NULL AFTER onboarding_completed;

-- Sync registration_step from onboarding_step so both point to same data
UPDATE users SET registration_step = onboarding_step WHERE registration_step = 0 AND onboarding_step > 0;


-- ────────────────────────────────────────────────────────────
-- 2. doctor_profiles table:
--    Add new onboarding fields not in v2.1 schema
-- ────────────────────────────────────────────────────────────
ALTER TABLE doctor_profiles
    -- Professional identity (Step 2)
    ADD COLUMN IF NOT EXISTS primary_title              VARCHAR(100)    NULL AFTER primary_specialty,
    ADD COLUMN IF NOT EXISTS secondary_title            VARCHAR(100)    NULL AFTER primary_title,
    ADD COLUMN IF NOT EXISTS therapy_approaches         JSON            NULL AFTER therapy_types,
    ADD COLUMN IF NOT EXISTS professional_bio           TEXT            NULL AFTER therapy_approaches,

    -- Government ID (Step 2 upload)
    ADD COLUMN IF NOT EXISTS govt_id_front_url          VARCHAR(500)    NULL AFTER professional_bio,
    ADD COLUMN IF NOT EXISTS govt_id_back_url           VARCHAR(500)    NULL AFTER govt_id_front_url,

    -- Professional registration / RCI (Step 4)
    ADD COLUMN IF NOT EXISTS registration_type          ENUM('rci', 'none') NOT NULL DEFAULT 'none' AFTER govt_id_back_url,
    ADD COLUMN IF NOT EXISTS rci_crr_number             VARCHAR(100)    NULL AFTER registration_type,
    ADD COLUMN IF NOT EXISTS rci_certificate_url        VARCHAR(500)    NULL AFTER rci_crr_number,
    ADD COLUMN IF NOT EXISTS self_declaration_accepted  TINYINT(1)      NOT NULL DEFAULT 0 AFTER rci_certificate_url,

    -- Session fee (Step 6)
    ADD COLUMN IF NOT EXISTS session_price              DECIMAL(10,2)   NULL AFTER follow_up_rate,
    ADD COLUMN IF NOT EXISTS consultation_duration_min  SMALLINT        NOT NULL DEFAULT 60 AFTER session_price,

    -- Submission tracking
    ADD COLUMN IF NOT EXISTS submitted_at               DATETIME        NULL AFTER trust_badge_earned,
    ADD COLUMN IF NOT EXISTS reviewed_at                DATETIME        NULL AFTER submitted_at,
    ADD COLUMN IF NOT EXISTS rejected_reason            TEXT            NULL AFTER reviewed_at;


-- ────────────────────────────────────────────────────────────
-- 3. doctor_experiences table:
--    Add work_type and proof_document_url columns
-- ────────────────────────────────────────────────────────────
ALTER TABLE doctor_experiences
    ADD COLUMN IF NOT EXISTS work_type          ENUM('hospital','private_practice','ngo','online_platform','other')
                                                NOT NULL DEFAULT 'hospital' AFTER employment_type,
    ADD COLUMN IF NOT EXISTS custom_work_type   VARCHAR(100)    NULL AFTER work_type,
    ADD COLUMN IF NOT EXISTS proof_document_url VARCHAR(500)    NULL AFTER description,
    ADD COLUMN IF NOT EXISTS verification_status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending' AFTER proof_document_url;

-- Sync work_type from employment_type for existing rows
UPDATE doctor_experiences
SET work_type = CASE
    WHEN employment_type IN ('full_time','part_time','contract') THEN 'hospital'
    WHEN employment_type = 'freelance' THEN 'private_practice'
    WHEN employment_type = 'internship' THEN 'hospital'
    ELSE 'other'
END
WHERE work_type = 'hospital' AND employment_type IS NOT NULL;


-- ────────────────────────────────────────────────────────────
-- 4. doctor_payout_accounts table (if not exists)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS doctor_payout_accounts (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id               CHAR(36)        NOT NULL,
    account_holder_name     VARCHAR(200)    NOT NULL,
    account_number          VARCHAR(50)     NOT NULL,
    ifsc_code               VARCHAR(20)     NOT NULL,
    bank_name               VARCHAR(100)    NOT NULL,
    branch_name             VARCHAR(100)    NOT NULL,
    pan_number              VARCHAR(20)     NOT NULL,
    is_gst_registered       TINYINT(1)      NOT NULL DEFAULT 0,
    gst_number              VARCHAR(20)     NULL,
    is_primary              TINYINT(1)      NOT NULL DEFAULT 1,
    verification_status     ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_payout_account_number (account_number),
    UNIQUE KEY uq_payout_pan (pan_number),
    INDEX idx_payout_doctor (doctor_id),

    CONSTRAINT fk_payout_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ────────────────────────────────────────────────────────────
-- 5. doctor_verification_logs table (if not exists)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS doctor_verification_logs (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    action              VARCHAR(100)    NOT NULL,   -- e.g. step_completed, submitted, approved
    step_number         TINYINT         NULL,
    previous_status     VARCHAR(50)     NULL,
    new_status          VARCHAR(50)     NULL,
    details             JSON            NULL,
    admin_id            CHAR(36)        NULL,
    admin_notes         TEXT            NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_vlog_doctor   (doctor_id),
    INDEX idx_vlog_created  (created_at),

    CONSTRAINT fk_vlog_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ────────────────────────────────────────────────────────────
-- VERIFICATION QUERIES — run these after migration to confirm
-- ────────────────────────────────────────────────────────────
-- DESCRIBE users;
-- DESCRIBE doctor_profiles;
-- DESCRIBE doctor_experiences;
-- SHOW CREATE TABLE doctor_payout_accounts;
-- SHOW CREATE TABLE doctor_verification_logs;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- END OF MIGRATION: 20260519_onboarding_schema_alignment.sql
-- ============================================================
