<?php

namespace Backend\Controllers;

use Backend\Config\JWT;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;
use Backend\Utils\EmailService;
use Backend\Utils\OtpManager;

class AuthController {
    private User $userModel;
    private Validator $validator;
    private EmailService $emailService;

    public function __construct() {
        $this->userModel = new User();
        $this->validator = new Validator();
        $this->emailService = new EmailService();
    }

    /**
     * Register new user (doctor or patient only)
     * POST /api/auth/register
     * 
     * Request:
     * {
     *   "email": "user@example.com",
     *   "password": "securepassword123",
     *   "userType": "doctor|patient",
     *   "fullName": "John Doe"
     * }
     * 
     * Response: 
     * {
     *   "success": true,
     *   "data": {
     *     "message": "User registered. Please verify email."
     *   }
     * }
     */
    public function register(): void {
        $input = $this->getInputData();

        // Validate input
        $isValid = $this->validator->validate($input, [
            'email' => ['required', 'email'],
            'password' => ['required', ['min', 6]],
            'fullName' => ['required', 'string'],
        ]);

        // Explicitly check userType
        if (empty($input['userType']) || !in_array($input['userType'], ['doctor', 'patient'])) {
            Response::validation(['userType' => 'userType is required and must be either doctor or patient']);
            return;
        }

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $email = trim($input['email']);
        $password = $input['password'];
        $userType = $input['userType'];
        $fullName = trim($input['fullName']);

        // Verify email is unique
        if ($this->userModel->emailExists($email)) {
            Response::error('Email already exists', 409);
            return;
        }

        try {
            // Hash password
            $hashedPassword = User::hashPassword($password);

            // Create user with is_email_verified = false
            $userId = $this->userModel->create([
                'email' => $email,
                'password' => $hashedPassword,
                'user_type' => $userType
            ]);

            // Create initial profile based on user type
            if ($userType === 'doctor') {
                $this->userModel->createDoctorProfile($userId, [
                    'full_name' => $fullName
                ]);
            } else if ($userType === 'patient') {
                $this->userModel->createPatientProfile($userId, [
                    'full_name' => $fullName
                ]);
            }

            // Generate OTP
            $otp = OtpManager::generateOtp();
            $hashedOtp = OtpManager::hashOtp($otp);
            $expiryTime = OtpManager::getOtpExpiry();

            // Store OTP in database
            $this->userModel->storeOtp($email, $hashedOtp, $expiryTime);

            // Send OTP via email
            $emailSent = $this->emailService->sendOtpEmail($email, $otp);

            if (!$emailSent) {
                error_log("Failed to send OTP email to: $email");
            }

            Response::success([
                'message' => 'User registered. Please verify email.'
            ], 201);

        } catch (\Exception $e) {
            error_log("Registration error: " . $e->getMessage());
            $errorMsg = getenv('APP_ENV') === 'development' ? $e->getMessage() : 'Registration failed. Please try again later.';
            Response::error($errorMsg, 500);
        }
    }

