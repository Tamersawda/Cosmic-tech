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
     * Find user by email with email verification fields
     */
    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, password, user_type, is_active, is_email_verified, 
                   email_verification_otp, email_verification_expires, created_at, updated_at
            FROM users
            WHERE email = ?
            LIMIT 1
        ');
        $stmt->execute([$email]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result ?: null;
    }

    /**
     * Find user by ID with email verification fields
     */
    public function findById(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, user_type, is_active, is_email_verified, created_at, updated_at
            FROM users
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result ?: null;
    }

    /**
     * Check if email exists
     */
    public function emailExists(string $email): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM users WHERE email = ? LIMIT 1
        ');
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Create new user
     * Returns user ID on success
     */
    public function create(array $userData): string {
        $userId = $this->generateUUID();

        $stmt = $this->db->prepare('
            INSERT INTO users (id, email, password, user_type, is_active, created_at, updated_at)
            VALUES (?, ?, ?, ?, 1, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $userId,
            $userData['email'],
            $userData['password'],
            $userData['user_type'] ?? null,
        ]);

        return $userId;
    }

    /**
     * Hash password using bcrypt
     */
    public static function hashPassword(string $password): string {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify password against hash
     */
    public static function verifyPassword(string $password, string $hash): bool {
        return password_verify($password, $hash);
    }

    /**
     * Store OTP for email verification
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
            error_log("Store OTP error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verify and mark email as verified
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
            error_log("Verify email error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Check if email is verified
     */
    public function isEmailVerified(string $email): bool {
        $stmt = $this->db->prepare('
            SELECT is_email_verified FROM users WHERE email = ? LIMIT 1
        ');
        $stmt->execute([$email]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $result ? (bool)$result['is_email_verified'] : false;
    }

    /**
     * Get user by email with all verification details
     */
    public function findByEmailWithVerification(string $email): ?array {
        $stmt = $this->db->prepare('
            SELECT id, email, password, user_type, is_active, is_email_verified, 
                   email_verification_otp, email_verification_expires, created_at, updated_at
            FROM users
            WHERE email = ?
            LIMIT 1
        ');
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Create empty doctor profile record
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

        $values = [
            $userId,
            $data['full_name'] ?? '',
            $data['gender'] ?? 'other',
            $data['primary_specialty'] ?? 'General Practice',
            $data['license_number'] ?? 'TEMP_' . $userId,
            $data['medical_council'] ?? 'Other',
            json_encode($data['languages_spoken'] ?? ['English']),
            $data['consultation_duration'] ?? '60min',
            $data['buffer_time'] ?? '10min',
        ];

        $stmt->execute($values);
    }

    /**
     * Create empty patient profile record
     */
    public function createPatientProfile(string $userId, array $data): void {
        $stmt = $this->db->prepare('
            INSERT INTO patient_profiles (
                user_id, first_name, last_name, gender, 
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $names = $this->splitFullName($data['full_name'] ?? 'User');

        $stmt->execute([
            $userId,
            $names['first_name'],
            $names['last_name'],
            $data['gender'] ?? 'other',
        ]);
    }

    /**
     * Split full name into first and last name
     */
    private function splitFullName(string $fullName): array {
        $parts = explode(' ', trim($fullName), 2);
        return [
            'first_name' => $parts[0] ?? 'User',
            'last_name' => $parts[1] ?? '',
        ];
    }

    /**
     * Generate UUID v4
     */
    private function generateUUID(): string {
        $data = openssl_random_pseudo_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
