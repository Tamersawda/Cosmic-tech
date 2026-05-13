<?php

namespace Backend\Controllers;

use Backend\Config\JWT;
use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;

/**
 * AuthController
 *
 * POST /api/auth/register
 * POST /api/auth/login
 * GET  /api/auth/me
 * POST /api/auth/logout
 *
 * Canonical field contract (what the API returns):
 *   { userId, name, email, role, token, refreshToken, isProfileCompleted, onboardingStep }
 *
 * Input normalization:
 *   Accepts both { name, role } (preferred) and { fullName, userType } (legacy).
 */
class AuthController {
    private User      $userModel;
    private Validator $validator;

    public function __construct() {
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/auth/register
    // ─────────────────────────────────────────────────────────
    public function register(): void {
        try {
            $input = $this->getInputData();

            // ── Normalize incoming fields (accept both conventions) ──
            $name  = trim($input['name'] ?? $input['fullName'] ?? '');
            $email = strtolower(trim($input['email'] ?? ''));
            $password = $input['password'] ?? '';
            $role  = strtolower(trim($input['role'] ?? $input['userType'] ?? ''));

            // ── Role validation ──
            $allowedRoles = ['client', 'doctor'];
            if (!in_array($role, $allowedRoles, true)) {
                Response::error(
                    'role must be one of: ' . implode(', ', $allowedRoles),
                    400,
                    'INVALID_ROLE'
                );
                return;
            }

            // ── Field validation ──
            $validation = $this->validator->validate(
                ['name' => $name, 'email' => $email, 'password' => $password],
                [
                    'name'     => ['required', 'string'],
                    'email'    => ['required', 'email'],
                    'password' => ['required', ['min', 6]],
                ]
            );

            if (!$validation['valid']) {
                Response::validation($validation['errors']);
                return;
            }

            // ── Duplicate email check ──
            if ($this->userModel->emailExists($email)) {
                Response::error('Email already registered', 409, 'EMAIL_EXISTS');
                return;
            }

            $hashedPassword = User::hashPassword($password);

            // ── Create user row ──
            $userId = $this->userModel->create([
                'email'     => $email,
                'password'  => $hashedPassword,
                'user_type' => $role,
                'full_name' => $name,
            ]);

            // ── Create profile skeleton ──
            if ($role === 'doctor') {
                $this->userModel->createDoctorProfile($userId);
            } elseif ($role === 'client') {
                $this->userModel->createClientProfile($userId);
            }

            // ── Issue tokens ──
            [$token, $refreshToken] = $this->issueTokens($userId, $role, $email);

            Response::success(
                $this->buildAuthPayload($userId, $name, $email, $role, $token, $refreshToken, false, 0),
                'Registration successful',
                201
            );

        } catch (\Exception $e) {
            error_log('Registration error: ' . $e->getMessage());
            Response::error('Registration failed', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/auth/login
    // ─────────────────────────────────────────────────────────
    public function login(): void {
        try {
            $input = $this->getInputData();

            $validation = $this->validator->validate($input, [
                'email'    => ['required', 'email'],
                'password' => ['required', 'string'],
            ]);

            if (!$validation['valid']) {
                Response::validation($validation['errors']);
                return;
            }

            $email = strtolower(trim($input['email']));
            $user  = $this->userModel->findByEmail($email);

            // Generic "invalid credentials" — never leak which field is wrong
            if (!$user || !password_verify($input['password'], $user['password'])) {
                Response::error('Invalid email or password', 401, 'INVALID_CREDENTIALS');
                return;
            }

            if (!$user['is_active']) {
                Response::error('Account is inactive. Contact support.', 403, 'ACCOUNT_INACTIVE');
                return;
            }

            $role = strtolower($user['user_type']);
            if (!in_array($role, ['client', 'doctor', 'admin'], true)) {
                Response::error('Unrecognized user role', 500, 'INVALID_ROLE');
                return;
            }

            // ── Runtime integrity check for clients ──
            if ($role === 'client' && (bool)$user['is_profile_completed']) {
                $db = \Backend\Config\Database::getInstance();
                $chk = $db->prepare('SELECT full_name, phone_number FROM client_profiles WHERE user_id = ? LIMIT 1');
                $chk->execute([$user['id']]);
                $profile = $chk->fetch(\PDO::FETCH_ASSOC);

                if (!$profile || empty($profile['full_name']) || empty($profile['phone_number'])) {
                    $db->prepare('UPDATE users SET is_profile_completed = 0, onboarding_step = 1 WHERE id = ?')
                       ->execute([$user['id']]);
                    $user['is_profile_completed'] = 0;
                    $user['onboarding_step']       = 1;
                }
            }

            [$token, $refreshToken] = $this->issueTokens($user['id'], $role, $user['email']);

            Response::success(
                $this->buildAuthPayload(
                    $user['id'],
                    $user['full_name'],
                    $user['email'],
                    $role,
                    $token,
                    $refreshToken,
                    (bool)$user['is_profile_completed'],
                    (int)$user['onboarding_step']
                ),
                'Login successful'
            );

        } catch (\Exception $e) {
            error_log('Login error: ' . $e->getMessage());
            Response::error('Login failed', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // GET /api/auth/me
    // ─────────────────────────────────────────────────────────
    public function getCurrentUser(object $payload): void {
        try {
            $userId = $payload->userId ?? $payload->user_id ?? null;
            if (!$userId) {
                Response::error('Invalid token payload', 400, 'BAD_TOKEN');
                return;
            }

            $user = $this->userModel->findById($userId);
            if (!$user) {
                Response::notFound('User not found');
                return;
            }

            Response::success([
                'userId'           => $user['id'],
                'name'             => $user['full_name'],
                'email'            => $user['email'],
                'role'             => $user['user_type'],
                'isEmailVerified'  => (bool)($user['is_email_verified'] ?? true),
                'isProfileCompleted' => (bool)$user['is_profile_completed'],
                'onboardingStep'   => (int)$user['onboarding_step'],
            ]);

        } catch (\Exception $e) {
            error_log('Get current user error: ' . $e->getMessage());
            Response::error('Failed to fetch user', 500, 'SERVER_ERROR');
        }
    }

    // ─────────────────────────────────────────────────────────
    // POST /api/auth/logout
    // ─────────────────────────────────────────────────────────
    public function logout(object $payload): void {
        // Stateless JWT — client must discard the token.
        Response::success([], 'Logged out successfully');
    }

    // ─────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────

    private function issueTokens(string $userId, string $role, string $email): array {
        $claims = ['userId' => $userId, 'userType' => $role, 'email' => $email];

        $token        = JWT::encode($claims);
        $refreshToken = JWT::encode(array_merge($claims, ['type' => 'refresh']), 7 * 24 * 3600);

        return [$token, $refreshToken];
    }

    /**
     * Build the canonical auth payload returned by register/login.
     * Only ONE set of field names — no duplicates.
     */
    private function buildAuthPayload(
        string $userId,
        string $name,
        string $email,
        string $role,
        string $token,
        string $refreshToken,
        bool   $isProfileCompleted,
        int    $onboardingStep
    ): array {
        return [
            'userId'             => $userId,
            'name'               => $name,
            'email'              => $email,
            'role'               => $role,
            'token'              => $token,
            'refreshToken'       => $refreshToken,
            'isProfileCompleted' => $isProfileCompleted,
            'onboardingStep'     => $onboardingStep,
        ];
    }

    private function getInputData(): array {
        $body = json_decode(file_get_contents('php://input'), true) ?? [];
        return array_merge($_POST, $body);   // body wins over POST (multipart fallback)
    }
}