    /**
     * Verify email with OTP
     * POST /api/auth/verify-email
     * 
     * Request:
     * {
     *   "email": "user@example.com",
     *   "otp": "123456"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "data": {
     *     "message": "Email verified successfully"
     *   }
     * }
     */
    public function verifyEmail(): void {
        $input = $this->getInputData();

        // Validate input
        $isValid = $this->validator->validate($input, [
            'email' => ['required', 'email'],
            'otp' => ['required', 'string'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $email = trim($input['email']);
        $otp = trim($input['otp']);

        // Validate OTP format
        if (!OtpManager::validateOtpFormat($otp)) {
            Response::error('Invalid OTP format. Must be 6 digits.', 400);
            return;
        }

        try {
            // Find user by email with verification details
            $user = $this->userModel->findByEmailWithVerification($email);

            if (!$user) {
                Response::error('User not found', 404);
                return;
            }

            // Check if already verified
            if ($user['is_email_verified']) {
                Response::error('Email already verified', 400);
                return;
            }

            // Check if OTP exists
            if (!$user['email_verification_otp']) {
                Response::error('No OTP found. Please request a new one.', 400);
                return;
            }

            // Check if OTP is expired
            if (OtpManager::isOtpExpired($user['email_verification_expires'])) {
                Response::error('OTP has expired. Please request a new one.', 400);
                return;
            }

            // Verify OTP
            if (!OtpManager::verifyOtp($otp, $user['email_verification_otp'])) {
                Response::error('Invalid OTP', 400);
                return;
            }

            // Mark email as verified
            $this->userModel->verifyEmail($email);

            // Send verification success email
            $this->emailService->sendVerificationSuccessEmail($email);

            Response::success([
                'message' => 'Email verified successfully'
            ], 200);

        } catch (\Exception $e) {
            error_log("Email verification error: " . $e->getMessage());
            Response::error('Email verification failed. Please try again later.', 500);
        }
    }

    /**
     * Resend OTP
     * POST /api/auth/resend-otp
     * 
     * Request:
     * {
     *   "email": "user@example.com"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "data": {
     *     "message": "OTP sent to your email"
     *   }
     * }
     */
    public function resendOtp(): void {
        $input = $this->getInputData();

        // Validate input
        $isValid = $this->validator->validate($input, [
            'email' => ['required', 'email'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $email = trim($input['email']);

        try {
            // Find user by email
            $user = $this->userModel->findByEmailWithVerification($email);

            if (!$user) {
                Response::error('User not found', 404);
                return;
            }

            // Check if already verified
            if ($user['is_email_verified']) {
                Response::error('Email is already verified', 400);
                return;
            }

            // Check resend cooldown (optional - can be removed for testing)
            // if ($user['email_verification_expires'] && !OtpManager::isOtpExpired($user['email_verification_expires'] - 590)) {
            //     Response::error('Please wait before requesting a new OTP', 429);
            //     return;
            // }

            // Generate new OTP
            $otp = OtpManager::generateOtp();
            $hashedOtp = OtpManager::hashOtp($otp);
            $expiryTime = OtpManager::getOtpExpiry();

            // Store new OTP
            $this->userModel->storeOtp($email, $hashedOtp, $expiryTime);

            // Send OTP via email
            $emailSent = $this->emailService->sendResendOtpEmail($email, $otp);

            if (!$emailSent) {
                error_log("Failed to send resend OTP email to: $email");
            }

            Response::success([
                'message' => 'OTP sent to your email'
            ], 200);

        } catch (\Exception $e) {
            error_log("Resend OTP error: " . $e->getMessage());
            Response::error('Failed to resend OTP. Please try again later.', 500);
        }
    }

    /**
     * Login user
     * POST /api/auth/login
     * 
     * Request:
     * {
     *   "email": "user@example.com",
     *   "password": "securepassword123"
     * }
     * 
     * Response:
     * {
     *   "success": true,
     *   "data": {
     *     "id": "user-uuid",
     *     "email": "user@example.com",
     *     "userType": "doctor",
     *     "token": "eyJhbGc...",
     *     "refreshToken": "eyJhbGc..."
     *   }
     * }
     */
    public function login(): void {
        $input = $this->getInputData();

        // Validate input
        $isValid = $this->validator->validate($input, [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if (!$isValid) {
            Response::validation($this->validator->getErrors());
            return;
        }

        $email = trim($input['email']);
        $password = $input['password'];

        try {
            // Find user by email with verification details
            $user = $this->userModel->findByEmailWithVerification($email);

            if (!$user) {
                Response::error('Invalid email or password', 401);
                return;
            }

            // Verify password
            if (!User::verifyPassword($password, $user['password'])) {
                Response::error('Invalid email or password', 401);
                return;
            }

            // Check if account is active
            if (!$user['is_active']) {
                Response::error('Account is inactive', 403);
                return;
            }

            // Check if email is verified
            if (!$user['is_email_verified']) {
                Response::error('EMAIL_NOT_VERIFIED', 403);
                return;
            }

            // Generate JWT token
            $token = JWT::encode([
                'user_id' => $user['id'],
                'user_type' => $user['user_type'],
                'email' => $user['email'],
            ]);

            // Generate refresh token with longer expiry
            $refreshToken = JWT::encode([
                'user_id' => $user['id'],
                'user_type' => $user['user_type'],
                'email' => $user['email'],
                'type' => 'refresh'
            ], 7 * 24 * 3600); // 7 days

            Response::success([
                'id' => $user['id'],
                'email' => $user['email'],
                'userType' => $user['user_type'],
                'token' => $token,
                'refreshToken' => $refreshToken
            ], 200);

        } catch (\Exception $e) {
            error_log("Login error: " . $e->getMessage());
            Response::error('Login failed. Please try again later.', 500);
        }
    }

    /**
     * Get current user info (protected route)
     * GET /api/me
     * 
     * Headers:
     * Authorization: Bearer <token>
     * 
     * Response:
     * {
     *   "success": true,
     *   "data": {
     *     "id": "user-uuid",
     *     "email": "user@example.com",
     *     "userType": "doctor",
     *     "isEmailVerified": true
     *   }
     * }
     */
    public function getCurrentUser(object $payload): void {
        try {
            $user = $this->userModel->findById($payload->user_id);

            if (!$user) {
                Response::error('User not found', 404);
                return;
            }

            Response::success([
                'id' => $user['id'],
                'email' => $user['email'],
                'userType' => $user['user_type'],
                'isEmailVerified' => (bool)$user['is_email_verified'],
            ]);

        } catch (\Exception $e) {
            error_log("Get current user error: " . $e->getMessage());
            Response::error('Failed to fetch user info', 500);
        }
    }

    /**
     * Parse input data from request
     */
    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];

        // Also check $_GET and $_POST for fallback
        return array_merge($_GET, $_POST, $data);
    }
}
