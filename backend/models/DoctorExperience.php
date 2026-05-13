<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class DoctorExperience {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function create(array $data): string {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_experiences
                (doctor_id, company, role_title, employment_type,
                 currently_working, start_date, end_date, description)
            VALUES
                (:doctor_id, :company, :role_title, :employment_type,
                 :currently_working, :start_date, :end_date, :description)
        ');
        $stmt->execute([
            ':doctor_id'         => $data['doctor_id'],
            ':company'           => $data['company'],
            ':role_title'        => $data['role_title'],
            ':employment_type'   => $data['employment_type'] ?? 'full_time',
            ':currently_working' => $data['currently_working'] ? 1 : 0,
            ':start_date'        => $data['start_date'],
            ':end_date'          => $data['end_date'] ?? null,
            ':description'       => $data['description'] ?? null,
        ]);

        return $this->fetchLastId($data['doctor_id']);
    }

    public function getByDoctorId(string $doctorId): array {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_experiences
            WHERE doctor_id = ?
            ORDER BY start_date DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(string $id): ?array {
        $stmt = $this->db->prepare('SELECT * FROM doctor_experiences WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function update(string $id, array $data): bool {
        $allowed = [
            'company', 'role_title', 'employment_type',
            'currently_working', 'start_date', 'end_date', 'description',
        ];
        $sets   = [];
        $params = [];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $sets[]         = "$col = :$col";
                $params[":$col"] = $data[$col];
            }
        }
        if (empty($sets)) return false;

        $params[':id'] = $id;
        $sql = 'UPDATE doctor_experiences SET ' . implode(', ', $sets) . ' WHERE id = :id';
        return $this->db->prepare($sql)->execute($params);
    }

    public function delete(string $id): bool {
        return $this->db->prepare('DELETE FROM doctor_experiences WHERE id = ?')->execute([$id]);
    }

    private function fetchLastId(string $doctorId): string {
        $stmt = $this->db->prepare('
            SELECT id FROM doctor_experiences
            WHERE doctor_id = ?
            ORDER BY created_at DESC LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['id'] ?? '';
    }
}
