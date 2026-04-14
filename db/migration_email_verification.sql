-- ============================================================
-- Email Verification Database Migration
-- Clinical Sanctuary - Therapy Booking Platform
-- ============================================================
-- This migration adds email verification support to the users table.
-- Run this script after deploying the updated code.

USE therapy_booking_db;

-- Add email verification columns to users table
ALTER TABLE users 
ADD COLUMN is_email_verified TINYINT(1) NOT NULL DEFAULT 0 AFTER is_active,
ADD COLUMN email_verification_otp VARCHAR(255) NULL AFTER is_email_verified,
ADD COLUMN email_verification_expires DATETIME NULL AFTER email_verification_otp,
ADD INDEX idx_users_email_verified (is_email_verified);

-- Backfill existing users as verified (since they were already registered)
-- IMPORTANT: Comment this out if you want existing users to verify their emails
-- UPDATE users SET is_email_verified = 1 WHERE is_active = 1;

-- Verify the migration
SELECT 
    COLUMN_NAME, 
    COLUMN_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'users' 
    AND TABLE_SCHEMA = 'therapy_booking_db'
    AND COLUMN_NAME IN (
        'is_email_verified',
        'email_verification_otp',
        'email_verification_expires'
    );

-- Show the updated table structure
DESCRIBE users;
