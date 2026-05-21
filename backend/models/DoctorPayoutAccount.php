<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorPayoutAccount Model
 * Manages payout account information for doctors
 */
class DoctorPayoutAccount
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Create a new payout account
     */
    public function create(array $data): ?string
    {
        // If this is the first account or marked as primary, set as primary
        $existingCount = $this->countByDoctor($data['doctor_id']);
        $isPrimary = $data['is_primary'] ?? ($existingCount === 0);

        $stmt = $this->db->prepare('
            INSERT INTO doctor_payout_accounts
            (id, doctor_id, account_holder_name, account_number, ifsc_code, bank_name, 
             branch_name, pan_number, is_gst_registered, gst_number, is_primary, 
             terms_consent, verification_status, created_at, updated_at)
            VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ');

        $success = $stmt->execute([
            $data['doctor_id'],
            $data['account_holder_name'],
            $data['account_number'],
            $data['ifsc_code'],
            $data['bank_name'],
            $data['branch_name'],
            $data['pan_number'] ?? null,
            $data['is_gst_registered'] ? 1 : 0,
            $data['gst_number'] ?? null,
            $isPrimary ? 1 : 0,
            $data['terms_consent'] ?? $data['termsConsent'] ?? false,
            $data['verification_status'] ?? 'pending',
        ]);

        if ($success) {
            // Return the inserted ID by querying the most recent insert
            $stmt = $this->db->prepare('
                SELECT id FROM doctor_payout_accounts
                WHERE doctor_id = ?
                ORDER BY created_at DESC
                LIMIT 1
            ');
            $stmt->execute([$data['doctor_id']]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            return $result['id'] ?? null;
        }
        return null;
    }

    /**
     * Get payout account by ID
     */
    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_payout_accounts WHERE id = ?
        ');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get primary payout account for doctor
     */
    public function getPrimaryByDoctor(string $doctorId): ?array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_payout_accounts
            WHERE doctor_id = ? AND is_primary = 1
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get all payout accounts for doctor
     */
    public function findByDoctor(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_payout_accounts
            WHERE doctor_id = ?
            ORDER BY is_primary DESC, created_at ASC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Count active accounts for doctor
     */
    public function countByDoctor(string $doctorId): int
    {
        $stmt = $this->db->prepare('
            SELECT COUNT(*) as count FROM doctor_payout_accounts
            WHERE doctor_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return (int)($result['count'] ?? 0);
    }

    /**
     * Check if account number already exists for another doctor
     */
    public function accountNumberExists(string $accountNumber, ?string $excludeDoctorId = null): bool
    {
        if ($excludeDoctorId) {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_payout_accounts
                WHERE account_number = ? AND doctor_id != ?
                LIMIT 1
            ');
            $stmt->execute([$accountNumber, $excludeDoctorId]);
        } else {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_payout_accounts
                WHERE account_number = ?
                LIMIT 1
            ');
            $stmt->execute([$accountNumber]);
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Update payout account
     */
    public function update(string $id, array $data): bool
    {
        $setClause = [];
        $params = [];

        foreach ($data as $key => $value) {
            if (in_array($key, [
                'account_holder_name', 'account_number', 'ifsc_code', 'bank_name',
                'branch_name', 'pan_number', 'is_gst_registered', 'gst_number',
                'terms_consent', 'verification_status', 'rejection_reason', 'is_primary'
            ])) {
                $setClause[] = "$key = :$key";
                $params[":$key"] = $value;
            }
        }

        if (empty($setClause)) {
            return false;
        }

        $params[':id'] = $id;
        $setClause[] = 'updated_at = CURRENT_TIMESTAMP';

        $sql = 'UPDATE doctor_payout_accounts SET ' . implode(', ', $setClause) . ' WHERE id = :id';
        return $this->db->prepare($sql)->execute($params);
    }

    /**
     * Verify account
     */
    public function verify(string $id): bool
    {
        $stmt = $this->db->prepare('
            UPDATE doctor_payout_accounts
            SET verification_status = "verified", updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
        ');
        return $stmt->execute([$id]);
    }

    /**
     * Reject account
     */
    public function reject(string $id, string $reason): bool
    {
        $stmt = $this->db->prepare('
            UPDATE doctor_payout_accounts
            SET verification_status = "rejected", rejection_reason = ?, updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$reason, $id]);
    }

    /**
     * Delete account
     */
    public function delete(string $id): bool
    {
        $stmt = $this->db->prepare('DELETE FROM doctor_payout_accounts WHERE id = ?');
        return $stmt->execute([$id]);
    }
}
