<?php

use Backend\Controllers\DoctorProfileController;
use Backend\Controllers\DoctorQualificationController;
use Backend\Controllers\DoctorExperienceController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

/**
 * Doctor Routes
 *
 * GET    /api/doctors                                          – list all
 * GET    /api/doctors/profile                                  – own profile (auth)
 * POST   /api/doctors/setup                                    – setup profile (auth, doctor)
 * PATCH  /api/doctors/status                                   – toggle active (auth, doctor)
 * GET    /api/doctors/appointments                             – own appointments (auth, doctor)
 * GET    /api/doctors/{id}                                     – public profile
 *
 * POST   /api/doctors/{id}/qualifications                      – create qual (auth)
 * GET    /api/doctors/{id}/qualifications                      – list quals (auth)
 * GET    /api/doctors/{id}/qualifications/{qid}                – get one qual (auth)
 * PUT    /api/doctors/{id}/qualifications/{qid}                – update qual (auth)
 * DELETE /api/doctors/{id}/qualifications/{qid}               – delete qual (auth)
 *
 * POST   /api/doctors/{id}/experiences                        – create exp (auth)
 * GET    /api/doctors/{id}/experiences                        – list exps (auth)
 * GET    /api/doctors/{id}/experiences/{eid}                  – get one exp (auth)
 * PUT    /api/doctors/{id}/experiences/{eid}                  – update exp (auth)
 * DELETE /api/doctors/{id}/experiences/{eid}                  – delete exp (auth)
 */
return function (string $method, string $path) {

    $controller    = new DoctorProfileController();
    $path          = strtolower(trim($path));

    // Strip prefix
    $normalizedPath = $path;
    if (strpos($path, '/api/doctors') === 0) {
        $normalizedPath = substr($path, 12);
    } elseif (strpos($path, '/doctors') === 0) {
        $normalizedPath = substr($path, 8);
    }
    if ($normalizedPath === '' || $normalizedPath === false) $normalizedPath = '/';

    // ════════════════════════════════════════════════════
    // QUALIFICATIONS  /api/doctors/{id}/qualifications[/{qid}]
    // ════════════════════════════════════════════════════
    if (preg_match('#^/([0-9a-f\-]+)/qualifications(?:/([0-9a-f\-]+))?$#i', $normalizedPath, $m)) {
        $doctorId  = $m[1];
        $qualId    = $m[2] ?? null;
        $qualCtrl  = new DoctorQualificationController();
        $payload   = AuthMiddleware::authenticate();

        match (true) {
            $method === 'GET'    && !$qualId => $qualCtrl->list($doctorId),
            $method === 'GET'    &&  $qualId => $qualCtrl->getOne($doctorId, $qualId),
            $method === 'POST'   && !$qualId => $qualCtrl->create($payload, $doctorId),
            $method === 'PUT'    &&  $qualId => $qualCtrl->update($payload, $doctorId, $qualId),
            $method === 'DELETE' &&  $qualId => $qualCtrl->delete($payload, $doctorId, $qualId),
            default => Response::error('Method not allowed', 405, 'METHOD_NOT_ALLOWED'),
        };
        return;
    }

    // ════════════════════════════════════════════════════
    // EXPERIENCES  /api/doctors/{id}/experiences[/{eid}]
    // ════════════════════════════════════════════════════
    if (preg_match('#^/([0-9a-f\-]+)/experiences(?:/([0-9a-f\-]+))?$#i', $normalizedPath, $m)) {
        $doctorId  = $m[1];
        $expId     = $m[2] ?? null;
        $expCtrl   = new DoctorExperienceController();
        $payload   = AuthMiddleware::authenticate();

        match (true) {
            $method === 'GET'    && !$expId => $expCtrl->list($doctorId),
            $method === 'GET'    &&  $expId => $expCtrl->getOne($doctorId, $expId),
            $method === 'POST'   && !$expId => $expCtrl->create($payload, $doctorId),
            $method === 'PUT'    &&  $expId => $expCtrl->update($payload, $doctorId, $expId),
            $method === 'DELETE' &&  $expId => $expCtrl->delete($payload, $doctorId, $expId),
            default => Response::error('Method not allowed', 405, 'METHOD_NOT_ALLOWED'),
        };
        return;
    }

    // ════════════════════════════════════════════════════
    // PROFILE ROUTES
    // ════════════════════════════════════════════════════

    if ($method === 'PATCH' && $normalizedPath === '/status') {
        $payload = AuthMiddleware::authenticate();
        $controller->updateStatus((array)$payload);
        return;
    }

    if ($method === 'POST' && $normalizedPath === '/setup') {
        $payload = AuthMiddleware::authenticate();
        $controller->setup($payload);
        return;
    }

    if ($method === 'GET') {

        if ($normalizedPath === '/profile') {
            $payload = AuthMiddleware::authenticate();
            $controller->getByUserId($payload);
            return;
        }

        if ($normalizedPath === '/' || $normalizedPath === '') {
            $payload = AuthMiddleware::authenticate();
            $controller->list($payload);
            return;
        }

        if ($normalizedPath === '/appointments') {
            $payload = AuthMiddleware::authenticate();
            $apptController = new \Backend\Controllers\AppointmentController();
            $apptController->getDoctorList($payload);
            return;
        }

        // GET /api/doctors/{id}  — public profile
        if (preg_match('#^/([0-9a-f\-]+)$#i', $normalizedPath, $m)) {
            $payload = AuthMiddleware::authenticate();
            $controller->getById($payload ?: (object)[], $m[1]);
            return;
        }
    }

    Response::error('Route not found: ' . $method . ' /api/doctors' . $normalizedPath, 404, 'NOT_FOUND');
};
