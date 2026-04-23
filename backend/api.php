<?php

use Backend\Controllers\AuthController;
use Backend\Controllers\DoctorProfileController;
use Backend\Controllers\PatientProfileController;
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

// Load environment variables
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        
        [$key, $value] = explode('=', $line, 2);
        $key = trim($key);
        $value = trim($value);
        
        if (!getenv($key)) {
            putenv("{$key}={$value}");
        }
    }
}

// Composer autoloader
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
} else {
    // Simple PSR-4 autoloader for Backend namespace
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

// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];

// Get path from REQUEST_URI or PATH_INFO
$path = isset($_SERVER['PATH_INFO']) ? $_SERVER['PATH_INFO'] : parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Clean up path - remove base paths
$basePaths = [
    '/Therapy Booking/backend',
    '/Therapy%20Booking/backend',
    '/backend',
    '/api',
];

foreach ($basePaths as $basePath) {
    if (strpos($path, $basePath) === 0) {
        $path = substr($path, strlen($basePath));
        break;
    }
}

// Remove api.php from path if present
if (strpos($path, '/api.php') === 0) {
    $path = substr($path, 8); // Remove "/api.php"
}

// Ensure path starts with /
if (empty($path) || $path === '') {
    $path = '/';
}
if ($path[0] !== '/') {
    $path = '/' . $path;
}

// Remove query string if present
if (strpos($path, '?') !== false) {
    $path = substr($path, 0, strpos($path, '?'));
}

// Route handler
$authController = new AuthController();

// Normalize path
$path = strtolower(trim($path));

// Simple path matching
$isRegisterRequest = ($method === 'POST' && (
    $path === '/api/auth/register' ||
    $path === '/auth/register' ||
    strpos($path, '/api/auth/register') === 0 || 
    strpos($path, '/auth/register') === 0
));

$isLoginRequest = ($method === 'POST' && (
    $path === '/api/auth/login' ||
    $path === '/auth/login' ||
    strpos($path, '/api/auth/login') === 0 ||
    strpos($path, '/auth/login') === 0
));

$isMeRequest = ($method === 'GET' && (
    $path === '/api/me' ||
    $path === '/me' ||
    strpos($path, '/api/me') === 0 ||
    strpos($path, '/me') === 0
));

// Doctor profile routes
$isDoctorSetupRequest = ($method === 'POST' && (
    $path === '/api/doctors/setup' ||
    $path === '/doctors/setup' ||
    strpos($path, '/api/doctors/setup') === 0 ||
    strpos($path, '/doctors/setup') === 0
));

$isDoctorAppointmentsRequest = ($method === 'GET' && (
    $path === '/api/doctors/appointments' ||
    $path === '/doctors/appointments' ||
    strpos($path, '/api/doctors/appointments') === 0 ||
    strpos($path, '/doctors/appointments') === 0
));

// Patient profile routes
$isPatientSetupRequest = ($method === 'POST' && (
    $path === '/api/patients/setup' ||
    $path === '/patients/setup' ||
    strpos($path, '/api/patients/setup') === 0 ||
    strpos($path, '/patients/setup') === 0
));

$isPatientAppointmentsRequest = ($method === 'GET' && (
    $path === '/api/patients/appointments' ||
    $path === '/patients/appointments' ||
    strpos($path, '/api/patients/appointments') === 0 ||
    strpos($path, '/patients/appointments') === 0
));

// Appointment routes
$isAppointmentBookRequest = ($method === 'POST' && (
    $path === '/api/appointments' ||
    $path === '/appointments' ||
    strpos($path, '/api/appointments') === 0 ||
    strpos($path, '/appointments') === 0
));

$isAppointmentListRequest = ($method === 'GET' && (
    $path === '/api/appointments' ||
    $path === '/appointments' ||
    strpos($path, '/api/appointments') === 0 ||
    strpos($path, '/appointments') === 0
));

// Check for cancel appointment pattern: /api/appointments/{id}/cancel
$cancelMatch = null;
if ($method === 'PATCH' && preg_match('/^\/api\/appointments\/([a-f0-9\-]+)\/cancel$/i', $path, $matches)) {
    $cancelMatch = $matches[1];
}

if ($isRegisterRequest) {
    $authController->register();
    exit;
}

if ($isLoginRequest) {
    $authController->login();
    exit;
}

if ($isMeRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $authController->getCurrentUser($payload);
    exit;
}

if ($isDoctorSetupRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->setup($payload);
    exit;
}

if ($isDoctorAppointmentsRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->getAppointments($payload);
    exit;
}

if ($isPatientSetupRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $patientController = new PatientProfileController();
    $patientController->setup($payload);
    exit;
}

if ($isPatientAppointmentsRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $patientController = new PatientProfileController();
    $patientController->getAppointments($payload);
    exit;
}

if ($isAppointmentBookRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->book($payload);
    exit;
}

if ($isAppointmentListRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->getAppointments($payload);
    exit;
}

if ($cancelMatch !== null) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->cancel($payload, $cancelMatch);
    exit;
}

