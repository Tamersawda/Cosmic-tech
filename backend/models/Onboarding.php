<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * Onboarding Model
 * Manages the onboarding workflow and state tracking
 */
class Onboarding
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Get current onboarding state for a doctor
     */
    public function getOnboardingState(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                u.registration_step,
                u.is_profile_completed,
                u.submitted_at,
                dp.verification_status,
                dp.submitted_at as profile_submitted_at
            FROM users u
            LEFT JOIN doctor_profiles dp ON u.id = dp.user_id
            WHERE u.id = ? AND u.user_type = "doctor"
        ');
        $stmt->execute([$doctorId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: [];
    }

    /**
     * Update registration step for a doctor
     */
    public function updateRegistrationStep(string $doctorId, int $step): bool
    {
        $stmt = $this->db->prepare('
            UPDATE users
            SET registration_step = ?, updated_at = UTC_TIMESTAMP()
            WHERE id = ? AND user_type = "doctor"
        ');
        return $stmt->execute([$step, $doctorId]);
    }

    /**
     * Mark onboarding as completed
     */
    public function completeOnboarding(string $doctorId): bool
    {
        $stmt = $this->db->prepare('
            UPDATE users
            SET onboarding_completed = TRUE, 
                onboarding_submitted_at = UTC_TIMESTAMP(),
                updated_at = UTC_TIMESTAMP()
            WHERE id = ? AND user_type = "doctor"
        ');
        return $stmt->execute([$doctorId]);
    }

    /**
     * Update verification status of doctor profile
     */
    public function updateVerificationStatus(
        string $doctorId,
        string $status,
        ?string $rejectionReason = null
    ): bool {
        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET verification_status = ?,
                rejected_reason = ?,
                updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');
        return $stmt->execute([$status, $rejectionReason, $doctorId]);
    }

    /**
     * Log verification action
     */
    public function logVerificationAction(
        string $doctorId,
        string $action,
        ?int $stepNumber = null,
        ?string $previousStatus = null,
        ?string $newStatus = null,
        ?array $details = null,
        ?string $adminId = null,
        ?string $adminNotes = null
    ): bool {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_verification_logs
            (doctor_id, action, step_number, previous_status, new_status, details, admin_id, admin_notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ');
        
        $detailsJson = $details ? json_encode($details) : null;
        
        return $stmt->execute([
            $doctorId,
            $action,
            $stepNumber,
            $previousStatus,
            $newStatus,
            $detailsJson,
            $adminId,
            $adminNotes
        ]);
    }

    /**
     * Get verification log history
     */
    public function getVerificationLog(string $doctorId, int $limit = 50): array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM doctor_verification_logs
            WHERE doctor_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ');
        $stmt->execute([$doctorId, $limit]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Check if onboarding is complete
     */
    public function isOnboardingComplete(string $doctorId): bool
    {
        $stmt = $this->db->prepare('
            SELECT onboarding_completed FROM users
            WHERE id = ? AND user_type = "doctor"
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ? (bool)$result['onboarding_completed'] : false;
    }

    /**
     * Get doctors pending verification
     */
    public function getPendingVerification(int $limit = 50, int $offset = 0): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                u.id, u.email, u.full_name,
                dp.user_id, dp.verification_status, dp.submitted_at
            FROM users u
            JOIN doctor_profiles dp ON u.id = dp.user_id
            WHERE dp.verification_status IN ("submitted", "under_review")
            ORDER BY dp.submitted_at ASC
            LIMIT ? OFFSET ?
        ');
        $stmt->execute([$limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
