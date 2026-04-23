<?php

namespace Backend\Middleware;

use Backend\Config\JWT;
use Backend\Utils\Response;

class AuthMiddleware {

    /**
     * Authenticate request using JWT Bearer token.
     * Returns the decoded token payload on success.
     * Sends 401 JSON and exits on failure — never returns null.
     */
    public static function authenticate(): object {
        $token = JWT::getTokenFromHeader();

        if (!$token) {
            Response::error('Unauthorized: Missing or invalid Authorization header', 401);
            exit; // Response::error already exits, but be explicit
        }

        try {
            return JWT::decode($token);
        } catch (\Exception $e) {
            Response::error('Unauthorized: ' . $e->getMessage(), 401);
            exit;
        }
    }

    /**
     * Verify that the authenticated user has a specific role.
     * Reads the 'role' claim from the JWT payload (canonical claim name).
     * Sends 403 JSON and exits on mismatch.
     *
     * Valid roles: 'admin', 'doctor', 'client'
     */
    public static function requireRole(object $payload, string $role): void {
        $userRole = $payload->userType ?? $payload->role ?? null;
        if (!$userRole || $userRole !== $role) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
            exit;
        }
    }

    /**
     * Verify that the authenticated user has one of the allowed roles.
     * Sends 403 JSON and exits on mismatch.
     */
    public static function requireRoles(object $payload, array $roles): void {
        $userRole = $payload->userType ?? $payload->role ?? null;
        if (!$userRole || !in_array($userRole, $roles, true)) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
            exit;
        }
    }
}