// PHASE 4 ROUTES

// Available slots endpoint
$isAvailableSlotsRequest = ($method === 'GET' && (
    $path === '/api/appointments/available-slots' ||
    strpos($path, '/api/appointments/available-slots') === 0
));

// Consultation start: /api/consultations/{id}/start
$startConsultationMatch = null;
if ($method === 'POST' && preg_match('/^\/api\/consultations\/([a-f0-9\-]+)\/start$/i', $path, $matches)) {
    $startConsultationMatch = $matches[1];
}

// Consultation end: /api/consultations/{id}/end
$endConsultationMatch = null;
if ($method === 'POST' && preg_match('/^\/api\/consultations\/([a-f0-9\-]+)\/end$/i', $path, $matches)) {
    $endConsultationMatch = $matches[1];
}

// Send message: /api/appointments/{id}/messages (POST)
$sendMessageMatch = null;
if ($method === 'POST' && preg_match('/^\/api\/appointments\/([a-f0-9\-]+)\/messages$/i', $path, $matches)) {
    $sendMessageMatch = $matches[1];
}

// Get messages: /api/appointments/{id}/messages (GET)
$getMessagesMatch = null;
if ($method === 'GET' && preg_match('/^\/api\/appointments\/([a-f0-9\-]+)\/messages$/i', $path, $matches)) {
    $getMessagesMatch = $matches[1];
}

if ($isAvailableSlotsRequest) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->getSlots($payload);
    exit;
}

if ($startConsultationMatch !== null) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->start($payload, $startConsultationMatch);
    exit;
}

if ($endConsultationMatch !== null) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->end($payload, $endConsultationMatch);
    exit;
}

if ($sendMessageMatch !== null) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->send($payload, $sendMessageMatch);
    exit;
}

if ($getMessagesMatch !== null) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->getAppointmentMessages($payload, $getMessagesMatch);
    exit;
}

// DOCTOR PROFILE ROUTES
if ($method === 'POST' && ($path === '/api/doctor-profile' || $path === '/doctor-profile')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->setup($payload);
    exit;
}

// GET current user's doctor profile
if ($method === 'GET' && ($path === '/api/doctor-profile' || $path === '/doctor-profile')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->getByUserId($payload);
    exit;
}

