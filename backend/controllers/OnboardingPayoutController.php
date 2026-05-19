<?php

namespace Backend\Controllers;

use Backend\Models\DoctorPayoutAccount;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;

require_once __DIR__ . '/../models/DoctorPayoutAccount.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * OnboardingPayoutController
 * Handles Step 7: Payout Setup
 * - Bank account details
 * - PAN number
 * - GST number
 */
class OnboardingPayoutController
{
    private DoctorPayoutAccount $payoutModel;
    private Onboarding $onboardingModel;
    private Validator $validator;

    public function __construct()
    {
        $this->payoutModel = new DoctorPayoutAccount();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
    }

    /**
     * POST /api/doctors/onboarding/payout
     * Save or create payout account information
     */
    public function savePayout($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Validation
        $rules = [
            'accountHolderName' => ['required', 'string'],
            'accountNumber' => ['required', 'string'],
            'ifscCode' => ['required', 'string'],
            'bankName' => ['required', 'string'],
            'branchName' => ['required', 'string'],
            'panNumber' => ['required', 'string'],
            'isGstRegistered' => ['required', 'boolean'],
            'gstNumber' => ['nullable', 'string'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Validate PAN number
        if (!$this->validator->validatePANNumber($input['panNumber'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'panNumber' => 'Invalid PAN number format (should be: AAAAA9999A)'
            ]);
            return;
        }

        // Validate IFSC code
        if (!$this->validator->validateIFSCCode($input['ifscCode'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'ifscCode' => 'Invalid IFSC code format'
            ]);
            return;
        }

        // Validate account number
        if (!$this->validator->validateAccountNumber($input['accountNumber'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'accountNumber' => 'Invalid account number format'
            ]);
            return;
        }

        // If GST registered, validate GST number
        if ($input['isGstRegistered']) {
            if (!isset($input['gstNumber']) || empty($input['gstNumber'])) {
                Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                    'gstNumber' => 'GST number is required when GST registered'
                ]);
                return;
            }

            if (!$this->validator->validateGSTNumber($input['gstNumber'])) {
                Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                    'gstNumber' => 'Invalid GST number format'
                ]);
                return;
            }
        }

        // Check if account number already exists for another doctor
        if ($this->payoutModel->accountNumberExists($input['accountNumber'], $userId)) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'accountNumber' => 'This account number is already registered'
            ]);
            return;
        }

        try {
            $payoutData = [
                'doctor_id' => $userId,
                'account_holder_name' => $input['accountHolderName'],
                'account_number' => $input['accountNumber'],
                'ifsc_code' => strtoupper($input['ifscCode']),
                'bank_name' => $input['bankName'],
                'branch_name' => $input['branchName'],
                'pan_number' => strtoupper($input['panNumber']),
                'is_gst_registered' => $input['isGstRegistered'],
                'gst_number' => $input['isGstRegistered'] ? strtoupper($input['gstNumber']) : null,
                'is_primary' => true,
            ];

            // Check if doctor already has a payout account
            $existingAccount = $this->payoutModel->getPrimaryByDoctor($userId);

            if ($existingAccount) {
                // Update existing account
                $this->payoutModel->update($existingAccount['id'], $payoutData);
                $payoutId = $existingAccount['id'];
            } else {
                // Create new account
                $payoutId = $this->payoutModel->create($payoutData);
            }

            if (!$payoutId) {
                Response::error('Failed to save payout information', 500);
                return;
            }

            // Update registration step to complete
            $this->onboardingModel->updateRegistrationStep($userId, 7);

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_completed',
                7
            );

            Response::success([
                'id' => $payoutId,
                'message' => 'Payout information saved successfully',
                'step' => 7,
                'nextStep' => 8,  // Final submission step
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save payout information: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/payout
     * Retrieve saved payout information
     */
    public function getPayout($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $account = $this->payoutModel->getPrimaryByDoctor($userId);

        if (!$account) {
            Response::success([
                'accountHolderName' => null,
                'accountNumber' => null,
                'ifscCode' => null,
                'bankName' => null,
                'branchName' => null,
                'panNumber' => null,
                'isGstRegistered' => false,
                'gstNumber' => null,
            ]);
            return;
        }

        Response::success([
            'id' => $account['id'],
            'accountHolderName' => $account['account_holder_name'],
            'accountNumber' => $account['account_number'],
            'ifscCode' => $account['ifsc_code'],
            'bankName' => $account['bank_name'],
            'branchName' => $account['branch_name'],
            'panNumber' => $account['pan_number'],
            'isGstRegistered' => (bool)$account['is_gst_registered'],
            'gstNumber' => $account['gst_number'],
            'verificationStatus' => $account['verification_status'],
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
