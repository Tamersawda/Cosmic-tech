<?php
namespace Backend\Controllers;

use Backend\Models\ClientProfile;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class ClientProfileController {
    private ClientProfile $profileModel;
    private Validator $validator;

    public function __construct() {
        $this->profileModel = new ClientProfile();
        $this->validator    = new Validator();
    }

    /**
     * Setup / update client profile
     * POST /api/clients/setup
     *
     * Request (JSON):
     * {
     *   "gender":        "female",          // required: male | female | other
     *   "dateOfBirth":   "1995-06-15",      // required: YYYY-MM-DD
     *   "phoneNumber":   "+911234567890"    // required
     * }
     *
     * Role required: 'client'
     */
    public function setup(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');

        $input  = $this->getInputData();
        $userId = $payload->userId ?? $payload->user_id;

        // Load current user state from DB (never hardcode).
        $userModel = new User();
        $user = $userModel->findById($userId);

        if (!$user) {
            Response::error('User not found', 404);
            return;
        }

        // --- Fix 2: Migration safety check in setup API (Hard Stop) ---
        $isCompleted = (bool)($user['is_profile_completed'] ?? false);
        if ($isCompleted) {
            $profile = $this->profileModel->findByUserId($userId);
            // Critical fields for migration check: first_name and phone_number
            if (!$profile || empty($profile['first_name']) || empty($profile['phone_number'])) {
                // reset is_profile_completed = false, onboarding_step = 1
                $db = \Backend\Config\Database::getInstance();
                $resetStmt = $db->prepare('UPDATE users SET is_profile_completed = 0, onboarding_step = 1 WHERE id = ?');
                $resetStmt->execute([$userId]);
                
                // Fix 2: HARD STOP - return error and do not continue
                Response::error('Profile reset due to invalid data. Restart onboarding.', 400);
                return;
            }
        }

        $currentStep = (int)($user['onboarding_step'] ?? 0);

        // Reject if profile is already complete.
        if ($isCompleted) {
            Response::error('Profile already completed', 400);
            return;
        }

        // Validate step field is present.
        if (!isset($input['step'])) {
            Response::error('Step is required', 400);
            return;
        }

        $incomingStep = (int)$input['step'];

        // Reject out-of-range steps.
        if ($incomingStep < 1 || $incomingStep > 3) {
            Response::error('Invalid step: must be 1, 2, or 3', 400);
            return;
        }

        // --- Fix 4 & 5: Strict step-field mapping & No extra fields ---
        $stepAllowedFields = [
            1 => ['firstName', 'lastName', 'gender', 'dateOfBirth', 'phoneNumber'],
            2 => ['medicalHistory', 'allergies', 'currentMedications'],
            3 => ['emergencyContact']
        ];

        $allowedForThisStep = $stepAllowedFields[$incomingStep] ?? [];
        $payloadFields = array_keys($input);

        foreach ($payloadFields as $field) {
            // Allow meta fields
            if ($field === 'step' || $field === 'token' || $field === 'userId' || $field === 'user_id') {
                continue;
            }

            // Fix 5: Reject ANY field not allowed for this step
            if (!in_array($field, $allowedForThisStep)) {
                Response::error('Invalid fields for this step', 400);
                return;
            }

            $value = $input[$field];
            // Fix 4: Reject null or empty values (No silent skip)
            if ($value === null || $value === '') {
                Response::error('Field cannot be empty', 400);
                return;
            }

            // Fix 3: Strict nested validation for Step 3
            if ($incomingStep === 3 && $field === 'emergencyContact') {
                if (!is_array($value) || 
                    !isset($value['name']) || 
                    !isset($value['phoneNumber']) || 
                    $value['name'] === '' || 
                    $value['phoneNumber'] === '') {
                    Response::error('Invalid emergencyContact structure', 400);
                    return;
                }
            }
        }

        // Surface-level sequence check (the model will re-check under lock).
        if ($incomingStep !== $currentStep && $incomingStep !== $currentStep + 1) {
            Response::error('Invalid onboarding step sequence', 400);
            return;
        }

        try {
            // Fix 6: Explicitly calculate completion state
            $isProfileCompleted = ($incomingStep === 3);

            // Fix 7 & 8: Single transaction flow with same PDO connection
            $this->profileModel->saveStepAndState($userId, $input, $incomingStep, $isProfileCompleted);

            Response::success([
                'onboarding_step'      => $incomingStep,
                'is_profile_completed' => $isProfileCompleted,
            ], 200);

        } catch (\RuntimeException $e) {
            Response::error($e->getMessage(), 400);
        } catch (\Exception $e) {
            error_log('Client profile setup error: ' . $e->getMessage());
            $msg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to setup profile';
            Response::error($msg, 500);
        }
    }

    /**
     * Get client's own appointments
     * GET /api/clients/appointments
     *
     * Role required: 'client'
     */
    public function getAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');

        $userId = $payload->userId ?? $payload->user_id;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->profileModel->getAppointments($userId, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log('Get client appointments error: ' . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Get current user's client profile
     * GET /api/clients/profile
     *
     * Role required: 'client'
     */
    public function getProfile(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');

        try {
            $userId  = $payload->userId ?? $payload->user_id;
            $client = $this->profileModel->findByUserId($userId);

            if (!$client) {
                Response::error('Client profile not found', 404);
                return;
            }

            Response::success(['client' => $client], 200);

        } catch (\Exception $e) {
            error_log('Get client profile error: ' . $e->getMessage());
            Response::error('Failed to fetch client profile', 500);
        }
    }

    /**
     * Parse JSON request body. Falls back to $_POST for form data.
     */
    private function getInputData(): array {
        $raw  = file_get_contents('php://input');
        $json = json_decode($raw, true) ?? [];
        return array_merge($_POST, $json);
    }
}
