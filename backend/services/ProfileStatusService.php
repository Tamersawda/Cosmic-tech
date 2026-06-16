<?php

namespace Backend\Services;

use Backend\Config\Database;
use PDO;

/**
 * ProfileStatusService
 * 
 * Central service managing doctor profile status transitions.
 * Enforces valid state machine transitions and handles all
 * profile_status changes in a single place (single source of truth).
 * 
 * Status Flow:
 *   draft → submitted → approved → payout_pending → active
 *   submitted → rejected → draft (resubmission)
 *   active → suspended → active (reinstatement)
 */
class ProfileStatusService
{
    private PDO $db;

    /**
     * Allowed transitions: key = current status, value = array of allowed next statuses
     */
    private const ALLOWED_TRANSITIONS = [
        'draft'          => ['submitted', 'suspended'],
        'submitted'      => ['approved', 'rejected', 'suspended'],
        'approved'       => ['payout_pending', 'active', 'suspended'],
        'rejected'       => ['draft', 'suspended'],
        'payout_pending' => ['active', 'suspended'],
        'active'         => ['suspended'],
        'suspended'      => ['draft', 'active'],
    ];

    /**
     * Registration step progression order (for sequential enforcement)
     */
    private const STEP_ORDER = [
        'basic_info'               => 1,
        'professional_details'     => 2,
        'qualifications'           => 3,
        'professional_registration' => 4,
        'work_experience'          => 5,
        'session_fee'              => 6,
        'completed'                => 7,
    ];

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    // ──────────────────────────────────────────────
    // Core Status Transition
    // ──────────────────────────────────────────────

    /**
     * Transition a doctor's profile to a new status.
     * 
     * @param string     $doctorId   users.id of the doctor
     * @param string     $newStatus  The target status
     * @param string|null $adminId   Admin performing the action (for reviewed_by)
     * @param string|null $adminNote Admin notes (for rejections, etc.)
     * @return array{success: bool, message: string, previous_status: ?string, new_status: string}
     */
    public function transition(
        string $doctorId,
        string $newStatus,
        ?string $adminId = null,
        ?string $adminNote = null
    ): array {
        // Fetch current status
        $currentStatus = $this->getCurrentStatus($doctorId);

        if ($currentStatus === null) {
            return [
                'success' => false,
                'message' => 'Doctor profile not found.',
                'previous_status' => null,
                'new_status' => $newStatus,
            ];
        }

        // Validate transition
        if (!isset(self::ALLOWED_TRANSITIONS[$currentStatus])) {
            return [
                'success' => false,
                'message' => "Invalid current status: {$currentStatus}",
                'previous_status' => $currentStatus,
                'new_status' => $newStatus,
            ];
        }

        if (!in_array($newStatus, self::ALLOWED_TRANSITIONS[$currentStatus], true)) {
            return [
                'success' => false,
                'message' => "Cannot transition from '{$currentStatus}' to '{$newStatus}'. Allowed: " .
                             implode(', ', self::ALLOWED_TRANSITIONS[$currentStatus]),
                'previous_status' => $currentStatus,
                'new_status' => $newStatus,
            ];
        }

        // Perform the transition
        $this->db->beginTransaction();

        try {
            $setClauses = ['profile_status = ?'];
            $params = [$newStatus];

            if ($newStatus === 'submitted') {
                $setClauses[] = 'registration_step = ?';
                $params[] = 'completed';
                $setClauses[] = 'submitted_at = UTC_TIMESTAMP()';
            }

            if ($newStatus === 'approved' || $newStatus === 'rejected') {
                $setClauses[] = 'reviewed_at = UTC_TIMESTAMP()';
                $setClauses[] = 'reviewed_by = ?';
                $params[] = $adminId;

                if ($adminNote !== null) {
                    $setClauses[] = 'admin_note = ?';
                    $params[] = $adminNote;
                }
            }

            $setClauses[] = 'updated_at = UTC_TIMESTAMP()';
            $params[] = $doctorId;

            $sql = 'UPDATE doctor_profiles SET ' . implode(', ', $setClauses) . ' WHERE user_id = ?';
            $stmt = $this->db->prepare($sql);
            $stmt->execute($params);

            // Log the transition
            $this->logTransition($doctorId, $currentStatus, $newStatus, $adminId, $adminNote);

            $this->db->commit();

            return [
                'success' => true,
                'message' => "Profile transitioned from '{$currentStatus}' to '{$newStatus}'.",
                'previous_status' => $currentStatus,
                'new_status' => $newStatus,
            ];
        } catch (\Exception $e) {
            $this->db->rollBack();
            error_log("ProfileStatusService transition error: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Database error during status transition.',
                'previous_status' => $currentStatus,
                'new_status' => $newStatus,
            ];
        }
    }

