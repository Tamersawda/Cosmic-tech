<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class User {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

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
            // Expose 'role' as alias for user_type so controllers use a stable field name
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
     * Check whether an email address is already registered.
     */
    public function emailExists(string $email): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM users WHERE email = ? LIMIT 1
        ');
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

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
            $userData['user_type'],   // DB column — stores 'admin' | 'doctor' | 'user'
            $userData['full_name'] ?? '',
        ]);

        return $userId;
    }

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

    /**
     * Create the initial doctor_profiles skeleton row when a doctor registers.
     * The profile will be fully completed via the /api/doctors/setup endpoint.
     *
     * @param string $userId  The users.id (CHAR 36 UUID)
     * @param array  $data    Keys: name
     */
    public function createDoctorProfile(string $userId, array $data): void {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_profiles (
                user_id, full_name, gender, primary_specialty,
                license_number, medical_council, languages_spoken,
                video_enabled, audio_enabled, consultation_duration,
                buffer_time, instant_booking_enabled, years_of_experience,
                onboarding_current_step, onboarding_percentage, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 1, 1, ?, ?, 0, 0, 1, 0, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            $data['name'] ?? '',
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
     * Create the initial patient_profiles skeleton row when a patient registers.
     * The profile will be fully completed via the /api/patients/setup endpoint.
     *
     * @param string $userId  The users.id (CHAR 36 UUID)
     * @param array  $data    Keys: name
     */
    public function createPatientProfile(string $userId, array $data): void {
        $stmt = $this->db->prepare('
            INSERT INTO patient_profiles (
                user_id, full_name, gender,
                created_at, updated_at
            ) VALUES (?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            $data['name'] ?? '',
            'other',
        ]);
    }

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
