<?php

use Backend\Controllers\AdminController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Admin Routes
 *
 * POST /api/admin/create-admin - Create a new admin (Admin only)
 */
return function(string $method, string $path) {
    $controller = new AdminController();
    $path = strtolower(trim($path));

    $normalizedPath = $path;
    if (strpos($path, '/api/admin') === 0) {
        $normalizedPath = substr($path, 10);
    } elseif (strpos($path, '/admin') === 0) {
        $normalizedPath = substr($path, 6);
    }
    
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'POST') {
        if ($normalizedPath === '/create-admin') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->createAdmin($payload);
            return;
        }
    }

    Response::error('Route not found in Admin: ' . $method . ' ' . $path, 404);
};
