<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class Message {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Send a message in an appointment
     */
    public function sendMessage(
        string $appointmentId,
        string $senderId,
        string $content,
        string $messageType = 'text'
    ): string {
        try {
            // Validate appointment exists
            $appointment = $this->getAppointment($appointmentId);
            if (!$appointment) {
                throw new \Exception('Appointment not found');
            }

            // Validate user belongs to appointment
            if ($appointment['doctor_id'] !== $senderId && $appointment['patient_id'] !== $senderId) {
                throw new \Exception('Unauthorized');
            }

            // Validate appointment status (scheduled or in_progress)
            if (!in_array($appointment['status'], ['scheduled', 'in_progress'])) {
                throw new \Exception('Cannot send messages for this appointment');
            }

            // Insert message
            $messageId = $this->generateUUID();
            $stmt = $this->db->prepare('
                INSERT INTO messages (
                    id, appointment_id, sender_id, content, message_type, is_read, created_at
                ) VALUES (?, ?, ?, ?, ?, 0, UTC_TIMESTAMP())
            ');

            $stmt->execute([
                $messageId,
                $appointmentId,
                $senderId,
                $content,
                $messageType
            ]);

            return $messageId;

        } catch (\Exception $e) {
            error_log("Send message error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Get messages for an appointment with pagination
     */
    public function getMessages(
        string $appointmentId,
        string $userId,
        int $page = 1,
        int $limit = 50
    ): array {
        try {
            // Validate appointment exists and user belongs to it
            $appointment = $this->getAppointment($appointmentId);
            if (!$appointment) {
                throw new \Exception('Appointment not found');
            }

            if ($appointment['doctor_id'] !== $userId && $appointment['patient_id'] !== $userId) {
                throw new \Exception('Unauthorized');
            }

            // Validate pagination
            if ($page < 1) {
                $page = 1;
            }
            if ($limit < 1 || $limit > 100) {
                $limit = 50;
            }

            $offset = ($page - 1) * $limit;

            // Get messages
            $stmt = $this->db->prepare('
                SELECT 
                    id,
                    sender_id,
                    content,
                    message_type,
                    is_read,
                    created_at
                FROM messages
                WHERE appointment_id = ?
                ORDER BY created_at ASC
                LIMIT ? OFFSET ?
            ');

            $stmt->execute([$appointmentId, $limit, $offset]);
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Mark messages as read
            $this->markMessagesAsRead($appointmentId, $userId);

            return $messages;

        } catch (\Exception $e) {
            error_log("Get messages error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Mark messages as read for a user
     */
    private function markMessagesAsRead(string $appointmentId, string $userId): void {
        $stmt = $this->db->prepare('
            UPDATE messages
            SET is_read = 1
            WHERE appointment_id = ?
            AND sender_id != ?
            AND is_read = 0
        ');

        $stmt->execute([$appointmentId, $userId]);
    }

    /**
     * Get unread message count for a user
     */
    public function getUnreadCount(string $userId): int {
        $stmt = $this->db->prepare('
            SELECT COUNT(*) as count FROM messages
            WHERE sender_id != ?
            AND is_read = 0
        ');

        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        return $result['count'] ?? 0;
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
     * Create a standalone message (non-appointment-specific)
     */
    public function create(array $data): string {
        $messageId = $this->generateUUID();
        $stmt = $this->db->prepare('
            INSERT INTO messages 
            (id, sender_id, recipient_id, content, message_type, subject, is_read, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 0, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');
        
        $stmt->execute([
            $messageId,
            $data['sender_id'],
            $data['recipient_id'],
            $data['content'],
            $data['message_type'] ?? 'text',
            $data['subject'] ?? null
        ]);
        
        return $messageId;
    }

    /**
     * Get inbox messages for a user
     */
    public function getInbox(string $userId): array {
        $stmt = $this->db->prepare('
            SELECT m.*,
                   u.first_name as sender_first_name,
                   u.last_name as sender_last_name,
                   u.email as sender_email
            FROM messages m
            JOIN users u ON m.sender_id = u.id
            WHERE m.recipient_id = ?
            ORDER BY m.created_at DESC
        ');
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get sent messages for a user
     */
    public function getSent(string $userId): array {
        $stmt = $this->db->prepare('
            SELECT m.*,
                   u.first_name as recipient_first_name,
                   u.last_name as recipient_last_name,
                   u.email as recipient_email
            FROM messages m
            JOIN users u ON m.recipient_id = u.id
            WHERE m.sender_id = ?
            ORDER BY m.created_at DESC
        ');
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get message by ID
     */
    public function getById(string $messageId): ?array {
        $stmt = $this->db->prepare('
            SELECT *
            FROM messages
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$messageId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Update a message
     */
    public function update(string $messageId, array $data): bool {
        $updates = [];
        $values = [];

        if (isset($data['is_read'])) {
            $updates[] = 'is_read = ?';
            $values[] = (int)$data['is_read'];
        }
        if (isset($data['content'])) {
            $updates[] = 'content = ?';
            $values[] = $data['content'];
        }
        if (isset($data['subject'])) {
            $updates[] = 'subject = ?';
            $values[] = $data['subject'];
        }

        if (empty($updates)) {
            return false;
        }

        $updates[] = 'updated_at = UTC_TIMESTAMP()';
        $values[] = $messageId;

        $query = 'UPDATE messages SET ' . implode(', ', $updates) . ' WHERE id = ?';
        $stmt = $this->db->prepare($query);
        return $stmt->execute($values);
    }

    /**
     * Delete a message
     */
    public function delete(string $messageId): bool {
        $stmt = $this->db->prepare('
            DELETE FROM messages
            WHERE id = ?
        ');
        return $stmt->execute([$messageId]);
    }
}
