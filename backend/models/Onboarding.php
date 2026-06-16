<?php

namespace Backend\Models;

use Backend\Config\Database;
use Backend\Services\ProfileStatusService;
use PDO;

/**
 * Onboarding Model
 * 
 * Manages the onboarding workflow and state tracking for doctor registration.
 * 
 * This model now delegates status transitions to ProfileStatusService
 * and focuses on onboarding-specific operations: step tracking,
 * progress calculation, and verification log management.
 * 
 * Registration Steps:
 *   1. basic_info               - Basic personal information
 *   2. professional_details     - Specialty, therapy approaches
 *   3. qualifications           - Degrees, certificates
 *   4. professional_registration - License, RCI registration
 *   5. work_experience          - Employment history
 *   6. session_fee              - Pricing and session settings
 *   7. completed                - All steps done, ready for submission
 */
class Onboarding
{
    private PDO $db;
    private ProfileStatusService $statusService;

    public function __construct()
    {
        $this->db = Database::getInstance();
        $this->statusService = new ProfileStatusService();
    }

    // ──────────────────────────────────────────────
    // Onboarding State Queries
    // ──────────────────────────────────────────────

    /**
     * Get current onboarding state for a doctor.
     * Returns profile status, registration step, and progress info.
     */
    public function getOnboardingState(string $doctorId): array
    {
        $stmt = $this->db->prepare('
            SELECT 
                dp.profile_status,
                dp.registration_step,
                dp.submitted_at,
                dp.reviewed_at,
                dp.admin_note
            FROM doctor_profiles dp
            WHERE dp.user_id = ?
        ');
        $stmt->execute([$doctorId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$result) {
            return [];
        }

        // Enrich with progress calculation
        $result['progress'] = $this->statusService->getOnboardingProgress($doctorId);
        $result['routing'] = $this->statusService->getRoutingAction($doctorId);

        return $result;
    }

    /**
     * Check if onboarding is complete (all 6 steps done and submitted).
     */
    public function isOnboardingComplete(string $doctorId): bool
    {
        $status = $this->statusService->getCurrentStatus($doctorId);
        return in_array($status, ['submitted', 'approved', 'payout_pending', 'active']);
    }

    // ──────────────────────────────────────────────
    // Step Progression
    // ──────────────────────────────────────────────

    /**
     * Mark a step as completed and advance to the next step.
     * Validates that the current step matches expected step before advancing.
     * 
     * @param string $doctorId     Doctor's user ID
     * @param string $currentStep  The step being completed
     * @return array{success: bool, message: string, next_step: ?string}
     */
    public function completeStep(string $doctorId, string $currentStep): array
    {
        $currentRegistrationStep = $this->statusService->getRegistrationStep($doctorId);

        if ($currentRegistrationStep !== $currentStep) {
            return [
                'success' => false,
                'message' => "Expected step '{$currentStep}' but current step is '{$currentRegistrationStep}'.",
                'next_step' => $currentRegistrationStep,
            ];
        }

        // Define step progression
        $stepOrder = [
            'basic_info'               => 'professional_details',
            'professional_details'     => 'qualifications',
            'qualifications'           => 'professional_registration',
            'professional_registration' => 'work_experience',
            'work_experience'          => 'session_fee',
            'session_fee'              => 'completed',
        ];

        $nextStep = $stepOrder[$currentStep] ?? null;

        if ($nextStep === null) {
            return [
                'success' => false,
                'message' => "Invalid step: {$currentStep}",
                'next_step' => null,
            ];
        }

        $success = $this->statusService->updateRegistrationStep($doctorId, $nextStep);

        if ($success) {
            // Log the step completion
            $this->logStepCompletion($doctorId, $currentStep);

            return [
                'success' => true,
                'message' => "Step '{$currentStep}' completed. Next: '{$nextStep}'.",
                'next_step' => $nextStep,
            ];
        }

        return [
            'success' => false,
            'message' => "Failed to update registration step.",
            'next_step' => $currentRegistrationStep,
        ];
    }

    /**
     * Submit the entire profile for admin review.
     * Validates that all steps are completed before allowing submission.
     * Transitions profile_status: draft → submitted
     * 
     * @return array{success: bool, message: string}
     */
    public function submitForReview(string $doctorId): array
    {
        $currentStep = $this->statusService->getRegistrationStep($doctorId);

        if ($currentStep !== 'completed') {
            return [
                'success' => false,
                'message' => "Cannot submit: onboarding not complete. Current step: '{$currentStep}'.",
            ];
        }

        $result = $this->statusService->submitProfile($doctorId);

        if ($result['success']) {
            // Log the submission
            $this->logVerificationAction(
                $doctorId,
                'profile_submitted_for_review',
                null,
                'draft',
                'submitted'
            );
        }

        return $result;
    }

    // ──────────────────────────────────────────────
    // Admin Review Operations
    // ──────────────────────────────────────────────

    /**
     * Admin approves a doctor profile.
     * Transitions profile_status: submitted → approved
     */
    public function approveProfile(string $doctorId, string $adminId, ?string $note = null): array
    {
        $result = $this->statusService->approveProfile($doctorId, $adminId, $note);

        if ($result['success']) {
            $this->logVerificationAction(
                $doctorId,
                'profile_approved',
                null,
                $result['previous_status'],
                'approved',
                null,
                $adminId,
                $note
            );
        }

        return $result;
    }

    /**
     * Admin rejects a doctor profile.
     * Transitions profile_status: submitted → rejected
     * The doctor can then resubmit from the indicated step.
     */
    public function rejectProfile(
        string $doctorId,
        string $adminId,
        string $reason,
        ?string $resumeStep = 'basic_info'
    ): array {
        $result = $this->statusService->rejectProfile($doctorId, $adminId, $reason);

        if ($result['success']) {
            // Reset the registration step so doctor can fix issues
            $this->statusService->updateRegistrationStep($doctorId, $resumeStep);

            $this->logVerificationAction(
                $doctorId,
                'profile_rejected',
                null,
                $result['previous_status'],
                'rejected',
                ['rejection_reason' => $reason, 'resume_step' => $resumeStep],
                $adminId,
                $reason
            );
        }

        return $result;
    }

    // ──────────────────────────────────────────────
    // Verification Log
    // ──────────────────────────────────────────────

    /**
     * Log a verification action to the doctor_verification_logs table.
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
            $adminNotes,
        ]);
    }

    /**
     * Get verification log history for a doctor.
     */
    public function getVerificationLog(string $doctorId, int $limit = 50): array
    {
        $stmt = $this->db->prepare('
            SELECT vlog.*, u.full_name AS admin_name
            FROM doctor_verification_logs vlog
            LEFT JOIN users u ON vlog.admin_id = u.id
            WHERE vlog.doctor_id = ?
            ORDER BY vlog.created_at DESC
            LIMIT ?
        ');
        $stmt->execute([$doctorId, $limit]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get doctors pending verification (for admin panel).
     */
    public function getPendingVerification(int $limit = 50, int $offset = 0): array
    {
        return $this->statusService->getPendingVerifications($limit, $offset);
    }

    // ──────────────────────────────────────────────
    // Private Helpers
    // ──────────────────────────────────────────────

    /**
     * Log a step completion event.
     */
    private function logStepCompletion(string $doctorId, string $stepName): void
    {
        $stepNumbers = [
            'basic_info'               => 1,
            'professional_details'     => 2,
            'qualifications'           => 3,
            'professional_registration' => 4,
            'work_experience'          => 5,
            'session_fee'              => 6,
        ];

        $this->logVerificationAction(
            $doctorId,
            'step_completed',
            $stepNumbers[$stepName] ?? null,
            $stepName,
            null,
            ['step_name' => $stepName]
        );
    }
}