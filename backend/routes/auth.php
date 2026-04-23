<?php

use Backend\Controllers\AuthController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Authentication Routes
 *
 * POST /api/auth/register  - Register (role: doctor|client)
 * POST /api/auth/login     - Login
 * POST /api/auth/logout    - Logout (protected)
 * GET  /api/auth/me        - Get current user (protected)
 */
return function(string $method, string $path) {
    $controller = new AuthController();
    $path = strtolower(trim($path));

    // Normalize path (remove leading /api/auth if present for easier matching)
    $normalizedPath = $path;
    if (strpos($path, '/api/auth') === 0) {
        $normalizedPath = substr($path, 9);
    } elseif (strpos($path, '/auth') === 0) {
        $normalizedPath = substr($path, 5);
    }
    
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'POST') {
        if ($normalizedPath === '/register') {
            $controller->register();
            return;
        }
        if ($normalizedPath === '/login') {
            $controller->login();
            return;
        }
        if ($normalizedPath === '/logout') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->logout($payload);
            return;
        }
    }

    if ($method === 'GET') {
        if ($normalizedPath === '/me') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->getCurrentUser($payload);
            return;
        }
    }

    Response::error('Route not found in Auth: ' . $method . ' ' . $path, 404);
};