    // ──────────────────────────────────────────────
    // Convenience Methods (readable API)
    // ──────────────────────────────────────────────

    /**
     * Doctor submits profile for review (draft → submitted)
     */
    public function submitProfile(string $doctorId): array
    {
        return $this->transition($doctorId, 'submitted');
    }

    /**
     * Admin approves profile (submitted → approved)
     */
    public function approveProfile(string $doctorId, string $adminId, ?string $note = null): array
    {
        return $this->transition($doctorId, 'approved', $adminId, $note);
    }

    /**
     * Admin rejects profile (submitted → rejected)
     */
    public function rejectProfile(string $doctorId, string $adminId, string $reason): array
    {
        return $this->transition($doctorId, 'rejected', $adminId, $reason);
    }

    /**
     * Doctor re-submits after rejection (rejected → draft)
     * Resets registration_step so doctor can edit and resubmit
     */
    public function resubmitProfile(string $doctorId, string $resumeStep = 'basic_info'): array
    {
        $result = $this->transition($doctorId, 'draft');

        if ($result['success']) {
            $this->updateRegistrationStep($doctorId, $resumeStep);
            $result['message'] = "Profile reset to draft. Registration step set to: {$resumeStep}";
        }

        return $result;
    }

    /**
     * Payout submitted (approved → payout_pending)
     */
    public function payoutSubmitted(string $doctorId): array
    {
        return $this->transition($doctorId, 'payout_pending');
    }

    /**
     * Payout verified — activates profile (approved/payout_pending → active)
     */
    public function activateProfile(string $doctorId): array
    {
        $currentStatus = $this->getCurrentStatus($doctorId);

        if ($currentStatus === 'approved') {
            return $this->transition($doctorId, 'active');
        } elseif ($currentStatus === 'payout_pending') {
            return $this->transition($doctorId, 'active');
        }

        return [
            'success' => false,
            'message' => "Cannot activate from status '{$currentStatus}'. Profile must be approved or payout_pending.",
            'previous_status' => $currentStatus,
            'new_status' => 'active',
        ];
    }

    /**
     * Admin suspends doctor (any → suspended)
     */
    public function suspendProfile(string $doctorId, string $adminId, ?string $reason = null): array
    {
        return $this->transition($doctorId, 'suspended', $adminId, $reason);
    }

    /**
     * Admin reinstates doctor (suspended → active)
     */
    public function reinstateProfile(string $doctorId, string $adminId): array
    {
        return $this->transition($doctorId, 'active', $adminId);
    }

    // ──────────────────────────────────────────────
    // Registration Step Management
    // ──────────────────────────────────────────────

