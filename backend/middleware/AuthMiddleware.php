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
        if (!isset($payload->user_type) || $payload->user_type !== $role) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }

    /**
     * Verify multiple roles
     */
    public static function requireRoles(object $payload, array $roles): void {
        if (!isset($payload->user_type) || !in_array($payload->user_type, $roles)) {
            Response::error('Forbidden: You do not have permission to access this resource', 403);
        }
    }
}
