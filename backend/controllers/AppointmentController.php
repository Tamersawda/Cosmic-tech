<?php

namespace Backend\Controllers;

use Backend\Models\Appointment;
use Backend\Models\DoctorProfile;
use Backend\Models\PatientProfile;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class AppointmentController {
    private Appointment   $appointmentModel;
    private DoctorProfile $doctorModel;
    private PatientProfile $patientModel;
    private Validator     $validator;

    public function __construct() {
        $this->appointmentModel = new Appointment();
        $this->doctorModel      = new DoctorProfile();
        $this->patientModel     = new PatientProfile();
        $this->validator        = new Validator();
    }

    /**
     * Book an appointment
     * POST /api/appointments
     *
     * Request (JSON):
     * {
     *   "doctorId":        "<uuid>",
     *   "scheduledDate":   "YYYY-MM-DD",
     *   "scheduledTime":   "HH:00",
     *   "consultationType": "video|audio"
     * }
     *
     * Role required: 'patient' (patients)
     */
    public function book(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        $input     = $this->getInputData();
        $patientId = $payload->userId ?? $payload->user_id;

        $isValid = $this->validator->validate($input, [
            'doctorId'         => ['required', 'string'],
            'scheduledDate'    => ['required', 'string'],
            'scheduledTime'    => ['required', 'string'],
            'consultationType' => ['required', ['in', 'video', 'audio', 'chat']],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $doctorId         = trim($input['doctorId']);
        $scheduledDate    = trim($input['scheduledDate']);
        $scheduledTime    = trim($input['scheduledTime']);
        $consultationType = trim($input['consultationType']);

        try {
            // Validate date format YYYY-MM-DD
            if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $scheduledDate)) {
                Response::error('scheduledDate must be in YYYY-MM-DD format', 400);
                return;
            }

            // Validate time format HH:MM
            if (!preg_match('/^\d{2}:\d{2}$/', $scheduledTime)) {
                Response::error('scheduledTime must be in HH:MM format', 400);
                return;
            }

            // Only whole-hour slots (e.g. 09:00, 14:00)
            [, $minutes] = explode(':', $scheduledTime);
            if ($minutes !== '00') {
                Response::error('Only whole-hour time slots are allowed (e.g. 09:00, 14:00)', 400);
                return;
            }

            // Must be a future date/time
            $appointmentTs = strtotime("$scheduledDate $scheduledTime");
            if ($appointmentTs === false || $appointmentTs <= time()) {
                Response::error('Appointment must be scheduled for a future date and time', 400);
                return;
            }

            // Doctor must exist
            if (!$this->doctorModel->exists($doctorId)) {
                Response::error('Doctor not found', 404);
                return;
            }

            // Patient must have a completed profile
            if (!$this->patientModel->exists($patientId)) {
                Response::error('Patient profile not found — complete your profile first', 404);
                return;
            }

            // End time = start + 50 minutes (session) + 10 min buffer = 1-hour block
            $startDt = new \DateTime("$scheduledDate $scheduledTime");
            $startDt->modify('+50 minutes');
            $endTime = $startDt->format('H:i');

            // Check doctor availability (no overlapping appointments)
            if ($this->appointmentModel->hasOverlappingAppointment(
                $doctorId, $scheduledDate, $scheduledTime, $endTime
            )) {
                Response::error('Doctor already has an appointment at this time', 409);
                return;
            }

            // Check patient does not have a conflicting appointment
            if ($this->appointmentModel->hasPatientConflict(
                $patientId, $scheduledDate, $scheduledTime, $endTime
            )) {
                Response::error('You already have an appointment at this time', 409);
                return;
            }

            $appointmentId = $this->appointmentModel->create([
                'doctor_id'         => $doctorId,
                'patient_id'        => $patientId,
                'scheduled_date'    => $scheduledDate,
                'scheduled_time'    => $scheduledTime,
                'end_time'          => $endTime,
                'consultation_type' => $consultationType,
            ]);

            $appointment = $this->appointmentModel->findById($appointmentId);

            Response::success([
                'id'               => $appointmentId,
                'status'           => $appointment['status'],
                'scheduledDate'    => $appointment['scheduled_date'],
                'scheduledTime'    => $appointment['scheduled_time'],
                'endTime'          => $appointment['end_time'],
                'consultationType' => $appointment['consultation_type'],
            ], 201);

        } catch (\Exception $e) {
            error_log('Appointment booking error: ' . $e->getMessage());
            $msg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to book appointment';
            Response::error($msg, 500);
        }
    }

    /**
     * Get appointments for the authenticated user (doctor or patient)
     * GET /api/appointments
     *
     * Role required: 'doctor' or 'patient'
     */
    public function getAppointments(object $payload): void {
        AuthMiddleware::requireRoles($payload, ['doctor', 'patient']);

        $userId   = $payload->user_id ?? $payload->userId;
        $userRole = $payload->role ?? $payload->userType; // Handle both cases
        $status   = $_GET['status'] ?? null;

        try {
            $appointments = $this->appointmentModel->getByUser($userId, $userRole, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log('Get appointments error: ' . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Cancel an appointment
     * PATCH /api/appointments/{id}/cancel
     *
     * Role required: 'patient' (patients)
     */
    public function cancel(object $payload, string $appointmentId): void {
        AuthMiddleware::requireRole($payload, 'patient');

        $userId = $payload->userId ?? $payload->user_id;

        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            if ($appointment['patient_id'] !== $userId) {
                Response::error('You can only cancel your own appointments', 403);
                return;
            }

            if ($appointment['status'] !== 'scheduled') {
                Response::error('Only scheduled appointments can be cancelled', 400);
                return;
            }

            $this->appointmentModel->cancel($appointmentId);

            Response::success([
                'id'     => $appointmentId,
                'status' => 'cancelled',
            ], 200);

        } catch (\Exception $e) {
            error_log('Cancel appointment error: ' . $e->getMessage());
            Response::error('Failed to cancel appointment', 500);
        }
    }

    /**
     * Get appointment details
     * GET /api/appointments/{id}
     */
    public function get(object $payload, string $appointmentId): void {
        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Only the doctor or patient belonging to this appointment may view it
            $userId = $payload->userId ?? $payload->user_id;
            if ($appointment['doctor_id'] !== $userId && $appointment['patient_id'] !== $userId) {
                Response::error('Forbidden', 403);
                return;
            }

            Response::success(['appointment' => $appointment], 200);

        } catch (\Exception $e) {
            error_log('Get appointment error: ' . $e->getMessage());
            Response::error('Failed to fetch appointment', 500);
        }
    }

    /**
     * Update appointment (status/notes)
     * PUT /api/appointments/{id}
     *
     * Only doctors may change status.
     */
    public function update(object $payload, string $appointmentId): void {
        $input = $this->getInputData();

        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            if (isset($input['status'])) {
                AuthMiddleware::requireRole($payload, 'doctor');
            }

            $this->appointmentModel->update($appointmentId, $input);
            Response::success(['id' => $appointmentId], 200);

        } catch (\Exception $e) {
            error_log('Update appointment error: ' . $e->getMessage());
            Response::error('Failed to update appointment', 500);
        }
    }

    /**
     * Get patient's appointments
     * GET /api/appointments/patient
     *
     * Role required: 'patient'
     */
    public function getPatientAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        try {
            $appointments = $this->appointmentModel->getByPatient($payload->userId ?? $payload->user_id);
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
     * Get doctor's appointments
     * GET /api/appointments/doctor
     *
     * Role required: 'doctor'
     */
    public function getDoctorAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        try {
            $appointments = $this->appointmentModel->getByDoctor($payload->userId ?? $payload->user_id);
            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log('Get doctor appointments error: ' . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Parse JSON request body.
     */
    private function getInputData(): array {
        $raw  = file_get_contents('php://input');
        $json = json_decode($raw, true) ?? [];
        return array_merge($_POST, $json);
    }
}
