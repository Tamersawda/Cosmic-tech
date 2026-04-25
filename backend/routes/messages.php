<?php

use Backend\Controllers\MessageController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Message Routes
 *
 * GET    /api/messages/inbox                   - Get inbox
 * GET    /api/messages/sent                    - Get sent messages
 * POST   /api/messages                         - Send standalone message
 * POST   /api/appointments/{id}/messages       - Send appointment message
 * GET    /api/appointments/{id}/messages        - Get appointment messages
 * GET    /api/messages/{id}                     - Get message by ID
 * PUT    /api/messages/{id}                     - Update message (mark read)
 * DELETE /api/messages/{id}                     - Delete message
 */
return function(string $method, string $path) {
    $controller = new MessageController();

    // ── GET /api/messages/inbox ──
    if ($method === 'GET' && $path === '/api/messages/inbox') {
        $payload = AuthMiddleware::authenticate();
        $controller->getInbox($payload);
        return;
    }

    // ── GET /api/messages/sent ──
    if ($method === 'GET' && $path === '/api/messages/sent') {
        $payload = AuthMiddleware::authenticate();
        $controller->getSent($payload);
        return;
    }

    // ── POST /api/messages (standalone send) ──
    if ($method === 'POST' && $path === '/api/messages') {
        $payload = AuthMiddleware::authenticate();
        $controller->sendMessage($payload);
        return;
    }

    // ── POST/GET /api/appointments/{id}/messages ──
    if (preg_match('#^/api/appointments/([^/]+)/messages$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        if ($method === 'POST') {
            $controller->send($payload, $matches[1]);
        } else {
            $controller->getAppointmentMessages($payload, $matches[1]);
        }
        return;
    }

    // ── GET/PUT/DELETE /api/messages/{id} ──
    if (preg_match('#^/api/messages/([^/]+)$#', $path, $matches)) {
        $payload = AuthMiddleware::authenticate();
        if ($method === 'GET') {
            $controller->get($payload, $matches[1]);
        } elseif ($method === 'PUT') {
            $controller->update($payload, $matches[1]);
        } elseif ($method === 'DELETE') {
            $controller->delete($payload, $matches[1]);
        }
        return;
    }

    Response::error('Route not found in Messages: ' . $method . ' ' . $path, 404);
};
