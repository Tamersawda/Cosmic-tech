<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorProfile Model
 * Manages doctor_profiles and doctor_qualifications tables.
 */
class DoctorProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

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
     * Update the doctor profile with the data supplied via /api/doctors/setup.
     * All column names match the combined_schema.sql exactly.
     */
    /**
     * Update the doctor profile with the data supplied via /api/doctors/setup.
     * All column names match the combined_schema.sql exactly.
     */
    /**
     * Create a new doctor profile.
     */
    public function create(array $data): bool {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_profiles (
                user_id, gender, date_of_birth, phone_number, profile_photo_url,
                primary_specialty, sub_specializations, years_of_experience,
                license_number, medical_council, languages_spoken,
                video_enabled, video_rate, audio_enabled, audio_rate,
                consultation_duration, buffer_time, is_active, street_address,
                city, state, country, postal_code, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())
        ');

        try {
            return $stmt->execute([
                $data['user_id'],
                $data['gender'] ?? 'other',
                $data['date_of_birth'] ?? null,
                $data['phone_number'] ?? null,
                $data['profile_photo_url'] ?? null,
                $data['primary_specialty'] ?? null,
                $data['sub_specializations'] ?? '[]',
                $data['years_of_experience'] ?? 0,
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
                $data['postal_code'] ?? null
            ]);
        } catch (\Exception $e) {
            error_log('Doctor profile create error: ' . $e->getMessage());
            return false;
        }
    }

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
                years_of_experience   = ?,
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
                $data['yearsOfExperience']   ?? 0,
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
                $userId,
            ]);
        } catch (\Exception $e) {
            error_log('Doctor profile setup error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Add a qualification row for a doctor.
     * Returns the new qualification UUID.
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

    /**
     * Get upcoming/past appointments for a doctor, optionally filtered by status.
     * Joins users for client name.
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

    /**
     * List all doctors with their basic profile information.
     */
    public function getAllDoctors(): array {
        try {
            $stmt = $this->db->prepare('
                SELECT
                    dp.user_id,
                    u.full_name,
                    dp.gender,
                    dp.primary_specialty,
                    dp.years_of_experience,
                    dp.languages_spoken,
                    dp.video_enabled,
                    dp.video_rate,
                    dp.consultation_duration,
                    dp.is_verified,
                    dp.is_active,
                    dp.profile_photo_url,
                    u.email,
                    u.user_type
                FROM doctor_profiles dp
                JOIN users u ON dp.user_id = u.id
                WHERE u.is_active = 1
                AND dp.is_active = 1
                AND dp.is_verified = 1
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
     * Generate a v4 UUID.
     */
    private function generateUUID(): string {
        $data = openssl_random_pseudo_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
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
     * Verify or reject a doctor.
     */
    public function verifyDoctor(string $userId, string $status): bool {
        $isVerified = ($status === 'approved') ? 1 : 0;
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET verification_status = ?, is_verified = ?, updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');
        return $stmt->execute([$status, $isVerified, $userId]);
    }
}
