<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class DoctorProfileController {
    private DoctorProfile $profileModel;
    private User $userModel;
    private Validator $validator;

    public function __construct() {
        $this->profileModel = new DoctorProfile();
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    /**
     * Setup doctor profile
     * POST /api/doctors/setup
     */
    public function setup(object $payload): void {
        // Verify user is a doctor
        AuthMiddleware::requireRole($payload, 'doctor');

        $input = $this->getInputData();
        $userId = $payload->user_id;

        // Validate required fields
        $isValid = $this->validator->validate($input, [
            'fullName'             => ['required', 'string'],
            'gender'               => ['required', ['in', 'male', 'female', 'other', 'prefer_not_to_say']],
            'dateOfBirth'          => ['required', 'string'],
            'phoneNumber'          => ['required', 'string'],
            'primarySpecialty'     => ['required', 'string'],
            'yearsOfExperience'    => ['required', 'numeric'],
            'licenseNumber'        => ['required', 'string'],
            'languagesSpoken'      => ['required'],
            'videoEnabled'         => ['required'],
            'videoRate'            => ['required', 'numeric'],
            'consultationDuration' => ['required', ['in', '30min', '45min', '60min']],
            'bufferTime'           => ['required', ['in', '5min', '10min', '15min', '30min']],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        // Validate languagesSpoken is array
        if (!is_array($input['languagesSpoken']) || empty($input['languagesSpoken'])) {
            Response::validation(['languagesSpoken' => 'languagesSpoken must be a non-empty array']);
            return;
        }

        // Validate dateOfBirth format (YYYY-MM-DD)
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $input['dateOfBirth'])) {
            Response::validation(['dateOfBirth' => 'dateOfBirth must be in YYYY-MM-DD format']);
            return;
        }

        // Check license number is unique
        if ($this->profileModel->licenseExists($input['licenseNumber'], $userId)) {
            Response::validation(['licenseNumber' => 'License number already exists']);
            return;
        }

        try {
            // Update doctor profile
            $this->profileModel->setupProfile($userId, $input);

            // Get updated profile
            $profile = $this->profileModel->findByUserId($userId);

            Response::success([
                'doctorId'      => $userId,
                'profileStatus' => 'completed',
                'profile'       => [
                    'fullName'          => $profile['full_name'],
                    'primarySpecialty'  => $profile['primary_specialty'],
                    'yearsOfExperience' => $profile['years_of_experience'],
                    'licenseNumber'     => $profile['license_number'],
                ],
            ], 201);

        } catch (\Exception $e) {
            error_log("Doctor profile setup error: " . $e->getMessage());
            $errorMsg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to setup profile';
            Response::error($errorMsg, 500);
        }
    }

    /**
     * Get doctor appointments
     * GET /api/doctors/appointments
     */
    public function getAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');

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
     * List all doctors
     * GET /api/doctors
     */
    public function list(object $payload): void {
        try {
            $doctors = $this->profileModel->getAllDoctors();

            Response::success([
                'doctors' => $doctors,
                'count' => count($doctors)
            ], 200);

        } catch (\Exception $e) {
            error_log("List doctors error: " . $e->getMessage());
            $errorMsg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to fetch doctors';
            Response::error($errorMsg, 500);
        }
    }

    /**
     * Get doctor by ID
     * GET /api/doctors/{id}
     */
    public function getById(object $payload, string $doctorId): void {
        try {
            $doctor = $this->profileModel->findByUserId($doctorId);

            if (!$doctor) {
                Response::error('Doctor not found', 404);
                return;
            }

            Response::success([
                'id' => $doctorId,
                'doctor' => $doctor
            ], 200);

        } catch (\Exception $e) {
            error_log("Get doctor error: " . $e->getMessage());
            Response::error('Failed to fetch doctor', 500);
        }
    }

    /**
     * Get current user's doctor profile
     * GET /api/doctor-profile
     */
    public function getByUserId(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        try {
            $userId = $payload->user_id;
            $doctor = $this->profileModel->findByUserId($userId);

            if (!$doctor) {
                Response::error('Doctor profile not found', 404);
                return;
            }

            Response::success([
                'doctor' => $doctor
            ], 200);

        } catch (\Exception $e) {
            error_log("Get doctor profile error: " . $e->getMessage());
            Response::error('Failed to fetch doctor profile', 500);
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
