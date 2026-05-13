<?php

namespace Backend\Controllers;

use Backend\Models\DoctorExperience;
use Backend\Utils\Response;
use Backend\Utils\Validator;

/**
 * DoctorExperienceController
 *
 * POST   /api/doctors/{doctorId}/experiences
 * GET    /api/doctors/{doctorId}/experiences
 * GET    /api/doctors/{doctorId}/experiences/{id}
 * PUT    /api/doctors/{doctorId}/experiences/{id}
 * DELETE /api/doctors/{doctorId}/experiences/{id}
 */
class DoctorExperienceController {
    private DoctorExperience $model;
    private Validator         $validator;

    private const EMPLOYMENT_TYPES = [
        'full_time', 'part_time', 'contract', 'freelance', 'internship', 'other',
    ];

    public function __construct() {
        $this->model     = new DoctorExperience();
        $this->validator = new Validator();
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/doctors/{doctorId}/experiences
    // ─────────────────────────────────────────────────────────
    public function create(object $payload, string $doctorId): void {
        $this->authorise($payload, $doctorId);

        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

        // Normalize boolean
        if (isset($input['currentlyWorking'])) {
            $v = $input['currentlyWorking'];
            $input['currentlyWorking'] = ($v === true || $v === 'true' || $v === '1' || $v === 1);
        }

        $result = $this->validator->validate($input, [
            'company'        => ['required', 'string'],
            'roleTitle'      => ['required', 'string'],
            'startDate'      => ['required', 'date'],
            'employmentType' => ['string', ['in', ...self::EMPLOYMENT_TYPES]],
        ]);
        if (!$result['valid']) {
            Response::validation($result['errors']);
            return;
        }

        $currentlyWorking = (bool)($input['currentlyWorking'] ?? false);
        $endDate = null;

        if (!$currentlyWorking) {
            if (empty($input['endDate'])) {
                Response::error('endDate is required when not currently working', 400, 'VALIDATION_ERROR');
                return;
            }
            $endDate = $input['endDate'];
        }

        try {
            $id = $this->model->create([
                'doctor_id'         => $doctorId,
                'company'           => trim($input['company']),
                'role_title'        => trim($input['roleTitle']),
                'employment_type'   => $input['employmentType'] ?? 'full_time',
                'currently_working' => $currentlyWorking,
                'start_date'        => $input['startDate'],
                'end_date'          => $endDate,
                'description'       => trim($input['description'] ?? ''),
            ]);
        } catch (\Throwable $e) {
            error_log('Create experience error: ' . $e->getMessage());
            Response::error('Failed to save experience', 500, 'SERVER_ERROR');
            return;
        }

        Response::success($this->format($this->model->getById($id)), 'Experience created', 201);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/doctors/{doctorId}/experiences
    // ─────────────────────────────────────────────────────────
    public function list(string $doctorId): void {
        $rows = $this->model->getByDoctorId($doctorId);
        Response::success(array_map([$this, 'format'], $rows), 'Experiences retrieved');
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/doctors/{doctorId}/experiences/{id}
    // ─────────────────────────────────────────────────────────
    public function getOne(string $doctorId, string $id): void {
        $row = $this->model->getById($id);
        if (!$row || $row['doctor_id'] !== $doctorId) {
            Response::notFound('Experience not found');
            return;
        }
        Response::success($this->format($row));
    }

    // ─────────────────────────────────────────────────────────
    // PUT /api/doctors/{doctorId}/experiences/{id}
    // ─────────────────────────────────────────────────────────
    public function update(object $payload, string $doctorId, string $id): void {
        $this->authorise($payload, $doctorId);

        $row = $this->model->getById($id);
        if (!$row || $row['doctor_id'] !== $doctorId) {
            Response::notFound('Experience not found');
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

        $updateData = [];
        $map = [
            'company'        => 'company',
            'roleTitle'      => 'role_title',
            'employmentType' => 'employment_type',
            'startDate'      => 'start_date',
            'endDate'        => 'end_date',
            'description'    => 'description',
        ];
        foreach ($map as $api => $db) {
            if (array_key_exists($api, $input)) {
                $updateData[$db] = is_string($input[$api]) ? trim($input[$api]) : $input[$api];
            }
        }
        if (array_key_exists('currentlyWorking', $input)) {
            $v = $input['currentlyWorking'];
            $updateData['currently_working'] = ($v === true || $v === 'true' || $v === 1) ? 1 : 0;
        }

        if (empty($updateData)) {
            Response::error('No valid fields provided', 400, 'EMPTY_UPDATE');
            return;
        }

        try {
            $this->model->update($id, $updateData);
        } catch (\Throwable $e) {
            error_log('Update experience error: ' . $e->getMessage());
            Response::error('Failed to update experience', 500, 'SERVER_ERROR');
            return;
        }

        Response::success($this->format($this->model->getById($id)), 'Experience updated');
    }

    // ─────────────────────────────────────────────────────────
    // DELETE /api/doctors/{doctorId}/experiences/{id}
    // ─────────────────────────────────────────────────────────
    public function delete(object $payload, string $doctorId, string $id): void {
        $this->authorise($payload, $doctorId);

        $row = $this->model->getById($id);
        if (!$row || $row['doctor_id'] !== $doctorId) {
            Response::notFound('Experience not found');
            return;
        }

        try {
            $this->model->delete($id);
        } catch (\Throwable $e) {
            error_log('Delete experience error: ' . $e->getMessage());
            Response::error('Failed to delete experience', 500, 'SERVER_ERROR');
            return;
        }

        Response::success([], 'Experience deleted');
    }

    // ─────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────

    private function authorise(object $payload, string $doctorId): void {
        $role   = $payload->userType ?? $payload->role ?? '';
        $userId = $payload->userId   ?? $payload->user_id ?? '';
        if ($role !== 'admin' && $userId !== $doctorId) {
            Response::forbidden('You do not have permission to manage these experiences');
        }
    }

    private function format(array $row): array {
        return [
            'id'               => $row['id'],
            'doctorId'         => $row['doctor_id'],
            'company'          => $row['company'],
            'roleTitle'        => $row['role_title'],
            'employmentType'   => $row['employment_type'],
            'currentlyWorking' => (bool)$row['currently_working'],
            'startDate'        => $row['start_date'],
            'endDate'          => $row['end_date'],
            'description'      => $row['description'],
            'createdAt'        => $row['created_at'],
            'updatedAt'        => $row['updated_at'],
        ];
    }
}
