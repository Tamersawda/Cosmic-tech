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
 * 
 * Blueprint (Contract-Compliant):
 * - sessionFeeTier: ENUM(799, 999, 1499, 1999, 2499)
 * - pricingJustification: TEXT
 * 
 * Deprecated (Phase 3 removal):
 * - sessionPrice (raw value)
 * - followUpPrice (deprecated)
 * - consultationDuration (moved to doctor_profiles.consultation_duration)
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
     * POST /api/doctors/onboarding/session-fee
     * Save pricing information (Blueprint-compliant)
     * 
     * Request (Canonical):
     * {
     *   "sessionFeeTier": "999",         // ENUM: 799|999|1499|1999|2499
     *   "pricingJustification": "..."    // TEXT: why this tier
     * }
     * 
     * Backward compatibility:
     * - Accepts legacy "sessionPrice" + "followUpPrice" (ignored, response uses tier)
     * - Accepts legacy "consultationDuration" (ignored, managed separately)
     */
    public function savePricing($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Backward compatibility: accept legacy field names but normalize to canonical
        if (!isset($input['sessionFeeTier']) && isset($input['sessionPrice'])) {
            // Legacy: convert numeric sessionPrice to nearest tier
            // For now, we still accept it but validate as tier
            $price = floatval($input['sessionPrice']);
            if ($price < 900) {
                $input['sessionFeeTier'] = '799';
            } elseif ($price < 1250) {
                $input['sessionFeeTier'] = '999';
            } elseif ($price < 1750) {
                $input['sessionFeeTier'] = '1499';
            } elseif ($price < 2250) {
                $input['sessionFeeTier'] = '1999';
            } else {
                $input['sessionFeeTier'] = '2499';
            }
        }

        // Blueprint validation: only tier + justification required
        $rules = [
            'sessionFeeTier'           => ['required', ['in', '799', '999', '1499', '1999', '2499']],
            'pricingJustification'     => ['required', 'string'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Additional validation: pricingJustification length
        if (strlen($input['pricingJustification']) < 10) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'pricingJustification' => 'Pricing justification must be at least 10 characters'
            ]);
            return;
        }

        try {
            $profile = $this->doctorModel->findByUserId($userId);

            $data = [
                'session_fee_tier'        => $input['sessionFeeTier'],
                'pricing_justification'   => $input['pricingJustification'],
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
                'sessionFeeTier' => $input['sessionFeeTier'],
                'pricingJustification' => $input['pricingJustification'],
                'step' => 6,
                'nextStep' => 7,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save pricing information: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/session-fee
     * Retrieve saved pricing information (Blueprint-compliant)
     * 
     * Response (Canonical only):
     * {
     *   "sessionFeeTier": "999",
     *   "pricingJustification": "..."
     * }
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
                'sessionFeeTier' => null,
                'pricingJustification' => null,
            ]);
            return;
        }

        // Return ONLY Blueprint fields (no legacy fields)
        Response::success([
            'sessionFeeTier' => $profile['session_fee_tier'] ?? null,
            'pricingJustification' => $profile['pricing_justification'] ?? null,
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
