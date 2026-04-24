<?php

namespace Backend\Controllers;

use Backend\Config\JWT;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;

/**
 * AuthController - MVP Implementation
 * 
 * Implements:
 * - POST /api/auth/register
 * - POST /api/auth/login
 * - GET /api/auth/me
 * 
 * Note: Email OTP verification is NOT implemented in this phase.
 * Users are created with isEmailVerified = true by default.
 * Fields are reserved for future OTP implementation without refactoring.
 */
class AuthController {
    private User $userModel;
    private Validator $validator;

    public function __construct() {
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    /**
     * Register new user (doctor or client)
     * POST /api/auth/register
     *
     * Request:
     * {
     *   "name": "John Doe",
     *   "email": "user@example.com",
     *   "password": "securepassword123",
     *   "role": "admin|doctor|user"
     * }
     *
     * Response (201):
     * { "success": true, "data": { "id", "name", "email", "role", "token", "refreshToken" } }
     */
    public function register(): void {
        try {
            $input = $this->getInputData();

            // --- Normalize and Validate individual fields ---------------------------
            $userType = $input['userType'] ?? $input['role'] ?? '';
            $fullName = $input['fullName'] ?? $input['name'] ?? '';
            
            $role = strtolower(trim($userType));
            $name = trim($fullName);

            // Ensure input has the expected keys for validation
            $input['userType'] = $role;
            $input['fullName'] = $name;

            // role must be 'client', or 'doctor'
            if (empty($role) || !in_array($role, ['client', 'doctor'], true)) {
                Response::error('userType must be one of client or doctor', 400);
                return;
            }

            $isValid = $this->validator->validate($input, [
                'fullName' => ['required', 'string'],
                'email'    => ['required', 'email'],
                'password' => ['required', ['min', 6]],
            ]);

            if (!$isValid) {
                $errors = $this->validator->getErrors();
                $firstError = array_values($errors)[0][0] ?? 'Invalid input';
                Response::error($firstError, 400);
                return;
            }

            $email    = strtolower(trim($input['email']));
            $password = $input['password'];

        // --- Duplicate email check ----------------------------------------------
        if ($this->userModel->emailExists($email)) {
            Response::error('Email already exists', 409);
            return;
        }

        $hashedPassword = User::hashPassword($password);

            // Create user (is_email_verified = true by default, no OTP flow)
            $userId = $this->userModel->create([
                'email'     => $email,
                'password'  => $hashedPassword,
                'user_type' => $role,          // stored as role in DB
                'full_name' => $name,
            ]);

            // Create initial sub-profile skeleton
            if ($role === 'doctor') {
                $this->userModel->createDoctorProfile($userId);
            } elseif ($role === 'client') {
                $this->userModel->createClientProfile($userId);
            }

            // Generate tokens so the user can navigate immediately after register
            $token = JWT::encode([
                'userId'   => $userId,
                'userType' => $role,
                'email'    => $email,
            ]);

            $refreshToken = JWT::encode([
                'userId'   => $userId,
                'userType' => $role,
                'email'    => $email,
                'type'     => 'refresh',
            ], 7 * 24 * 3600);

            // Exact response match
            Response::success([
                'userId'       => $userId,
                'fullName'     => $name,
                'email'        => $email,
                'userType'     => $role,
                'token'        => $token,
                'refreshToken' => $refreshToken,
                'is_profile_completed' => false,
                'onboarding_step' => 0,
            ]);

        } catch (\Exception $e) {
            error_log('Registration error: ' . $e->getMessage());
            Response::error($e->getMessage(), 500);
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
     * Response (200):
     * {
     *   "success": true,
     *   "data": {
     *     "id": "550e8400-e29b-41d4-a716-446655440000",
     *     "email": "user@example.com",
     *     "userType": "doctor",
     *     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     *     "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
     *   }
     * }
     * 
     * Note: Email verification is NOT checked (MVP feature set)
     */
    public function login(): void {
        try {
            $input = $this->getInputData();

            // Validate input
            $isValid = $this->validator->validate($input, [
                'email'    => ['required', 'email'],
                'password' => ['required', 'string'],
            ]);

            if (!$isValid) {
                $errors = $this->validator->getErrors();
                $firstError = array_values($errors)[0][0] ?? 'Invalid input';
                Response::error($firstError, 400);
                return;
            }

            $email    = strtolower(trim($input['email']));
            $password = $input['password'];
            $user = $this->userModel->findByEmail($email);

            if (!$user) {
                Response::error("Invalid credentials", 401);
                return;
            }

            if (!password_verify($password, $user['password'])) {
                Response::error("Invalid credentials", 401);
                return;
            }

            if (!$user['is_active']) {
                Response::error('Account is inactive', 403);
                return;
            }

            $name = $user['full_name'];
            $role = strtolower($user['user_type']);

            if (!in_array($role, ['client', 'doctor', 'admin'], true)) {
                Response::error("Invalid user role", 500);
                return;
            }

            // ------------------------------------------------------------------
            // Fix 8: Runtime migration safety check (client only).
            // If the DB says profile is complete but critical fields are missing,
            // reset onboarding state so the frontend resumes correctly.
            // Critical fields: client_profiles.first_name, phone_number.
            // ------------------------------------------------------------------
            if ($role === 'client' && (bool)$user['is_profile_completed']) {
                $db = \Backend\Config\Database::getInstance();
                $chkStmt = $db->prepare(
                    'SELECT full_name, phone_number FROM client_profiles WHERE user_id = ? LIMIT 1'
                );
                $chkStmt->execute([$user['id']]);
                $profile = $chkStmt->fetch(\PDO::FETCH_ASSOC);

                $criticalMissing = !$profile
                    || empty($profile['full_name'])
                    || empty($profile['phone_number']);

                if ($criticalMissing) {
                    $resetStmt = $db->prepare(
                        'UPDATE users SET is_profile_completed = 0, onboarding_step = 1 WHERE id = ?'
                    );
                    $resetStmt->execute([$user['id']]);
                    // Refresh values so the response reflects the corrected state.
                    $user['is_profile_completed'] = 0;
                    $user['onboarding_step']       = 1;
                }
            }

            $token = JWT::encode([
                'userId'   => $user['id'],
                'userType' => $role,
                'email'    => $user['email'],
            ]);

            $refreshToken = JWT::encode([
                'userId'   => $user['id'],
                'userType' => $role,
                'email'    => $user['email'],
                'type'     => 'refresh',
            ], 7 * 24 * 3600);

            Response::success([
                'userId'               => $user['id'],
                'fullName'             => $name,
                'email'                => $user['email'],
                'userType'             => $role,
                'token'                => $token,
                'refreshToken'         => $refreshToken,
                'is_profile_completed' => (bool)$user['is_profile_completed'],
                'onboarding_step'      => (int)$user['onboarding_step'],
            ], 200);

        } catch (\Exception $e) {
            error_log('Login error: ' . $e->getMessage());
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Get current authenticated user
     * GET /api/auth/me
     * 
     * Headers:
     * Authorization: Bearer <token>
     * 
     * Response (200):
     * {
     *   "success": true,
     *   "data": {
     *     "id": "550e8400-e29b-41d4-a716-446655440000",
     *     "email": "user@example.com",
     *     "userType": "doctor",
     *     "isEmailVerified": true
     *   }
     * }
     */
    public function getCurrentUser(object $payload): void {
        try {
            $userId = $payload->userId ?? $payload->user_id ?? null;
            if (!$userId) {
                Response::error('Invalid token payload', 400);
                return;
            }

            $user = $this->userModel->findById($userId);

            if (!$user) {
                Response::error('User not found', 404);
                return;
            }

            Response::success([
                'userId'         => $user['id'],
                'email'          => $user['email'],
                'fullName'       => $user['full_name'] ?? '',
                'userType'       => $user['role'], // role is alias for user_type
                'isEmailVerified'=> (bool)($user['is_email_verified'] ?? true),
            ]);

        } catch (\Exception $e) {
            error_log('Get current user error: ' . $e->getMessage());
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Logout user
     * POST /api/auth/logout
     * 
     * Headers:
     * Authorization: Bearer <token>
     */
    public function logout(object $payload): void {
        try {
            // For stateless JWT, we return a success response and the client must discard the token.
            // If using a stateful refresh token database, you would invalidate it here.
            Response::success([
                'message' => 'Logged out successfully'
            ], 200);
        } catch (\Exception $e) {
            error_log('Logout error: ' . $e->getMessage());
            Response::error('Failed to logout', 500);
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
