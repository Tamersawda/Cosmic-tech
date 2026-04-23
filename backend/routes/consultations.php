<?php

use Backend\Controllers\ConsultationController;

/**
 * Consultation Routes
 */
return function(string $method, string $path) {
    $controller = new ConsultationController();

    // /api/consultations/{id}/start
    if ($method === 'POST' && preg_match('#^/api/consultations/([^/]+)/start$#', $path, $matches)) {
        $controller->start((object)[], $matches[1]);
        return;
    }

    // /api/consultations/{id}/end
    if ($method === 'POST' && preg_match('#^/api/consultations/([^/]+)/end$#', $path, $matches)) {
        $controller->end((object)[], $matches[1]);
        return;
    }

    // /api/consultations/client
    if ($method === 'GET' && $path === '/api/consultations/client') {
        $controller->getClientConsultations((object)[]);
        return;
    }

    // /api/consultations/doctor
    if ($method === 'GET' && $path === '/api/consultations/doctor') {
        $controller->getDoctorConsultations((object)[]);
        return;
    }

    // /api/consultations/{id}
    if ($method === 'GET' && preg_match('#^/api/consultations/([^/]+)$#', $path, $matches)) {
        $controller->get((object)[], $matches[1]);
        return;
    }

    // Default 404 for this route group
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Consultation route not found'
    ]);
};
