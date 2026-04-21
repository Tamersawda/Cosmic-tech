<?php

use Backend\Controllers\AuthController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Authentication Routes - MVP Implementation
 * 
 * Endpoints:
 * - POST /api/auth/register - User registration
 * - POST /api/auth/login - User login
 * - GET /api/auth/me - Get current user (protected)
 * 
 * Removed endpoints (for future implementation):
 * - POST /api/auth/verify-email
 * - POST /api/auth/resend-otp
 */
return function(string $method, string $path) {
    $controller = new AuthController();

    // Normalize path
    $path = strtolower(trim($path));
    if ($path === '' || $path === '/') {
        Response::error('No endpoint specified', 404);
        return;
    }

    // Helper function to match paths
    $matchesPath = function(string $path, string $pattern): bool {
        $pattern = strtolower(trim($pattern));
        return strpos($path, $pattern) === 0 || 
               $path === $pattern || 
               $path === '/' . $pattern ||
               $path === $pattern . '/';
    };

    // POST endpoint routes
    if ($method === 'POST') {
        // Register
        if ($matchesPath($path, '/api/auth/register') || $matchesPath($path, 'api/auth/register')) {
            $controller->register();
            return;
        }

        // Login
        if ($matchesPath($path, '/api/auth/login') || $matchesPath($path, 'api/auth/login')) {
            $controller->login();
            return;
        }
    }

    // GET endpoint routes
    if ($method === 'GET') {
        // Get current user (protected)
        if ($matchesPath($path, '/api/me') || $matchesPath($path, 'api/me')) {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->getCurrentUser($payload);
            return;
        }
    }

    // Route not found
    http_response_code(404);
    Response::error('Route not found: ' . $method . ' ' . $path, 404);
    return;
};
