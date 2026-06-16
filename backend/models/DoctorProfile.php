<?php

namespace Backend\Models;

use Backend\Config\Database;
use Backend\Services\ProfileStatusService;
use PDO;

/**
 * DoctorProfile Model
 * Manages doctor_profiles table with the new status-based workflow.
 * 
 * Profile Status: draft → submitted → approved → payout_pending → active
 * Registration Steps: basic_info → professional_details → qualifications →
 *                     professional_registration → work_experience → session_fee → completed
 */
class DoctorProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    // ──────────────────────────────────────────────
    // Basic CRUD Operations
    // ──────────────────────────────────────────────

    /**
     * Get a doctor profile by user ID.
     */
    public function findByUserId(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            if ($result['languages_spoken']) {
                $result['languages_spoken'] = json_decode($result['languages_spoken'], true);
            }
            if ($result['sub_specializations']) {
                $result['sub_specializations'] = json_decode($result['sub_specializations'], true);
            }
            if ($result['therapy_approaches']) {
                $result['therapy_approaches'] = json_decode($result['therapy_approaches'], true);
            }
        }

        return $result ?: null;
    }

    /**
     * Get doctor profile with joined user data (for admin panel).
     */
    public function findByUserIdWithUser(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT 
                dp.*,
                u.full_name,
                u.email,
                u.is_active AS user_is_active,
                u.is_email_verified,
                reviewer.full_name AS reviewed_by_name
            FROM doctor_profiles dp
            JOIN users u ON dp.user_id = u.id
            LEFT JOIN users reviewer ON dp.reviewed_by = reviewer.id
            WHERE dp.user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            if ($result['languages_spoken']) {
                $result['languages_spoken'] = json_decode($result['languages_spoken'], true);
            }
            if ($result['sub_specializations']) {
                $result['sub_specializations'] = json_decode($result['sub_specializations'], true);
            }
            if ($result['therapy_approaches']) {
                $result['therapy_approaches'] = json_decode($result['therapy_approaches'], true);
            }
        }

        return $result ?: null;
    }

    /**
     * Check whether a license number is already in use (optionally excluding a specific user).
     */
    public function licenseExists(string $licenseNumber, ?string $excludeUserId = null): bool {
        if ($excludeUserId) {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_profiles
                WHERE license_number = ? AND user_id != ?
                LIMIT 1
            ');
            $stmt->execute([$licenseNumber, $excludeUserId]);
        } else {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_profiles
                WHERE license_number = ?
                LIMIT 1
            ');
            $stmt->execute([$licenseNumber]);
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Create a new doctor profile skeleton row on registration.
     * Profile starts at: profile_status = draft, registration_step = basic_info
     */
    public function create(array $data): bool {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_profiles (
                user_id, profile_status, registration_step,
                gender, date_of_birth, phone_number, profile_photo_url,
                primary_specialty, sub_specializations, therapy_approaches,
                license_number, medical_council, languages_spoken,
                video_enabled, video_rate, audio_enabled, audio_rate,
                consultation_duration, buffer_time, is_active, street_address,
                city, state, country, postal_code, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())
        ');

        try {
            return $stmt->execute([
                $data['user_id'],
                $data['profile_status'] ?? 'draft',
                $data['registration_step'] ?? 'basic_info',
                $data['gender'] ?? 'other',
                $data['date_of_birth'] ?? null,
                $data['phone_number'] ?? null,
                $data['profile_photo_url'] ?? null,
                $data['primary_specialty'] ?? null,
                $data['sub_specializations'] ?? '[]',
                $data['therapy_approaches'] ?? '[]',
                $data['license_number'] ?? null,
                $data['medical_council'] ?? null,
                $data['languages_spoken'] ?? '[]',
                $data['video_enabled'] ?? 1,
                $data['video_rate'] ?? null,
                $data['audio_enabled'] ?? 1,
                $data['audio_rate'] ?? null,
                $data['consultation_duration'] ?? '60min',
                $data['buffer_time'] ?? '10min',
                $data['is_active'] ?? 1,
                $data['street_address'] ?? null,
                $data['city'] ?? null,
                $data['state'] ?? null,
                $data['country'] ?? null,
                $data['postal_code'] ?? null,
            ]);
        } catch (\Exception $e) {
            error_log('Doctor profile create error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Update specific fields in a doctor profile (partial update).
     */
    public function update(string $userId, array $data): bool {
        if (empty($data)) {
            return true;
        }

        // Allowed columns for partial updates
        $allowedColumns = [
            'phone_number',
            'gender',
            'date_of_birth',
            'profile_photo_url',
            'primary_specialty',
            'primary_title',
            'secondary_title',
            'professional_bio',
            'languages_spoken',
            'therapy_approaches',
            'sub_specializations',
            'govt_id_front_url',
            'govt_id_back_url',
            'registration_step',
            'admin_note',
        ];

        // Build dynamic SET clause
        $setClauses = [];
        $values = [];

        foreach ($data as $key => $value) {
            if (in_array($key, $allowedColumns)) {
                // Handle JSON fields
                if (in_array($key, ['languages_spoken', 'therapy_approaches', 'sub_specializations'])) {
                    $value = is_array($value) ? json_encode($value) : $value;
                }
                $setClauses[] = "{$key} = ?";
                $values[] = $value;
            }
        }

        if (empty($setClauses)) {
            return true;
        }

        $setClauses[] = "updated_at = UTC_TIMESTAMP()";
        $values[] = $userId;

        $sql = 'UPDATE doctor_profiles SET ' . implode(', ', $setClauses) . ' WHERE user_id = ?';

        try {
            $stmt = $this->db->prepare($sql);
            return $stmt->execute($values);
        } catch (\Exception $e) {
            error_log('Doctor profile update error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Bulk update profile from onboarding setup endpoint.
     * Saves all onboarding form data in a single UPDATE.
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET
                gender                = ?,
                date_of_birth         = ?,
                phone_number          = ?,
                profile_photo_url     = ?,
                primary_specialty     = ?,
                sub_specializations   = ?,
                therapy_approaches    = ?,
                license_number        = ?,
                languages_spoken      = ?,
                street_address        = ?,
                city                  = ?,
                state                 = ?,
                country               = ?,
                postal_code           = ?,
                video_enabled         = ?,
                video_rate            = ?,
                consultation_duration = ?,
                buffer_time           = ?,
                session_fee_tier      = ?,
                pricing_justification = ?,
                updated_at            = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            return $stmt->execute([
                $data['gender']              ?? 'other',
                $data['dateOfBirth']         ?? null,
                $data['phoneNumber']         ?? null,
                $data['profilePhotoUrl']     ?? null,
                $data['primarySpecialty']    ?? null,
                json_encode($data['subSpecializations'] ?? []),
                json_encode($data['therapyApproaches'] ?? []),
                $data['licenseNumber']       ?? null,
                json_encode($data['languagesSpoken'] ?? ['English']),
                $data['streetAddress']       ?? null,
                $data['city']                ?? null,
                $data['state']               ?? null,
                $data['country']             ?? null,
                $data['postalCode']          ?? null,
                isset($data['videoEnabled']) ? (int)$data['videoEnabled'] : 1,
                $data['videoRate']           ?? null,
                $data['consultationDuration'] ?? '60min',
                $data['bufferTime']          ?? '10min',
                $data['sessionFeeTier']      ?? null,
                $data['pricingJustification'] ?? null,
                $userId,
            ]);
        } catch (\Exception $e) {
            error_log('Doctor profile setup error: ' . $e->getMessage());
            throw $e;
        }
    }

    // ──────────────────────────────────────────────
    // Qualification Management
    // ──────────────────────────────────────────────

    /**
     * Add a qualification row for a doctor.
     */
    public function addQualification(string $doctorId, array $data): string {
        $qualificationId = $this->generateUUID();

        $stmt = $this->db->prepare('
            INSERT INTO doctor_qualifications
                (id, doctor_id, degree, institute_name, year_of_completion, certificate_file)
            VALUES (?, ?, ?, ?, ?, ?)
        ');

        try {
            $stmt->execute([
                $qualificationId,
                $doctorId,
                $data['degree']           ?? null,
                $data['instituteName']    ?? null,
                $data['yearOfCompletion'] ?? null,
                $data['certificateFile']  ?? null,
            ]);
            return $qualificationId;
        } catch (\Exception $e) {
            error_log('Add qualification error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get all qualifications for a doctor, newest first.
     */
    public function getQualifications(string $doctorId): array {
        $stmt = $this->db->prepare('
            SELECT id, degree, institute_name, year_of_completion, certificate_file
            FROM doctor_qualifications
            WHERE doctor_id = ?
            ORDER BY year_of_completion DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Update a qualification row.
     */
    public function updateQualification(string $qualificationId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_qualifications
            SET degree = ?, institute_name = ?, year_of_completion = ?, certificate_file = ?
            WHERE id = ?
        ');

        try {
            return $stmt->execute([
                $data['degree']           ?? null,
                $data['instituteName']    ?? null,
                $data['yearOfCompletion'] ?? null,
                $data['certificateFile']  ?? null,
                $qualificationId,
            ]);
        } catch (\Exception $e) {
            error_log('Update qualification error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Delete a qualification row.
     */
    public function deleteQualification(string $qualificationId): bool {
        $stmt = $this->db->prepare('DELETE FROM doctor_qualifications WHERE id = ?');
        try {
            return $stmt->execute([$qualificationId]);
        } catch (\Exception $e) {
            error_log('Delete qualification error: ' . $e->getMessage());
            throw $e;
        }
    }

    // ──────────────────────────────────────────────
    // Appointment Queries
    // ──────────────────────────────────────────────

    /**
     * Get upcoming/past appointments for a doctor.
     */
    public function getAppointments(string $doctorId, ?string $status = null): array {
        $query = '
            SELECT
                a.id,
                a.doctor_id,
                a.client_id,
                a.scheduled_date,
                a.scheduled_time,
                a.end_time,
                a.consultation_type,
                a.status,
                u.full_name AS client_name
            FROM appointments a
            JOIN users u ON a.client_id = u.id
            WHERE a.doctor_id = ?
        ';

        $params = [$doctorId];

        if ($status !== null) {
            $query .= ' AND a.status = ?';
            $params[] = $status;
        }

        $query .= ' ORDER BY a.scheduled_date ASC, a.scheduled_time ASC';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // ──────────────────────────────────────────────
    // Existence Checks
    // ──────────────────────────────────────────────

    /**
     * Check whether a doctor profile exists for the given user ID.
     */
    public function exists(string $doctorId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_profiles WHERE user_id = ? LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    // ──────────────────────────────────────────────
    // List / Query Operations
    // ──────────────────────────────────────────────

    /**
     * List all fully active and approved doctors (for public listing).
     * Uses profile_status = 'active' instead of old is_verified + is_active.
     */
    public function getAllDoctors(): array {
        try {
            $stmt = $this->db->prepare('
                SELECT
                    dp.user_id,
                    u.full_name,
                    dp.gender,
                    dp.primary_specialty,
                    dp.languages_spoken,
                    dp.video_enabled,
                    dp.video_rate,
                    dp.consultation_duration,
                    dp.profile_status,
                    dp.is_active,
                    dp.profile_photo_url,
                    u.email,
                    u.user_type
                FROM doctor_profiles dp
                JOIN users u ON dp.user_id = u.id
                WHERE u.is_active = 1
                AND dp.is_active = 1
                AND dp.profile_status = "active"
                ORDER BY u.full_name ASC
            ');
            $stmt->execute();
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($results as &$doctor) {
                if ($doctor['languages_spoken']) {
                    $doctor['languages_spoken'] = json_decode($doctor['languages_spoken'], true);
                }
            }

            return $results;
        } catch (\Exception $e) {
            error_log('getAllDoctors error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get doctors filtered by profile status (for admin panel).
     */
    public function getByProfileStatus(string $status, int $limit = 50, int $offset = 0): array {
        $stmt = $this->db->prepare('
            SELECT
                dp.user_id,
                u.full_name,
                u.email,
                dp.primary_specialty,
                dp.profile_status,
                dp.registration_step,
                dp.submitted_at,
                dp.reviewed_at,
                dp.admin_note,
                dp.profile_photo_url
            FROM doctor_profiles dp
            JOIN users u ON dp.user_id = u.id
            WHERE dp.profile_status = ?
            ORDER BY dp.updated_at DESC
            LIMIT ? OFFSET ?
        ');
        $stmt->execute([$status, $limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // ──────────────────────────────────────────────
    // Status & Profile Management
    // ──────────────────────────────────────────────

    /**
     * Update doctor availability status.
     */
    public function updateActiveStatus(string $userId, int $isActive): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET is_active = ?, updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');
        return $stmt->execute([$isActive, $userId]);
    }

    /**
     * Verify or reject a doctor (DEPRECATED — use ProfileStatusService instead).
     * Kept for backward compatibility during migration period.
     * 
     * @deprecated Use ProfileStatusService::approveProfile() or rejectProfile()
     */
    public function verifyDoctor(string $userId, string $status): bool {
        $service = new ProfileStatusService();

        if ($status === 'approved') {
            $result = $service->approveProfile($userId, 'system');
        } else {
            $result = $service->rejectProfile($userId, 'system', 'Rejected via legacy method');
        }

        return $result['success'];
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