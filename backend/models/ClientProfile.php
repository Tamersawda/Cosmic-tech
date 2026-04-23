<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * ClientProfile Model
 * Manages the client_profiles table.
 */
class ClientProfile {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get a client profile by user ID.
     */
    public function findByUserId(string $userId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM client_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Update the client profile with setup data.
     *
     * Input keys (camelCase from frontend):
     *   gender, dateOfBirth, phoneNumber
     *
     * DB columns (snake_case per schema):
     *   gender, date_of_birth, phone_number
     */
    public function setupProfile(string $userId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE client_profiles
            SET
                gender          = ?,
                date_of_birth   = ?,
                phone_number    = ?,
                updated_at      = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');

        try {
            return $stmt->execute([
                $data['gender']         ?? 'other',
                $data['dateOfBirth']    ?? null,
                $data['phoneNumber']    ?? null,
                $userId,
            ]);
        } catch (\Exception $e) {
            error_log('Client profile setup error: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get a client's appointments, optionally filtered by status.
     * Joins users for doctor name and doctor_profiles for specialty.
     */
    public function getAppointments(string $clientId, ?string $status = null): array {
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
                u.full_name       AS doctor_name,
                d.primary_specialty
            FROM appointments a
            JOIN doctor_profiles d ON a.doctor_id = d.user_id
            JOIN users u ON d.user_id = u.id
            WHERE a.client_id = ?
        ';

        $params = [$clientId];

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
     * Check whether a client profile exists for the given user ID.
     */
    public function exists(string $clientId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM client_profiles WHERE user_id = ? LIMIT 1
        ');
        $stmt->execute([$clientId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }
}
