<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorDocument Model
 * Manages document uploads for onboarding verification
 */
class DoctorDocument
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Create a new document record
     */
    public function create(array $data): ?string
    {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_documents
            (id, doctor_id, document_type, file_url, file_name, file_size, mime_type, verification_status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ');

        $id = $this->generateUUID();
        $success = $stmt->execute([
            $id,
            $data['doctor_id'],
            $data['document_type'],
            $data['file_url'],
            $data['file_name'],
            $data['file_size'] ?? 0,
            $data['mime_type'] ?? 'application/octet-stream',
            $data['verification_status'] ?? 'pending'
        ]);

        return $success ? $id : null;
    }

    /**
     * Get document by ID
     */
    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_documents WHERE id = ?
        ');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get documents by doctor and type
     */
    public function findByDoctorAndType(string $doctorId, string $documentType): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_documents
            WHERE doctor_id = ? AND document_type = ?
            ORDER BY uploaded_at DESC
        ');
        $stmt->execute([$doctorId, $documentType]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get all documents for a doctor
     */
    public function findByDoctor(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_documents
            WHERE doctor_id = ?
            ORDER BY uploaded_at DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Update verification status
     */
    public function updateVerificationStatus(
        string $documentId,
        string $status,
        ?string $rejectionReason = null
    ): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_documents
            SET verification_status = ?,
                rejection_reason = ?,
                verified_at = UTC_TIMESTAMP(),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$status, $rejectionReason, $documentId]);
    }

    /**
     * Delete document
     */
    public function delete(string $id): bool
    {
        $stmt = $this->db->prepare('DELETE FROM doctor_documents WHERE id = ?');
        return $stmt->execute([$id]);
    }

    /**
     * Generate a v4 UUID.
     */
    private function generateUUID(): string {
        $data = openssl_random_pseudo_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
