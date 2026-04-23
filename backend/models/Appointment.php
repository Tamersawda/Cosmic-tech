<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class Appointment {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get appointment by ID
     */
    public function findById(string $appointmentId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM appointments
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$appointmentId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * CRITICAL: Check for overlapping appointments for a doctor
     * Returns true if there IS an overlap (conflict)
     * Condition: new_start < existing_end AND new_end > existing_start
     */
    public function hasOverlappingAppointment(
        string $doctorId,
        string $scheduledDate,
        string $scheduledTime,
        string $endTime,
        ?string $excludeAppointmentId = null
    ): bool {
        $query = '
            SELECT 1 FROM appointments
            WHERE doctor_id = ?
            AND scheduled_date = ?
            AND status IN ("scheduled", "in_progress")
            AND scheduled_time < ?
            AND end_time > ?
        ';

        $params = [
            $doctorId,
            $scheduledDate,
            $endTime,           // new_start < existing_end
            $scheduledTime      // new_end > existing_start
        ];

        if ($excludeAppointmentId) {
            $query .= ' AND id != ?';
            $params[] = $excludeAppointmentId;
        }

        $query .= ' LIMIT 1';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * CRITICAL: Check for client's conflicting appointments
     * Condition: new_start < existing_end AND new_end > existing_start
     */
    public function hasClientConflict(
        string $clientId,
        string $scheduledDate,
        string $scheduledTime,
        string $endTime,
        ?string $excludeAppointmentId = null
    ): bool {
        $query = '
            SELECT 1 FROM appointments
            WHERE client_id = ?
            AND scheduled_date = ?
            AND status IN ("scheduled", "in_progress")
            AND scheduled_time < ?
            AND end_time > ?
        ';

        $params = [
            $clientId,
            $scheduledDate,
            $endTime,           // new_start < existing_end
            $scheduledTime      // new_end > existing_start
        ];

        if ($excludeAppointmentId) {
            $query .= ' AND id != ?';
            $params[] = $excludeAppointmentId;
        }

        $query .= ' LIMIT 1';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Create new appointment
     */
    public function create(array $data): string {
        $appointmentId = $this->generateUUID();

        $stmt = $this->db->prepare('
            INSERT INTO appointments (
                id, doctor_id, client_id, scheduled_date,
                scheduled_time, end_time, consultation_type,
                status, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, "scheduled", UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $stmt->execute([
            $appointmentId,
            $data['doctor_id'],
            $data['client_id'],
            $data['scheduled_date'],
            $data['scheduled_time'],
            $data['end_time'],
            $data['consultation_type'] ?? 'video'
        ]);

        return $appointmentId;
    }

    /**
     * Get appointments for doctor or client
     */
    public function getByUser(string $userId, string $userType, ?string $status = null): array {
        if ($userType === 'doctor') {
            $field = 'doctor_id';
        } else {
            $field = 'client_id';
        }

        $query = "
            SELECT a.*,
                CASE 
                    WHEN '$userType' = 'doctor' THEN c.full_name
                    ELSE d.full_name
                END as other_party_name
            FROM appointments a
        ";

        if ($userType === 'doctor') {
            $query .= ' LEFT JOIN client_profiles c ON a.client_id = c.user_id';
        } else {
            $query .= ' LEFT JOIN doctor_profiles d ON a.doctor_id = d.user_id';
        }

        $query .= " WHERE a.$field = ?";
        $params = [$userId];

        if ($status) {
            $query .= ' AND a.status = ?';
            $params[] = $status;
        }

        $query .= ' ORDER BY a.scheduled_date DESC, a.scheduled_time DESC';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Cancel appointment (update status to cancelled)
     */
    public function cancel(string $appointmentId): bool {
        $stmt = $this->db->prepare('
            UPDATE appointments
            SET status = "cancelled", updated_at = UTC_TIMESTAMP()
            WHERE id = ? AND status = "scheduled"
        ');

        return $stmt->execute([$appointmentId]);
    }

    /**
     * Update an appointment
     */
    public function update(string $appointmentId, array $data): bool {
        $updates = [];
        $values = [];

        if (isset($data['status'])) {
            $updates[] = 'status = ?';
            $values[] = $data['status'];
        }
        if (isset($data['notes'])) {
            $updates[] = 'notes = ?';
            $values[] = $data['notes'];
        }
        if (isset($data['scheduled_date'])) {
            $updates[] = 'scheduled_date = ?';
            $values[] = $data['scheduled_date'];
        }
        if (isset($data['scheduled_time'])) {
            $updates[] = 'scheduled_time = ?';
            $values[] = $data['scheduled_time'];
        }

        if (empty($updates)) {
            return false;
        }

        $updates[] = 'updated_at = UTC_TIMESTAMP()';
        $values[] = $appointmentId;

        $query = 'UPDATE appointments SET ' . implode(', ', $updates) . ' WHERE id = ?';
        $stmt = $this->db->prepare($query);
        return $stmt->execute($values);
    }

    public function getByClient(string $clientId, ?string $status = null): array {
        return $this->getByUser($clientId, 'client', $status);
    }

    /**
     * Get appointments for a doctor
     */
    public function getByDoctor(string $doctorId, ?string $status = null): array {
        return $this->getByUser($doctorId, 'doctor', $status);
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
