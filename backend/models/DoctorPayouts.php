<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * DoctorPayouts Model
 * Manages doctor_payouts table — payout account information for doctors.
 * 
 * Supports multiple payment providers: bank, upi, razorpay, stripe, paypal.
 * Status flow: pending → submitted → verified | rejected
 * 
 * A doctor's profile transitions to 'active' only after a payout is verified.
 */
class DoctorPayouts
{
    private PDO $db;

    /**
     * Valid payment providers
     */
    public const PROVIDERS = ['bank', 'upi', 'razorpay', 'stripe', 'paypal'];

    /**
     * Valid payout statuses
     */
    public const STATUSES = ['pending', 'submitted', 'verified', 'rejected'];

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Create a new payout account record.
     * Returns the generated UUID on success, null on failure.
     */
    public function create(array $data): ?string
    {
        $id = $this->generateUUID();

        $stmt = $this->db->prepare('
            INSERT INTO doctor_payouts (
                id, doctor_id, provider, account_holder_name, bank_name,
                account_number, ifsc_code, branch_name, upi_id,
                pan_number, is_gst_registered, gst_number,
                provider_account_id, terms_consent, status,
                is_primary, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())
        ');

        $success = $stmt->execute([
            $id,
            $data['doctor_id'],
            $data['provider'] ?? 'bank',
            $data['account_holder_name'],
            $data['bank_name'] ?? null,
            $data['account_number'] ?? null,
            $data['ifsc_code'] ?? null,
            $data['branch_name'] ?? null,
            $data['upi_id'] ?? null,
            $data['pan_number'] ?? null,
            $data['is_gst_registered'] ?? 0,
            $data['gst_number'] ?? null,
            $data['provider_account_id'] ?? null,
            $data['terms_consent'] ?? 0,
            $data['status'] ?? 'pending',
            $data['is_primary'] ?? 1,
        ]);

        return $success ? $id : null;
    }

    /**
     * Get payout account by ID.
     */
    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('
            SELECT dp.*, u.full_name AS verified_by_name
            FROM doctor_payouts dp
            LEFT JOIN users u ON dp.verified_by = u.id
            WHERE dp.id = ?
        ');
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get payout accounts for a doctor.
     */
    public function findByDoctor(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT dp.*, u.full_name AS verified_by_name
            FROM doctor_payouts dp
            LEFT JOIN users u ON dp.verified_by = u.id
            WHERE dp.doctor_id = ?
            ORDER BY dp.is_primary DESC, dp.created_at ASC
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get the primary payout account for a doctor.
     */
    public function getPrimaryByDoctor(string $doctorId): ?array
    {
        $stmt = $this->db->prepare('
            SELECT dp.*, u.full_name AS verified_by_name
            FROM doctor_payouts dp
            LEFT JOIN users u ON dp.verified_by = u.id
            WHERE dp.doctor_id = ? AND dp.is_primary = 1
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get the active (submitted or verified) payout for a doctor.
     */
    public function getActiveByDoctor(string $doctorId): ?array
    {
        $stmt = $this->db->prepare('
            SELECT dp.*, u.full_name AS verified_by_name
            FROM doctor_payouts dp
            LEFT JOIN users u ON dp.verified_by = u.id
            WHERE dp.doctor_id = ? AND dp.status IN ("submitted", "verified")
            ORDER BY dp.created_at DESC
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Check if doctor has a verified payout account.
     */
    public function hasVerifiedPayout(string $doctorId): bool
    {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_payouts
            WHERE doctor_id = ? AND status = "verified"
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Check if doctor has any submitted/verified payout (in process or completed).
     */
    public function hasActivePayout(string $doctorId): bool
    {
        $stmt = $this->db->prepare('
            SELECT 1 FROM doctor_payouts
            WHERE doctor_id = ? AND status IN ("submitted", "verified")
            LIMIT 1
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Count payout accounts for a doctor.
     */
    public function countByDoctor(string $doctorId): int
    {
        $stmt = $this->db->prepare('
            SELECT COUNT(*) as count FROM doctor_payouts WHERE doctor_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return (int) ($result['count'] ?? 0);
    }

    /**
     * Check if an account number already exists for another doctor.
     */
    public function accountNumberExists(string $accountNumber, ?string $excludeDoctorId = null): bool
    {
        if ($excludeDoctorId) {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_payouts
                WHERE account_number = ? AND doctor_id != ?
                LIMIT 1
            ');
            $stmt->execute([$accountNumber, $excludeDoctorId]);
        } else {
            $stmt = $this->db->prepare('
                SELECT 1 FROM doctor_payouts
                WHERE account_number = ?
                LIMIT 1
            ');
            $stmt->execute([$accountNumber]);
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }

    /**
     * Update payout account fields.
     */
    public function update(string $id, array $data): bool
    {
        $allowedColumns = [
            'account_holder_name', 'bank_name', 'account_number', 'ifsc_code',
            'branch_name', 'upi_id', 'provider', 'pan_number',
            'is_gst_registered', 'gst_number', 'provider_account_id',
            'terms_consent', 'is_primary',
        ];

        $setClause = [];
        $params = [];

        foreach ($data as $key => $value) {
            if (in_array($key, $allowedColumns)) {
                $setClause[] = "{$key} = ?";
                $params[] = $value;
            }
        }

        if (empty($setClause)) {
            return false;
        }

        $setClause[] = 'updated_at = UTC_TIMESTAMP()';
        $params[] = $id;

        $sql = 'UPDATE doctor_payouts SET ' . implode(', ', $setClause) . ' WHERE id = ?';
        return $this->db->prepare($sql)->execute($params);
    }

    /**
     * Submit payout for admin review (pending → submitted).
     */
    public function submit(string $id): bool
    {
        $stmt = $this->db->prepare('
            UPDATE doctor_payouts
            SET status = "submitted",
                submitted_at = UTC_TIMESTAMP(),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ? AND status = "pending"
        ');
        return $stmt->execute([$id]);
    }

    /**
     * Admin verifies payout account (submitted → verified).
     */
    public function verify(string $id, ?string $adminId = null): bool
    {
        $stmt = $this->db->prepare('
            UPDATE doctor_payouts
            SET status = "verified",
                verified_at = UTC_TIMESTAMP(),
                verified_by = ?,
                updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$adminId, $id]);
    }

    /**
     * Admin rejects payout account (submitted → rejected).
     */
    public function reject(string $id, string $reason, ?string $adminId = null): bool
    {
        $stmt = $this->db->prepare('
            UPDATE doctor_payouts
            SET status = "rejected",
                rejection_reason = ?,
                verified_by = ?,
                verified_at = UTC_TIMESTAMP(),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ?
        ');
        return $stmt->execute([$reason, $adminId, $id]);
    }

    /**
     * Set a payout as primary, unset others for the same doctor.
     */
    public function setPrimary(string $id, string $doctorId): bool
    {
        $this->db->beginTransaction();

        try {
            // Unset all other primary accounts
            $stmt1 = $this->db->prepare('
                UPDATE doctor_payouts
                SET is_primary = 0, updated_at = UTC_TIMESTAMP()
                WHERE doctor_id = ? AND id != ?
            ');
            $stmt1->execute([$doctorId, $id]);

            // Set this one as primary
            $stmt2 = $this->db->prepare('
                UPDATE doctor_payouts
                SET is_primary = 1, updated_at = UTC_TIMESTAMP()
                WHERE id = ?
            ');
            $stmt2->execute([$id]);

            $this->db->commit();
            return true;
        } catch (\Exception $e) {
            $this->db->rollBack();
            error_log("setPrimary error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Delete a payout account.
     */
    public function delete(string $id): bool
    {
        $stmt = $this->db->prepare('DELETE FROM doctor_payouts WHERE id = ?');
        return $stmt->execute([$id]);
    }

    /**
     * Get all payouts pending verification (for admin panel).
     */
    public function getPendingVerifications(int $limit = 50, int $offset = 0): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                dp.*,
                u.full_name AS doctor_name,
                u.email AS doctor_email
            FROM doctor_payouts dp
            JOIN doctor_profiles dpr ON dp.doctor_id = dpr.user_id
            JOIN users u ON dp.doctor_id = u.id
            WHERE dp.status = "submitted"
            ORDER BY dp.submitted_at ASC
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