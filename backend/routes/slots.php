<?php

use Backend\Controllers\AvailableSlotController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Available Slots Routes
 *
 * POST   /api/available-slots                  - Create slot (doctor)
 * GET    /api/available-slots/{id}             - Get slot details
 * GET    /api/available-slots/doctor/{id}      - Get doctor's slots
 * PUT    /api/available-slots/{id}             - Update slot (doctor)
 * DELETE /api/available-slots/{id}             - Delete slot (doctor)
 */
return function(string $method, string $path) {
    $controller = new AvailableSlotController();
    $path = strtolower(trim($path));

    // Normalize path
    $normalizedPath = $path;
    if (strpos($path, '/api/available-slots') === 0) {
        $normalizedPath = substr($path, 20); // strlen('/api/available-slots') = 20
    } elseif (strpos($path, '/available-slots') === 0) {
        $normalizedPath = substr($path, 16);
    }

    if ($normalizedPath === '' || $normalizedPath === false) $normalizedPath = '/';
    if ($normalizedPath[0] !== '/') $normalizedPath = '/' . $normalizedPath;

    // ── POST /api/available-slots ──
    if ($method === 'POST' && $normalizedPath === '/') {
        $payload = AuthMiddleware::authenticate();
        $controller->create($payload);
        return;
    }

    // ── GET routes ──
    if ($method === 'GET') {
        // /api/available-slots/doctor/{doctorId}
        if (preg_match('/^\/doctor\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $controller->getDoctorSlots($payload, $matches[1]);
            return;
        }

        // /api/available-slots/{id}
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $controller->get($payload, $matches[1]);
            return;
        }
    }

    // ── PUT /api/available-slots/{id} ──
    if ($method === 'PUT') {
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $controller->update($payload, $matches[1]);
            return;
        }
    }

    // ── DELETE /api/available-slots/{id} ──
    if ($method === 'DELETE') {
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $controller->delete($payload, $matches[1]);
            return;
        }
    }

    Response::error('Route not found in Available Slots: ' . $method . ' ' . $path, 404);
};
