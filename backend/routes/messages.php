<?php

use Backend\Controllers\MessageController;

/**
 * Message Routes
 */
return function(string $method, string $path) {
    $controller = new MessageController();

    // /api/messages/inbox
    if ($method === 'GET' && $path === '/api/messages/inbox') {
        $controller->getInbox((object)[]);
        return;
    }

    // /api/messages/sent
    if ($method === 'GET' && $path === '/api/messages/sent') {
        $controller->getSent((object)[]);
        return;
    }

    // /api/messages (send)
    if ($method === 'POST' && $path === '/api/messages') {
        $controller->sendMessage((object)[]);
        return;
    }

    // /api/appointments/{id}/messages (send/get)
    if (preg_match('#^/api/appointments/([^/]+)/messages$#', $path, $matches)) {
        if ($method === 'POST') {
            $controller->send((object)[], $matches[1]);
        } else {
            $controller->getAppointmentMessages((object)[], $matches[1]);
        }
        return;
    }

    // /api/messages/{id} (get/update/delete)
    if (preg_match('#^/api/messages/([^/]+)$#', $path, $matches)) {
        if ($method === 'GET') {
            $controller->get((object)[], $matches[1]);
        } elseif ($method === 'PUT') {
            $controller->update((object)[], $matches[1]);
        } elseif ($method === 'DELETE') {
            $controller->delete((object)[], $matches[1]);
        }
        return;
    }

    // Default 404 for this route group
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Message route not found'
    ]);
};
