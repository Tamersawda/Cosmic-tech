-- ============================================================
-- Migration: Refactor Doctor Onboarding Schema
-- Date: 2026-06-16
-- Description: Replace boolean flags with profile_status ENUM,
--              add registration_step ENUM, create doctor_payouts,
--              and enhance doctor_documents table.
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================
-- STEP 1: ALTER doctor_profiles
-- - Drop boolean columns (is_verified, is_profile_approved, onboarding_* fields, verification_status)
-- - Add profile_status ENUM
-- - Add registration_step ENUM
-- - Add admin_note, submitted_at, reviewed_at, reviewed_by
-- ============================================================

-- Drop old columns that are being replaced
ALTER TABLE `doctor_profiles`
    DROP COLUMN IF EXISTS `is_verified`,
    DROP COLUMN IF EXISTS `is_profile_approved`,
    DROP COLUMN IF EXISTS `onboarding_current_step`,
    DROP COLUMN IF EXISTS `onboarding_completed_steps`,
    DROP COLUMN IF EXISTS `onboarding_percentage`,
    DROP COLUMN IF EXISTS `verification_status`;

-- Add new workflow columns after user_id (primary key)
ALTER TABLE `doctor_profiles`
    ADD COLUMN `profile_status` ENUM(
        'draft','submitted','approved','rejected',
        'payout_pending','active','suspended'
    ) NOT NULL DEFAULT 'draft' AFTER `user_id`,
    ADD COLUMN `registration_step` ENUM(
        'basic_info','professional_details','qualifications',
        'professional_registration','work_experience','session_fee','completed'
    ) NOT NULL DEFAULT 'basic_info' AFTER `profile_status`,
    ADD COLUMN `admin_note` TEXT NULL AFTER `pricing_justification`,
    ADD COLUMN `submitted_at` DATETIME NULL AFTER `admin_note`,
    ADD COLUMN `reviewed_at` DATETIME NULL AFTER `submitted_at`,
    ADD COLUMN `reviewed_by` CHAR(36) NULL AFTER `reviewed_at`;

-- Add indexes for new columns
ALTER TABLE `doctor_profiles`
    ADD INDEX `idx_profile_status` (`profile_status`),
    ADD INDEX `idx_registration_step` (`registration_step`),
    ADD INDEX `idx_reviewed_by` (`reviewed_by`);

-- Add foreign key for reviewed_by
ALTER TABLE `doctor_profiles`
    ADD CONSTRAINT `fk_dp_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- ============================================================
-- STEP 2: Migrate existing data in doctor_profiles
-- Map old boolean/enum values to new profile_status
-- ============================================================

-- Migrate: If verification_status was 'approved' → 'approved' or 'active'
UPDATE `doctor_profiles`
SET `profile_status` = 'approved',
    `registration_step` = 'completed'
WHERE `is_profile_approved` = 1 AND `profile_status` = 'draft';

-- Migrate: If was submitted but not yet approved
UPDATE `doctor_profiles`
SET `profile_status` = 'submitted',
    `registration_step` = 'completed'
WHERE `submitted_at` IS NOT NULL 
    AND `profile_status` = 'draft'
    AND `is_profile_approved` = 0;

-- Migrate: Default completed step based on data completeness
UPDATE `doctor_profiles`
SET `registration_step` = CASE
    WHEN `street_address` IS NOT NULL AND `video_rate` IS NOT NULL THEN 'completed'
    WHEN `license_number` IS NOT NULL AND `license_number` NOT LIKE 'TEMP_%' THEN 'professional_registration'
    WHEN `primary_specialty` IS NOT NULL AND `primary_specialty` != 'General Practice' THEN 'professional_details'
    ELSE 'basic_info'
END
WHERE `registration_step` = 'basic_info' AND `profile_status` = 'draft';

-- ============================================================
-- STEP 3: ALTER users table
-- Remove is_profile_completed (moved to profile_status in doctor_profiles)
-- Clean up registration_step in users (registration_step should only live in doctor_profiles now)
-- ============================================================

-- Keep registration_step in users for backward compatibility during transition
-- but mark it as deprecated — all logic should use doctor_profiles.registration_step instead
-- Do NOT drop yet to avoid breaking other queries during rollout

-- ============================================================
-- STEP 4: ALTER doctor_documents
-- Add verified_by column
-- ============================================================

ALTER TABLE `doctor_documents`
    ADD COLUMN `verified_by` CHAR(36) NULL AFTER `verified_at`,
    ADD INDEX `idx_doc_verified_by` (`verified_by`);

ALTER TABLE `doctor_documents`
    ADD CONSTRAINT `fk_doc_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- ============================================================
-- STEP 5: CREATE doctor_payouts table
-- Supports bank accounts, UPI, and future payment providers
-- ============================================================

