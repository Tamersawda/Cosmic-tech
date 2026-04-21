<?php

namespace Backend\Controllers;

use Backend\Models\PatientProfile;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class PatientProfileController {
    private PatientProfile $profileModel;
    private User $userModel;
    private Validator $validator;

    public function __construct() {
        $this->profileModel = new PatientProfile();
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    /**
     * Setup patient profile
     * POST /api/patients/setup
     */
    public function setup(object $payload): void {
        // Verify user is a patient
        AuthMiddleware::requireRole($payload, 'patient');

        $input = $this->getInputData();
        $userId = $payload->user_id;

        // Validate required fields
        $isValid = $this->validator->validate($input, [
            'firstName' => ['required', 'string'],
            'lastName' => ['required', 'string'],
            'gender' => ['required', ['in', 'male', 'female', 'other']],
            'dateOfBirth' => ['required', 'string'],
            'phoneNumber' => ['required', 'string'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        // Validate dateOfBirth format (YYYY-MM-DD)
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $input['dateOfBirth'])) {
            Response::validation(['dateOfBirth' => 'dateOfBirth must be in YYYY-MM-DD format']);
            return;
        }

        try {
            // Update patient profile
            $this->profileModel->setupProfile($userId, $input);

            // Get updated profile
            $profile = $this->profileModel->findByUserId($userId);

            Response::success([
                'patient_id' => $userId,
                'profile_status' => 'completed',
                'message' => 'Patient profile setup completed successfully',
                'profile' => [
                    'first_name' => $profile['first_name'],
                    'last_name' => $profile['last_name'],
                    'gender' => $profile['gender'],
                    'phone_number' => $profile['phone_number'],
                ]
            ], 201);

        } catch (\Exception $e) {
            error_log("Patient profile setup error: " . $e->getMessage());
            $errorMsg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to setup profile';
            Response::error($errorMsg, 500);
        }
    }

    /**
     * Get patient appointments
     * GET /api/patients/appointments
     */
    public function getAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        $userId = $payload->user_id;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->profileModel->getAppointments($userId, $status);

            Response::success([
                'appointments' => $appointments,
                'count' => count($appointments)
            ], 200);

        } catch (\Exception $e) {
            error_log("Get appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Get current user's patient profile
     * GET /api/patient-profile
     */
    public function getByUserId(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        try {
            $userId = $payload->user_id;
            $patient = $this->profileModel->findByUserId($userId);

            if (!$patient) {
                Response::error('Patient profile not found', 404);
                return;
            }

            Response::success([
                'patient' => $patient
            ], 200);

        } catch (\Exception $e) {
            error_log("Get patient profile error: " . $e->getMessage());
            Response::error('Failed to fetch patient profile', 500);
        }
    }

    /**
     * Get specific patient profile by ID
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
                'id' => $patientId,
                'patient' => $patient
            ], 200);

        } catch (\Exception $e) {
            error_log("Get patient error: " . $e->getMessage());
            Response::error('Failed to fetch patient', 500);
        }
    }

    /**
     * Parse input data from request
     */
    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];
        return array_merge($_GET, $_POST, $data);
    }
}
