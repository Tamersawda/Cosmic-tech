<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class PatientProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get patient profile by user ID
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
     * Update patient profile with setup data
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE patient_profiles
            SET 
                first_name = ?,
                last_name = ?,
                gender = ?,
                date_of_birth = ?,
                phone_number = ?,
                medical_history = ?,
                updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            $result = $stmt->execute([
                $data['firstName'] ?? null,
                $data['lastName'] ?? null,
                $data['gender'] ?? 'other',
                $data['dateOfBirth'] ?? null,
                $data['phoneNumber'] ?? null,
                $data['medicalHistory'] ?? null,
                $userId
            ]);

            return $result;
        } catch (\Exception $e) {
            error_log("Patient profile setup error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get patient's appointments
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
                d.full_name as doctor_name,
                d.primary_specialty
            FROM appointments a
            JOIN doctor_profiles d ON a.doctor_id = d.user_id
            WHERE a.patient_id = ?
        ';

        $params = [$patientId];

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
     * Check if patient exists
     */
    public function exists(string $patientId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM patient_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$patientId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }
}
