<?php

namespace Backend\Controllers;

use Backend\Models\DoctorProfile;
use Backend\Utils\Response;
use Backend\Utils\Validator;

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';

class DoctorProfileController
{
    private $doctorModel;
    private $validator;

    public function __construct($db = null)
    {
        $this->doctorModel = new DoctorProfile();
        $this->validator = new Validator();
    }

    public function setup($user)
    {
        // Use $_POST for multipart/form-data
        $input = $_POST;

        // ✅ Normalize input (since multipart/form-data sends everything as string)
        foreach (['videoEnabled', 'audioEnabled'] as $boolField) {
            if (isset($input[$boolField])) {
                $val = strtolower((string)$input[$boolField]);
                $input[$boolField] = ($val === 'true' || $val === '1');
            }
        }

        foreach (['languagesSpoken', 'subSpecializations'] as $arrayField) {
            if (isset($input[$arrayField]) && is_string($input[$arrayField])) {
                $decoded = json_decode($input[$arrayField], true);
                if (is_array($decoded)) {
                    $input[$arrayField] = $decoded;
                }
            }
        }

        // ✅ File Validation (profilePhoto)
        if (!isset($_FILES['profilePhoto']) || $_FILES['profilePhoto']['error'] !== UPLOAD_ERR_OK) {
            Response::error("Profile photo is required and must be valid", 400);
            return;
        }

        $file = $_FILES['profilePhoto'];
        
        // Harden MIME type validation
        $finfo = new \finfo(FILEINFO_MIME_TYPE);
        $mimeType = $finfo->file($file['tmp_name']);
        $allowedTypes = ['image/jpeg', 'image/png'];
        
        if (!in_array($mimeType, $allowedTypes)) {
            Response::error("Invalid file type. Only JPG, JPEG, and PNG are allowed.", 400);
            return;
        }

        if ($file['size'] > 2 * 1024 * 1024) {
            Response::error("File size exceeds 2MB limit.", 400);
            return;
        }

        // 🔐 Use authenticated user_id
        $userId = $user['id'];

        // Prepare storage path - ensure it's absolute and safe
        $uploadDir = dirname(__DIR__, 1) . '/public/uploads/doctors/';
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                Response::error("Server storage error", 500);
                return;
            }
        }

        // Sanitized filename (completely server-controlled)
        $filename = "doctor_" . preg_replace('/[^a-zA-Z0-9_\-]/', '', $userId) . ".jpg";
        $targetPath = $uploadDir . $filename;

        // move_uploaded_file safely overwrites existing files for the same user, preventing orphans
        if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
            Response::error("Failed to save profile photo", 500);
            return;
        }

        // Stored path matches the public accessibility pattern
        $profilePhotoUrl = "uploads/doctors/" . $filename;

        // 🔥 Block forbidden fields
        $forbidden = ['fullName', 'firstName', 'lastName', 'age', 'medicalHistory'];
        foreach ($forbidden as $field) {
            if (isset($input[$field])) {
                Response::error("Field '$field' is not allowed in profile setup", 400);
                return;
            }
        }

        // ✅ Validation rules
        $validation = $this->validator->validate($input, [
            'gender'               => ['required', ['in', 'male', 'female', 'other']],
            'dateOfBirth'          => ['required', 'string'],
            'phoneNumber'          => ['required', 'string'],
            'primarySpecialty'     => ['required', 'string'],
            'yearsOfExperience'    => ['required', 'numeric'],
            'licenseNumber'        => ['required', 'string'],
            'languagesSpoken'      => ['required', 'array'],
            'videoEnabled'         => ['required', 'boolean'],
            'videoRate'            => ['required', 'numeric'],
            'audioEnabled'         => ['boolean'],
            'audioRate'            => ['numeric'],
            'consultationDuration' => ['required', ['in', '30min', '45min', '60min']],
            'bufferTime'           => ['required', ['in', '5min', '10min', '15min', '30min']],
            'streetAddress'        => ['string'],
            'city'                 => ['string'],
            'state'                => ['string'],
            'country'              => ['string'],
            'postalCode'           => ['string'],
            'subSpecializations'   => ['array']
        ]);

        if (!$validation['valid']) {
            Response::error("Validation failed", 400, $validation['errors']);
            return;
        }

        // ✅ 📦 Prepare data
        $data = [
            'user_id'              => $userId,
            'gender'               => $input['gender'],
            'dateOfBirth'          => $input['dateOfBirth'],
            'phoneNumber'          => $input['phoneNumber'],
            'profilePhotoUrl'      => $profilePhotoUrl, // Fixed mapping for setupProfile
            'primarySpecialty'     => $input['primarySpecialty'],
            'subSpecializations'   => $input['subSpecializations'] ?? [],
            'yearsOfExperience'    => $input['yearsOfExperience'],
            'licenseNumber'        => $input['licenseNumber'],
            'languagesSpoken'      => $input['languagesSpoken'],
            'videoEnabled'         => $input['videoEnabled'],
            'videoRate'            => $input['videoRate'],
            'audioEnabled'         => $input['audioEnabled'] ?? false,
            'audioRate'            => $input['audioRate'] ?? null,
            'consultationDuration' => $input['consultationDuration'],
            'bufferTime'           => $input['bufferTime'],
            'streetAddress'        => $input['streetAddress'] ?? null,
            'city'                 => $input['city'] ?? null,
            'state'                => $input['state'] ?? null,
            'country'              => $input['country'] ?? null,
            'postalCode'           => $input['postalCode'] ?? null
        ];

        // ❗ Upsert logic: Update if exists, Create if not (though registration should have created it)
        if ($this->doctorModel->exists($userId)) {
            $success = $this->doctorModel->setupProfile($userId, $data);
        } else {
            // Map keys back for create method (snake_case)
            $createData = [
                'user_id'             => $userId,
                'gender'              => $data['gender'],
                'date_of_birth'       => $data['dateOfBirth'],
                'phone_number'        => $data['phoneNumber'],
                'profile_photo_url'   => $profilePhotoUrl,
                'primary_specialty'   => $data['primarySpecialty'],
                'sub_specializations' => json_encode($data['subSpecializations']),
                'years_of_experience' => $data['yearsOfExperience'],
                'license_number'      => $data['licenseNumber'],
                'languages_spoken'    => json_encode($data['languagesSpoken']),
                'video_enabled'       => $data['videoEnabled'],
                'video_rate'          => $data['videoRate'],
                'audio_enabled'       => $data['audioEnabled'],
                'audio_rate'          => $data['audioRate'],
                'consultation_duration'=> $data['consultationDuration'],
                'buffer_time'         => $data['bufferTime'],
                'street_address'      => $data['streetAddress'],
                'city'                => $data['city'],
                'state'               => $data['state'],
                'country'             => $data['country'],
                'postal_code'         => $data['postalCode']
            ];
            $success = $this->doctorModel->create($createData);
        }

        if (!$success) {
            Response::error("Failed to save doctor profile", 500);
            return;
        }

        Response::success([
            'message' => "Doctor profile created successfully",
            'profile_photo_url' => $profilePhotoUrl
        ], 201);
    }

    public function getByUserId($user)
    {
        $userId = $user->id ?? $user->userId ?? $user['id'] ?? null;

        if (!$userId) {
            Response::error("User ID not found in payload", 400);
            return;
        }

        $profile = $this->doctorModel->findByUserId($userId);

        if (!$profile) {
            Response::error("Doctor profile not found", 404);
            return;
        }

        // ✅ Default Image handling
        if (empty($profile['profile_photo_url'])) {
            $profile['profilePhotoUrl'] = "uploads/doctors/default-doctor.png";
        } else {
            $profile['profilePhotoUrl'] = $profile['profile_photo_url'];
        }

        // Decode JSON fields
        $profile['languagesSpoken'] = is_string($profile['languages_spoken']) ? json_decode($profile['languages_spoken'], true) : [];
        $profile['subSpecializations'] = is_string($profile['sub_specializations']) ? json_decode($profile['sub_specializations'], true) : [];

        // Map internal snake_case to camelCase for API
        $profile['primarySpecialty'] = $profile['primary_specialty'];
        $profile['yearsOfExperience'] = $profile['years_of_experience'];
        $profile['isActive'] = (bool)$profile['is_active'];

        unset($profile['languages_spoken'], $profile['sub_specializations'], $profile['profile_photo_url'], $profile['is_active']);

        Response::success($profile);
    }

    public function updateStatus($user)
    {
        if ($user['role'] !== 'doctor') {
            Response::error("Only doctors can update their availability status", 403);
            return;
        }

        $input = json_decode(file_get_contents("php://input"), true);
        
        // Strict boolean check
        if (!isset($input['isActive']) || !is_bool($input['isActive'])) {
            Response::error("isActive field (boolean) is required", 400);
            return;
        }

        $isActive = $input['isActive'] ? 1 : 0;
        $userId = $user['id'];

        // Verify profile exists before update
        if (!$this->doctorModel->exists($userId)) {
            Response::error("Doctor profile not found", 404);
            return;
        }

        $updated = $this->doctorModel->updateActiveStatus($userId, $isActive);

        if (!$updated) {
            Response::error("Failed to update status", 500);
            return;
        }

        Response::success([
            'message' => "Status updated successfully",
            'isActive' => (bool)$isActive
        ]);
    }

    public function list($user)
    {
        try {
            $doctors = $this->doctorModel->getAllDoctors();
            Response::success($doctors);
        } catch (\Exception $e) {
            Response::error("Failed to fetch doctors list", 500);
        }
    }

    public function getById($user, $doctorId)
    {
        $profile = $this->doctorModel->findByUserId($doctorId);

        if (!$profile) {
            Response::error("Doctor not found", 404);
            return;
        }

        // 🛡️ Public Profile Protection (Phase 4)
        // If the viewer is not an admin, they can only see verified and active doctors
        $viewerRole = $user->userType ?? $user->role ?? null;
        
        if ($viewerRole !== 'admin') {
            if (!$profile['is_verified'] || !$profile['is_active']) {
                Response::error("Doctor not available", 403);
                return;
            }
        }

        // ✅ Default Image handling
        if (empty($profile['profile_photo_url'])) {
            $profile['profilePhotoUrl'] = "uploads/doctors/default-doctor.png";
        } else {
            $profile['profilePhotoUrl'] = $profile['profile_photo_url'];
        }

        // Map internal snake_case to camelCase
        $profile['primarySpecialty'] = $profile['primary_specialty'];
        $profile['yearsOfExperience'] = $profile['years_of_experience'];
        $profile['isActive'] = (bool)$profile['is_active'];
        $profile['isVerified'] = (bool)$profile['is_verified'];

        unset($profile['is_active'], $profile['is_verified'], $profile['profile_photo_url'], $profile['languages_spoken'], $profile['sub_specializations']);

        Response::success($profile);
    }
}