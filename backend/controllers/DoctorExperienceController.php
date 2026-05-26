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

        $result = $this->validator->validate($input, [
            'organization'   => ['required', 'string'],
            'role'           => ['required', 'string'],
            'workType'       => ['required', ['in', 'hospital', 'private_practice', 'ngo', 'online_platform', 'other']],
            'startDate'      => ['required', 'date'],
            'endDate'        => ['nullable', 'date'],
            'yearsOfExperience' => ['nullable', 'numeric'],
        ]);
        if (!$result['valid']) {
            Response::validation($result['errors']);
            return;
        }

        try {
            $id = $this->model->create([
                'doctor_id'         => $doctorId,
                'organization'      => trim($input['organization']),
                'role'              => trim($input['role']),
                'work_type'         => $input['workType'],
                'custom_work_type'  => $input['customWorkType'] ?? null,
                'start_date'        => $input['startDate'],
                'end_date'          => $input['endDate'] ?? null,
                'experience_proof'  => $input['experienceProof'] ?? null,
                'years_of_experience' => isset($input['yearsOfExperience']) ? (int)$input['yearsOfExperience'] : null,
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
            'organization'   => 'organization',
            'role'           => 'role',
            'workType'       => 'work_type',
            'customWorkType' => 'custom_work_type',
            'startDate'      => 'start_date',
            'endDate'        => 'end_date',
            'experienceProof'=> 'experience_proof',
        ];
        foreach ($map as $api => $db) {
            if (array_key_exists($api, $input)) {
                $updateData[$db] = is_string($input[$api]) ? trim($input[$api]) : $input[$api];
            }
        }
        if (array_key_exists('yearsOfExperience', $input)) {
            $updateData['years_of_experience'] = (int)$input['yearsOfExperience'];
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
            'organization'     => $row['organization'],
            'role'             => $row['role'],
            'workType'         => $row['work_type'],
            'customWorkType'   => $row['custom_work_type'],
            'startDate'        => $row['start_date'],
            'endDate'          => $row['end_date'],
            'yearsOfExperience'=> $row['years_of_experience'],
            'experienceProof'  => $row['experience_proof'],
            'createdAt'        => $row['created_at'],
            'updatedAt'        => $row['updated_at'],
        ];
    }
}
