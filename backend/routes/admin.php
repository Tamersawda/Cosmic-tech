<?php

use Backend\Controllers\AdminController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Admin Routes
 *
 * POST  /api/admin/create-admin     - Create admin user (admin only)
 * PATCH /api/admin/verify-doctor    - Approve/reject doctor (admin only)
 * GET   /api/admin/doctors          - List all doctors (admin only)
 * GET   /api/admin/appointments     - List all appointments (admin only)
 */
return function(string $method, string $path) {
    $controller = new AdminController();
    $path = strtolower(trim($path));

    // Normalize path
    $normalizedPath = $path;
    if (strpos($path, '/api/admin') === 0) {
        $normalizedPath = substr($path, 10); // strlen('/api/admin') = 10
    } elseif (strpos($path, '/admin') === 0) {
        $normalizedPath = substr($path, 6);
    }

    if ($normalizedPath === '' || $normalizedPath === false) $normalizedPath = '/';
    if ($normalizedPath[0] !== '/') $normalizedPath = '/' . $normalizedPath;

    // ── POST /api/admin/create-admin ──
    if ($method === 'POST' && $normalizedPath === '/create-admin') {
        $payload = AuthMiddleware::authenticate();
        $controller->createAdmin($payload);
        return;
    }

    // ── PATCH /api/admin/verify-doctor ──
    if ($method === 'PATCH' && $normalizedPath === '/verify-doctor') {
        $payload = AuthMiddleware::authenticate();
        $controller->verifyDoctor($payload);
        return;
    }

    // ── GET /api/admin/doctors ──
    if ($method === 'GET' && $normalizedPath === '/doctors') {
        $payload = AuthMiddleware::authenticate();
        $controller->listDoctors($payload);
        return;
    }

    // ── GET /api/admin/appointments ──
    if ($method === 'GET' && $normalizedPath === '/appointments') {
        $payload = AuthMiddleware::authenticate();
        $controller->listAppointments($payload);
        return;
    }

    Response::error('Route not found in Admin: ' . $method . ' ' . $path, 404);
};
