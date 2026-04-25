<?php

use Backend\Controllers\AuthController;
use Backend\Controllers\DoctorProfileController;
use Backend\Controllers\ClientProfileController;
use Backend\Controllers\AdminController;
use Backend\Controllers\AppointmentController;
use Backend\Controllers\AvailableSlotController;
use Backend\Controllers\ConsultationController;
use Backend\Controllers\MessageController;
use Backend\Middleware\AuthMiddleware;
use Backend\Utils\Response;

// Disable Xdebug HTML errors - we want JSON
ini_set('xdebug.mode', 'off');
if (function_exists('xdebug_disable')) {
    xdebug_disable();
}

// Enable error reporting for development
if (getenv('APP_ENV') === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// Set error handler to output JSON
set_error_handler(function($errno, $errstr, $errfile, $errline) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $errstr,
        'error' => $errstr,
        'file' => $errfile,
        'line' => $errline
    ]);
    exit;
});

// Set exception handler to output JSON
set_exception_handler(function($exception) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $exception->getMessage(),
        'error' => $exception->getMessage(),
        'file' => $exception->getFile(),
        'line' => $exception->getLine()
    ]);
    exit;
});

// Autoloader (if not already handled by index.php)
if (!class_exists('Backend\Utils\Response')) {
    if (file_exists(__DIR__ . '/vendor/autoload.php')) {
        require_once __DIR__ . '/vendor/autoload.php';
    } else {
        spl_autoload_register(function($class) {
            $prefix = 'Backend\\';
            if (strpos($class, $prefix) === 0) {
                $relativeClass = substr($class, strlen($prefix));
                $file = __DIR__ . '/' . str_replace('\\', '/', $relativeClass) . '.php';
                if (file_exists($file)) {
                    require_once $file;
                }
            }
        });
    }
}

// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Clean path
$basePaths = ['/api.php', '/api', '/cosmic-tech/backend', '/backend'];
foreach ($basePaths as $base) {
    if (strpos($path, $base) === 0) {
        $path = substr($path, strlen($base));
    }
}

// Normalize path
$path = strtolower(trim($path));
if (empty($path)) $path = '/';

// Legacy fallback for api.php
// This handles any routes not caught by modular routers in index.php

$authController = new AuthController();
$clientController = new ClientProfileController();
$doctorController = new DoctorProfileController();
$appointmentController = new AppointmentController();
$consultationController = new ConsultationController();
$messageController = new MessageController();
$slotController = new AvailableSlotController();

// ------------------------------------------------------------------
// AUTH ROUTES
// ------------------------------------------------------------------
if ($method === 'POST' && ($path === '/auth/register' || $path === '/register')) {
    $authController->register();
    exit;
}

if ($method === 'POST' && ($path === '/auth/login' || $path === '/login')) {
    $authController->login();
    exit;
}

if ($method === 'POST' && ($path === '/auth/logout' || $path === '/logout')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $authController->logout($payload);
    exit;
}

if ($method === 'GET' && ($path === '/auth/me' || $path === '/me')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $authController->getCurrentUser($payload);
    exit;
}

// ------------------------------------------------------------------
// CLIENT ROUTES (Legacy Patient mapping)
// ------------------------------------------------------------------
if ($path === '/clients/profile' || $path === '/patient-profile' || $path === '/clients/setup' || $path === '/patients/setup') {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;
    
    if ($method === 'POST') {
        $clientController->setup($payload);
    } else {
        $clientController->getProfile($payload);
    }
    exit;
}

// ------------------------------------------------------------------
// DOCTOR ROUTES
// ------------------------------------------------------------------
if ($path === '/doctors/profile' || $path === '/doctor-profile' || $path === '/doctors/setup') {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;

    if ($method === 'POST') {
        $doctorController->setup($payload);
    } else {
        $doctorController->getByUserId($payload);
    }
    exit;
}

if ($method === 'GET' && ($path === '/doctors' || $path === '/api/doctors')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $doctorController->list($payload);
    exit;
}

// ------------------------------------------------------------------
// APPOINTMENT ROUTES
// ------------------------------------------------------------------
if ($method === 'POST' && ($path === '/appointments' || $path === '/api/appointments')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $appointmentController->book($payload);
    exit;
}

