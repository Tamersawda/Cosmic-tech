<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * User Model
 * 
 * Manages the users table — the parent authentication table.
 * Doctor profile status is now tracked in doctor_profiles.profile_status.
 * The users.is_profile_completed column is deprecated in favor of
 * querying doctor_profiles.profile_status directly.
 */
class User {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    // ──────────────────────────────────────────────
    // Authentication Queries
    // ──────────────────────────────────────────────

    /**
     * Find user by email — returns row including password hash for login.
     */
    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, password, user_type, full_name,
                   is_active, is_email_verified, created_at, updated_at
            FROM users
            WHERE email = ?
            LIMIT 1
        ');
        $stmt->execute([$email]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $result['role'] = $result['user_type'];
        }
        return $result ?: null;
    }

    /**
     * Find user by ID — does not return password hash.
     */
    public function findById(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, user_type, full_name,
                   is_active, is_email_verified, created_at, updated_at
            FROM users
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $result['role'] = $result['user_type'];
        }
        return $result ?: null;
    }

    /**
     * Find user with doctor profile status (for login routing).
     * Joins doctor_profiles to get profile_status and registration_step.
     */
    public function findDoctorWithStatus(string $email): ?array {
        $stmt = $this->db->prepare('
            SELECT 
                u.id, u.email, u.password, u.user_type, u.full_name,
                u.is_active, u.is_email_verified, u.created_at,
                dp.profile_status, dp.registration_step, dp.admin_note
            FROM users u
            LEFT JOIN doctor_profiles dp ON u.id = dp.user_id
            WHERE u.email = ?
            LIMIT 1
        ');
        $stmt->execute([$email]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $result['role'] = $result['user_type'];
        }
        return $result ?: null;
    }

    /**
     * Check whether an email address is already registered.
     */
    public function emailExists(string $email): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM users WHERE email = ? LIMIT 1
        ');
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    // ──────────────────────────────────────────────
    // User Creation
    // ──────────────────────────────────────────────

    /**
     * Create a new user row.
     * $userData keys: email, password (hashed), user_type, full_name
     * Returns the generated UUID string.
     */
    public function create(array $userData): string {
        $userId = $this->generateUUID();

        $stmt = $this->db->prepare('
            INSERT INTO users (id, email, password, user_type, full_name, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, 1, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            $userData['email'],
            $userData['password'],
            $userData['user_type'],
            $userData['full_name'] ?? '',
        ]);

        return $userId;
    }

    /**
     * Create the initial doctor_profiles skeleton row when a doctor registers.
     * Profile starts at: profile_status = 'draft', registration_step = 'basic_info'
     *
     * @param string $userId  The users.id (CHAR 36 UUID)
     */
    public function createDoctorProfile(string $userId): void {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_profiles (
                user_id, profile_status, registration_step,
                gender, primary_specialty,
                license_number, medical_council, languages_spoken,
                video_enabled, audio_enabled, consultation_duration,
                buffer_time, is_active, instant_booking_enabled,
                created_at, updated_at
            ) VALUES (?, "draft", "basic_info", ?, ?, ?, ?, ?, 1, 1, ?, ?, 1, 0, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            'other',
            'General Practice',
            'TEMP_' . substr($userId, 0, 8),
            'Other',
            json_encode(['English']),
            '60min',
            '10min',
        ]);
    }

    /**
     * Create the initial client_profiles skeleton row when a client registers.
     *
     * @param string $userId  The users.id (CHAR 36 UUID)
     */
    public function createClientProfile(string $userId): void {
        $stmt = $this->db->prepare('
            INSERT INTO client_profiles (
                user_id, gender,
                created_at, updated_at
            ) VALUES (?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            'other',
        ]);
    }

    // ──────────────────────────────────────────────
    // Email Verification
    // ──────────────────────────────────────────────

    /**
     * Store an OTP hash for email verification.
     */
    public function storeOtp(string $email, string $hashedOtp, string $expiryTime): bool {
        $stmt = $this->db->prepare('
            UPDATE users
            SET email_verification_otp = ?, email_verification_expires = ?
            WHERE email = ?
        ');
        try {
            return $stmt->execute([$hashedOtp, $expiryTime, $email]);
        } catch (\Exception $e) {
            error_log('Store OTP error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Mark a user's email as verified and clear OTP fields.
     */
    public function verifyEmail(string $email): bool {
        $stmt = $this->db->prepare('
            UPDATE users
            SET is_email_verified = 1,
                email_verification_otp = NULL,
                email_verification_expires = NULL
            WHERE email = ?
        ');
        try {
            return $stmt->execute([$email]);
        } catch (\Exception $e) {
            error_log('Verify email error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Get user with all email-verification detail fields included.
     */
    public function findByEmailWithVerification(string $email): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, password, user_type, full_name,
                   is_active, is_email_verified,
                   email_verification_otp, email_verification_expires,
                   created_at, updated_at
            FROM users
            WHERE email = ?
            LIMIT 1
        ');
        $stmt->execute([$email]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $result['role'] = $result['user_type'];
        }
        return $result ?: null;
    }

    // ──────────────────────────────────────────────
    // Password Management
    // ──────────────────────────────────────────────

    /**
     * Hash a password with bcrypt.
     */
    public static function hashPassword(string $password): string {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify a plaintext password against a stored hash.
     */
    public static function verifyPassword(string $password, string $hash): bool {
        return password_verify($password, $hash);
    }

    // ──────────────────────────────────────────────
    // Profile Completion (DEPRECATED)
    // ──────────────────────────────────────────────

    /**
     * Update is_profile_completed flag for a user.
     * 
     * @deprecated This method is deprecated. Use ProfileStatusService to manage
     *             profile status via doctor_profiles.profile_status instead.
     *             Kept for backward compatibility during migration.
     */
    public function updateProfileCompletion(string $userId, bool $completed): bool {
        $stmt = $this->db->prepare('
            UPDATE users
            SET is_profile_completed = ?, updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$completed ? 1 : 0, $userId]);
    }

    // ──────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────

    /**
     * Generate a v4 UUID.
     */
    private function generateUUID(): string {
        $data = openssl_random_pseudo_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}