<?php

namespace Backend\Controllers;

use Backend\Config\Database;
use Backend\Models\User;
use Backend\Models\DoctorProfile;
use Backend\Models\Appointment;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

/**
 * AdminController
 *
 * POST  /api/admin/create-admin
 * PATCH /api/admin/verify-doctor
 * GET   /api/admin/doctors
 * GET   /api/admin/appointments
 */
class AdminController {
    private User          $userModel;
    private DoctorProfile $doctorModel;
    private Appointment   $appointmentModel;
    private Validator     $validator;

    public function __construct() {
        $this->userModel        = new User();
        $this->doctorModel      = new DoctorProfile();
        $this->appointmentModel = new Appointment();
        $this->validator        = new Validator();
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/admin/create-admin
    // ─────────────────────────────────────────────────────────
    public function createAdmin(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        $input = $this->getInputData();

        // Normalise: accept 'name' or 'fullName'
        $input['name'] = $input['name'] ?? $input['fullName'] ?? '';

        $result = $this->validator->validate($input, [
            'name'     => ['required', 'string'],
            'email'    => ['required', 'email'],
            'password' => ['required', 'string', ['min', 6]],
        ]);

        if (!$result['valid']) {
            Response::validation($result['errors']);
            return;
        }

        if ($this->userModel->emailExists($input['email'])) {
            Response::error('Email already registered', 409, 'EMAIL_EXISTS');
            return;
        }

        try {
            $userId = $this->userModel->create([
                'email'     => strtolower(trim($input['email'])),
                'password'  => User::hashPassword($input['password']),
                'user_type' => 'admin',
                'full_name' => trim($input['name']),
            ]);

            Response::success(['userId' => $userId], 'Admin user created successfully', 201);
        } catch (\Exception $e) {
            error_log('Create admin error: ' . $e->getMessage());
            Response::error('Failed to create admin user', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // PATCH /api/admin/verify-doctor
    // ─────────────────────────────────────────────────────────
    public function verifyDoctor(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        $input = $this->getInputData();

        $result = $this->validator->validate($input, [
            'doctorId' => ['required', 'string'],
            'status'   => ['required', 'string', ['in', 'approved', 'rejected', 'resubmission_required']],
        ]);

        if (!$result['valid']) {
            Response::validation($result['errors']);
            return;
        }

        try {
            if (!$this->doctorModel->exists($input['doctorId'])) {
                Response::notFound('Doctor profile not found');
                return;
            }

            $this->doctorModel->verifyDoctor($input['doctorId'], $input['status']);

            Response::success([
                'doctorId' => $input['doctorId'],
                'status'   => $input['status'],
            ], 'Doctor verification status updated');

        } catch (\Exception $e) {
            error_log('Verify doctor error: ' . $e->getMessage());
            Response::error('Failed to update verification status', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/admin/doctors
    // ─────────────────────────────────────────────────────────
    public function listDoctors(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        try {
            $db   = Database::getInstance();
            $stmt = $db->prepare('
                SELECT
                    dp.user_id        AS userId,
                    u.full_name       AS name,
                    u.email,
                    dp.gender,
                    dp.primary_specialty  AS primarySpecialty,
                    dp.years_of_experience AS yearsOfExperience,
                    dp.license_number AS licenseNumber,
                    dp.is_profile_approved AS isProfileApproved,
                    u.is_profile_complete AS isProfileComplete,
                    dp.is_active      AS isActive,
                    dp.verification_status AS verificationStatus,
                    dp.profile_photo_url   AS profilePhotoUrl,
                    dp.created_at
                FROM doctor_profiles dp
                JOIN users u ON dp.user_id = u.id
                ORDER BY dp.created_at DESC
            ');
            $stmt->execute();
            $doctors = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            // Cast booleans
            foreach ($doctors as &$d) {
                $d['isProfileApproved'] = (bool)$d['isProfileApproved'];
                $d['isProfileComplete'] = (bool)$d['isProfileComplete'];
                $d['isActive']          = (bool)$d['isActive'];
            }
            unset($d);

            Response::success(['doctors' => $doctors, 'count' => count($doctors)]);

        } catch (\Exception $e) {
            error_log('Admin list doctors: ' . $e->getMessage());
            Response::error('Failed to fetch doctors', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/admin/appointments
    // ─────────────────────────────────────────────────────────
    public function listAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'admin');

        try {
            $db     = Database::getInstance();
            $status = $_GET['status'] ?? null;

            $sql    = '
                SELECT
                    a.id, a.scheduled_date AS scheduledDate,
                    a.scheduled_time AS scheduledTime, a.end_time AS endTime,
                    a.consultation_type AS consultationType,
                    a.status, a.notes,
                    ud.full_name AS doctorName,
                    uc.full_name AS clientName
                FROM appointments a
                LEFT JOIN users ud ON a.doctor_id = ud.id
                LEFT JOIN users uc ON a.client_id = uc.id
            ';
            $params = [];
            if ($status) {
                $sql      .= ' WHERE a.status = ?';
                $params[] = $status;
            }
            $sql .= ' ORDER BY a.scheduled_date DESC, a.scheduled_time DESC';

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $rows = $stmt->fetchAll(\PDO::FETCH_ASSOC);

            Response::success(['appointments' => $rows, 'count' => count($rows)]);

        } catch (\Exception $e) {
            error_log('Admin list appointments: ' . $e->getMessage());
            Response::error('Failed to fetch appointments', 500, 'SERVER_ERROR');
        }
    }

    private function getInputData(): array {
        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        return array_merge($_POST, $body);
    }
}
