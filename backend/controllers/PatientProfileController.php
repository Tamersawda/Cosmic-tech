<?php

namespace Backend\Controllers;

use Backend\Models\PatientProfile;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class PatientProfileController {
    private PatientProfile $profileModel;
    private Validator $validator;

    public function __construct() {
        $this->profileModel = new PatientProfile();
        $this->validator    = new Validator();
    }

    /**
     * Setup / update patient profile
     * POST /api/patients/setup
     *
     * Request (JSON):
     * {
     *   "fullName":      "Jane Doe",       // required
     *   "gender":        "female",          // required: male | female | other
     *   "dateOfBirth":   "1995-06-15",      // required: YYYY-MM-DD
     *   "phoneNumber":   "+911234567890",   // required
     *   "age":           28,                // optional integer
     *   "medicalHistory": "..."             // optional
     * }
     *
     * Role required: 'user'  (patients are stored with user_type = 'user')
     */
    public function setup(object $payload): void {
        AuthMiddleware::requireRole($payload, 'user');

        $input  = $this->getInputData();
        $userId = $payload->user_id;

        // Validate required fields
        $isValid = $this->validator->validate($input, [
            'fullName'    => ['required', 'string'],
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
                'patientId'     => $userId,
                'profileStatus' => 'completed',
                'profile'       => [
                    'fullName'    => $profile['full_name'],
                    'gender'      => $profile['gender'],
                    'phoneNumber' => $profile['phone_number'],
                    'age'         => $profile['age'],
                ],
            ], 201);

        } catch (\Exception $e) {
            error_log('Patient profile setup error: ' . $e->getMessage());
            $msg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to setup profile';
            Response::error($msg, 500);
        }
    }

    /**
     * Get patient's own appointments
     * GET /api/patients/appointments
     *
     * Role required: 'user'
     */
    public function getAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'user');

        $userId = $payload->user_id;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->profileModel->getAppointments($userId, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log('Get patient appointments error: ' . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Get current user's patient profile
     * GET /api/patient-profile
     *
     * Role required: 'user'
     */
    public function getByUserId(object $payload): void {
        AuthMiddleware::requireRole($payload, 'user');

        try {
            $userId  = $payload->user_id;
            $patient = $this->profileModel->findByUserId($userId);

            if (!$patient) {
                Response::error('Patient profile not found', 404);
                return;
            }

            Response::success(['patient' => $patient], 200);

        } catch (\Exception $e) {
            error_log('Get patient profile error: ' . $e->getMessage());
            Response::error('Failed to fetch patient profile', 500);
        }
    }

    /**
     * Get a specific patient profile by user ID
     * GET /api/patient-profile/{id}
     */
    public function getById(object $payload, string $patientId): void {
        try {
            $patient = $this->profileModel->findByUserId($patientId);

            if (!$patient) {
                Response::error('Patient not found', 404);
                return;
            }

            Response::success([
                'id'      => $patientId,
                'patient' => $patient,
            ], 200);

        } catch (\Exception $e) {
            error_log('Get patient error: ' . $e->getMessage());
            Response::error('Failed to fetch patient', 500);
        }
    }

    /**
     * Parse JSON request body. Falls back to $_POST for form data.
     */
    private function getInputData(): array {
        $raw  = file_get_contents('php://input');
        $json = json_decode($raw, true) ?? [];
        return array_merge($_POST, $json); // JSON wins over POST on key collision
    }
}
