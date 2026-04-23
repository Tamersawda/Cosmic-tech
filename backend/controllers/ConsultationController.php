<?php

namespace Backend\Controllers;

use Backend\Models\Consultation;
use Backend\Models\Appointment;
use Backend\Utils\Response;
use Backend\Middleware\AuthMiddleware;

class ConsultationController {
    private Consultation $consultationModel;
    private Appointment $appointmentModel;

    public function __construct() {
        $this->consultationModel = new Consultation();
        $this->appointmentModel = new Appointment();
    }

    /**
     * Start consultation
     * POST /api/consultations/{appointmentId}/start
     */
    public function start(object $payload, string $appointmentId): void {
        AuthMiddleware::requireRoles($payload, ['doctor', 'client']);

        $userId = $payload->userId ?? $payload->user_id;
        $userType = $payload->userType ?? $payload->user_type ?? $payload->role;

        try {
            $result = null;

            if ($userType === 'doctor') {
                $result = $this->consultationModel->startConsultation($appointmentId, $userId);
            } else {
                $result = $this->consultationModel->startConsultationAsClient($appointmentId, $userId);
            }

            Response::success($result, 201);

        } catch (\Exception $e) {
            $message = $e->getMessage();

            if ($message === 'Unauthorized') {
                Response::error('You do not belong to this appointment', 403);
            } else if ($message === 'Appointment not found') {
                Response::error('Appointment not found', 404);
            } else if ($message === 'Appointment is not scheduled') {
                Response::error('Appointment is not in scheduled state', 400);
            } else {
                error_log("Start consultation error: " . $message);
                Response::error('Failed to start consultation', 500);
            }
        }
    }

    /**
     * End consultation
     * POST /api/consultations/{appointmentId}/end
     */
    public function end(object $payload, string $appointmentId): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        $userId = $payload->userId ?? $payload->user_id;
        $input = $this->getInputData();
        $notes = $input['notes'] ?? null;

        try {
            $this->consultationModel->endConsultation($appointmentId, $userId, $notes);

            Response::success([
                'message' => 'Consultation ended successfully',
                'appointmentId' => $appointmentId,
                'status' => 'completed'
            ], 200);

        } catch (\Exception $e) {
            $message = $e->getMessage();

            if ($message === 'Unauthorized') {
                Response::error('Only the doctor can end the consultation', 403);
            } else if ($message === 'Appointment not found') {
                Response::error('Appointment not found', 404);
            } else if ($message === 'Appointment is not in progress') {
                Response::error('Appointment is not in progress', 400);
            } else {
                error_log("End consultation error: " . $message);
                Response::error('Failed to end consultation', 500);
            }
        }
    }

    /**
     * Create consultation
     * POST /api/consultations
     */
    public function create(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');
        $input = $this->getInputData();

        try {
            $consultationId = $this->consultationModel->create($input);
            Response::success(['id' => $consultationId], 201);

        } catch (\Exception $e) {
            error_log("Create consultation error: " . $e->getMessage());
            Response::error('Failed to create consultation', 500);
        }
    }

    /**
     * Get consultation
     * GET /api/consultations/{id}
     */
    public function get(object $payload, string $consultationId): void {
        try {
            $consultation = $this->consultationModel->getById($consultationId);

            if (!$consultation) {
                Response::error('Consultation not found', 404);
                return;
            }

            Response::success(['consultation' => $consultation], 200);

        } catch (\Exception $e) {
            error_log("Get consultation error: " . $e->getMessage());
            Response::error('Failed to fetch consultation', 500);
        }
    }

    /**
     * Update consultation
     * PUT /api/consultations/{id}
     */
    public function update(object $payload, string $consultationId): void {
        AuthMiddleware::requireRole($payload, 'doctor');
        $input = $this->getInputData();

        try {
            $this->consultationModel->update($consultationId, $input);
            Response::success(['id' => $consultationId], 200);

        } catch (\Exception $e) {
            error_log("Update consultation error: " . $e->getMessage());
            Response::error('Failed to update consultation', 500);
        }
    }

    /**
     * Get client consultations
     * GET /api/consultations/client
     */
    public function getClientConsultations(object $payload): void {
        AuthMiddleware::requireRole($payload, 'client');

        try {
            $consultations = $this->consultationModel->getClientConsultations($payload->userId ?? $payload->user_id);
            Response::success(['consultations' => $consultations, 'count' => count($consultations)], 200);

        } catch (\Exception $e) {
            error_log("Get client consultations error: " . $e->getMessage());
            Response::error('Failed to fetch consultations', 500);
        }
    }

    /**
     * Get doctor consultations
     * GET /api/consultations/doctor
     */
    public function getDoctorConsultations(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        try {
            $consultations = $this->consultationModel->getDoctorConsultations($payload->userId ?? $payload->user_id);
            Response::success(['consultations' => $consultations, 'count' => count($consultations)], 200);

        } catch (\Exception $e) {
            error_log("Get doctor consultations error: " . $e->getMessage());
            Response::error('Failed to fetch consultations', 500);
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
