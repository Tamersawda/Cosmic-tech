<?php

use Backend\Controllers\AuthController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

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

        // Verify Email
        if ($matchesPath($path, '/api/auth/verify-email') || $matchesPath($path, 'api/auth/verify-email')) {
            $controller->verifyEmail();
            return;
        }

        // Resend OTP
        if ($matchesPath($path, '/api/auth/resend-otp') || $matchesPath($path, 'api/auth/resend-otp')) {
            $controller->resendOtp();
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
