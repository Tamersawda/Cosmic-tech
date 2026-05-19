<?php

namespace Backend\Controllers;

use Backend\Models\DoctorExperience;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\FileUploadHandler;

require_once __DIR__ . '/../models/DoctorExperience.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/FileUploadHandler.php';

/**
 * OnboardingExperiencesController
 * Handles Step 5: Work Experience CRUD
 * - Add experience
 * - List experiences
 * - Update experience
 * - Delete experience
 * - Upload experience proof
 */
class OnboardingExperiencesController
{
    private DoctorExperience $experienceModel;
    private Onboarding $onboardingModel;
    private Validator $validator;
    private FileUploadHandler $fileUploader;

    public function __construct()
    {
        $this->experienceModel = new DoctorExperience();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
        $this->fileUploader = new FileUploadHandler();
    }

    /**
     * POST /api/doctors/onboarding/experiences
     * Add a new work experience entry
     */
    public function addExperience($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Validation
        $rules = [
            'organization' => ['required', 'string'],
            'role' => ['required', 'string'],
            'workType' => ['required', ['in', 'hospital', 'private_practice', 'ngo', 'online_platform', 'other']],
            'startDate' => ['required', 'date'],
            'endDate' => ['nullable', 'date'],
            'currentlyWorking' => ['required', 'boolean'],
            'description' => ['nullable', 'string'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // If not currently working, endDate is required
        if (!$input['currentlyWorking'] && !isset($input['endDate'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'endDate' => 'End date is required when not currently working'
            ]);
            return;
        }

        // Validate dates
        $startDate = strtotime($input['startDate']);
        $endDate = $input['endDate'] ? strtotime($input['endDate']) : null;

        if ($endDate && $endDate < $startDate) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'endDate' => 'End date must be after start date'
            ]);
            return;
        }

        if ($startDate > time()) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'startDate' => 'Start date cannot be in the future'
            ]);
            return;
        }

        try {
            $proofUrl = null;

            // Handle proof document upload if provided
            if (isset($_FILES['proofDocument']) && $_FILES['proofDocument']['error'] === UPLOAD_ERR_OK) {
                try {
                    $proofUrl = $this->fileUploader->uploadExperienceProof(
                        $_FILES['proofDocument'],
                        $userId
                    );
                } catch (\Exception $e) {
                    Response::error('Failed to upload proof document: ' . $e->getMessage(), 400);
                    return;
                }
            }

            // Create experience record
            $experienceData = [
                'doctor_id' => $userId,
                'company' => $input['organization'],
                'role_title' => $input['role'],
                'work_type' => $input['workType'],
                'custom_work_type' => $input['customWorkType'] ?? null,
                'start_date' => $input['startDate'],
                'end_date' => $input['endDate'] ?? null,
                'currently_working' => $input['currentlyWorking'] ? 1 : 0,
                'description' => $input['description'] ?? null,
                'proof_document_url' => $proofUrl,
                'employment_type' => $input['workType'],  // Legacy field
            ];

            $expId = $this->experienceModel->create($experienceData);

            if (!$expId) {
                Response::error('Failed to create experience', 500);
                return;
            }

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_started',
                5
            );

            Response::success([
                'id' => $expId,
                'message' => 'Experience added successfully',
            ], 201);

        } catch (\Exception $e) {
            Response::error('Failed to add experience: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/experiences
     * List all work experiences
     */
    public function listExperiences($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $experiences = $this->experienceModel->findByDoctor($userId);

        // Transform to frontend format
        $formatted = array_map(function($exp) {
            return [
                'id' => $exp['id'],
                'organization' => $exp['company'],
                'role' => $exp['role_title'],
                'workType' => $exp['work_type'],
                'customWorkType' => $exp['custom_work_type'],
                'startDate' => $exp['start_date'],
                'endDate' => $exp['end_date'],
                'currentlyWorking' => (bool)$exp['currently_working'],
                'description' => $exp['description'],
                'proofDocumentUrl' => $exp['proof_document_url'],
                'verificationStatus' => $exp['verification_status'] ?? 'pending',
                'createdAt' => $exp['created_at'],
            ];
        }, $experiences);

        Response::success([
            'count' => count($formatted),
            'experiences' => $formatted,
        ]);
    }

    /**
     * PUT /api/doctors/onboarding/experiences/{id}
     * Update experience entry
     */
    public function updateExperience($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $id = $this->getIdFromUrl();
        if (!$id) {
            Response::error('Experience ID is required', 400);
            return;
        }

        $input = $this->getJsonInput();

        // Verify ownership
        $experience = $this->experienceModel->findById($id);
        if (!$experience || $experience['doctor_id'] !== $userId) {
            Response::error('Experience not found', 404);
            return;
        }

        try {
            $updateData = [];

            if (isset($input['organization'])) $updateData['company'] = $input['organization'];
            if (isset($input['role'])) $updateData['role_title'] = $input['role'];
            if (isset($input['workType'])) $updateData['work_type'] = $input['workType'];
            if (isset($input['customWorkType'])) $updateData['custom_work_type'] = $input['customWorkType'];
            if (isset($input['startDate'])) $updateData['start_date'] = $input['startDate'];
            if (isset($input['endDate'])) $updateData['end_date'] = $input['endDate'];
            if (isset($input['currentlyWorking'])) $updateData['currently_working'] = $input['currentlyWorking'] ? 1 : 0;
            if (isset($input['description'])) $updateData['description'] = $input['description'];

            if (!empty($updateData)) {
                $this->experienceModel->update($id, $updateData);
            }

            Response::success([
                'message' => 'Experience updated successfully',
                'id' => $id,
            ]);

        } catch (\Exception $e) {
            Response::error('Failed to update experience: ' . $e->getMessage(), 500);
        }
    }

    /**
     * DELETE /api/doctors/onboarding/experiences/{id}
     * Delete experience entry
     */
    public function deleteExperience($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $id = $this->getIdFromUrl();
        if (!$id) {
            Response::error('Experience ID is required', 400);
            return;
        }

        // Verify ownership
        $experience = $this->experienceModel->findById($id);
        if (!$experience || $experience['doctor_id'] !== $userId) {
            Response::error('Experience not found', 404);
            return;
        }

        try {
            $this->experienceModel->delete($id);

            Response::success([
                'message' => 'Experience deleted successfully',
                'id' => $id,
            ]);

        } catch (\Exception $e) {
            Response::error('Failed to delete experience: ' . $e->getMessage(), 500);
        }
    }

    private function extractUserId($user): ?string
    {
        return is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);
    }

    private function getJsonInput(): array
    {
        $input = json_decode(file_get_contents('php://input'), true);
        return is_array($input) ? $input : [];
    }

    private function getIdFromUrl(): ?string
    {
        $pathInfo = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $parts = explode('/', trim($pathInfo, '/'));
        return end($parts) ?: null;
    }
}
