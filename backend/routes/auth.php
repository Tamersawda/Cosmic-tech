<?php

use Backend\Controllers\AuthController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Authentication Routes
 *
 * POST /api/auth/register  - Register (role: admin|doctor|user)
 * POST /api/auth/login     - Login
 * GET  /api/auth/me        - Get current user (protected)
 */
return function(string $method, string $path) {
    $controller = new AuthController();

    $path = strtolower(trim($path));

    $matchesPath = function(string $path, string $pattern): bool {
        $pattern = strtolower(trim($pattern));
        return strpos($path, $pattern) === 0
            || $path === $pattern
            || $path === '/' . $pattern
            || $path === $pattern . '/';
    };

    if ($method === 'POST') {
        if ($matchesPath($path, '/api/auth/register') || $matchesPath($path, 'api/auth/register')) {
            $controller->register();
            return;
        }
        if ($matchesPath($path, '/api/auth/login') || $matchesPath($path, 'api/auth/login')) {
            $controller->login();
            return;
        }
    }

    if ($method === 'GET') {
        if ($matchesPath($path, '/api/auth/me') || $matchesPath($path, 'api/auth/me')) {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->getCurrentUser($payload);
            return;
        }
    }

    Response::error('Route not found: ' . $method . ' ' . $path, 404);
};
