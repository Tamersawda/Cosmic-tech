<?php

namespace Backend\Controllers;

use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;

class AdminController {
    private User $userModel;
    private Validator $validator;

    public function __construct() {
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    /**
     * Create a new admin user
     * POST /api/admin/create-admin
     * 
     * Requires Authorization: Bearer <token>
     * where the token belongs to an existing admin.
     */
    public function createAdmin(object $payload): void {
        try {
            // Check authorization
            if (!isset($payload->userType) || $payload->userType !== 'admin') {
                Response::error('Forbidden: Admin access required', 403);
                return;
            }

            $input = $this->getInputData();

            $isValid = $this->validator->validate($input, [
                'email'    => ['required', 'email'],
                'password' => ['required', ['min', 6]],
            ]);

            if (!$isValid) {
                $errors = $this->validator->getErrors();
                $firstError = array_values($errors)[0][0] ?? 'Invalid input';
                Response::error($firstError, 400);
                return;
            }

            $email    = strtolower(trim($input['email']));
            $password = $input['password'];
            $fullName = $input['fullName'] ?? 'System Administrator';

            // Check duplicate email
            if ($this->userModel->emailExists($email)) {
                Response::error('Email already exists', 409);
                return;
            }

            $hashedPassword = User::hashPassword($password);

            $userId = $this->userModel->create([
                'email'     => $email,
                'password'  => $hashedPassword,
                'user_type' => 'admin',
                'full_name' => $fullName,
            ]);

            Response::success([
                'id'       => $userId,
                'email'    => $email,
                'userType' => 'admin',
                'fullName' => $fullName
            ], 201);

        } catch (\Exception $e) {
            error_log('Create admin error: ' . $e->getMessage());
            Response::error('Internal server error', 500);
        }
    }

    /**
     * Verify or reject a doctor profile
     * PATCH /api/admin/verify-doctor
     */
    public function verifyDoctor(object $payload): void {
        try {
            // Check authorization
            if (!isset($payload->userType) || $payload->userType !== 'admin') {
                Response::error('Forbidden: Admin access required', 403);
                return;
            }

            $input = $this->getInputData();

            $isValid = $this->validator->validate($input, [
                'doctorId' => ['required', 'string'],
                'status'   => ['required', ['in', 'approved', 'rejected', 'pending']],
            ]);

            if (!$isValid) {
                Response::validation($this->validator->getErrors());
                return;
            }

            $doctorId = $input['doctorId'];
            $status   = $input['status'];

            $doctorModel = new \Backend\Models\DoctorProfile();
            
            if (!$doctorModel->exists($doctorId)) {
                Response::error('Doctor profile not found', 404);
                return;
            }

            $success = $doctorModel->verifyDoctor($doctorId, $status);

            if (!$success) {
                Response::error('Failed to update verification status', 500);
                return;
            }

            Response::success([
                'message' => "Doctor verification status updated to $status",
                'isVerified' => ($status === 'approved')
            ]);

        } catch (\Exception $e) {
            error_log('Verify doctor error: ' . $e->getMessage());
            Response::error('Internal server error', 500);
        }
    }

    /**
     * List all doctors (Admin only)
     * GET /api/admin/doctors
     */
    public function listDoctors(object $payload): void {
        try {
            if (!isset($payload->userType) || $payload->userType !== 'admin') {
                Response::error('Forbidden: Admin access required', 403);
                return;
            }

            $doctorModel = new \Backend\Models\DoctorProfile();
            $doctors = $doctorModel->getAllDoctors(); // This model method already exists

            Response::success($doctors);

        } catch (\Exception $e) {
            error_log('Admin list doctors error: ' . $e->getMessage());
            Response::error('Internal server error', 500);
        }
    }

    /**
     * List all appointments (Admin only)
     * GET /api/admin/appointments
     */
    public function listAppointments(object $payload): void {
        try {
            if (!isset($payload->userType) || $payload->userType !== 'admin') {
                Response::error('Forbidden: Admin access required', 403);
                return;
            }

            $appointmentModel = new \Backend\Models\Appointment();
            // Assuming we want ALL appointments
            $stmt = $appointmentModel->db->prepare("
                SELECT a.*, u.full_name as client_name, ud.full_name as doctor_name
                FROM appointments a
                JOIN users u ON a.client_id = u.id
                JOIN users ud ON a.doctor_id = ud.id
                ORDER BY a.scheduled_date DESC, a.scheduled_time DESC
            ");
            $stmt->execute();
            $appointments = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            Response::success($appointments);

        } catch (\Exception $e) {
            error_log('Admin list appointments error: ' . $e->getMessage());
            Response::error('Internal server error', 500);
        }
    }

    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];
        return array_merge($_GET, $_POST, $data);
    }
}
