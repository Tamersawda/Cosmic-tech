<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorExperience Model
 *
 * Manages the doctor_experiences table.
 * Updated to support new onboarding fields: work_type, custom_work_type,
 * proof_document_url, verification_status.
 */
class DoctorExperience
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Create a new experience record.
     *
     * @param array $data Keys: doctor_id, company, role_title, work_type, custom_work_type,
     *                    currently_working, start_date, end_date, description, proof_document_url
     * @return string UUID of the created record
     */
    public function create(array $data): string
    {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_experiences
                (doctor_id, company, role_title, work_type,
                 custom_work_type, currently_working, start_date, end_date,
                 description, proof_document_url)
            VALUES
                (:doctor_id, :company, :role_title, :work_type,
                 :custom_work_type, :currently_working, :start_date, :end_date,
                 :description, :proof_document_url)
        ');
        $stmt->execute([
            ':doctor_id'           => $data['doctor_id'],
            ':company'             => $data['company'],
            ':role_title'          => $data['role_title'],
            ':work_type'           => $data['work_type'] ?? 'hospital',
            ':custom_work_type'    => $data['custom_work_type'] ?? null,
            ':currently_working'   => (int)(!empty($data['currently_working'])),
            ':start_date'          => $data['start_date'],
            ':end_date'            => $data['end_date'] ?? null,
            ':description'         => $data['description'] ?? null,
            ':proof_document_url'  => $data['proof_document_url'] ?? null,
        ]);

        return $this->fetchLastId($data['doctor_id']);
    }

    /**
     * Get all experiences for a doctor, newest first.
     * Alias: findByDoctor() (used by OnboardingExperiencesController)
     */
    public function findByDoctor(string $doctorId): array
    {
        return $this->getByDoctorId($doctorId);
    }

    public function getByDoctorId(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_experiences
            WHERE doctor_id = ?
            ORDER BY start_date DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get a single experience by ID.
     * Alias: findById() (used by OnboardingExperiencesController)
     */
    public function findById(string $id): ?array
    {
        return $this->getById($id);
    }

    public function getById(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM doctor_experiences WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    /**
     * Update specific fields of an experience record.
     */
    public function update(string $id, array $data): bool
    {
        $allowed = [
            'company', 'role_title', 'work_type',
            'custom_work_type', 'currently_working',
            'start_date', 'end_date', 'description', 'proof_document_url',
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

    /**
     * Delete an experience record by ID.
     */
    public function delete(string $id): bool
    {
        return $this->db->prepare('DELETE FROM doctor_experiences WHERE id = ?')
                        ->execute([$id]);
    }

    private function fetchLastId(string $doctorId): string
    {
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
