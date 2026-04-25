<?php

use Backend\Controllers\AppointmentController;
use Backend\Controllers\AvailableSlotController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Appointment Routes
 *
 * POST   /api/appointments                    - Book appointment (client)
 * GET    /api/appointments                    - List own appointments
 * GET    /api/appointments/client             - Client-specific list
 * GET    /api/appointments/doctor             - Doctor-specific list
 * GET    /api/appointments/available-slots     - Get available slots for a doctor
 * GET    /api/appointments/{id}               - Get appointment details
 * PUT    /api/appointments/{id}               - Update appointment
 * PATCH  /api/appointments/{id}/cancel        - Cancel appointment
 * POST   /api/appointments/{id}/messages      - (handled by messages.php)
 * GET    /api/appointments/{id}/messages       - (handled by messages.php)
 */
return function(string $method, string $path) {
    $path = strtolower(trim($path));

    // Normalize path
    $normalizedPath = $path;
    if (strpos($path, '/api/appointments') === 0) {
        $normalizedPath = substr($path, 17); // strlen('/api/appointments') = 17
    } elseif (strpos($path, '/appointments') === 0) {
        $normalizedPath = substr($path, 13);
    }

    if ($normalizedPath === '' || $normalizedPath === false) $normalizedPath = '/';
    if ($normalizedPath[0] !== '/') $normalizedPath = '/' . $normalizedPath;

    // ── Available Slots (must be before {id} catch-all) ──
    if ($normalizedPath === '/available-slots' && $method === 'GET') {
        $slotController = new AvailableSlotController();
        $payload = AuthMiddleware::authenticate();
        $slotController->getSlots($payload);
        return;
    }

    $appointmentController = new AppointmentController();

    // ── POST /api/appointments ──
    if ($method === 'POST' && $normalizedPath === '/') {
        $payload = AuthMiddleware::authenticate();
        $appointmentController->create($payload);
        return;
    }

    // ── GET routes ──
    if ($method === 'GET') {
        // /api/appointments/client
        if ($normalizedPath === '/client') {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->getClientList($payload);
            return;
        }

        // /api/appointments/doctor
        if ($normalizedPath === '/doctor') {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->getDoctorList($payload);
            return;
        }

        // /api/appointments (list all for current user)
        if ($normalizedPath === '/') {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->list($payload);
            return;
        }

        // /api/appointments/{id}
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->get($payload, $matches[1]);
            return;
        }
    }

    // ── PUT /api/appointments/{id} ──
    if ($method === 'PUT') {
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->update($payload, $matches[1]);
            return;
        }
    }

    // ── PATCH /api/appointments/{id}/cancel ──
    if ($method === 'PATCH') {
        if (preg_match('/^\/([a-f0-9\-]+)\/cancel$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $appointmentController->cancel($payload, $matches[1]);
            return;
        }
    }

    Response::error('Route not found in Appointments: ' . $method . ' ' . $path, 404);
};
