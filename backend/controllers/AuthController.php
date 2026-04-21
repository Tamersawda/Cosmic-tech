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
     * Register new user (doctor or patient)
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
     * Response (201):
     * {
     *   "success": true,
     *   "data": {
     *     "id": "550e8400-e29b-41d4-a716-446655440000",
     *     "email": "user@example.com",
     *     "userType": "doctor"
     *   }
     * }
     */
    /**
     * Register new user (doctor or user)
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
     * {
     *   "id": "uuid",
     *   "name": "John Doe",
     *   "email": "user@example.com",
     *   "role": "doctor",
     *   "token": "jwt...",
     *   "refreshToken": "jwt..."
     * }
     */
    public function register(): void {
        $input = $this->getInputData();

        // --- Normalize and Validate individual fields ---------------------------

        $role = strtolower(trim($input['role'] ?? ''));

        // role must be 'admin', 'doctor', or 'user'
        if (empty($role) || !in_array($role, ['admin', 'doctor', 'user'], true)) {
            Response::error('role must be one of admin, doctor, or user', 400);
            return;
        }

        $isValid = $this->validator->validate($input, [
            'name'     => ['required', 'string'],
            'email'    => ['required', 'email'],
            'password' => ['required', ['min', 6]],
        ]);

        if (!$isValid) {
            $errors = $this->validator->getErrors();
            $firstError = array_values($errors)[0][0] ?? 'Invalid input';
            Response::error($firstError, 400);
            return;
        }

        $name     = trim($input['name']);
        $email    = trim($input['email']);
        $password = $input['password'];

        // --- Duplicate email check ----------------------------------------------
        if ($this->userModel->emailExists($email)) {
            Response::error('Email already exists', 409);
            return;
        }

        try {
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
                $this->userModel->createDoctorProfile($userId, [
                    'name' => $name,
                ]);
            } elseif ($role === 'user') {
                $this->userModel->createPatientProfile($userId, [
                    'name' => $name,
                ]);
            }

            // Generate tokens so the user can navigate immediately after register
            $token = JWT::encode([
                'user_id' => $userId,
                'role'    => $role,
                'email'   => $email,
            ]);

            $refreshToken = JWT::encode([
                'user_id' => $userId,
                'role'    => $role,
                'email'   => $email,
                'type'    => 'refresh',
            ], 7 * 24 * 3600);

            // Exact response match
            Response::success([
                'id'           => $userId,
                'name'         => $name,
                'email'        => $email,
                'role'         => $role,
                'token'        => $token,
                'refreshToken' => $refreshToken,
            ]);

        } catch (\Exception $e) {
            error_log('Registration error: ' . $e->getMessage());
            $msg = getenv('APP_ENV') === 'development'
                ? $e->getMessage()
                : 'Registration failed. Please try again later.';
            Response::error($msg, 500);
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

        try {
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

            if (!in_array($role, ['admin', 'doctor', 'user'], true)) {
                Response::error("Invalid user role", 500);
                return;
            }

            $token = JWT::encode([
                'user_id' => $user['id'],
                'role'    => $role,
                'email'   => $user['email'],
            ]);

            $refreshToken = JWT::encode([
                'user_id' => $user['id'],
                'role'    => $role,
                'email'   => $user['email'],
                'type'    => 'refresh',
            ], 7 * 24 * 3600);

            // Response matches exactly what frontend expects
            Response::flat([
                'id'           => $user['id'],
                'name'         => $name,
                'email'        => $user['email'],
                'role'         => $role,
                'token'        => $token,
                'refreshToken' => $refreshToken,
            ], 200);

        } catch (\Exception $e) {
            error_log('Login error: ' . $e->getMessage());
            Response::error('Login failed. Please try again later.', 500);
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
            $user = $this->userModel->findById($payload->user_id);

            if (!$user) {
                Response::error('User not found', 404);
                return;
            }

            Response::success([
                'id'             => $user['id'],
                'email'          => $user['email'],
                'role'           => $user['role'],
                'fullName'       => $user['full_name'] ?? '',
                'isEmailVerified'=> (bool)$user['is_email_verified'],
            ]);

        } catch (\Exception $e) {
            error_log('Get current user error: ' . $e->getMessage());
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
