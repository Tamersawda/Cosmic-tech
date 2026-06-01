<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Models\DoctorQualification;
use Backend\Models\DoctorExperience;
use Backend\Models\DoctorPayoutAccount;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\EmailService;

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../models/DoctorQualification.php';
require_once __DIR__ . '/../models/DoctorExperience.php';
require_once __DIR__ . '/../models/DoctorPayoutAccount.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/EmailService.php';

/**
 * OnboardingSubmissionController
 * Handles Final Submission (Step 7)
 * - Validates all onboarding steps are complete
 * - Locks onboarding
 * - Transitions to admin review
 * - Sends notification emails
 */
class OnboardingSubmissionController
{
    private DoctorProfile $doctorModel;
    private DoctorQualification $qualificationModel;
    private DoctorExperience $experienceModel;
    private DoctorPayoutAccount $payoutModel;
    private Onboarding $onboardingModel;
    private EmailService $emailService;

    public function __construct()
    {
        $this->doctorModel = new DoctorProfile();
        $this->qualificationModel = new DoctorQualification();
        $this->experienceModel = new DoctorExperience();
        $this->payoutModel = new DoctorPayoutAccount();
        $this->onboardingModel = new Onboarding();
        $this->emailService = new EmailService();
    }

    /**
     * POST /api/doctors/onboarding/submit
     * Final onboarding submission
     * Validates all required steps and submits for admin review
     */
    public function submitOnboarding($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        try {
            // Get doctor profile
            $profile = $this->doctorModel->findByUserId($userId);
            if (!$profile) {
                Response::error('Doctor profile not found. Please complete Step 1 first.', 400);
                return;
            }

            // Validate all steps are complete
            $validationErrors = $this->validateAllSteps($userId, $profile);
            if (!empty($validationErrors)) {
                Response::error('Cannot submit: incomplete steps', 400, 'INCOMPLETE_STEPS', $validationErrors);
                return;
            }

            // Update user table with profile completion flag
            $userModel = new \Backend\Models\User();
            $userModel->updateProfileCompletion($userId, true);

            // Update doctor profile with verification status and submission timestamp
            $this->doctorModel->update($userId, [
                'verification_status' => 'pending',
                'submitted_at' => date('Y-m-d H:i:s'),
            ]);

            // Log submission action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'profile_submitted_for_review',
                7,
                'in_progress',
                'pending'
            );

            // Send notification to doctor
            try {
                $this->emailService->sendOnboardingSubmissionConfirmation($userId);
            } catch (\Exception $e) {
                // Log error but don't fail the submission
                error_log('Failed to send submission email: ' . $e->getMessage());
            }

            // Send notification to admin
            try {
                $this->emailService->sendAdminNewOnboardingNotification($userId);
            } catch (\Exception $e) {
                error_log('Failed to send admin notification: ' . $e->getMessage());
            }

            Response::success([
                'message' => 'Onboarding submitted successfully for admin review',
                'verificationStatus' => 'submitted',
                'nextSteps' => 'Your profile will be reviewed by our team. You will be notified via email once the review is complete.',
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to submit onboarding: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/status
     * Get current onboarding status
     */
    public function getOnboardingStatus($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $onboardingState = $this->onboardingModel->getOnboardingState($userId);
        $profile = $this->doctorModel->findByUserId($userId);

        // Build completedSteps based on actual data in DB
        $completedSteps = $this->computeCompletedSteps($userId, $profile ?? []);

        Response::success([
            'registrationStep'    => $onboardingState['registration_step'] ?? 0,
            'isProfileCompleted'  => (bool)($onboardingState['is_profile_completed'] ?? false),
            'verificationStatus'  => $profile['verification_status'] ?? 'pending',
            'completedSteps'      => $completedSteps,
            'totalSteps'          => 7,
            'progressPercent'     => count($completedSteps) > 0 ? (int)round((count($completedSteps) / 7) * 100) : 0,
            'submittedAt'         => $onboardingState['profile_submitted_at'] ?? null,
            'reviewedAt'          => $profile['reviewed_at'] ?? null,
            'rejectionReason'     => $profile['rejected_reason'] ?? null,
        ]);
    }

    /**
     * Compute which steps have been completed based on actual data in DB.
     * Returns an array of completed step numbers (1-indexed).
     */
    private function computeCompletedSteps(string $userId, array $profile): array
    {
        $completed = [];

        // Step 1: Basic Info
        if (!empty($profile['phone_number']) && !empty($profile['date_of_birth']) && !empty($profile['gender'])) {
            $completed[] = 1;
        }

        // Step 2: Professional Details
        if (!empty($profile['primary_title']) && !empty($profile['languages_spoken'])) {
            $completed[] = 2;
        }

        // Step 3: Qualifications
        $qualifications = $this->qualificationModel->findByDoctor($userId);
        if (!empty($qualifications)) {
            $completed[] = 3;
        }

        // Step 4: Professional Registration
        if (!empty($profile['registration_type'])) {
            $completed[] = 4;
        }

        // Step 5: Work Experience
        $experiences = $this->experienceModel->findByDoctor($userId);
        if (!empty($experiences)) {
            $completed[] = 5;
        }

        // Step 6: Session Fee
        if (!empty($profile['session_price'])) {
            $completed[] = 6;
        }

        // Step 7: Payout
        $payoutAccount = $this->payoutModel->getPrimaryByDoctor($userId);
        if ($payoutAccount) {
            $completed[] = 7;
        }

        return $completed;
    }

    /**
     * Validate all required onboarding steps before final submission
     */
    private function validateAllSteps(string $userId, array $profile): array
    {
        $errors = [];

        // Step 1: Basic Info
        if (empty($profile['phone_number']) || empty($profile['date_of_birth']) || empty($profile['gender'])) {
            $errors[] = 'Step 1 (Basic Information) is incomplete';
        }

        // Step 2: Professional Details
        if (empty($profile['primary_title']) || empty($profile['languages_spoken'])) {
            $errors[] = 'Step 2 (Professional Details) is incomplete';
        }

        if (empty($profile['govt_id_front_url']) || empty($profile['govt_id_back_url'])) {
            $errors[] = 'Step 2: Government ID documents are required';
        }

        // Step 3: Qualifications (at least one required)
        $qualifications = $this->qualificationModel->findByDoctor($userId);
        if (empty($qualifications)) {
            $errors[] = 'Step 3 (Qualifications): At least one qualification is required';
        }

        // Step 4: Verification
        if (empty($profile['registration_type'])) {
            $errors[] = 'Step 4 (Professional Registration) is incomplete';
        }

        // Step 5: Work Experience (at least one required)
        $experiences = $this->experienceModel->findByDoctor($userId);
        if (empty($experiences)) {
            $errors[] = 'Step 5 (Work Experience): At least one experience entry is required';
        }

        // Step 6: Session Fee
        if (empty($profile['session_price'])) {
            $errors[] = 'Step 6 (Session Pricing) is incomplete';
        }

        // Step 7: Payout
        $payoutAccount = $this->payoutModel->getPrimaryByDoctor($userId);
        if (!$payoutAccount) {
            $errors[] = 'Step 7 (Payout Setup) is incomplete';
        }

        return $errors;
    }

    private function extractUserId($user): ?string
    {
        return is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);
    }
}
