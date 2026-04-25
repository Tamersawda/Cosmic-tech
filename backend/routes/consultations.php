<?php

use Backend\Controllers\ConsultationController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Consultation Routes
 *
 * POST  /api/consultations                   - Create consultation (doctor)
 * POST  /api/consultations/{id}/start        - Start consultation
 * POST  /api/consultations/{id}/end          - End consultation (doctor)
 * GET   /api/consultations/client            - Client's consultations
 * GET   /api/consultations/doctor            - Doctor's consultations
 * GET   /api/consultations/{id}              - Get consultation details
 * PUT   /api/consultations/{id}              - Update consultation (doctor)
 */
return function(string $method, string $path) {
    $controller = new ConsultationController();

    // ── POST /api/consultations/{id}/start ──
    if ($method === 'POST' && preg_match('#^/api/consultations/([^/]+)/start$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        $controller->start($payload, $matches[1]);
        return;
    }

    // ── POST /api/consultations/{id}/end ──
    if ($method === 'POST' && preg_match('#^/api/consultations/([^/]+)/end$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        $controller->end($payload, $matches[1]);
        return;
    }

    // ── POST /api/consultations (create) ──
    if ($method === 'POST' && ($path === '/api/consultations' || $path === '/consultations')) {
        $payload = AuthMiddleware::authenticate();
        $controller->create($payload);
        return;
    }

    // ── GET /api/consultations/client ──
    if ($method === 'GET' && ($path === '/api/consultations/client' || $path === '/consultations/client')) {
        $payload = AuthMiddleware::authenticate();
        $controller->getClientConsultations($payload);
        return;
    }

    // ── GET /api/consultations/doctor ──
    if ($method === 'GET' && ($path === '/api/consultations/doctor' || $path === '/consultations/doctor')) {
        $payload = AuthMiddleware::authenticate();
        $controller->getDoctorConsultations($payload);
        return;
    }

    // ── PUT /api/consultations/{id} (update) ──
    if ($method === 'PUT' && preg_match('#^/api/consultations/([^/]+)$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        $controller->update($payload, $matches[1]);
        return;
    }

    // ── GET /api/consultations/{id} ──
    if ($method === 'GET' && preg_match('#^/api/consultations/([^/]+)$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        $controller->get($payload, $matches[1]);
        return;
    }

    Response::error('Route not found in Consultations: ' . $method . ' ' . $path, 404);
};