    /**
     * Update registration step with sequential enforcement.
     * Can only move forward by one step, or stay at current.
     */
    public function updateRegistrationStep(string $doctorId, string $step): bool
    {
        if (!isset(self::STEP_ORDER[$step])) {
            error_log("Invalid registration step: {$step}");
            return false;
        }

        $currentStep = $this->getRegistrationStep($doctorId);

        if ($currentStep !== null && isset(self::STEP_ORDER[$currentStep])) {
            $currentOrder = self::STEP_ORDER[$currentStep];
            $newOrder = self::STEP_ORDER[$step];

            // Allow moving to same step (save/continue) or forward by one
            // Allow jumping back for rejected profiles
            if ($newOrder > $currentOrder + 1 && $step !== 'completed') {
                error_log("Cannot skip steps: going from '{$currentStep}' to '{$step}'");
                return false;
            }
        }

        $stmt = $this->db->prepare('
            UPDATE doctor_profiles
            SET registration_step = ?, updated_at = UTC_TIMESTAMP()
            WHERE user_id = ?
        ');
        return $stmt->execute([$step, $doctorId]);
    }

    /**
     * Get current registration step for a doctor
     */
    public function getRegistrationStep(string $doctorId): ?string
    {
        $stmt = $this->db->prepare('
            SELECT registration_step FROM doctor_profiles WHERE user_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['registration_step'] ?? null;
    }

    /**
     * Get onboarding progress as percentage (1-6 steps, step 7 = completed = 100%)
     */
    public function getOnboardingProgress(string $doctorId): array
    {
        $step = $this->getRegistrationStep($doctorId);

        $order = self::STEP_ORDER[$step] ?? 1;
        $totalSteps = count(self::STEP_ORDER) - 1; // Exclude 'completed' from total count
        $completedSteps = max(0, $order - 1); // Steps before current are completed

        if ($step === 'completed') {
            $completedSteps = $totalSteps;
        }

        $percentage = round(($completedSteps / $totalSteps) * 100);

        return [
            'total_steps' => $totalSteps,
            'completed_steps' => $completedSteps,
            'current_step' => $step,
            'percentage' => $percentage,
        ];
    }

    // ──────────────────────────────────────────────
    // Query Methods
    // ──────────────────────────────────────────────

    /**
     * Get current profile status
     */
    public function getCurrentStatus(string $doctorId): ?string
    {
        $stmt = $this->db->prepare('
            SELECT profile_status FROM doctor_profiles WHERE user_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['profile_status'] ?? null;
    }

    /**
     * Get full profile status summary for routing
     */
    public function getStatusSummary(string $doctorId): ?array
    {
        $stmt = $this->db->prepare('
            SELECT 
                dp.profile_status,
                dp.registration_step,
                dp.admin_note,
                dp.submitted_at,
                dp.reviewed_at,
                dp.reviewed_by
            FROM doctor_profiles dp
            WHERE dp.user_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$result) {
            return null;
        }

        $result['progress'] = $this->getOnboardingProgress($doctorId);
        $result['has_payout'] = $this->hasPayoutSetup($doctorId);

        return $result;
    }

    /**
     * Get routing action based on current status
     */
    public function getRoutingAction(string $doctorId): array
    {
        $status = $this->getCurrentStatus($doctorId);

        switch ($status) {
            case 'draft':
                $step = $this->getRegistrationStep($doctorId);
                return [
                    'route' => '/onboarding/' . $step,
                    'action' => 'resume_onboarding',
                    'status' => $status,
                ];

            case 'submitted':
                return [
                    'route' => '/onboarding/pending-review',
                    'action' => 'profile_under_review',
                    'status' => $status,
                ];

            case 'approved':
                if ($this->hasPayoutSetup($doctorId)) {
                    return [
                        'route' => '/doctor/dashboard',
                        'action' => 'dashboard',
                        'status' => $status,
                    ];
                }
                return [
                    'route' => '/onboarding/payout-setup',
                    'action' => 'payout_setup_required',
                    'status' => $status,
                ];

            case 'rejected':
                $summary = $this->getStatusSummary($doctorId);
                return [
                    'route' => '/onboarding?tab=revisions',
                    'action' => 'profile_rejected',
                    'status' => $status,
                    'admin_note' => $summary['admin_note'] ?? null,
                ];

            case 'payout_pending':
                return [
                    'route' => '/onboarding/payout-setup',
                    'action' => 'payout_pending',
                    'status' => $status,
                ];

            case 'active':
                return [
                    'route' => '/doctor/dashboard',
                    'action' => 'dashboard',
                    'status' => $status,
                ];

            case 'suspended':
                return [
                    'route' => '/account-suspended',
                    'action' => 'account_suspended',
                    'status' => $status,
                ];

            default:
                return [
                    'route' => '/onboarding/basic-info',
                    'action' => 'start_onboarding',
                    'status' => 'unknown',
                ];
        }
    }

    /**
     * Get doctors pending verification (for admin panel)
     */
    public function getPendingVerifications(int $limit = 50, int $offset = 0): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                u.id, u.email, u.full_name,
                dp.profile_status, dp.registration_step,
                dp.submitted_at, dp.admin_note
            FROM users u
            JOIN doctor_profiles dp ON u.id = dp.user_id
            WHERE dp.profile_status = "submitted"
            ORDER BY dp.submitted_at ASC
            LIMIT ? OFFSET ?
        ');
        $stmt->execute([$limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // ──────────────────────────────────────────────
    // Private Helpers
    // ──────────────────────────────────────────────

    /**
     * Check if doctor has an active payout setup
     */
    private function hasPayoutSetup(string $doctorId): bool
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
     * Log a status transition to doctor_verification_logs
     */
    private function logTransition(
        string $doctorId,
        string $previousStatus,
        string $newStatus,
        ?string $adminId = null,
        ?string $adminNote = null
    ): void {
        $stmt = $this->db->prepare('
            INSERT INTO doctor_verification_logs
                (doctor_id, action, previous_status, new_status, admin_id, admin_notes)
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        $stmt->execute([
            $doctorId,
            'profile_status_changed',
            $previousStatus,
            $newStatus,
            $adminId,
            $adminNote,
        ]);
    }

    /**
     * Get allowed transitions for a given status (for frontend display)
     */
    public function getAllowedTransitions(string $status): array
    {
        return self::ALLOWED_TRANSITIONS[$status] ?? [];
    }
}