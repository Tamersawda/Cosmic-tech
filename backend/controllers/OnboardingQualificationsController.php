<?php

namespace Backend\Controllers;

use Backend\Models\DoctorQualification;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\FileUploadHandler;

require_once __DIR__ . '/../models/DoctorQualification.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/FileUploadHandler.php';

/**
 * OnboardingQualificationsController
 * Handles Step 3: Qualifications CRUD
 * - Add qualification
 * - List qualifications
 * - Update qualification
 * - Delete qualification
 * - Upload certificates
 */
class OnboardingQualificationsController
{
    private DoctorQualification $qualificationModel;
    private Onboarding $onboardingModel;
    private Validator $validator;
    private FileUploadHandler $fileUploader;

    public function __construct()
    {
        $this->qualificationModel = new DoctorQualification();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
        $this->fileUploader = new FileUploadHandler();
    }

    /**
     * POST /api/doctors/onboarding/qualifications
     * Add a new qualification with certificate upload
     */
    public function addQualification($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Blueprint validation: requires degree (qualification_name), institution, passing_year
        // Accepts backward compatibility: 'degree' (canonical: 'qualification_name')
        $rules = [
            'degree' => ['required', 'string'],              // Alias for qualification_name
            'institution' => ['required', 'string'],         // NEW: Blueprint requirement
            'specialization' => ['nullable', 'string'],
            'passingYear' => ['required', 'numeric'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Validate passing year
        $year = (int)$input['passingYear'];
        $currentYear = (int)date('Y');
        if ($year < 1950 || $year > $currentYear) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'passingYear' => 'Passing year must be between 1950 and ' . $currentYear
            ]);
            return;
        }

        try {
            $certificateUrl = null;

            // Handle certificate upload if provided
            if (isset($_FILES['certificate']) && $_FILES['certificate']['error'] === UPLOAD_ERR_OK) {
                try {
                    $certificateUrl = $this->fileUploader->uploadQualificationDocument(
                        $_FILES['certificate'],
                        $userId
                    );
                } catch (\Exception $e) {
                    Response::error('Failed to upload certificate: ' . $e->getMessage(), 400);
                    return;
                }
            }

            // Create qualification record
            $qualificationData = [
                'doctor_id' => $userId,
                'qualification_name' => $input['degree'],
                'institution' => $input['institution'],  // NEW: Blueprint requirement
                'specialization' => $input['specialization'] ?? null,
                'passing_year' => $year,
                'certificate_url' => $certificateUrl,
                'verification_status' => 'pending',
            ];

            $qualId = $this->qualificationModel->create($qualificationData);

            if (!$qualId) {
                Response::error('Failed to create qualification', 500);
                return;
            }

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_started',
                3
            );

            Response::success([
                'id' => $qualId,
                'message' => 'Qualification added successfully',
            ], 201);

        } catch (\Exception $e) {
            Response::error('Failed to add qualification: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/qualifications
     * List all qualifications for the authenticated doctor
     */
    public function listQualifications($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $qualifications = $this->qualificationModel->findByDoctor($userId);

        // Transform to Blueprint format (canonical fields only)
        $formatted = array_map(function($qual) {
            return [
                'id' => $qual['id'],
                'qualificationName' => $qual['qualification_name'],
                'institution' => $qual['institution'],  // NEW: Blueprint field
                'specialization' => $qual['specialization'],
                'passingYear' => $qual['passing_year'],
                'certificateUrl' => $qual['certificate_url'],
                'verificationStatus' => $qual['verification_status'] ?? 'pending',
            ];
        }, $qualifications);

        Response::success([
            'count' => count($formatted),
            'qualifications' => $formatted,
        ]);
    }

    /**
     * PUT /api/doctors/onboarding/qualifications/{id}
     * Update qualification
     */
    public function updateQualification($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        // Get ID from URL parameter
        $pathInfo = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $parts = explode('/', trim($pathInfo, '/'));
        $id = end($parts);

        if (!$id) {
            Response::error('Qualification ID is required', 400);
            return;
        }

        $input = $this->getJsonInput();

        // Get existing qualification to verify ownership
        $qualification = $this->qualificationModel->findById($id);
        if (!$qualification || $qualification['doctor_id'] !== $userId) {
            Response::error('Qualification not found', 404);
            return;
        }

        try {
            $updateData = [];

            if (isset($input['degree'])) {
                $updateData['qualification_name'] = $input['degree'];
            }
            if (isset($input['specialization'])) {
                $updateData['specialization'] = $input['specialization'];
            }
            if (isset($input['passingYear'])) {
                $year = (int)$input['passingYear'];
                if ($year < 1950 || $year > date('Y')) {
                    Response::error('Invalid passing year', 400);
                    return;
                }
                $updateData['passing_year'] = $year;
            }

            if (!empty($updateData)) {
                $this->qualificationModel->update($id, $updateData);
            }

            Response::success([
                'message' => 'Qualification updated successfully',
                'id' => $id,
            ]);

        } catch (\Exception $e) {
            Response::error('Failed to update qualification: ' . $e->getMessage(), 500);
        }
    }

    /**
     * DELETE /api/doctors/onboarding/qualifications/{id}
     * Delete qualification
     */
    public function deleteQualification($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        // Get ID from URL parameter
        $pathInfo = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $parts = explode('/', trim($pathInfo, '/'));
        $id = end($parts);

        if (!$id) {
            Response::error('Qualification ID is required', 400);
            return;
        }

        // Verify ownership
        $qualification = $this->qualificationModel->findById($id);
        if (!$qualification || $qualification['doctor_id'] !== $userId) {
            Response::error('Qualification not found', 404);
            return;
        }

        try {
            $this->qualificationModel->delete($id);

            Response::success([
                'message' => 'Qualification deleted successfully',
                'id' => $id,
            ]);

        } catch (\Exception $e) {
            Response::error('Failed to delete qualification: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Helper methods
     */
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
}
