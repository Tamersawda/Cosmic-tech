<?php

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
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Clean path - remove multiple possible base paths
$basePaths = [
    '/cosmic-tech/backend',
    '/Therapy%20Booking/backend',
    '/Therapy Booking/backend',
    '/backend',
    '/api',
];

$path = $uri;
foreach ($basePaths as $basePath) {
    if (strpos($path, $basePath) === 0) {
        $path = substr($path, strlen($basePath));
        break;
    }
}

// Ensure path starts with /
if (empty($path) || $path === '') {
    $path = '/';
}
if ($path[0] !== '/') {
    $path = '/' . $path;
}

// Route handler
if (strpos($path, '/api/auth') === 0 || strpos($path, '/auth') === 0) {
    $router = require __DIR__ . '/routes/auth.php';
    $router($method, $path);
} else {
    // Route everything else through api.php
    require __DIR__ . '/api.php';
}
