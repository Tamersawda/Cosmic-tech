<?php

use Backend\Controllers\ClientProfileController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Client Routes
 *
 * POST /api/clients/setup         - Setup client profile
 * GET  /api/clients/profile       - Get own profile
 * GET  /api/clients/appointments  - Get own appointments
 */
return function(string $method, string $path) {
    $controller = new ClientProfileController();
    $path = strtolower(trim($path));

    $normalizedPath = $path;
    if (strpos($path, '/api/clients') === 0) {
        $normalizedPath = substr($path, 12);
    } elseif (strpos($path, '/clients') === 0) {
        $normalizedPath = substr($path, 8);
    }
    
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'POST') {
        if ($normalizedPath === '/setup') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->setup($payload);
            return;
        }
    }

    if ($method === 'GET') {
        if ($normalizedPath === '/profile') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->getProfile($payload);
            return;
        }
        if ($normalizedPath === '/appointments') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            $controller->getAppointments($payload);
            return;
        }
    }

    Response::error('Route not found in Clients: ' . $method . ' ' . $path, 404);
};
