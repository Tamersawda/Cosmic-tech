-- ============================================================
-- Migration: Add Onboarding State Tracking Fields
-- Date: 2026-05-17
-- Purpose: Add fields to users and doctor_profiles to properly
--          track onboarding progress, verification status, and lifecycle
-- ============================================================

USE therapy_booking;

-- ============================================================
-- 1. Add fields to users table
-- ============================================================
ALTER TABLE users
ADD COLUMN IF NOT EXISTS registration_step INT DEFAULT 0 COMMENT 'Current onboarding step (0=not started, 1-7=step number, 8=completed)',
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE COMMENT 'True when all 7 steps are submitted',
ADD COLUMN IF NOT EXISTS onboarding_submitted_at DATETIME NULL COMMENT 'Timestamp when onboarding was submitted for review';

-- ============================================================
-- 2. Update doctor_profiles table with proper verification lifecycle
-- ============================================================
ALTER TABLE doctor_profiles
ADD COLUMN IF NOT EXISTS verification_status ENUM(
    'draft',
    'in_progress',
    'submitted',
    'under_review',
    'approved',
    'rejected',
    'resubmission_required'
) DEFAULT 'draft' COMMENT 'Onboarding verification lifecycle state',
ADD COLUMN IF NOT EXISTS submitted_at DATETIME NULL COMMENT 'When profile submission was completed',
ADD COLUMN IF NOT EXISTS reviewed_at DATETIME NULL COMMENT 'When admin review was completed',
ADD COLUMN IF NOT EXISTS rejected_reason TEXT NULL COMMENT 'Reason for rejection if status is rejected',
ADD COLUMN IF NOT EXISTS primary_title VARCHAR(100) NULL COMMENT 'Primary professional title',
ADD COLUMN IF NOT EXISTS secondary_title VARCHAR(100) NULL COMMENT 'Secondary professional title',
ADD COLUMN IF NOT EXISTS professional_bio TEXT NULL COMMENT 'Professional biography (max 600 chars)',
ADD COLUMN IF NOT EXISTS registration_number VARCHAR(100) NULL COMMENT 'Professional registration/license number',
ADD COLUMN IF NOT EXISTS registration_type ENUM('rci', 'none') DEFAULT 'none' COMMENT 'Type of professional registration',
ADD COLUMN IF NOT EXISTS rci_number VARCHAR(100) NULL COMMENT 'RCI registration number if applicable',
ADD COLUMN IF NOT EXISTS session_price DECIMAL(10, 2) NULL COMMENT 'Consultation session price',
ADD COLUMN IF NOT EXISTS consultation_duration_minutes INT DEFAULT 60 COMMENT 'Standard consultation duration',
ADD COLUMN IF NOT EXISTS followup_price DECIMAL(10, 2) NULL COMMENT 'Follow-up session price',
ADD COLUMN IF NOT EXISTS govt_id_front_url VARCHAR(255) NULL COMMENT 'URL to front side of government ID',
ADD COLUMN IF NOT EXISTS govt_id_back_url VARCHAR(255) NULL COMMENT 'URL to back side of government ID',
ADD COLUMN IF NOT EXISTS rci_certificate_url VARCHAR(255) NULL COMMENT 'URL to RCI certificate if applicable';

-- ============================================================
-- 3. Update doctor_qualifications table with better structure
-- ============================================================
ALTER TABLE doctor_qualifications
ADD COLUMN IF NOT EXISTS qualification_name VARCHAR(255) NULL COMMENT 'Name of qualification/degree',
ADD COLUMN IF NOT EXISTS specialization VARCHAR(255) NULL COMMENT 'Specialization within the qualification',
ADD COLUMN IF NOT EXISTS passing_year INT NULL COMMENT 'Year of passing',
ADD COLUMN IF NOT EXISTS certificate_url VARCHAR(255) NULL COMMENT 'URL to uploaded certificate/proof',
ADD COLUMN IF NOT EXISTS verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending' COMMENT 'Verification status by admin';

-- ============================================================
-- 4. Update doctor_experiences table with better structure
-- ============================================================
ALTER TABLE doctor_experiences
ADD COLUMN IF NOT EXISTS work_type ENUM(
    'hospital',
    'private_practice',
    'ngo',
    'online_platform',
    'other'
) DEFAULT 'other' COMMENT 'Type of work environment',
ADD COLUMN IF NOT EXISTS custom_work_type VARCHAR(100) NULL COMMENT 'Custom work type if work_type is other',
ADD COLUMN IF NOT EXISTS proof_document_url VARCHAR(255) NULL COMMENT 'URL to experience proof/certificate',
ADD COLUMN IF NOT EXISTS verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending' COMMENT 'Verification status by admin';

-- ============================================================
-- 5. Create indexes for efficient onboarding querying
-- ============================================================
CREATE INDEX idx_users_registration_step ON users(registration_step);
CREATE INDEX idx_users_onboarding_completed ON users(onboarding_completed);
CREATE INDEX idx_doctor_verification_status ON doctor_profiles(verification_status);
CREATE INDEX idx_doctor_submitted_at ON doctor_profiles(submitted_at);
CREATE INDEX idx_qualifications_verification ON doctor_qualifications(verification_status);
CREATE INDEX idx_experiences_verification ON doctor_experiences(verification_status);
