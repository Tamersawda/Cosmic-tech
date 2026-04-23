-- Verification Queries for patient -> client migration

-- 1. Check if patient_profiles table is gone
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'patient_profiles';

-- 2. Check if client_profiles table exists
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'client_profiles';

-- 3. Check for any 'patient' or 'user' roles left in users table
SELECT id, email, user_type FROM users WHERE user_type IN ('user', 'patient');

-- 4. Check if client_id column exists in appointments and reviews
SELECT column_name FROM information_schema.columns WHERE table_name = 'appointments' AND column_name = 'client_id';
SELECT column_name FROM information_schema.columns WHERE table_name = 'reviews' AND column_name = 'client_id';

-- 5. Check foreign keys
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME IN ('appointments', 'reviews') AND COLUMN_NAME = 'client_id';

-- 6. Orphaned client profiles (profiles with no corresponding user)
SELECT cp.user_id 
FROM client_profiles cp 
LEFT JOIN users u ON cp.user_id = u.id 
WHERE u.id IS NULL;

-- 7. Appointments with NULL or non-existent client_id
SELECT a.id, a.client_id 
FROM appointments a 
LEFT JOIN users u ON a.client_id = u.id 
WHERE u.id IS NULL;
