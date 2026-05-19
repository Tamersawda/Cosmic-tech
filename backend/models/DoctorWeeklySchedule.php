<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorWeeklySchedule Model
 *
 * Manages the doctor_weekly_schedule table.
 * Each row represents one day of the week for a specific doctor.
 * Unique key: (doctor_id, day_of_week) — upsert is the primary write path.
 */
class DoctorWeeklySchedule
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Upsert a single day entry for a doctor.
     * If a row already exists for (doctor_id, day_of_week), update it.
     * Otherwise insert a new row.
     */
    public function upsert(string $doctorId, array $data): bool
    {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_weekly_schedule
                (doctor_id, day_of_week, is_available, start_time, end_time, break_times)
            VALUES
                (:doctor_id, :day_of_week, :is_available, :start_time, :end_time, :break_times)
            ON DUPLICATE KEY UPDATE
                is_available = VALUES(is_available),
                start_time   = VALUES(start_time),
                end_time     = VALUES(end_time),
                break_times  = VALUES(break_times)
        ');

        return $stmt->execute([
            ':doctor_id'   => $doctorId,
            ':day_of_week' => (int)$data['day_of_week'],
            ':is_available'=> (int)($data['is_available'] ?? 0),
            ':start_time'  => $data['start_time'] ?? null,
            ':end_time'    => $data['end_time']   ?? null,
            ':break_times' => $data['break_times'] ?? null,
        ]);
    }

    /**
     * Get all schedule entries for a doctor, ordered by day.
     */
    public function findByDoctor(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_weekly_schedule
            WHERE doctor_id = ?
            ORDER BY day_of_week ASC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get a single slot by its UUID.
     */
    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM doctor_weekly_schedule WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    /**
     * Update specific fields of a slot by ID.
     *
     * @param string $id   The slot UUID
     * @param array  $data Associative array of allowed columns to update:
     *                     is_available, start_time, end_time, break_times
     */
    public function update(string $id, array $data): bool
    {
        $allowed = ['is_available', 'start_time', 'end_time', 'break_times'];
        $sets    = [];
        $params  = [];

        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $sets[]         = "$col = :$col";
                $params[":$col"] = $data[$col];
            }
        }

        if (empty($sets)) {
            return false;
        }

        $params[':id'] = $id;
        $sql = 'UPDATE doctor_weekly_schedule SET ' . implode(', ', $sets) . ' WHERE id = :id';
        return $this->db->prepare($sql)->execute($params);
    }

    /**
     * Delete a single slot by ID.
     */
    public function delete(string $id): bool
    {
        return $this->db->prepare('DELETE FROM doctor_weekly_schedule WHERE id = ?')
                        ->execute([$id]);
    }

    /**
     * Delete all slots for a doctor (used when replacing the full schedule).
     */
    public function deleteByDoctor(string $doctorId): bool
    {
        return $this->db->prepare('DELETE FROM doctor_weekly_schedule WHERE doctor_id = ?')
                        ->execute([$doctorId]);
    }
}
