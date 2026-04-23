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

        // Reject forbidden fields
        $forbidden = ['firstName', 'lastName', 'fullName', 'age', 'medicalHistory'];
        foreach ($forbidden as $field) {
            if (isset($input[$field])) {
                Response::error("Field '$field' is not allowed in profile setup", 400);
                return;
            }
        }

        // Validate required fields
        $isValid = $this->validator->validate($input, [
            'gender'      => ['required', ['in', 'male', 'female', 'other']],
            'dateOfBirth' => ['required', 'string'],
            'phoneNumber' => ['required', 'string'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        // Validate dateOfBirth format (YYYY-MM-DD)
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $input['dateOfBirth'])) {
            Response::validation(['dateOfBirth' => ['dateOfBirth must be in YYYY-MM-DD format']]);
            return;
        }

        try {
            $this->profileModel->setupProfile($userId, $input);

            // Return the saved profile
            $profile = $this->profileModel->findByUserId($userId);

            Response::success([
                'clientId'      => $userId,
                'profileStatus' => 'completed',
                'profile'       => [
                    'gender'      => $profile['gender'],
                    'phoneNumber' => $profile['phone_number'],
                    'dateOfBirth' => $profile['date_of_birth'],
                ],
            ], 201);

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
