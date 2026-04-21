<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorProfile Model
 * Handles doctor profile management, qualifications, and documents
 */
class DoctorProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get doctor profile by user ID
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
            // Decode JSON fields
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
     * Check if license number exists (excluding given user)
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
     * Update doctor profile with comprehensive data
     * Aligns with MVP schema requirements
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET 
                full_name = ?,
                gender = ?,
                date_of_birth = ?,
                phone_number = ?,
                profile_photo = ?,
                primary_specialty = ?,
                sub_specializations = ?,
                years_of_experience = ?,
                license_number = ?,
                languages_spoken = ?,
                street_address = ?,
                city = ?,
                state = ?,
                country = ?,
                postal_code = ?,
                video_enabled = ?,
                video_rate = ?,
                consultation_duration = ?,
                buffer_time = ?,
                updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            return $stmt->execute([
                $data['fullName'] ?? null,
                $data['gender'] ?? 'other',
                $data['dateOfBirth'] ?? null,  // YYYY-MM-DD format
                $data['phoneNumber'] ?? null,
                $data['profilePhoto'] ?? null,
                $data['primarySpecialty'] ?? null,
                json_encode($data['subSpecializations'] ?? []),
                $data['yearsOfExperience'] ?? 0,
                $data['licenseNumber'] ?? null,
                json_encode($data['languagesSpoken'] ?? ['English']),
                $data['streetAddress'] ?? null,
                $data['city'] ?? null,
                $data['state'] ?? null,
                $data['country'] ?? null,
                $data['postalCode'] ?? null,  // mapped from pincode
                $data['videoEnabled'] ?? 1,
                $data['videoRate'] ?? null,
                $data['consultationDuration'] ?? '60min',
                $data['bufferTime'] ?? '10min',
                $userId
            ]);
        } catch (\Exception $e) {
            error_log("Doctor profile setup error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Add qualification to doctor
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
                $data['degree'] ?? null,
                $data['instituteName'] ?? null,
                $data['yearOfCompletion'] ?? null,
                $data['certificateFile'] ?? null,
            ]);
            return $qualificationId;
        } catch (\Exception $e) {
            error_log("Add qualification error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get all qualifications for doctor
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
     * Update qualification
     */
    public function updateQualification(string $qualificationId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_qualifications
            SET degree = ?, institute_name = ?, year_of_completion = ?, certificate_file = ?
            WHERE id = ?
        ');

        try {
            return $stmt->execute([
                $data['degree'] ?? null,
                $data['instituteName'] ?? null,
                $data['yearOfCompletion'] ?? null,
                $data['certificateFile'] ?? null,
                $qualificationId
            ]);
        } catch (\Exception $e) {
            error_log("Update qualification error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Delete qualification
     */
    public function deleteQualification(string $qualificationId): bool {
        $stmt = $this->db->prepare('DELETE FROM doctor_qualifications WHERE id = ?');
        try {
            return $stmt->execute([$qualificationId]);
        } catch (\Exception $e) {
            error_log("Delete qualification error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get doctor's appointments
     */
    public function getAppointments(string $doctorId, ?string $status = null): array {
        $query = '
            SELECT 
                a.id,
                a.doctor_id,
                a.patient_id,
                a.scheduled_date,
                a.scheduled_time,
                a.end_time,
                a.consultation_type,
                a.status,
                p.full_name,
                p.age
            FROM appointments a
            JOIN patient_profiles p ON a.patient_id = p.user_id
            WHERE a.doctor_id = ?
        ';

        $params = [$doctorId];

        if ($status) {
            $query .= ' AND a.status = ?';
            $params[] = $status;
        }

        $query .= ' ORDER BY a.scheduled_date ASC, a.scheduled_time ASC';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Check if doctor exists
     */
    public function exists(string $doctorId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Get all doctors (list with basic info)
     */
    public function getAllDoctors(): array {
        try {
            $stmt = $this->db->prepare('
                SELECT 
                    dp.user_id,
                    dp.full_name,
                    dp.gender,
                    dp.primary_specialty,
                    dp.years_of_experience,
                    dp.languages_spoken,
                    dp.video_enabled,
                    dp.video_rate,
                    dp.consultation_duration,
                    dp.is_verified,
                    u.email,
                    u.user_type
                FROM doctor_profiles dp
                JOIN users u ON dp.user_id = u.id
                ORDER BY dp.full_name ASC
            ');
            $stmt->execute();
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Decode JSON fields
            foreach ($results as &$doctor) {
                if ($doctor['languages_spoken']) {
                    $doctor['languages_spoken'] = json_decode($doctor['languages_spoken'], true);
                }
            }

            return $results;
        } catch (\Exception $e) {
            error_log("getAllDoctors error: " . $e->getMessage());
            throw $e;
        }
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
