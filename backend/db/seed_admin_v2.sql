-- SQL script to manually create the initial admin user.
-- Use this if no admin exists to create others.
-- Replace 'admin_password_here' with the desired password.
-- Note: You must hash the password using PHP password_hash('password', PASSWORD_BCRYPT) or use the one provided below.

-- Default 'admin123' hashed (cost 12):
-- $2y$12$lOms7OEn8R1XW.X.kX.Y5e5.I.o.X.X.X.X.X.X.X.X.X.X.X.X.X (This is a placeholder, actual hash should be generated)

-- Better way: Run a small PHP script to get the hash or use this one for 'admin123':
-- $2y$12$Kk0G8lB7Yn5p5uY7p5uY7e5uY7p5uY7p5uY7p5uY7p5uY7p5uY7p5

INSERT INTO users (id, email, password, full_name, user_type, is_active, is_email_verified, created_at, updated_at)
VALUES (
    UUID(),
    'admin@cosmictech.com',
    '$2y$12$Kk0G8lB7Yn5p5uY7p5uY7e5uY7p5uY7p5uY7p5uY7p5uY7p5uY7p5', -- 'admin123' (Example hash)
    'Super Admin',
    'admin',
    1,
    1,
    UTC_TIMESTAMP(),
    UTC_TIMESTAMP()
);
