-- SAFE MIGRATION: patient → client

START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;

-- 🔹 STEP 1: Drop foreign keys FIRST (safe)
-- (Use actual FK names if different)

ALTER TABLE appointments DROP FOREIGN KEY fk_appt_patient;
ALTER TABLE reviews DROP FOREIGN KEY fk_review_patient;

-- 🔹 STEP 2: Rename table
RENAME TABLE patient_profiles TO client_profiles;

-- 🔹 STEP 3: Rename columns
ALTER TABLE appointments CHANGE patient_id client_id CHAR(36) NOT NULL;
ALTER TABLE reviews CHANGE patient_id client_id CHAR(36) NOT NULL;

-- 🔹 STEP 4: Update ENUM safely

-- Expand enum
ALTER TABLE users 
MODIFY COLUMN user_type ENUM('admin', 'doctor', 'user', 'patient', 'client') NOT NULL;

-- Migrate values
UPDATE users 
SET user_type = 'client' 
WHERE user_type IN ('user', 'patient');

-- Shrink enum
ALTER TABLE users 
MODIFY COLUMN user_type ENUM('admin', 'doctor', 'client') NOT NULL;

-- 🔹 STEP 5: Recreate foreign keys
ALTER TABLE appointments 
ADD CONSTRAINT fk_appt_client 
FOREIGN KEY (client_id) 
REFERENCES client_profiles(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE reviews 
ADD CONSTRAINT fk_review_client 
FOREIGN KEY (client_id) 
REFERENCES client_profiles(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE client_profiles DROP COLUMN medical_history;

COMMIT;