CREATE TABLE IF NOT EXISTS `doctor_payouts` (
    `id`                    CHAR(36) NOT NULL DEFAULT (UUID()),
    `doctor_id`             CHAR(36) NOT NULL,
    `provider`              VARCHAR(50) NOT NULL DEFAULT 'bank'
                            COMMENT 'Payment provider: bank, upi, razorpay, stripe, paypal',
    `account_holder_name`   VARCHAR(255) NOT NULL,
    `bank_name`             VARCHAR(255) NULL,
    `account_number`        VARCHAR(50) NULL,
    `ifsc_code`             VARCHAR(11) NULL,
    `branch_name`           VARCHAR(255) NULL,
    `upi_id`                VARCHAR(100) NULL,
    `pan_number`            VARCHAR(20) NULL,
    `is_gst_registered`     TINYINT(1) DEFAULT 0,
    `gst_number`            VARCHAR(15) NULL,
    `provider_account_id`   VARCHAR(255) NULL
                            COMMENT 'External payment provider account reference ID',
    `terms_consent`         TINYINT(1) NOT NULL DEFAULT 0,
    `status`                ENUM('pending','submitted','verified','rejected') NOT NULL DEFAULT 'pending',
    `rejection_reason`      TEXT NULL,
    `submitted_at`          DATETIME NULL,
    `verified_at`           DATETIME NULL,
    `verified_by`           CHAR(36) NULL,
    `is_primary`            TINYINT(1) DEFAULT 1,
    `created_at`            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_payout_doctor` (`doctor_id`),
    INDEX `idx_payout_status` (`status`),
    INDEX `idx_payout_provider` (`provider`),
    INDEX `idx_payout_verified_by` (`verified_by`),
    CONSTRAINT `fk_payout_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_payout_verified_by` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- STEP 6: Migrate existing doctor_payout_accounts data
-- into the new doctor_payouts table
-- ============================================================

INSERT INTO `doctor_payouts` (
    `id`, `doctor_id`, `provider`, `account_holder_name`, `bank_name`,
    `account_number`, `ifsc_code`, `pan_number`, `is_gst_registered`,
    `gst_number`, `terms_consent`, `status`, `rejection_reason`,
    `is_primary`, `created_at`, `updated_at`
)
SELECT
    `id`, `doctor_id`, 'bank', `account_holder_name`, `bank_name`,
    `account_number`, `ifsc_code`, `pan_number`, `is_gst_registered`,
    `gst_number`, `terms_consent`,
    CASE `verification_status`
        WHEN 'verified' THEN 'verified'
        WHEN 'rejected' THEN 'rejected'
        ELSE 'submitted'
    END AS `status`,
    `rejection_reason`,
    `is_primary`, `created_at`, `updated_at`
FROM `doctor_payout_accounts`;

-- ============================================================
-- STEP 7: Enhance doctor_verification_logs
-- Add new actions for the profile_status workflow
-- ============================================================

-- The existing enum values cover most cases; no change needed
-- The log already supports: step_started, step_completed, step_submitted,
-- profile_submitted_for_review, profile_approved, profile_rejected, etc.

-- ============================================================
-- STEP 8: Add unique constraint to ensure one primary payout per doctor
-- ============================================================

-- Ensure only one active payout per doctor (at status 'verified' or 'submitted')
CREATE UNIQUE INDEX `uq_payout_active` ON `doctor_payouts` (`doctor_id`, `status`) 
WHERE `status` IN ('verified', 'submitted');

COMMIT;

-- ============================================================
-- Rollback script (save before executing migration)
-- ============================================================
-- To rollback, run:
-- ALTER TABLE doctor_profiles DROP COLUMN profile_status;
-- ALTER TABLE doctor_profiles DROP COLUMN registration_step;
-- ALTER TABLE doctor_profiles DROP COLUMN admin_note;
-- ALTER TABLE doctor_profiles DROP COLUMN submitted_at;
-- ALTER TABLE doctor_profiles DROP COLUMN reviewed_at;
-- ALTER TABLE doctor_profiles DROP COLUMN reviewed_by;
-- ALTER TABLE doctor_profiles DROP INDEX idx_profile_status;
-- ALTER TABLE doctor_profiles DROP INDEX idx_registration_step;
-- ALTER TABLE doctor_profiles DROP INDEX idx_reviewed_by;
-- ALTER TABLE doctor_profiles DROP FOREIGN KEY fk_dp_reviewed_by;
-- ALTER TABLE doctor_documents DROP COLUMN verified_by;
-- ALTER TABLE doctor_documents DROP INDEX idx_doc_verified_by;
-- ALTER TABLE doctor_documents DROP FOREIGN KEY fk_doc_verified_by;
-- DROP TABLE IF EXISTS doctor_payouts;