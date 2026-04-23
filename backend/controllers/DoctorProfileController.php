<?php

require_once __DIR__ . '/../models/DoctorProfile.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';

class DoctorProfileController
{
    private $doctorModel;
    private $validator;

    public function __construct($db)
    {
        $this->doctorModel = new DoctorProfile($db);
        $this->validator = new Validator();
    }

    public function setup($user)
    {
        $input = json_decode(file_get_contents("php://input"), true);

        if (!$input) {
            Response::error("Invalid JSON input", 400);
            return;
        }

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

        // 🔐 Use authenticated user_id
        $userId = $user['id'];

        // ❗ Prevent duplicate setup
        if ($this->doctorModel->existsByUserId($userId)) {
            Response::error("Doctor profile already exists", 409);
            return;
        }

        // 📦 Prepare data
        $data = [
            'user_id'              => $userId,
            'gender'               => $input['gender'],
            'date_of_birth'        => $input['dateOfBirth'],
            'phone_number'         => $input['phoneNumber'],
            'primary_specialty'    => $input['primarySpecialty'],
            'sub_specializations'  => isset($input['subSpecializations']) 
                                        ? json_encode($input['subSpecializations']) 
                                        : json_encode([]),
            'years_of_experience'  => $input['yearsOfExperience'],
            'license_number'       => $input['licenseNumber'],
            'medical_council'      => $input['medicalCouncil'] ?? null,
            'languages_spoken'     => json_encode($input['languagesSpoken']),
            'video_enabled'        => $input['videoEnabled'],
            'video_rate'           => $input['videoRate'],
            'audio_enabled'        => $input['audioEnabled'] ?? false,
            'audio_rate'           => $input['audioRate'] ?? null,
            'consultation_duration'=> $input['consultationDuration'],
            'buffer_time'          => $input['bufferTime'],
            'street_address'       => $input['streetAddress'] ?? null,
            'city'                 => $input['city'] ?? null,
            'state'                => $input['state'] ?? null,
            'country'              => $input['country'] ?? null,
            'postal_code'          => $input['postalCode'] ?? null
        ];

        // 💾 Save
        $created = $this->doctorModel->create($data);

        if (!$created) {
            Response::error("Failed to create doctor profile", 500);
            return;
        }

        Response::success("Doctor profile created successfully");
    }

    public function getProfile($user)
    {
        $userId = $user['id'];

        $profile = $this->doctorModel->getByUserId($userId);

        if (!$profile) {
            Response::error("Doctor profile not found", 404);
            return;
        }

        // Decode JSON fields
        $profile['languagesSpoken'] = json_decode($profile['languages_spoken'], true);
        $profile['subSpecializations'] = json_decode($profile['sub_specializations'], true);

        unset($profile['languages_spoken'], $profile['sub_specializations']);

        Response::success($profile);
    }
}