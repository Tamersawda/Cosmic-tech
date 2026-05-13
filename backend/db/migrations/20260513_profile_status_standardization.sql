-- Migration: Rename is_profile_completed to is_profile_complete and add is_profile_approved
-- Purpose: Standardize naming for frontend integration

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Update users table
ALTER TABLE users CHANGE COLUMN is_profile_completed is_profile_complete BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN is_profile_approved BOOLEAN DEFAULT FALSE AFTER is_profile_complete;

-- 2. Sync is_profile_approved for doctors who are already verified
UPDATE users u
JOIN doctor_profiles dp ON u.id = dp.user_id
SET u.is_profile_approved = 1
WHERE dp.is_verified = 1;

-- 3. Also add is_profile_approved to doctor_profiles as an alias for is_verified if needed, 
-- but we will primarily use the users table flag for global auth responses.
ALTER TABLE doctor_profiles ADD COLUMN is_profile_approved BOOLEAN DEFAULT FALSE AFTER is_verified;
UPDATE doctor_profiles SET is_profile_approved = is_verified;

SET FOREIGN_KEY_CHECKS = 1;
