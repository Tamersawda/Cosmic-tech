<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class Consultation {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Get consultation session for an appointment
     */
    public function findByAppointmentId(string $appointmentId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM consultation_sessions
            WHERE appointment_id = ?
            LIMIT 1
        ');
        $stmt->execute([$appointmentId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Start consultation - update appointment status and create session
     */
    public function startConsultation(string $appointmentId, string $doctorId): array {
        try {
            // Check appointment exists and belongs to doctor
            $appointment = $this->getAppointment($appointmentId);
            if (!$appointment) {
                throw new \Exception('Appointment not found');
            }

            if ($appointment['doctor_id'] !== $doctorId) {
                throw new \Exception('Unauthorized');
            }

            if ($appointment['status'] !== 'scheduled') {
                throw new \Exception('Appointment is not scheduled');
            }

            // Update appointment status
            $updateStmt = $this->db->prepare('
                UPDATE appointments
                SET status = "in_progress", updated_at = UTC_TIMESTAMP()
                WHERE id = ?
            ');
            $updateStmt->execute([$appointmentId]);

            // Create consultation session
            $consultationId = $this->generateUUID();
            $sessionStmt = $this->db->prepare('
                INSERT INTO consultation_sessions (
                    id, appointment_id, started_at
                ) VALUES (?, ?, UTC_TIMESTAMP())
            ');
            $sessionStmt->execute([$consultationId, $appointmentId]);

            return [
                'consultationId' => $consultationId,
                'startedAt' => date('c'),
                'sessionToken' => 'temp_session_' . substr($consultationId, 0, 8),
                'meetingDetails' => [
                    'platform' => 'placeholder',
                    'joinUrl' => null
                ]
            ];

        } catch (\Exception $e) {
            error_log("Start consultation error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * End consultation
     */
    public function endConsultation(string $appointmentId, string $doctorId, ?string $notes = null): bool {
        try {
            // Check appointment exists and belongs to doctor
            $appointment = $this->getAppointment($appointmentId);
            if (!$appointment) {
                throw new \Exception('Appointment not found');
            }

            if ($appointment['doctor_id'] !== $doctorId) {
                throw new \Exception('Unauthorized');
            }

            if ($appointment['status'] !== 'in_progress') {
                throw new \Exception('Appointment is not in progress');
            }

            // Get consultation session
            $consultation = $this->findByAppointmentId($appointmentId);
            if (!$consultation) {
                throw new \Exception('Consultation session not found');
            }

            // Update appointment status
            $updateStmt = $this->db->prepare('
                UPDATE appointments
                SET status = "completed", updated_at = UTC_TIMESTAMP()
                WHERE id = ?
            ');
            $updateStmt->execute([$appointmentId]);

            // Update consultation session
            $sessionStmt = $this->db->prepare('
                UPDATE consultation_sessions
                SET ended_at = UTC_TIMESTAMP(),
                    notes = ?,
                    duration_minutes = TIMESTAMPDIFF(MINUTE, started_at, UTC_TIMESTAMP())
                WHERE appointment_id = ?
            ');
            $sessionStmt->execute([$notes, $appointmentId]);

            return true;

        } catch (\Exception $e) {
            error_log("End consultation error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Allow client to start consultation too
     */
    public function startConsultationAsClient(string $appointmentId, string $clientId): array {
            // Check appointment exists and belongs to client
            $appointment = $this->getAppointment($appointmentId);
            if (!$appointment) {
                throw new \Exception('Appointment not found');
            }

            if ($appointment['client_id'] !== $clientId) {
                throw new \Exception('Unauthorized');
            }

            if ($appointment['status'] !== 'scheduled') {
                throw new \Exception('Appointment is not scheduled');
            }

            // Update appointment status
            $updateStmt = $this->db->prepare('
                UPDATE appointments
                SET status = "in_progress", updated_at = UTC_TIMESTAMP()
                WHERE id = ?
            ');
            $updateStmt->execute([$appointmentId]);

            // Create consultation session
            $consultationId = $this->generateUUID();
            $sessionStmt = $this->db->prepare('
                INSERT INTO consultation_sessions (
                    id, appointment_id, started_at
                ) VALUES (?, ?, UTC_TIMESTAMP())
            ');
            $sessionStmt->execute([$consultationId, $appointmentId]);

            return [
                'consultationId' => $consultationId,
                'startedAt' => date('c'),
                'sessionToken' => 'temp_session_' . substr($consultationId, 0, 8),
                'meetingDetails' => []
            ];

        } catch (\Exception $e) {
            error_log("Start consultation (client) error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get appointment details
     */
    private function getAppointment(string $appointmentId): ?array {
        $stmt = $this->db->prepare('
            SELECT * FROM appointments
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$appointmentId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
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

    /**
     * Create a consultation record
     */
    public function create(array $data): string {
        $consultationId = $this->generateUUID();
        $stmt = $this->db->prepare('
            INSERT INTO consultation_sessions
            (id, appointment_id, started_at, notes, prescriptions, next_follow_up_date)
            VALUES (?, ?, ?, ?, ?, ?)
        ');

        $stmt->execute([
            $consultationId,
            $data['appointment_id'],
            $data['started_at'] ?? date('Y-m-d H:i:s'),
            $data['notes'] ?? null,
            !empty($data['prescriptions']) ? json_encode($data['prescriptions']) : null,
            $data['next_follow_up_date'] ?? $data['follow_up_date'] ?? null,
        ]);
        
        return $consultationId;
    }

    /**
     * Get consultation by ID
     */
    public function getById(string $consultationId): ?array {
        $stmt = $this->db->prepare('
            SELECT *
            FROM consultation_sessions
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$consultationId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result && $result['prescriptions']) {
            $result['prescriptions'] = json_decode($result['prescriptions'], true);
        }

        return $result ?: null;
    }

    /**
     * Update a consultation
     */
    public function update(string $consultationId, array $data): bool {
        $updates = [];
        $values = [];

        if (isset($data['notes'])) {
            $updates[] = 'notes = ?';
            $values[] = $data['notes'];
        }
        if (isset($data['prescriptions'])) {
            $updates[] = 'prescriptions = ?';
            $values[] = json_encode($data['prescriptions']);
        }
        if (isset($data['next_follow_up_date']) || isset($data['follow_up_date'])) {
            $updates[] = 'next_follow_up_date = ?';
            $values[] = $data['next_follow_up_date'] ?? $data['follow_up_date'];
        }
        if (isset($data['ended_at'])) {
            $updates[] = 'ended_at = ?';
            $values[] = $data['ended_at'];
        }

        if (empty($updates)) {
            return false;
        }

        $values[] = $consultationId;

        $query = 'UPDATE consultation_sessions SET ' . implode(', ', $updates) . ' WHERE id = ?';
        $stmt = $this->db->prepare($query);
        return $stmt->execute($values);
    }

    /**
     * Get consultations for a client
     */
    public function getClientConsultations(string $clientId): array {
        $stmt = $this->db->prepare('
            SELECT cs.*
            FROM consultation_sessions cs
            JOIN appointments a ON cs.appointment_id = a.id
            WHERE a.client_id = ?
            ORDER BY cs.started_at DESC
        ');
        $stmt->execute([$clientId]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($results as &$consultation) {
            if ($consultation['prescriptions']) {
                $consultation['prescriptions'] = json_decode($consultation['prescriptions'], true);
            }
        }

        return $results;
    }

    /**
     * Get consultations for a doctor
     */
    public function getDoctorConsultations(string $doctorId): array {
        $stmt = $this->db->prepare('
            SELECT cs.*
            FROM consultation_sessions cs
            JOIN appointments a ON cs.appointment_id = a.id
            WHERE a.doctor_id = ?
            ORDER BY cs.started_at DESC
        ');
        $stmt->execute([$doctorId]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($results as &$consultation) {
            if ($consultation['prescriptions']) {
                $consultation['prescriptions'] = json_decode($consultation['prescriptions'], true);
            }
        }

        return $results;
    }
}
