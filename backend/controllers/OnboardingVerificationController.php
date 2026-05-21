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
 * OnboardingVerificationController
 * Handles Step 4: Professional Registration & Verification
 * - Registration number
 * - RCI registration
 * - Government ID uploads
 * - Self-declaration
 */
class OnboardingVerificationController
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
     * POST /api/doctors/onboarding/verification
     * Save professional registration and verification details
     */
    public function saveVerification($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Normalize field aliases - support both canonical and legacy names
        // Canonical: rciCrrNumber, selfDeclarationAccepted
        // Legacy:    rciNumber,    selfDeclarationAgreed
        if (!isset($input['rciCrrNumber']) && isset($input['rciNumber'])) {
            $input['rciCrrNumber'] = $input['rciNumber'];
        }
        if (!isset($input['selfDeclarationAccepted']) && isset($input['selfDeclarationAgreed'])) {
            $input['selfDeclarationAccepted'] = $input['selfDeclarationAgreed'];
        }

        // Validation based on Blueprint rules
        $registrationType = $input['registrationType'] ?? '';
        
        // Base validation
        $rules = [
            'registrationType' => ['required', ['in', 'rci', 'none']],
        ];

        // Blueprint Rule 1: If registrationType='rci'
        //   → rciCrrNumber (required)
        //   → rciCertificate file upload (required)
        //   → selfDeclarationAccepted (not required)
        if ($registrationType === 'rci') {
            $rules['rciCrrNumber'] = ['required', 'string'];
            // Certificate file check done after validation
        }
        // Blueprint Rule 2: If registrationType='none'
        //   → selfDeclarationAccepted=true (required)
        //   → rciCrrNumber (not required)
        //   → rciCertificate (not required)
        elseif ($registrationType === 'none') {
            $rules['selfDeclarationAccepted'] = ['required', 'boolean'];
        }

        $validation = $this->validator->validate($input, $rules);
        if (!$validation['valid']) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $validation['errors']);
            return;
        }

        // Additional Blueprint validation: RCI must have certificate upload
        if ($registrationType === 'rci') {
            if (!isset($_FILES['rciCertificate']) || $_FILES['rciCertificate']['error'] === UPLOAD_ERR_NO_FILE) {
                Response::error('Validation failed', 400, 'VALIDATION_ERROR', [
                    'rciCertificate' => 'RCI certificate upload is required when registrationType is "rci"'
                ]);
                return;
            }
        }

        try {
            $profile = $this->doctorModel->findByUserId($userId);
            
            $isRci = ($input['registrationType'] === 'rci');
            $data = [
                'registration_type'         => $input['registrationType'],
                'rci_crr_number'            => $isRci ? ($input['rciCrrNumber'] ?? null) : null,
                'self_declaration_accepted' => (int)(!empty($input['selfDeclarationAccepted'])),
            ];

            if ($profile) {
                $this->doctorModel->update($userId, $data);
            } else {
                $data['user_id'] = $userId;
                $this->doctorModel->create($data);
            }

            // Handle RCI certificate upload if provided
            if ($input['registrationType'] === 'rci' && isset($_FILES['rciCertificate']) && $_FILES['rciCertificate']['error'] === UPLOAD_ERR_OK) {
                try {
                    $certificateUrl = $this->fileUploader->uploadRegistrationCertificate(
                        $_FILES['rciCertificate'],
                        $userId
                    );

                    // Update profile
                    $this->doctorModel->update($userId, ['rci_certificate_url' => $certificateUrl]);

                    // Create document record
                    $this->documentModel->create([
                        'doctor_id' => $userId,
                        'document_type' => 'rci_certificate',
                        'file_url' => $certificateUrl,
                        'file_name' => $_FILES['rciCertificate']['name'],
                        'file_size' => $_FILES['rciCertificate']['size'],
                        'mime_type' => $_FILES['rciCertificate']['type'],
                    ]);
                } catch (\Exception $e) {
                    Response::error('Failed to upload RCI certificate: ' . $e->getMessage(), 400);
                    return;
                }
            }

            // Update registration step
            $this->onboardingModel->updateRegistrationStep($userId, 4);

            // Log action
            $this->onboardingModel->logVerificationAction(
                $userId,
                'step_completed',
                4
            );

            Response::success([
                'message' => 'Verification details saved successfully',
                'step' => 4,
                'nextStep' => 5,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save verification details: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/doctors/onboarding/verification
     * Retrieve saved verification details
     */
    public function getVerification($user)
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $profile = $this->doctorModel->findByUserId($userId);

        if (!$profile) {
            Response::success([
                'registrationType'         => 'none',
                'rciCrrNumber'             => null,
                'rciCertificateUrl'        => null,
                'selfDeclarationAccepted'  => false,
            ]);
            return;
        }

        // Return canonical field names (and legacy aliases for backward compatibility)
        $rciNum = $profile['rci_crr_number'] ?? null;
        Response::success([
            'registrationType'         => $profile['registration_type'] ?? 'none',
            'rciCrrNumber'             => $rciNum,
            'rciNumber'                => $rciNum,          // Legacy alias
            'rciCertificateUrl'        => $profile['rci_certificate_url'] ?? null,
            'selfDeclarationAccepted'  => (bool)($profile['self_declaration_accepted'] ?? false),
            'selfDeclarationAgreed'    => (bool)($profile['self_declaration_accepted'] ?? false),  // Legacy alias
        ]);
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
}
