<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * OnboardingPricingController
 * Handles Step 6: Session Pricing
 * - Session price/tier
 * - Consultation duration
 * - Follow-up price
 */
class OnboardingPricingController
{
    private DoctorProfile $doctorModel;
    private Onboarding $onboardingModel;
    private Validator $validator;

    public function __construct()
    {
        $this->doctorModel = new DoctorProfile();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
    }

    /**
     * POST /api/doctors/onboarding/pricing
     * Save pricing information
     */
    public function savePricing($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Validation
        $rules = [
            'sessionPrice' => ['required', 'numeric'],
            'consultationDuration' => ['required', ['in', '30min', '45min', '60min']],
            'followUpPrice' => ['nullable', 'numeric'],
            'currency' => ['required', 'string'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Validate prices
        if (!$this->validator->validateSessionPrice($input['sessionPrice'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'sessionPrice' => 'Session price must be a positive number up to 99999.99'
            ]);
            return;
        }

        if (isset($input['followUpPrice']) && !$this->validator->validateSessionPrice($input['followUpPrice'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'followUpPrice' => 'Follow-up price must be a positive number up to 99999.99'
            ]);
            return;
        }

        try {
            $profile = $this->doctorModel->findByUserId($userId);

            // Convert consultation duration to database format
            $durationMap = [
                '30min' => '30min',
                '45min' => '45min',
                '60min' => '60min',
            ];

            $data = [
                'session_price' => floatval($input['sessionPrice']),
                'consultation_duration_minutes' => (int)str_replace('min', '', $input['consultationDuration']),
                'consultation_duration' => $durationMap[$input['consultationDuration']] ?? '60min',
                'followup_price' => isset($input['followUpPrice']) ? floatval($input['followUpPrice']) : null,
                'video_rate' => floatval($input['sessionPrice']),  // Legacy field
            ];

            if ($profile) {
                $this->doctorModel->update($userId, $data);
            } else {
                $data['user_id'] = $userId;
                $this->doctorModel->create($data);
            }

            // Update registration step
            $this->onboardingModel->updateRegistrationStep($userId, 6);

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_completed',
                6
            );

            Response::success([
                'message' => 'Pricing information saved successfully',
                'step' => 6,
                'nextStep' => 7,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save pricing information: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/pricing
     * Retrieve saved pricing information
     */
    public function getPricing($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $profile = $this->doctorModel->findByUserId($userId);

        if (!$profile) {
            Response::success([
                'sessionPrice' => null,
                'consultationDuration' => '60min',
                'followUpPrice' => null,
                'currency' => 'INR',
            ]);
            return;
        }

        Response::success([
            'sessionPrice' => $profile['session_price'] ?? $profile['video_rate'],
            'consultationDuration' => $profile['consultation_duration'] ?? '60min',
            'followUpPrice' => $profile['followup_price'],
            'currency' => 'INR',  // Currently hardcoded for India
        ]);
    }

    private function extractUserId($user): ?string
    {
        return is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);
    }

    private function getJsonInput(): array
    {
        $input = json_decode(file_get_contents('php://input'), true);
        return is_array($input) ? $input : [];
    }
}
