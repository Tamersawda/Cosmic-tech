<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\FileUploadHandler;

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';
require_once __DIR__ . '/../utils/FileUploadHandler.php';

/**
 * OnboardingBasicInfoController
 * Handles Step 1: Basic Information
 * - Profile photo
 * - Full name
 * - Email
 * - Phone number
 * - Gender
 * - Date of birth
 */
class OnboardingBasicInfoController
{
    private DoctorProfile $doctorModel;
    private Onboarding $onboardingModel;
    private Validator $validator;
    private FileUploadHandler $fileUploader;

    public function __construct()
    {
        $this->doctorModel = new DoctorProfile();
        $this->onboardingModel = new Onboarding();
        $this->validator = new Validator();
        $this->fileUploader = new FileUploadHandler();
    }

    /**
     * POST /api/doctors/onboarding/basic-info
     * Save or update basic information
     */
    public function saveBasicInfo($user)
    {
        // Extract user ID from JWT token
        $userId = is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);

        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        // Parse JSON body
        $input = $this->getJsonInput();

        // Validation rules
        $rules = [
            'phoneNumber' => ['required', ['min', 10]],
            'gender' => ['required', ['in', 'male', 'female', 'other', 'prefer_not_to_say']],
            'dateOfBirth' => ['required', 'date'],
        ];

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Additional custom validations
        $phoneErrors = [];
        if (!$this->validator->validatePhoneNumber($input['phoneNumber'])) {
            $phoneErrors[] = 'phoneNumber: Invalid phone number format';
        }

        $dobErrors = $this->validator->validateDateOfBirth($input['dateOfBirth']);
        if (!empty($dobErrors)) {
            $phoneErrors[] = 'dateOfBirth: ' . implode(', ', $dobErrors);
        }

        if (!empty($phoneErrors)) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $phoneErrors);
            return;
        }

        try {
            // Handle profile photo upload if provided
            $profilePhotoUrl = null;
            if (isset($_FILES['profilePhoto']) && $_FILES['profilePhoto']['error'] === UPLOAD_ERR_OK) {
                $profilePhotoUrl = $this->fileUploader->uploadProfilePhoto($_FILES['profilePhoto'], $userId);
            }

            // Update or create doctor profile
            $profile = $this->doctorModel->findByUserId($userId);
            
            if ($profile) {
                // Update existing profile
                $data = [
                    'phone_number' => $input['phoneNumber'],
                    'gender' => $input['gender'],
                    'date_of_birth' => $input['dateOfBirth'],
                ];

                if ($profilePhotoUrl) {
                    $data['profile_photo_url'] = $profilePhotoUrl;
                }

                $this->doctorModel->update($userId, $data);
            } else {
                // Create new profile
                $data = [
                    'user_id' => $userId,
                    'phone_number' => $input['phoneNumber'],
                    'gender' => $input['gender'],
                    'date_of_birth' => $input['dateOfBirth'],
                    'profile_photo_url' => $profilePhotoUrl,
                ];

                $this->doctorModel->create($data);
            }

            // Update registration step
            $this->onboardingModel->updateRegistrationStep($userId, 1);

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_completed',
                1
            );

            Response::success([
                'message' => 'Basic information saved successfully',
                'step' => 1,
                'nextStep' => 2,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save basic information: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/basic-info
     * Retrieve saved basic information
     */
    public function getBasicInfo($user)
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
                'profilePhoto' => null,
                'phoneNumber' => null,
                'gender' => null,
                'dateOfBirth' => null,
            ]);
            return;
        }

        Response::success([
            'profilePhoto' => $profile['profile_photo_url'],
            'phoneNumber' => $profile['phone_number'],
            'gender' => $profile['gender'],
            'dateOfBirth' => $profile['date_of_birth'],
        ]);
    }

    /**
     * Helper to get JSON input
     */
    private function getJsonInput(): array
    {
        $input = json_decode(file_get_contents('php://input'), true);
        return is_array($input) ? $input : [];
    }
}
