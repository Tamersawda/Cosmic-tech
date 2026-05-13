<?php

/**
 * API Entry Point
 * Handles routing for the backend.
 */

// -----------------------------
// Error reporting (dev only)
// -----------------------------
if (getenv('APP_ENV') === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// -----------------------------
// Load .env
// -----------------------------
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') === false) continue;

        [$key, $value] = explode('=', $line, 2);
        putenv(trim($key) . '=' . trim($value));
    }
}

// -----------------------------
// Autoloader (PSR-like)
// -----------------------------
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
} else {
    spl_autoload_register(function ($class) {
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

// -----------------------------
// CORS
// -----------------------------
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// -----------------------------
// Extract clean path (CRITICAL FIX)
// -----------------------------
$method = $_SERVER['REQUEST_METHOD'];

// Full URI path
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Detect current script directory dynamically
$scriptName = $_SERVER['SCRIPT_NAME']; 
$baseDir = dirname($scriptName);

// Normalize slashes
$baseDir = rtrim(str_replace('\\', '/', $baseDir), '/');

// Remove base directory from URI
if (strpos($uri, $baseDir) === 0) {
    $path = substr($uri, strlen($baseDir));
} else {
    $path = $uri;
}

// Final normalization
if ($path === '' || $path === false) $path = '/';
if ($path[0] !== '/') $path = '/' . $path;

// -----------------------------
// Routing (STRICT MATCHING)
// ORDER MATTERS:
//   1. /api/auth
//   2. /api/clients
//   3. /api/doctors
//   4. /api/admin
//   5. /api/available-slots       ← NEW
//   6. /api/consultations
//   7. /api/appointments/{id}/messages  ← must come BEFORE /api/appointments
//   8. /api/appointments           ← NEW (also handles /api/appointments/available-slots)
//   9. /api/messages
//  10. fallback
// -----------------------------
try {

    if (strpos($path, '/api/auth') === 0 || strpos($path, '/auth') === 0) {
        $router = require __DIR__ . '/routes/auth.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/clients') === 0 || strpos($path, '/clients') === 0) {
        $router = require __DIR__ . '/routes/clients.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/doctors') === 0 || strpos($path, '/doctors') === 0) {
        $router = require __DIR__ . '/routes/doctors.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/admin') === 0 || strpos($path, '/admin') === 0) {
        $router = require __DIR__ . '/routes/admin.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/available-slots') === 0 || strpos($path, '/available-slots') === 0) {
        // Available Slots — standalone CRUD endpoints
        $router = require __DIR__ . '/routes/slots.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/consultations') === 0 || strpos($path, '/consultations') === 0) {
        $router = require __DIR__ . '/routes/consultations.php';
        $router($method, $path);

    } elseif (preg_match('#^/api/appointments/[^/]+/messages#', $path)) {
        // Appointment-scoped messages — MUST match before generic /api/appointments
        $router = require __DIR__ . '/routes/messages.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/appointments') === 0 || strpos($path, '/appointments') === 0) {
        // Appointments — booking, CRUD, list, and also /api/appointments/available-slots
        $router = require __DIR__ . '/routes/appointments.php';
        $router($method, $path);

    } elseif (strpos($path, '/api/messages') === 0 || strpos($path, '/messages') === 0) {
        // Standalone messages — inbox, sent, CRUD
        $router = require __DIR__ . '/routes/messages.php';
        $router($method, $path);

    } else {
        // Fallback (legacy support)
        if (file_exists(__DIR__ . '/api.php')) {
            require __DIR__ . '/api.php';
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => "Route not found: $method $path"
            ]);
        }
    }

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => [
            'code'    => 'INTERNAL_SERVER_ERROR',
            'message' => 'Internal Server Error',
            'details' => getenv('APP_ENV') === 'development'
                ? ['exception' => $e->getMessage(), 'file' => $e->getFile(), 'line' => $e->getLine()]
                : []
        ]
    ]);
}