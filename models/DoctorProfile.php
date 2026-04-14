<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

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

        if ($result && $result['languages_spoken']) {
            $result['languages_spoken'] = json_decode($result['languages_spoken'], true);
        }

        return $result ?: null;
    }

    /**
     * Check if license number exists
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
     * Update doctor profile with setup data
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET 
                full_name = ?,
                gender = ?,
                date_of_birth = ?,
                phone_number = ?,
                primary_specialty = ?,
                years_of_experience = ?,
                license_number = ?,
                languages_spoken = ?,
                video_enabled = ?,
                video_rate = ?,
                consultation_duration = ?,
                buffer_time = ?,
                onboarding_percentage = 100,
                updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            $result = $stmt->execute([
                $data['fullName'] ?? null,
                $data['gender'] ?? 'other',
                $data['dateOfBirth'] ?? null,
                $data['phoneNumber'] ?? null,
                $data['primarySpecialty'] ?? null,
                $data['yearsOfExperience'] ?? 0,
                $data['licenseNumber'] ?? null,
                json_encode($data['languagesSpoken'] ?? ['English']),
                $data['videoEnabled'] ?? 1,
                $data['videoRate'] ?? null,
                $data['consultationDuration'] ?? '50min',
                $data['bufferTime'] ?? '10min',
                $userId
            ]);

            return $result;
        } catch (\Exception $e) {
            error_log("Doctor profile setup error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get doctor's upcoming appointments
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
                p.first_name,
                p.last_name
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
     * Get all doctors (list)
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
}
