<?php

use Backend\Controllers\DoctorProfileController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Doctor Routes
 *
 * POST /api/doctors/setup         - Setup doctor profile
 * GET  /api/doctors/profile       - Get own profile
 * GET  /api/doctors/appointments  - Get own appointments
 * GET  /api/doctors               - List all doctors (public or protected?)
 */
return function(string $method, string $path) {
    $controller = new DoctorProfileController();
    $path = strtolower(trim($path));

    $normalizedPath = $path;
    if (strpos($path, '/api/doctors') === 0) {
        $normalizedPath = substr($path, 12);
    } elseif (strpos($path, '/doctors') === 0) {
        $normalizedPath = substr($path, 8);
    }
    
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'PATCH') {
        if ($normalizedPath === '/status') {
            $payload = AuthMiddleware::authenticate();
            if ($payload === null) {
                Response::error('Unauthorized', 401);
                return;
            }
            // convert payload object to array for controller
            $user = (array)$payload;
            $controller->updateStatus($user);
            return;
        }
    }

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
        if ($normalizedPath === '/profile' || $normalizedPath === '/') {
            // If it's just /api/doctors/, list all. If /api/doctors/profile, get own.
            if ($normalizedPath === '/profile') {
                $payload = AuthMiddleware::authenticate();
                if ($payload === null) {
                    Response::error('Unauthorized', 401);
                    return;
                }
                $controller->getByUserId($payload);
                return;
            } else {
                // List all doctors
                $payload = AuthMiddleware::authenticate(); // or public?
                $controller->list($payload ?: (object)[]);
                return;
            }
        }
        if ($normalizedPath === '/appointments') {
            $payload = AuthMiddleware::authenticate();
            // Delegate to AppointmentController — DoctorProfileController has no getAppointments()
            $apptController = new \Backend\Controllers\AppointmentController();
            $apptController->getDoctorList($payload);
            return;
        }
        
        // Match /api/doctors/{id}
        if (preg_match('/^\/([a-f0-9\-]+)$/i', $normalizedPath, $matches)) {
            $payload = AuthMiddleware::authenticate();
            $controller->getById($payload ?: (object)[], $matches[1]);
            return;
        }
    }

    Response::error('Route not found in Doctors: ' . $method . ' ' . $path, 404);
};
