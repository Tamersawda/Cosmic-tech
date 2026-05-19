-- ============================================================
-- Migration: Create Onboarding-Specific Tables
-- Date: 2026-05-17
-- Purpose: Create separate tables for documents, payout accounts, and
--          verification logs to properly structure onboarding data
-- ============================================================

USE therapy_booking;

-- ============================================================
-- 1. DOCTOR DOCUMENTS TABLE
-- Stores all onboarding-related document uploads
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_documents (
    id CHAR(36) NOT NULL DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    document_type ENUM(
        'govt_id_front',
        'govt_id_back',
        'qualification_certificate',
        'rci_certificate',
        'experience_proof'
    ) NOT NULL COMMENT 'Type of document being uploaded',
    
    file_url VARCHAR(255) NOT NULL COMMENT 'Secure URL to uploaded file',
    file_name VARCHAR(255) NOT NULL COMMENT 'Original filename',
    file_size INT NOT NULL COMMENT 'File size in bytes',
    mime_type VARCHAR(50) NOT NULL COMMENT 'MIME type of file',
    
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending' COMMENT 'Admin verification status',
    rejection_reason TEXT NULL COMMENT 'Reason for rejection if applicable',
    
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    INDEX idx_doc_doctor (doctor_id),
    INDEX idx_doc_type (document_type),
    INDEX idx_doc_verification (verification_status),
    
    CONSTRAINT fk_doc_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. DOCTOR PAYOUT ACCOUNTS TABLE
-- Stores banking and tax information for payment transfers
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_payout_accounts (
    id CHAR(36) NOT NULL DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    
    account_holder_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    ifsc_code VARCHAR(11) NOT NULL,
    bank_name VARCHAR(255) NOT NULL,
    branch_name VARCHAR(255) NOT NULL,
    
    pan_number VARCHAR(20) NULL,
    is_gst_registered BOOLEAN DEFAULT FALSE,
    gst_number VARCHAR(15) NULL,
    
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
    rejection_reason TEXT NULL,
    
    is_primary BOOLEAN DEFAULT TRUE COMMENT 'Primary payout account',
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    UNIQUE KEY uq_payout_account (doctor_id, account_number),
    INDEX idx_payout_doctor (doctor_id),
    INDEX idx_payout_primary (doctor_id, is_primary),
    
    CONSTRAINT fk_payout_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. DOCTOR VERIFICATION LOGS TABLE
-- Audit trail for verification status changes
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_verification_logs (
    id CHAR(36) NOT NULL DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    
    action ENUM(
        'step_started',
        'step_completed',
        'step_submitted',
        'profile_submitted_for_review',
        'profile_approved',
        'profile_rejected',
        'resubmission_requested',
        'document_verified',
        'document_rejected'
    ) NOT NULL,
    
    step_number INT NULL COMMENT 'Which onboarding step this action relates to',
    previous_status VARCHAR(50) NULL,
    new_status VARCHAR(50) NULL,
    details JSON NULL COMMENT 'Additional details about the action',
    
    admin_id CHAR(36) NULL COMMENT 'Admin who performed the action',
    admin_notes TEXT NULL COMMENT 'Notes from admin',
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    INDEX idx_log_doctor (doctor_id),
    INDEX idx_log_action (action),
    INDEX idx_log_created (created_at),
    
    CONSTRAINT fk_log_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_log_admin
        FOREIGN KEY (admin_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
