<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorDocument Model
 * Manages document uploads for onboarding verification.
 * 
 * Each document is verified independently by admin.
 * Document types: govt_id_front, govt_id_back, qualification_certificate,
 *                 rci_certificate, experience_proof
 * 
 * Verification statuses: pending → verified | rejected
 */
class DoctorDocument
{
    private PDO $db;

    /**
     * Valid document types (must match ENUM in doctor_documents table)
     */
    public const DOCUMENT_TYPES = [
        'govt_id_front',
        'govt_id_back',
        'qualification_certificate',
        'rci_certificate',
        'experience_proof',
    ];

    /**
     * Valid verification statuses
     */
    public const VERIFICATION_STATUSES = ['pending', 'verified', 'rejected'];

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Create a new document record.
     * Returns the generated UUID on success, null on failure.
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
            $data['verification_status'] ?? 'pending',
        ]);

        return $success ? $id : null;
    }

    /**
     * Get document by ID.
     */
    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('
            SELECT dd.*, u.full_name AS verified_by_name
            FROM doctor_documents dd
            LEFT JOIN users u ON dd.verified_by = u.id
            WHERE dd.id = ?
        ');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get documents by doctor and type.
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
     * Get all documents for a doctor.
     */
    public function findByDoctor(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT dd.*, u.full_name AS verified_by_name
            FROM doctor_documents dd
            LEFT JOIN users u ON dd.verified_by = u.id
            WHERE dd.doctor_id = ?
            ORDER BY dd.uploaded_at DESC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get documents grouped by type for a doctor.
     * Useful for onboarding UI showing required vs uploaded docs.
     */
    public function getGroupedByType(string $doctorId): array
    {
        $docs = $this->findByDoctor($doctorId);
        $grouped = [];

        foreach (self::DOCUMENT_TYPES as $type) {
            $grouped[$type] = array_filter($docs, fn($d) => $d['document_type'] === $type);
            $grouped[$type] = array_values($grouped[$type]);
        }

        return $grouped;
    }

    /**
     * Check if all required documents are uploaded for a doctor.
     * Required: govt_id_front, govt_id_back, qualification_certificate
     * Optional: rci_certificate, experience_proof
     */
    public function hasRequiredDocuments(string $doctorId): array
    {
        $required = ['govt_id_front', 'govt_id_back', 'qualification_certificate'];
        $uploaded = $this->findByDoctor($doctorId);
        $uploadedTypes = array_column($uploaded, 'document_type');

        $missing = array_diff($required, $uploadedTypes);

        return [
            'complete' => empty($missing),
            'required' => $required,
            'uploaded' => array_intersect($required, $uploadedTypes),
            'missing' => array_values($missing),
        ];
    }

    /**
     * Check if all uploaded documents are verified for a doctor.
     */
    public function allDocumentsVerified(string $doctorId): bool
    {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_documents
            WHERE doctor_id = ? AND verification_status != "verified"
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) === false;
    }

    /**
     * Get document verification summary for a doctor.
     */
    public function getVerificationSummary(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                verification_status,
                COUNT(*) as count
            FROM doctor_documents
            WHERE doctor_id = ?
            GROUP BY verification_status
        ');
        $stmt->execute([$doctorId]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $summary = [
            'total' => 0,
            'pending' => 0,
            'verified' => 0,
            'rejected' => 0,
        ];

        foreach ($results as $row) {
            $summary[$row['verification_status']] = (int) $row['count'];
            $summary['total'] += (int) $row['count'];
        }

        return $summary;
    }

    /**
     * Update verification status for a document.
     * Tracks which admin verified/rejected the document.
     */
    public function updateVerificationStatus(
        string $documentId,
        string $status,
        ?string $rejectionReason = null,
        ?string $adminId = null
    ): bool {
        if (!in_array($status, self::VERIFICATION_STATUSES)) {
            error_log("Invalid verification status: {$status}");
            return false;
        }

        $stmt = $this->db->prepare('
            UPDATE doctor_documents
            SET verification_status = ?,
                rejection_reason = ?,
                verified_by = ?,
                verified_at = UTC_TIMESTAMP(),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$status, $rejectionReason, $adminId, $documentId]);
    }

    /**
     * Approve a document.
     */
    public function approve(string $documentId, ?string $adminId = null): bool
    {
        return $this->updateVerificationStatus($documentId, 'verified', null, $adminId);
    }

    /**
     * Reject a document with a reason.
     */
    public function reject(string $documentId, string $reason, ?string $adminId = null): bool
    {
        return $this->updateVerificationStatus($documentId, 'rejected', $reason, $adminId);
    }

    /**
     * Delete a document.
     */
    public function delete(string $id): bool
    {
        $stmt = $this->db->prepare('DELETE FROM doctor_documents WHERE id = ?');
        return $stmt->execute([$id]);
    }

    /**
     * Get all documents pending verification (for admin panel).
     */
    public function getPendingVerifications(int $limit = 50, int $offset = 0): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                dd.*,
                dp.user_id,
                u.full_name AS doctor_name,
                u.email AS doctor_email
            FROM doctor_documents dd
            JOIN doctor_profiles dp ON dd.doctor_id = dp.user_id
            JOIN users u ON dp.user_id = u.id
            WHERE dd.verification_status = "pending"
            ORDER BY dd.uploaded_at ASC
            LIMIT ? OFFSET ?
        ');
        $stmt->execute([$limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Generate a v4 UUID.
     */
    private function generateUUID(): string
    {
        $data = openssl_random_pseudo_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}