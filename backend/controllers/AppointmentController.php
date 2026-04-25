<?php

namespace Backend\Controllers;

use Backend\Models\Appointment;
use Backend\Models\AvailableSlots;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

/**
 * AppointmentController
 *
 * Handles all appointment CRUD operations.
 * Uses the existing Appointment model for database access.
 */
class AppointmentController {
    private Appointment $appointmentModel;
    private Validator $validator;

    public function __construct() {
        $this->appointmentModel = new Appointment();
        $this->validator = new Validator();
    }

    /**
     * Book a new appointment
     * POST /api/appointments
     */
    public function create(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');

        $input = $this->getInputData();
        $clientId = $payload->userId ?? $payload->user_id;

        // Validate required fields
        $validation = $this->validator->validate($input, [
            'doctorId'         => ['required', 'string'],
            'scheduledDate'    => ['required', 'string'],
            'scheduledTime'    => ['required', 'string'],
        ]);

        if (!$validation['valid']) {
            Response::validation($validation['errors']);
            return;
        }

        // Validate date format
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $input['scheduledDate'])) {
            Response::error('Invalid scheduledDate format. Use YYYY-MM-DD', 400);
            return;
        }

        // Validate time format (HH:MM or HH:MM:SS)
        if (!preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $input['scheduledTime'])) {
            Response::error('Invalid scheduledTime format. Use HH:MM or HH:MM:SS', 400);
            return;
        }

        // Normalize time to HH:MM
        $scheduledTime = substr($input['scheduledTime'], 0, 5);

        // Calculate end time (default 50 min)
        $durationMinutes = (int)($input['durationMinutes'] ?? 50);
        $startDT = \DateTime::createFromFormat('H:i', $scheduledTime);
        $endDT = (clone $startDT)->modify("+{$durationMinutes} minutes");
        $endTime = $endDT->format('H:i');

        try {
            // Check for doctor overlap
            if ($this->appointmentModel->hasOverlappingAppointment(
                $input['doctorId'],
                $input['scheduledDate'],
                $scheduledTime,
                $endTime
            )) {
                Response::error('Doctor already has an appointment at this time', 409);
                return;
            }

            // Check for client overlap
            if ($this->appointmentModel->hasClientConflict(
                $clientId,
                $input['scheduledDate'],
                $scheduledTime,
                $endTime
            )) {
                Response::error('You already have an appointment at this time', 409);
                return;
            }

            $appointmentId = $this->appointmentModel->create([
                'doctor_id'         => $input['doctorId'],
                'client_id'         => $clientId,
                'scheduled_date'    => $input['scheduledDate'],
                'scheduled_time'    => $scheduledTime,
                'end_time'          => $endTime,
                'consultation_type' => $input['consultationType'] ?? 'video',
            ]);

            Response::success([
                'id'            => $appointmentId,
                'message'       => 'Appointment booked successfully',
                'scheduledDate' => $input['scheduledDate'],
                'scheduledTime' => $scheduledTime,
                'endTime'       => $endTime,
            ], 201);

        } catch (\Exception $e) {
            error_log("Create appointment error: " . $e->getMessage());
            Response::error('Failed to create appointment', 500);
        }
    }

    /**
     * Get appointment by ID
     * GET /api/appointments/{id}
     */
    public function get(object $payload, string $appointmentId): void {
        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Ensure the user is part of this appointment
            $userId = $payload->userId ?? $payload->user_id;
            $userType = $payload->userType ?? $payload->role ?? null;

            if ($userType !== 'admin' &&
                $appointment['doctor_id'] !== $userId &&
                $appointment['client_id'] !== $userId) {
                Response::error('You do not have access to this appointment', 403);
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
        $userId = $payload->userId ?? $payload->user_id;

        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Only participants can update
            $userType = $payload->userType ?? $payload->role ?? null;
            if ($userType !== 'admin' &&
                $appointment['doctor_id'] !== $userId &&
                $appointment['client_id'] !== $userId) {
                Response::error('You do not have access to this appointment', 403);
                return;
            }

            $this->appointmentModel->update($appointmentId, $input);

            Response::success([
                'id'      => $appointmentId,
                'message' => 'Appointment updated successfully',
            ], 200);

        } catch (\Exception $e) {
            error_log("Update appointment error: " . $e->getMessage());
            Response::error('Failed to update appointment', 500);
        }
    }

    /**
     * Cancel appointment
     * PATCH /api/appointments/{id}/cancel
     */
    public function cancel(object $payload, string $appointmentId): void {
        $userId = $payload->userId ?? $payload->user_id;

        try {
            $appointment = $this->appointmentModel->findById($appointmentId);

            if (!$appointment) {
                Response::error('Appointment not found', 404);
                return;
            }

            // Only participants can cancel
            $userType = $payload->userType ?? $payload->role ?? null;
            if ($userType !== 'admin' &&
                $appointment['doctor_id'] !== $userId &&
                $appointment['client_id'] !== $userId) {
                Response::error('You do not have access to this appointment', 403);
                return;
            }

            if ($appointment['status'] !== 'scheduled') {
                Response::error('Only scheduled appointments can be cancelled', 400);
                return;
            }

            $this->appointmentModel->cancel($appointmentId);

            Response::success([
                'id'      => $appointmentId,
                'message' => 'Appointment cancelled successfully',
                'status'  => 'cancelled',
            ], 200);

        } catch (\Exception $e) {
            error_log("Cancel appointment error: " . $e->getMessage());
            Response::error('Failed to cancel appointment', 500);
        }
    }

    /**
     * List appointments for the authenticated user
     * GET /api/appointments
     */
    public function list(object $payload): void {
        $userId = $payload->userId ?? $payload->user_id;
        $userType = $payload->userType ?? $payload->role ?? null;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->appointmentModel->getByUser($userId, $userType, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log("List appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * List appointments for the authenticated client
     * GET /api/appointments/client
     */
    public function getClientList(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');
        $userId = $payload->userId ?? $payload->user_id;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->appointmentModel->getByClient($userId, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log("Get client appointments error: " . $e->getMessage());
            Response::error('Failed to fetch appointments', 500);
        }
    }

    /**
     * List appointments for the authenticated doctor
     * GET /api/appointments/doctor
     */
    public function getDoctorList(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');
        $userId = $payload->userId ?? $payload->user_id;
        $status = $_GET['status'] ?? null;

        try {
            $appointments = $this->appointmentModel->getByDoctor($userId, $status);

            Response::success([
                'appointments' => $appointments,
                'count'        => count($appointments),
            ], 200);

        } catch (\Exception $e) {
            error_log("Get doctor appointments error: " . $e->getMessage());
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
