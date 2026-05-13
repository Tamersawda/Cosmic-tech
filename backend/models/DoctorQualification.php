<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

class DoctorQualification {
    private PDO $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function create(array $data): string {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_qualifications
                (doctor_id, title, degree, institution, year, document_path)
            VALUES
                (:doctor_id, :title, :degree, :institution, :year, :document_path)
        ');
        $stmt->execute([
            ':doctor_id'     => $data['doctor_id'],
            ':title'         => $data['title'],
            ':degree'        => $data['degree'] ?? null,
            ':institution'   => $data['institution'] ?? null,
            ':year'          => $data['year'] ?? null,
            ':document_path' => $data['document_path'] ?? null,
        ]);

        // For UUID primary keys MySQL won't expose lastInsertId() usefully.
        // Re-fetch the most recent row for this doctor.
        return $this->fetchLastId($data['doctor_id']);
    }

    public function getByDoctorId(string $doctorId): array {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_qualifications
            WHERE doctor_id = ?
            ORDER BY created_at DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(string $id): ?array {
        $stmt = $this->db->prepare('SELECT * FROM doctor_qualifications WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function update(string $id, array $data): bool {
        $allowed = ['title', 'degree', 'institution', 'year', 'document_path'];
        $sets    = [];
        $params  = [];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $sets[]         = "$col = :$col";
                $params[":$col"] = $data[$col];
            }
        }
        if (empty($sets)) return false;

        $params[':id'] = $id;
        $sql = 'UPDATE doctor_qualifications SET ' . implode(', ', $sets) . ' WHERE id = :id';
        return $this->db->prepare($sql)->execute($params);
    }

    public function delete(string $id): bool {
        return $this->db->prepare('DELETE FROM doctor_qualifications WHERE id = ?')->execute([$id]);
    }

    private function fetchLastId(string $doctorId): string {
        $stmt = $this->db->prepare('
            SELECT id FROM doctor_qualifications
            WHERE doctor_id = ?
            ORDER BY created_at DESC
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['id'] ?? '';
    }
}
