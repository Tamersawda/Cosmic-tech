<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * PatientProfile Model
 * Manages the patient_profiles table.
 */
class PatientProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get a patient profile by user ID.
     */
    public function findByUserId(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM patient_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Update the patient profile with setup data.
     *
     * Input keys (camelCase from frontend):
     *   fullName, age, gender, phoneNumber, profilePhoto, medicalHistory
     *
     * DB columns (snake_case per schema):
     *   full_name, age, gender, phone_number, profile_photo, medical_history
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE patient_profiles
            SET
                full_name       = ?,
                age             = ?,
                gender          = ?,
                phone_number    = ?,
                profile_photo   = ?,
                medical_history = ?,
                updated_at      = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            return $stmt->execute([
                $data['fullName']       ?? null,
                isset($data['age']) ? (int)$data['age'] : null,
                $data['gender']         ?? 'other',
                $data['phoneNumber']    ?? null,
                $data['profilePhoto']   ?? null,
                $data['medicalHistory'] ?? null,
                $userId,
            ]);
        } catch (\Exception $e) {
            error_log('Patient profile setup error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get a patient's appointments, optionally filtered by status.
     * Joins doctor_profiles for doctor name and specialty.
     */
    public function getAppointments(string $patientId, ?string $status = null): array {
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
                d.full_name       AS doctor_name,
                d.primary_specialty
            FROM appointments a
            JOIN doctor_profiles d ON a.doctor_id = d.user_id
            WHERE a.patient_id = ?
        ';

        $params = [$patientId];

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
     * Check whether a patient profile exists for the given user ID.
     */
    public function exists(string $patientId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM patient_profiles WHERE user_id = ? LIMIT 1
        ');
        $stmt->execute([$patientId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }
}
