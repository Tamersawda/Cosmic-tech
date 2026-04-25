<?php

namespace Backend\Controllers;

use Backend\Models\User;
use Backend\Models\DoctorProfile;
use Backend\Models\Appointment;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

/**
 * AdminController
 *
 * Handles admin-only operations:
 *  - Create admin users
 *  - Verify/reject doctor profiles
 *  - List all doctors (including unverified)
 *  - List all appointments system-wide
 */
class AdminController {
    private User $userModel;
    private DoctorProfile $doctorModel;
    private Appointment $appointmentModel;
    private Validator $validator;

    public function __construct() {
        $this->userModel = new User();
        $this->doctorModel = new DoctorProfile();
        $this->appointmentModel = new Appointment();
        $this->validator = new Validator();
    }

    /**
     * Create a new admin user
     * POST /api/admin/create-admin
     */
    public function createAdmin(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        $input = $this->getInputData();

        $validation = $this->validator->validate($input, [
            'fullName' => ['required', 'string'],
            'email'    => ['required', 'email'],
            'password' => ['required', 'string', ['min', 6]],
        ]);

        if (!$validation['valid']) {
            Response::validation($validation['errors']);
            return;
        }

        // Check for duplicate email
        if ($this->userModel->emailExists($input['email'])) {
            Response::error('Email already registered', 409);
            return;
        }

        try {
            $hashedPassword = User::hashPassword($input['password']);
            $userId = $this->userModel->create([
                'email'     => $input['email'],
                'password'  => $hashedPassword,
                'user_type' => 'admin',
                'full_name' => $input['fullName'],
            ]);

            Response::success([
                'id'      => $userId,
                'message' => 'Admin user created successfully',
            ], 201);

        } catch (\Exception $e) {
            error_log("Create admin error: " . $e->getMessage());
            Response::error('Failed to create admin user', 500);
        }
    }

    /**
     * Verify or reject a doctor's profile
     * PATCH /api/admin/verify-doctor
     */
    public function verifyDoctor(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        $input = $this->getInputData();

        $validation = $this->validator->validate($input, [
            'doctorId' => ['required', 'string'],
            'status'   => ['required', 'string', ['in', 'approved', 'rejected']],
        ]);

        if (!$validation['valid']) {
            Response::validation($validation['errors']);
            return;
        }

        try {
            // Verify doctor exists
            if (!$this->doctorModel->exists($input['doctorId'])) {
                Response::error('Doctor profile not found', 404);
                return;
            }

            $this->doctorModel->verifyDoctor($input['doctorId'], $input['status']);

            Response::success([
                'doctorId' => $input['doctorId'],
                'status'   => $input['status'],
                'message'  => 'Doctor verification status updated',
            ], 200);

        } catch (\Exception $e) {
            error_log("Verify doctor error: " . $e->getMessage());
            Response::error('Failed to update doctor verification', 500);
        }
    }

    /**
     * List all doctors (including unverified/inactive)
     * GET /api/admin/doctors
     */
    public function listDoctors(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        try {
            // Use a direct query to get ALL doctors, not just active/verified
            $db = \Backend\Config\Database::getInstance();
            $stmt = $db->prepare('
                SELECT
                    dp.user_id,
                    u.full_name,
                    u.email,
                    dp.gender,
                    dp.primary_specialty,
                    dp.years_of_experience,
                    dp.is_verified,
                    dp.is_active,
                    dp.verification_status,
                    dp.profile_photo_url,
                    dp.created_at,
                    dp.updated_at
                FROM doctor_profiles dp
                JOIN users u ON dp.user_id = u.id
                ORDER BY dp.created_at DESC
            ');
            $stmt->execute();
            $doctors = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            Response::success([
                'doctors' => $doctors,
                'count'   => count($doctors),
            ], 200);

        } catch (\Exception $e) {
            error_log("Admin list doctors error: " . $e->getMessage());
            Response::error('Failed to fetch doctors', 500);
        }
    }

    /**
     * List all appointments system-wide
     * GET /api/admin/appointments
     */
    public function listAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        try {
            $db = \Backend\Config\Database::getInstance();
            $status = $_GET['status'] ?? null;

            $query = '
                SELECT
                    a.*,
                    d.full_name AS doctor_name,
                    c.full_name AS client_name
                FROM appointments a
                LEFT JOIN users d ON a.doctor_id = d.id
                LEFT JOIN users c ON a.client_id = c.id
            ';

            $params = [];
            if ($status) {
                $query .= ' WHERE a.status = ?';
                $params[] = $status;
            }

            $query .= ' ORDER BY a.scheduled_date DESC, a.scheduled_time DESC';

            $stmt = $db->prepare($query);
            $stmt->execute($params);
            $appointments = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log("Admin list appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Parse input data from request body
     */
    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];
        return array_merge($_GET, $_POST, $data);
    }
}
