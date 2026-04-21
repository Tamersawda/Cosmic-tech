<<<<<<< HEAD:middleware/AuthMiddleware.php
<?php

namespace Backend\Middleware;

use Backend\Config\JWT;
use Backend\Utils\Response;

class AuthMiddleware {
    
    /**
     * Authenticate request using JWT token
     * Returns decoded token payload on success
     * Returns null and exits on failure
     */
    public static function authenticate(): ?object {
        $token = JWT::getTokenFromHeader();

        if (!$token) {
            Response::error('Unauthorized: Missing or invalid Authorization header', 401);
        }

        try {
            $payload = JWT::decode($token);
            return $payload;
        } catch (\Exception $e) {
            Response::error('Unauthorized: ' . $e->getMessage(), 401);
        }
    }

    /**
     * Verify that user has specific role
     */
    public static function requireRole(object $payload, string $role): void {
        // Support both new 'role' claim and legacy 'user_type' claim
        $userRole = $payload->role ?? $payload->user_type ?? null;
        if (!$userRole || $userRole !== $role) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }

    /**
     * Verify multiple roles
     */
    public static function requireRoles(object $payload, array $roles): void {
        $userRole = $payload->role ?? $payload->user_type ?? null;
        if (!$userRole || !in_array($userRole, $roles, true)) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }
}
=======
<?php

namespace Backend\Middleware;

use Backend\Config\JWT;
use Backend\Utils\Response;

class AuthMiddleware {
    
    /**
     * Authenticate request using JWT token
     * Returns decoded token payload on success
     * Returns null and exits on failure
     */
    public static function authenticate(): ?object {
        $token = JWT::getTokenFromHeader();

        if (!$token) {
            Response::error('Unauthorized: Missing or invalid Authorization header', 401);
        }

        try {
            $payload = JWT::decode($token);
            return $payload;
        } catch (\Exception $e) {
            Response::error('Unauthorized: ' . $e->getMessage(), 401);
        }
    }

    /**
     * Verify that user has specific role
     */
    public static function requireRole(object $payload, string $role): void {
        // Support both new 'role' claim and legacy 'user_type' claim
        $userRole = $payload->role ?? $payload->user_type ?? null;
        if (!$userRole || $userRole !== $role) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }

    /**
     * Verify multiple roles
     */
    public static function requireRoles(object $payload, array $roles): void {
        $userRole = $payload->role ?? $payload->user_type ?? null;
        if (!$userRole || !in_array($userRole, $roles, true)) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }
}
>>>>>>> 87a1fb828da8724dd6db926372bb850a47ca6f5c:backend/middleware/AuthMiddleware.php
