<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class AvailableSlots {
    private PDO $db;

    // Fixed working hours for MVP
    private const WORKING_START = '09:00';
    private const WORKING_END = '17:00';
    private const SLOT_DURATION = 50;    // minutes
    private const BUFFER_TIME = 10;      // minutes
    private const SLOT_INTERVAL = 60;    // 1 hour between slots

    public function __construct() {
        $this->db = Database::getInstance();
    }

    /**
     * Generate available slots for a doctor in a date range
     */
    public function getAvailableSlots(
        string $doctorId,
        string $fromDate,
        string $toDate
    ): array {
        // Validate doctor exists
        $doctorExists = $this->doctorExists($doctorId);
        if (!$doctorExists) {
            throw new \Exception('Doctor not found');
        }

        // Validate dates
        $from = \DateTime::createFromFormat('Y-m-d', $fromDate);
        $to = \DateTime::createFromFormat('Y-m-d', $toDate);

        if (!$from || !$to) {
            throw new \Exception('Invalid date format');
        }

        if ($from > $to) {
            throw new \Exception('From date must be before or equal to to date');
        }

        // Get existing appointments for this doctor in the range
        $existingAppointments = $this->getExistingAppointments($doctorId, $fromDate, $toDate);

        // Generate all possible slots
        $availableSlots = [];
        $currentDate = clone $from;

        while ($currentDate <= $to) {
            $dateStr = $currentDate->format('Y-m-d');

            // Skip past dates (for today, skip past times)
            if ($dateStr < date('Y-m-d')) {
                $currentDate->modify('+1 day');
                continue;
            }

            // Generate hourly slots for this day
            $daySlots = $this->generateDaySlots($dateStr, $existingAppointments);
            $availableSlots = array_merge($availableSlots, $daySlots);

            $currentDate->modify('+1 day');
        }

        return $availableSlots;
    }

    /**
     * Generate all possible slots for a single day, excluding occupied ones
     */
    private function generateDaySlots(string $date, array $existingAppointments): array {
        $slots = [];

        // Parse working hours
        $workStart = \DateTime::createFromFormat('H:i', self::WORKING_START);
        $workEnd = \DateTime::createFromFormat('H:i', self::WORKING_END);

        $currentSlot = clone $workStart;
        $today = date('Y-m-d');

        while ($currentSlot < $workEnd) {
            $slotTime = $currentSlot->format('H:i');
            $endTime = (clone $currentSlot)->modify('+' . self::SLOT_DURATION . ' minutes')->format('H:i');

            // Skip past slots for today
            if ($date === $today) {
                $slotDateTime = \DateTime::createFromFormat('Y-m-d H:i', "$date $slotTime");
                if ($slotDateTime < new \DateTime()) {
                    $currentSlot->modify('+' . self::SLOT_INTERVAL . ' minutes');
                    continue;
                }
            }

            // Check if this slot overlaps with existing appointments
            if (!$this->isSlotOccupied($date, $slotTime, $endTime, $existingAppointments)) {
                $slots[] = [
                    'date' => $date,
                    'time' => $slotTime,
                    'endTime' => $endTime
                ];
            }

            $currentSlot->modify('+' . self::SLOT_INTERVAL . ' minutes');
        }

        return $slots;
    }

    /**
     * Check if a slot is occupied by existing appointments
     * Condition: new_start < existing_end AND new_end > existing_start
     */
    private function isSlotOccupied(
        string $date,
        string $startTime,
        string $endTime,
        array $existingAppointments
    ): bool {
        foreach ($existingAppointments as $appointment) {
            if ($appointment['scheduled_date'] === $date) {
                // Check overlap condition
                if ($startTime < $appointment['end_time'] && $endTime > $appointment['scheduled_time']) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Get existing appointments for doctor (scheduled and in_progress only)
     */
    private function getExistingAppointments(string $doctorId, string $fromDate, string $toDate): array {
        $stmt = $this->db->prepare('
            SELECT 
                doctor_id,
                scheduled_date,
                scheduled_time,
                end_time,
                status
            FROM appointments
            WHERE doctor_id = ?
            AND scheduled_date BETWEEN ? AND ?
            AND status IN ("scheduled", "in_progress")
            ORDER BY scheduled_date ASC, scheduled_time ASC
        ');

        $stmt->execute([$doctorId, $fromDate, $toDate]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Check if doctor exists
     */
    private function doctorExists(string $doctorId): bool {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Create a new available slot
     */
    public function create(array $data): string {
        $slotId = bin2hex(random_bytes(16));
        $stmt = $this->db->prepare('
            INSERT INTO available_slots 
            (id, doctor_id, slot_date, slot_time, duration_minutes, is_available, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, 1, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');
        
        $stmt->execute([
            $slotId,
            $data['doctor_id'],
            $data['slot_date'],
            $data['slot_time'],
            $data['duration_minutes'] ?? 50
        ]);
        
        return $slotId;
    }

    /**
     * Get all slots for a doctor
     */
    public function getDoctorSlots(string $doctorId): array {
        $stmt = $this->db->prepare('
            SELECT *
            FROM available_slots
            WHERE doctor_id = ?
            ORDER BY slot_date ASC, slot_time ASC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get slot by ID
     */
    public function getById(string $slotId): ?array {
        $stmt = $this->db->prepare('
            SELECT *
            FROM available_slots
            WHERE id = ?
            LIMIT 1
        ');
        $stmt->execute([$slotId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Update a slot
     */
    public function update(string $slotId, array $data): bool {
        $stmt = $this->db->prepare('
            UPDATE available_slots
            SET 
                slot_time = COALESCE(?, slot_time),
                duration_minutes = COALESCE(?, duration_minutes),
                is_available = COALESCE(?, is_available),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        
        return $stmt->execute([
            $data['slot_time'] ?? null,
            $data['duration_minutes'] ?? null,
            isset($data['is_available']) ? (int)$data['is_available'] : null,
            $slotId
        ]);
    }

    /**
     * Delete a slot
     */
    public function delete(string $slotId): bool {
        $stmt = $this->db->prepare('
            DELETE FROM available_slots
            WHERE id = ?
        ');
        return $stmt->execute([$slotId]);
    }
}