if ($method === 'GET' && ($path === '/appointments' || $path === '/api/appointments')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $appointmentController->getAppointments($payload);
    exit;
}

if ($path === '/appointments/client' || $path === '/appointments/patient') {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $appointmentController->getClientAppointments($payload);
    exit;
}

if ($path === '/appointments/doctor') {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $appointmentController->getDoctorAppointments($payload);
    exit;
}

if (preg_match('#^/appointments/([^/]+)/cancel$#', $path, $matches)) {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $appointmentController->cancel($payload, $matches[1]);
    exit;
}

if (preg_match('#^/appointments/([^/]+)$#', $path, $matches)) {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;
    $appointmentId = $matches[1];

    if ($method === 'GET') $appointmentController->get($payload, $appointmentId);
    elseif ($method === 'PUT') $appointmentController->update($payload, $appointmentId);
    exit;
}

// ------------------------------------------------------------------
// AVAILABLE SLOT ROUTES
// ------------------------------------------------------------------
if ($path === '/appointments/available-slots' && $method === 'GET') {
    $payload = AuthMiddleware::authenticate();
    if ($payload) $slotController->getSlots($payload);
    exit;
}

if (strpos($path, '/available-slots') === 0) {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;

    $normalizedPath = substr($path, 16);
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'POST' && $normalizedPath === '/') {
        $slotController->create($payload);
    } elseif ($method === 'GET' && strpos($normalizedPath, '/doctor/') === 0) {
        $doctorId = substr($normalizedPath, 8);
        $slotController->getDoctorSlots($payload, $doctorId);
    } elseif (preg_match('#^/([^/]+)$#', $normalizedPath, $matches)) {
        $slotId = $matches[1];
        if ($method === 'GET') $slotController->get($payload, $slotId);
        elseif ($method === 'PUT') $slotController->update($payload, $slotId);
        elseif ($method === 'DELETE') $slotController->delete($payload, $slotId);
    }
    exit;
}

// ------------------------------------------------------------------
// CONSULTATION ROUTES
// ------------------------------------------------------------------
if (strpos($path, '/consultations') === 0) {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;

    $normalizedPath = substr($path, 14);
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'GET' && $normalizedPath === '/client') {
        $consultationController->getClientConsultations($payload);
    } elseif ($method === 'GET' && $normalizedPath === '/doctor') {
        $consultationController->getDoctorConsultations($payload);
    } elseif (preg_match('#^/([^/]+)/start$#', $normalizedPath, $matches)) {
        $consultationController->start($payload, $matches[1]);
    } elseif (preg_match('#^/([^/]+)/end$#', $normalizedPath, $matches)) {
        $consultationController->end($payload, $matches[1]);
    } elseif (preg_match('#^/([^/]+)$#', $normalizedPath, $matches)) {
        $consultationController->get($payload, $matches[1]);
    }
    exit;
}

// ------------------------------------------------------------------
// MESSAGE ROUTES
// ------------------------------------------------------------------
if (strpos($path, '/messages') === 0) {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;

    $normalizedPath = substr($path, 9);
    if (empty($normalizedPath)) $normalizedPath = '/';

    if ($method === 'GET' && $normalizedPath === '/inbox') {
        $messageController->getInbox($payload);
    } elseif ($method === 'GET' && $normalizedPath === '/sent') {
        $messageController->getSent($payload);
    } elseif ($method === 'POST' && $normalizedPath === '/') {
        $messageController->sendMessage($payload);
    } elseif (preg_match('#^/([^/]+)$#', $normalizedPath, $matches)) {
        $messageId = $matches[1];
        if ($method === 'GET') $messageController->get($payload, $messageId);
        elseif ($method === 'PUT') $messageController->update($payload, $messageId);
        elseif ($method === 'DELETE') $messageController->delete($payload, $messageId);
    }
    exit;
}

if (preg_match('#^/appointments/([^/]+)/messages$#', $path, $matches)) {
    $payload = AuthMiddleware::authenticate();
    if (!$payload) exit;
    
    if ($method === 'POST') $messageController->send($payload, $matches[1]);
    else $messageController->getAppointmentMessages($payload, $matches[1]);
    exit;
}

// ------------------------------------------------------------------
// FALLBACK 404
// ------------------------------------------------------------------
http_response_code(404);
Response::error('Route not found in api.php: ' . $method . ' ' . $path, 404);
