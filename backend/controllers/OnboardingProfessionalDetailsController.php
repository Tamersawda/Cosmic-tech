<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Models\DoctorDocument;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\FileUploadHandler;

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../models/DoctorDocument.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/FileUploadHandler.php';

/**
 * OnboardingProfessionalDetailsController
 * Handles Step 2: Professional Details
 * - Primary title
 * - Secondary title
 * - Specializations (hierarchical)
 * - Therapy approaches
 * - Languages
 * - Professional bio
 * - Government ID uploads (front & back)
 */
class OnboardingProfessionalDetailsController
{
    private DoctorProfile $doctorModel;
    private DoctorDocument $documentModel;
    private Onboarding $onboardingModel;
    private Validator $validator;
    private FileUploadHandler $fileUploader;

    public function __construct()
    {
        $this->doctorModel = new DoctorProfile();
        $this->documentModel = new DoctorDocument();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
        $this->fileUploader = new FileUploadHandler();
    }

    /**
     * POST /api/doctors/onboarding/professional-details
     * Save professional details and government ID
     */
    public function saveProfessionalDetails($user)
    {
        $userId = is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);

        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Normalize field aliases
        // Frontend (canonical): languagesSpoken | Legacy: languages
        if (!isset($input['languages']) && isset($input['languagesSpoken'])) {
            $input['languages'] = $input['languagesSpoken'];
        }

        // Validation
        $rules = [
            'primaryTitle' => ['required', 'string'],
            'secondaryTitle' => ['nullable', 'string'],
            'specializations' => ['required', 'array'],
            'therapyApproaches' => ['required', 'array'],
            'languages' => ['required', 'array'],
            'bio' => ['nullable', 'string'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Validate bio length
        if (isset($input['bio']) && !$this->validator->validateBioLength($input['bio'])) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                'bio' => 'Bio must be 600 characters or less'
            ]);
            return;
        }

        try {
            $profile = $this->doctorModel->findByUserId($userId);
            
            $data = [
                'primary_title' => $input['primaryTitle'],
                'secondary_title' => $input['secondaryTitle'] ?? null,
                'sub_specializations' => json_encode($input['specializations']),
                'therapy_approaches' => json_encode($input['therapyApproaches']),
                'languages_spoken' => json_encode($input['languages']),
                'professional_bio' => $input['bio'] ?? null,
            ];

            if ($profile) {
                $this->doctorModel->update($userId, $data);
            } else {
                $data['user_id'] = $userId;
                $this->doctorModel->create($data);
            }

            // Handle government ID uploads if provided
            $govtIdFrontUrl = null;
            $govtIdBackUrl = null;

            if (isset($_FILES['govtIdFront']) && $_FILES['govtIdFront']['error'] === UPLOAD_ERR_OK) {
                try {
                    $govtIdFrontUrl = $this->fileUploader->uploadGovernmentID(
                        $_FILES['govtIdFront'],
                        $userId,
                        'front'
                    );

                    // Update profile with govt ID URL
                    $this->doctorModel->update($userId, ['govt_id_front_url' => $govtIdFrontUrl]);

                    // Create document record
                    $this->documentModel->create([
                        'doctor_id' => $userId,
                        'document_type' => 'govt_id_front',
                        'file_url' => $govtIdFrontUrl,
                        'file_name' => $_FILES['govtIdFront']['name'],
                        'file_size' => $_FILES['govtIdFront']['size'],
                        'mime_type' => $_FILES['govtIdFront']['type'],
                    ]);
                } catch (\Exception $e) {
                    Response::error('Failed to upload government ID (front): ' . $e->getMessage(), 400);
                    return;
                }
            }

            if (isset($_FILES['govtIdBack']) && $_FILES['govtIdBack']['error'] === UPLOAD_ERR_OK) {
                try {
                    $govtIdBackUrl = $this->fileUploader->uploadGovernmentID(
                        $_FILES['govtIdBack'],
                        $userId,
                        'back'
                    );

                    // Update profile with govt ID URL
                    $this->doctorModel->update($userId, ['govt_id_back_url' => $govtIdBackUrl]);

                    // Create document record
                    $this->documentModel->create([
                        'doctor_id' => $userId,
                        'document_type' => 'govt_id_back',
                        'file_url' => $govtIdBackUrl,
                        'file_name' => $_FILES['govtIdBack']['name'],
                        'file_size' => $_FILES['govtIdBack']['size'],
                        'mime_type' => $_FILES['govtIdBack']['type'],
                    ]);
                } catch (\Exception $e) {
                    Response::error('Failed to upload government ID (back): ' . $e->getMessage(), 400);
                    return;
                }
            }

            // Update registration step
            $this->onboardingModel->updateRegistrationStep($userId, 2);

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_completed',
                2
            );

            Response::success([
                'message' => 'Professional details saved successfully',
                'step' => 2,
                'nextStep' => 3,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save professional details: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/professional-details
     * Retrieve saved professional details
     */
    public function getProfessionalDetails($user)
    {
        $userId = is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);

        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $profile = $this->doctorModel->findByUserId($userId);

        if (!$profile) {
            Response::success([
                'primaryTitle' => null,
                'secondaryTitle' => null,
                'specializations' => [],
                'therapyApproaches' => [],
                'languages' => [],
                'bio' => null,
                'govtIdFront' => null,
                'govtIdBack' => null,
            ]);
            return;
        }

        Response::success([
            'primaryTitle' => $profile['primary_title'],
            'secondaryTitle' => $profile['secondary_title'],
            'specializations' => $profile['sub_specializations'] ? json_decode($profile['sub_specializations'], true) : [],
            'therapyApproaches' => $profile['therapy_approaches'] ? json_decode($profile['therapy_approaches'], true) : [],
            'languages' => $profile['languages_spoken'] ? json_decode($profile['languages_spoken'], true) : [],
            'bio' => $profile['professional_bio'],
            'govtIdFront' => $profile['govt_id_front_url'],
            'govtIdBack' => $profile['govt_id_back_url'],
        ]);
    }

    private function getJsonInput(): array
    {
        $input = json_decode(file_get_contents('php://input'), true);
        return is_array($input) ? $input : [];
    }
}
