<?php

/**
 * API Entry Point
 * 
 * Handles routing for the Cosmic Tech Backend.
 */

// Enable error reporting for development
if (getenv('APP_ENV') === 'development') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// Load environment variables
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        
        [$key, $value] = explode('=', $line, 2);
        putenv(trim($key) . '=' . trim($value));
    }
}

// Autoloader
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

// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Clean path - remove base paths
$basePaths = [
    '/cosmic-tech/backend',
    '/Therapy%20Booking/backend',
    '/Therapy Booking/backend',
    '/backend',
];

foreach ($basePaths as $basePath) {
    if (strpos($path, $basePath) === 0) {
        $path = substr($path, strlen($basePath));
        break;
    }
}

// Ensure path starts with /
if (empty($path) || $path === '') $path = '/';
if ($path[0] !== '/') $path = '/' . $path;

// Routing logic
if (strpos($path, '/api/auth') !== false || strpos($path, '/auth') === 0) {
    $router = require __DIR__ . '/routes/auth.php';
    $router($method, $path);
} elseif (strpos($path, '/api/clients') !== false || strpos($path, '/clients') === 0) {
    $router = require __DIR__ . '/routes/clients.php';
    $router($method, $path);
} elseif (strpos($path, '/api/doctors') !== false || strpos($path, '/doctors') === 0) {
    $router = require __DIR__ . '/routes/doctors.php';
    $router($method, $path);
} elseif (strpos($path, '/api/admin') !== false || strpos($path, '/admin') === 0) {
    $router = require __DIR__ . '/routes/admin.php';
    $router($method, $path);
} elseif (strpos($path, '/api/consultations') !== false || strpos($path, '/consultations') === 0) {
    $router = require __DIR__ . '/routes/consultations.php';
    $router($method, $path);
} elseif (strpos($path, '/api/messages') !== false || strpos($path, '/messages') === 0) {
    $router = require __DIR__ . '/routes/messages.php';
    $router($method, $path);
} else {
    // Legacy support for other routes in api.php
    if (file_exists(__DIR__ . '/api.php')) {
        require __DIR__ . '/api.php';
    } else {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Route not found: ' . $method . ' ' . $path
        ]);
    }
}
