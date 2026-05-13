<?php

namespace Backend\Controllers;

use Backend\Models\DoctorQualification;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\FileUploadHandler;
use Backend\Config\Database;
use PDO;

/**
 * DoctorQualificationController
 *
 * POST   /api/doctors/{doctorId}/qualifications           – create
 * GET    /api/doctors/{doctorId}/qualifications           – list
 * GET    /api/doctors/{doctorId}/qualifications/{id}      – get one
 * PUT    /api/doctors/{doctorId}/qualifications/{id}      – update metadata
 * DELETE /api/doctors/{doctorId}/qualifications/{id}      – delete
 */
class DoctorQualificationController {
    private DoctorQualification $model;
    private Validator           $validator;
    private FileUploadHandler   $fileHandler;
    private PDO                 $db;

    public function __construct() {
        $this->model       = new DoctorQualification();
        $this->validator   = new Validator();
        $this->fileHandler = new FileUploadHandler();
        $this->db          = Database::getInstance();
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/doctors/{doctorId}/qualifications
    // ─────────────────────────────────────────────────────────
    public function create(object $payload, string $doctorId): void {
        $this->authorise($payload, $doctorId);

        $input = $_POST; // multipart/form-data

        $result = $this->validator->validate($input, [
            'title'       => ['required', 'string'],
            'degree'      => ['string'],
            'institution' => ['string'],
            'year'        => ['numeric'],
        ]);
        if (!$result['valid']) {
            Response::validation($result['errors']);
            return;
        }

        // ── File upload (optional) ──
        $documentPath = null;
        $fileProvided = isset($_FILES['document']) && $_FILES['document']['error'] !== UPLOAD_ERR_NO_FILE;

        if ($fileProvided) {
            try {
                $documentPath = $this->fileHandler->uploadQualificationDocument($_FILES['document'], $doctorId);
            } catch (\RuntimeException $e) {
                Response::error($e->getMessage(), 400, 'UPLOAD_ERROR');
                return;
            }
        }

        // ── Atomic DB write + file (roll back file on DB failure) ──
        try {
            $this->db->beginTransaction();

            $id = $this->model->create([
                'doctor_id'    => $doctorId,
                'title'        => trim($input['title']),
                'degree'       => trim($input['degree'] ?? ''),
                'institution'  => trim($input['institution'] ?? ''),
                'year'         => isset($input['year']) ? (int)$input['year'] : null,
                'document_path'=> $documentPath,
            ]);

            $this->db->commit();
        } catch (\Throwable $e) {
            $this->db->rollBack();
            // Clean up uploaded file to avoid orphans
            if ($documentPath) $this->fileHandler->deleteFile($documentPath);
            error_log('Create qualification error: ' . $e->getMessage());
            Response::error('Failed to save qualification', 500, 'SERVER_ERROR');
            return;
        }

        $qual = $this->model->getById($id);
        Response::success($this->format($qual), 'Qualification created successfully', 201);
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/doctors/{doctorId}/qualifications
    // ─────────────────────────────────────────────────────────
    public function list(string $doctorId): void {
        $quals = $this->model->getByDoctorId($doctorId);
        Response::success(array_map([$this, 'format'], $quals), 'Qualifications retrieved');
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/doctors/{doctorId}/qualifications/{id}
    // ─────────────────────────────────────────────────────────
    public function getOne(string $doctorId, string $id): void {
        $qual = $this->model->getById($id);
        if (!$qual || $qual['doctor_id'] !== $doctorId) {
            Response::notFound('Qualification not found');
            return;
        }
        Response::success($this->format($qual));
    }

    // ─────────────────────────────────────────────────────────
    // PUT /api/doctors/{doctorId}/qualifications/{id}
    // ─────────────────────────────────────────────────────────
    public function update(object $payload, string $doctorId, string $id): void {
        $this->authorise($payload, $doctorId);

        $qual = $this->model->getById($id);
        if (!$qual || $qual['doctor_id'] !== $doctorId) {
            Response::notFound('Qualification not found');
            return;
        }

        $body = json_decode(file_get_contents('php://input'), true) ?? $_POST;

        $updateData = [];
        foreach (['title', 'degree', 'institution'] as $f) {
            if (isset($body[$f])) $updateData[$f] = trim($body[$f]);
        }
        if (isset($body['year'])) $updateData['year'] = (int)$body['year'];

        if (empty($updateData)) {
            Response::error('No valid fields to update', 400, 'EMPTY_UPDATE');
            return;
        }

        try {
            $this->model->update($id, $updateData);
        } catch (\Throwable $e) {
            error_log('Update qualification error: ' . $e->getMessage());
            Response::error('Failed to update qualification', 500, 'SERVER_ERROR');
            return;
        }

        Response::success($this->format($this->model->getById($id)), 'Qualification updated');
    }

    // ─────────────────────────────────────────────────────────
    // DELETE /api/doctors/{doctorId}/qualifications/{id}
    // ─────────────────────────────────────────────────────────
    public function delete(object $payload, string $doctorId, string $id): void {
        $this->authorise($payload, $doctorId);

        $qual = $this->model->getById($id);
        if (!$qual || $qual['doctor_id'] !== $doctorId) {
            Response::notFound('Qualification not found');
            return;
        }

        try {
            $this->db->beginTransaction();
            $this->model->delete($id);
            $this->db->commit();

            // Delete file AFTER successful DB delete
            if (!empty($qual['document_path'])) {
                $this->fileHandler->deleteFile($qual['document_path']);
            }
        } catch (\Throwable $e) {
            $this->db->rollBack();
            error_log('Delete qualification error: ' . $e->getMessage());
            Response::error('Failed to delete qualification', 500, 'SERVER_ERROR');
            return;
        }

        Response::success([], 'Qualification deleted');
    }

    // ─────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────

    private function authorise(object $payload, string $doctorId): void {
        $role   = $payload->userType ?? $payload->role ?? '';
        $userId = $payload->userId   ?? $payload->user_id ?? '';

        if ($role !== 'admin' && $userId !== $doctorId) {
            Response::forbidden('You do not have permission to manage these qualifications');
        }
    }

    /** Normalise a DB row to camelCase for the API response. */
    private function format(array $row): array {
        return [
            'id'           => $row['id'],
            'doctorId'     => $row['doctor_id'],
            'title'        => $row['title'],
            'degree'       => $row['degree'] ?? null,
            'institution'  => $row['institution'] ?? null,
            'year'         => $row['year'] !== null ? (int)$row['year'] : null,
            'documentPath' => $row['document_path'] ?? null,
            'documentUrl'  => FileUploadHandler::publicUrl($row['document_path'] ?? ''),
            'createdAt'    => $row['created_at'] ?? null,
            'updatedAt'    => $row['updated_at'] ?? null,
        ];
    }
}
