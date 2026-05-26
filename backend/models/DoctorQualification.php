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
                (doctor_id, qualification_name, institution, passing_year, 
                 certificate_url, verification_status)
            VALUES
                (:doctor_id, :qualification_name, :institution, :passing_year, 
                 :certificate_url, :verification_status)
        ');
        $stmt->execute([
            ':doctor_id'           => $data['doctor_id'],
            ':qualification_name'  => $data['qualification_name'] ?? null,
            ':institution'         => $data['institution'] ?? null,
            ':passing_year'        => $data['passing_year'] ?? null,
            ':certificate_url'     => $data['certificate_url'] ?? null,
            ':verification_status' => $data['verification_status'] ?? 'pending',
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

    /**
     * Alias for getByDoctorId() for controller compatibility.
     */
    public function findByDoctor(string $doctorId): array {
        return $this->getByDoctorId($doctorId);
    }

    public function getById(string $id): ?array {
        $stmt = $this->db->prepare('SELECT * FROM doctor_qualifications WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    /**
     * Alias for getById() for controller compatibility.
     */
    public function findById(string $id): ?array {
        return $this->getById($id);
    }

    public function update(string $id, array $data): bool {
        $allowed = ['qualification_name', 'institution', 'passing_year', 
                   'certificate_url', 'verification_status'];
        $sets   = [];
        $params = [];
        
        foreach ($data as $key => $value) {
            if (in_array($key, $allowed)) {
                $sets[]         = "$key = :$key";
                $params[":$key"] = $value;
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
