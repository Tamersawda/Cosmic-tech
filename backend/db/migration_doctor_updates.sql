-- PRODUCTION MIGRATION: DOCTOR UPDATES
-- TABLE: doctor_profiles

ALTER TABLE doctor_profiles
ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1;

-- Ensure all existing profiles are active
UPDATE doctor_profiles
SET is_active = 1
WHERE is_active IS NULL;

-- Ensure profile_photo_url exists (renaming from profile_photo if necessary or adding)
-- Based on audit, we use profile_photo_url VARCHAR(255)
ALTER TABLE doctor_profiles
CHANGE COLUMN profile_photo profile_photo_url VARCHAR(255) NULL;

-- If profile_photo did not exist, use this instead:
-- ALTER TABLE doctor_profiles ADD COLUMN profile_photo_url VARCHAR(255) NULL;

-- Add performance index
ALTER TABLE doctor_profiles
ADD INDEX idx_doctor_active (is_active);