// GET specific doctor profile by ID
if ($method === 'GET' && preg_match('/^\/api\/doctor-profile\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->getById($payload, $matches[1]);
    exit;
}

// GET ALL DOCTORS
if ($method === 'GET' && ($path === '/api/doctors' || $path === '/doctors')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->list($payload);
    exit;
}

// GET DOCTOR BY ID
if ($method === 'GET' && preg_match('/^\/api\/doctors\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $doctorId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $doctorController = new DoctorProfileController();
    $doctorController->getById($payload, $doctorId);
    exit;
}

// PATIENT PROFILE ROUTES
if ($method === 'POST' && ($path === '/api/patient-profile' || $path === '/patient-profile')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $patientController = new PatientProfileController();
    $patientController->setup($payload);
    exit;
}

// GET current user's patient profile
if ($method === 'GET' && ($path === '/api/patient-profile' || $path === '/patient-profile')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $patientController = new PatientProfileController();
    $patientController->getByUserId($payload);
    exit;
}

// GET specific patient profile by ID
if ($method === 'GET' && preg_match('/^\/api\/patient-profile\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $patientController = new PatientProfileController();
    $patientController->getById($payload, $matches[1]);
    exit;
}

// AVAILABLE SLOTS ROUTES
if ($method === 'POST' && ($path === '/api/available-slots' || $path === '/available-slots')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->create($payload);
    exit;
}
if ($method === 'GET' && preg_match('/^\/api\/available-slots\/doctor\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $doctorId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->getDoctorSlots($payload, $doctorId);
    exit;
}
if ($method === 'GET' && preg_match('/^\/api\/available-slots\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $slotId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->get($payload, $slotId);
    exit;
}
if ($method === 'PUT' && preg_match('/^\/api\/available-slots\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $slotId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->update($payload, $slotId);
    exit;
}
if ($method === 'DELETE' && preg_match('/^\/api\/available-slots\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $slotId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $slotController = new AvailableSlotController();
    $slotController->delete($payload, $slotId);
    exit;
}

// APPOINTMENT ROUTES
if ($method === 'GET' && preg_match('/^\/api\/appointments\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $appointmentId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->get($payload, $appointmentId);
    exit;
}
if ($method === 'PUT' && preg_match('/^\/api\/appointments\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $appointmentId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->update($payload, $appointmentId);
    exit;
}

// GET PATIENT APPOINTMENTS
if ($method === 'GET' && ($path === '/api/appointments/patient' || $path === '/appointments/patient')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->getPatientAppointments($payload);
    exit;
}

// GET DOCTOR APPOINTMENTS
if ($method === 'GET' && ($path === '/api/appointments/doctor' || $path === '/appointments/doctor')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $appointmentController = new AppointmentController();
    $appointmentController->getDoctorAppointments($payload);
    exit;
}

// CONSULTATIONS ROUTES
if ($method === 'POST' && ($path === '/api/consultations' || $path === '/consultations')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->create($payload);
    exit;
}
if ($method === 'GET' && preg_match('/^\/api\/consultations\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $consultationId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->get($payload, $consultationId);
    exit;
}
if ($method === 'PUT' && preg_match('/^\/api\/consultations\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $consultationId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->update($payload, $consultationId);
    exit;
}
if ($method === 'GET' && ($path === '/api/consultations/patient' || $path === '/consultations/patient')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->getPatientConsultations($payload);
    exit;
}
if ($method === 'GET' && ($path === '/api/consultations/doctor' || $path === '/consultations/doctor')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $consultationController = new ConsultationController();
    $consultationController->getDoctorConsultations($payload);
    exit;
}

// MESSAGES ROUTES
if ($method === 'POST' && ($path === '/api/messages' || $path === '/messages')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->sendMessage($payload);
    exit;
}
if ($method === 'GET' && ($path === '/api/messages/inbox' || $path === '/messages/inbox')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->getInbox($payload);
    exit;
}
if ($method === 'GET' && ($path === '/api/messages/sent' || $path === '/messages/sent')) {
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->getSent($payload);
    exit;
}
if ($method === 'GET' && preg_match('/^\/api\/messages\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $messageId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->get($payload, $messageId);
    exit;
}
if ($method === 'PUT' && preg_match('/^\/api\/messages\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $messageId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->update($payload, $messageId);
    exit;
}
if ($method === 'DELETE' && preg_match('/^\/api\/messages\/([a-f0-9\-]+)$/i', $path, $matches)) {
    $messageId = $matches[1];
    $payload = AuthMiddleware::authenticate();
    if ($payload === null) {
        Response::error('Unauthorized', 401);
        exit;
    }
    $messageController = new MessageController();
    $messageController->delete($payload, $messageId);
    exit;
}

// Route not found
http_response_code(404);
Response::error('Route not found: ' . $method . ' ' . $path, 404);
?>
