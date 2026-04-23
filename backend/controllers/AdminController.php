<?php

namespace Backend\Controllers;

use Backend\Models\User;
use Backend\Utils\Response;
use Backend\Utils\Validator;

class AdminController {
    private User $userModel;
    private Validator $validator;

    public function __construct() {
        $this->userModel = new User();
        $this->validator = new Validator();
    }

    /**
     * Create a new admin user
     * POST /api/admin/create-admin
     * 
     * Requires Authorization: Bearer <token>
     * where the token belongs to an existing admin.
     */
    public function createAdmin(object $payload): void {
        try {
            // Check authorization
            if (!isset($payload->userType) || $payload->userType !== 'admin') {
                Response::error('Forbidden: Admin access required', 403);
                return;
            }

            $input = $this->getInputData();

            $isValid = $this->validator->validate($input, [
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
            $fullName = $input['fullName'] ?? 'System Administrator';

            // Check duplicate email
            if ($this->userModel->emailExists($email)) {
                Response::error('Email already exists', 409);
                return;
            }

            $hashedPassword = User::hashPassword($password);

            $userId = $this->userModel->create([
                'email'     => $email,
                'password'  => $hashedPassword,
                'user_type' => 'admin',
                'full_name' => $fullName,
            ]);

            Response::success([
                'id'       => $userId,
                'email'    => $email,
                'userType' => 'admin',
                'fullName' => $fullName
            ], 201);

        } catch (\Exception $e) {
            error_log('Create admin error: ' . $e->getMessage());
            Response::error('Internal server error', 500);
        }
    }

    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];
        return array_merge($_GET, $_POST, $data);
    }
}
