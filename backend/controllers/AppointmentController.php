<?php

namespace Backend\Controllers;

use Backend\Models\Appointment;
use Backend\Models\DoctorProfile;
use Backend\Models\PatientProfile;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class AppointmentController {
    private Appointment $appointmentModel;
    private DoctorProfile $doctorModel;
    private PatientProfile $patientModel;
    private Validator $validator;

    public function __construct() {
        $this->appointmentModel = new Appointment();
        $this->doctorModel = new DoctorProfile();
        $this->patientModel = new PatientProfile();
        $this->validator = new Validator();
    }

    /**
     * Book an appointment
     * POST /api/appointments
     */
    public function book(object $payload): void {
        // Only patients can book appointments
        AuthMiddleware::requireRole($payload, 'patient');

        $input = $this->getInputData();
        $patientId = $payload->user_id;

        // Validate input
        $isValid = $this->validator->validate($input, [
            'doctorId' => ['required', 'string'],
            'scheduledDate' => ['required', 'string'],
            'scheduledTime' => ['required', 'string'],
            'consultationType' => ['required', ['in', 'video', 'audio']],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $doctorId = $input['doctorId'];
        $scheduledDate = $input['scheduledDate'];
        $scheduledTime = $input['scheduledTime'];
        $consultationType = $input['consultationType'];

        try {
            // Validate date format (YYYY-MM-DD)
            if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $scheduledDate)) {
                Response::validation(['scheduledDate' => 'scheduledDate must be in YYYY-MM-DD format']);
                return;
            }

            // Validate time format (HH:MM)
            if (!preg_match('/^\d{2}:\d{2}$/', $scheduledTime)) {
                Response::validation(['scheduledTime' => 'scheduledTime must be in HH:MM format']);
                return;
            }

            // Validate it's a valid time slot (whole hour only: 09:00, 10:00, etc.)
            $timeParts = explode(':', $scheduledTime);
            if ($timeParts[1] !== '00') {
                Response::error('Only whole hour time slots are allowed (e.g., 09:00, 10:00)', 400);
                return;
            }

            // Check date is in future
            $appointmentDateTime = strtotime("$scheduledDate $scheduledTime");
            if ($appointmentDateTime === false || $appointmentDateTime <= time()) {
                Response::error('Appointment must be scheduled for a future date and time', 400);
                return;
            }

            // Check doctor exists
            if (!$this->doctorModel->exists($doctorId)) {
                Response::error('Doctor not found', 404);
                return;
            }

            // Check patient exists
            if (!$this->patientModel->exists($patientId)) {
                Response::error('Patient not found', 404);
                return;
            }

            // Calculate end time (fixed 50 minutes + 10 minutes buffer = 1 hour)
            $startDateTime = new \DateTime("$scheduledDate $scheduledTime");
            $startDateTime->modify('+50 minutes');
            $endTime = $startDateTime->format('H:i');

            // CRITICAL: Check for doctor availability (no overlapping appointments)
            if ($this->appointmentModel->hasOverlappingAppointment(
                $doctorId,
                $scheduledDate,
                $scheduledTime,
                $endTime
            )) {
                Response::error('Doctor has an existing appointment at this time', 409);
                return;
            }

            // CRITICAL: Check for patient conflict
            if ($this->appointmentModel->hasPatientConflict(
                $patientId,
                $scheduledDate,
                $scheduledTime,
                $endTime
            )) {
                Response::error('You already have an appointment at this time', 409);
                return;
            }

            // Create appointment
            $appointmentId = $this->appointmentModel->create([
                'doctor_id' => $doctorId,
                'patient_id' => $patientId,
                'scheduled_date' => $scheduledDate,
                'scheduled_time' => $scheduledTime,
                'end_time' => $endTime,
                'consultation_type' => $consultationType
            ]);

            // Get created appointment
            $appointment = $this->appointmentModel->findById($appointmentId);

            Response::success([
                'appointment_id' => $appointmentId,
                'status' => $appointment['status'],
                'scheduled_date' => $appointment['scheduled_date'],
                'scheduled_time' => $appointment['scheduled_time'],
                'end_time' => $appointment['end_time'],
                'consultation_type' => $appointment['consultation_type'],
                'message' => 'Appointment booked successfully'
            ], 201);

        } catch (\Exception $e) {
            error_log("Appointment booking error: " . $e->getMessage());
            $errorMsg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Failed to book appointment';
            Response::error($errorMsg, 500);
        }
    }

    /**
     * Get appointments for current user
     * GET /api/appointments
     */
    public function getAppointments(object $payload): void {
        // Both doctor and patient can view appointments
        AuthMiddleware::requireRoles($payload, ['doctor', 'patient']);

        $userId = $payload->user_id;
        $userType = $payload->user_type;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->appointmentModel->getByUser($userId, $userType, $status);

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
     * Cancel appointment
     * PATCH /api/appointments/{id}/cancel
     */
    public function cancel(object $payload, string $appointmentId): void {
        // Only patients can cancel their own appointments
        AuthMiddleware::requireRole($payload, 'patient');

        $userId = $payload->user_id;

        try {
            // Get appointment
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Verify ownership
            if ($appointment['patient_id'] !== $userId) {
                Response::error('You can only cancel your own appointments', 403);
                return;
            }

            // Verify status is scheduled
            if ($appointment['status'] !== 'scheduled') {
                Response::error('Only scheduled appointments can be cancelled', 400);
                return;
            }

            // Cancel appointment
            $this->appointmentModel->cancel($appointmentId);

            Response::success([
                'appointment_id' => $appointmentId,
                'status' => 'cancelled',
                'message' => 'Appointment cancelled successfully'
            ], 200);

        } catch (\Exception $e) {
            error_log("Cancel appointment error: " . $e->getMessage());
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

            Response::success(['appointment' => $appointment], 200);

        } catch (\Exception $e) {
            error_log("Get appointment error: " . $e->getMessage());
            Response::error('Failed to fetch appointment', 500);
        }
    }

    /**
     * Update appointment
     * PUT /api/appointments/{id}
     */
    public function update(object $payload, string $appointmentId): void {
        $input = $this->getInputData();

        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Only doctors can update appointment status
            if (isset($input['status'])) {
                AuthMiddleware::requireRole($payload, 'doctor');
            }

            $this->appointmentModel->update($appointmentId, $input);
            Response::success(['id' => $appointmentId], 200);

        } catch (\Exception $e) {
            error_log("Update appointment error: " . $e->getMessage());
            Response::error('Failed to update appointment', 500);
        }
    }

    /**
     * Get patient appointments
     * GET /api/appointments/patient
     */
    public function getPatientAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        try {
            $appointments = $this->appointmentModel->getByPatient($payload->user_id);
            Response::success(['appointments' => $appointments, 'count' => count($appointments)], 200);

        } catch (\Exception $e) {
            error_log("Get patient appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * Get doctor appointments
     * GET /api/appointments/doctor
     */
    public function getDoctorAppointments(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        try {
            $appointments = $this->appointmentModel->getByDoctor($payload->user_id);
            Response::success(['appointments' => $appointments, 'count' => count($appointments)], 200);

        } catch (\Exception $e) {
            error_log("Get doctor appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
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
