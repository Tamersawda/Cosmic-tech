<?php

namespace Backend\Controllers;

use Backend\Models\AvailableSlots;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Middleware\AuthMiddleware;

class AvailableSlotController {
    private AvailableSlots $slotsModel;
    private Validator $validator;

    public function __construct() {
        $this->slotsModel = new AvailableSlots();
        $this->validator = new Validator();
    }

    /**
     * Get available slots for a doctor
     * GET /api/appointments/available-slots
     */
    public function getSlots(object $payload): void {
        AuthMiddleware::requireRole($payload, 'patient');

        // Get query parameters
        $doctorId = $_GET['doctorId'] ?? null;
        $fromDate = $_GET['fromDate'] ?? null;
        $toDate = $_GET['toDate'] ?? null;

        // Validate input
        if (empty($doctorId) || empty($fromDate) || empty($toDate)) {
            Response::error('Missing required parameters: doctorId, fromDate, toDate', 400);
            return;
        }

        // Validate date formats
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fromDate)) {
            Response::error('Invalid fromDate format. Use YYYY-MM-DD', 400);
            return;
        }

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $toDate)) {
            Response::error('Invalid toDate format. Use YYYY-MM-DD', 400);
            return;
        }

        try {
            $availableSlots = $this->slotsModel->getAvailableSlots($doctorId, $fromDate, $toDate);

            Response::success([
                'availableSlots' => $availableSlots,
                'count' => count($availableSlots)
            ], 200);

        } catch (\Exception $e) {
            if (strpos($e->getMessage(), 'Doctor not found') !== false) {
                Response::error('Doctor not found', 404);
            } else if (strpos($e->getMessage(), 'Invalid') !== false) {
                Response::error($e->getMessage(), 400);
            } else {
                error_log("Get available slots error: " . $e->getMessage());
                Response::error('Failed to fetch available slots', 500);
            }
        }
    }

    /**
     * Create available slot
     * POST /api/available-slots
     */
    public function create(object $payload): void {
        AuthMiddleware::requireRole($payload, 'doctor');
        $input = $this->getInputData();
        $doctorId = $payload->user_id;

        $isValid = $this->validator->validate($input, [
            'slot_date' => ['required', 'string'],
            'slot_time' => ['required', 'string'],
            'duration_minutes' => ['required', 'numeric'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        try {
            $slotData = [
                'doctor_id' => $doctorId,
                'slot_date' => $input['slot_date'],
                'slot_time' => $input['slot_time'],
                'duration_minutes' => $input['duration_minutes'],
                'is_available' => $input['is_available'] ?? true,
            ];

            $slotId = $this->slotsModel->create($slotData);
            Response::success(['id' => $slotId], 201);

        } catch (\Exception $e) {
            error_log("Create slot error: " . $e->getMessage());
            Response::error('Failed to create slot', 500);
        }
    }

    /**
     * Get doctor slots
     * GET /api/available-slots/doctor/{doctorId}
     */
    public function getDoctorSlots(object $payload, string $doctorId): void {
        try {
            $slots = $this->slotsModel->getDoctorSlots($doctorId);
            Response::success(['slots' => $slots, 'count' => count($slots)], 200);
        } catch (\Exception $e) {
            error_log("Get doctor slots error: " . $e->getMessage());
            Response::error('Failed to fetch slots', 500);
        }
    }

    /**
     * Get slot details
     * GET /api/available-slots/{slotId}
     */
    public function get(object $payload, string $slotId): void {
        try {
            $slot = $this->slotsModel->getById($slotId);
            if (!$slot) {
                Response::error('Slot not found', 404);
                return;
            }
            Response::success(['slot' => $slot], 200);
        } catch (\Exception $e) {
            error_log("Get slot error: " . $e->getMessage());
            Response::error('Failed to fetch slot', 500);
        }
    }

    /**
     * Update slot
     * PUT /api/available-slots/{slotId}
     */
    public function update(object $payload, string $slotId): void {
        AuthMiddleware::requireRole($payload, 'doctor');
        $input = $this->getInputData();

        try {
            $this->slotsModel->update($slotId, $input);
            Response::success(['id' => $slotId], 200);
        } catch (\Exception $e) {
            error_log("Update slot error: " . $e->getMessage());
            Response::error('Failed to update slot', 500);
        }
    }

    /**
     * Delete slot
     * DELETE /api/available-slots/{slotId}
     */
    public function delete(object $payload, string $slotId): void {
        AuthMiddleware::requireRole($payload, 'doctor');

        try {
            $this->slotsModel->delete($slotId);
            Response::success(['id' => $slotId], 200);
        } catch (\Exception $e) {
            error_log("Delete slot error: " . $e->getMessage());
            Response::error('Failed to delete slot', 500);
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
