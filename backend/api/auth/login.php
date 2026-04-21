<?php
// 2. ERROR VISIBILITY (DEV MODE)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// 3. RESPONSE FORMAT
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit;
}

// Load DB connection
$baseDir = dirname(__DIR__, 2);
if (file_exists($baseDir . '/.env')) {
    $lines = file($baseDir . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0 || strpos($line, '=') === false) continue;
        [$key, $value] = explode('=', $line, 2);
        if (!getenv(trim($key))) putenv(trim($key) . '=' . trim($value));
    }
}
require_once $baseDir . '/config/Database.php';

try {
    // 1. JSON INPUT HANDLING
    $data = json_decode(file_get_contents("php://input"), true);
    if ($data === null) {
        echo json_encode(["success" => false, "message" => "Invalid JSON payload"]);
        exit;
    }

    $email = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';

    // Validation Rules
    if (empty($email)) {
        echo json_encode(["success" => false, "message" => "Email is required"]);
        exit;
    }
    if (empty($password)) {
        echo json_encode(["success" => false, "message" => "Password is required"]);
        exit;
    }

    $db = \Backend\Config\Database::getInstance();

    // Step 2: Fetch user by email
    $stmt = $db->prepare("SELECT id, email, password, userType FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // Step 3: If not found -> error
    if (!$user) {
        echo json_encode(["success" => false, "message" => "Invalid credentials"]);
        exit;
    }

    // Step 4: Verify password
    if (!password_verify($password, $user['password'])) {
        echo json_encode(["success" => false, "message" => "Invalid credentials"]);
        exit;
    }

    // Fetch profile context to align schema
    $profile = [];
    if ($user['userType'] === 'patient') {
        $stmt = $db->prepare("SELECT id as patientId, firstName, lastName FROM patients WHERE userId = ?");
        $stmt->execute([$user['id']]);
        $profile = $stmt->fetch() ?: [];
    } elseif ($user['userType'] === 'doctor') {
        $stmt = $db->prepare("SELECT id as doctorId, fullName FROM doctors WHERE userId = ?");
        $stmt->execute([$user['id']]);
        $profile = $stmt->fetch() ?: [];
    }

    // Step 5: Return success response
    echo json_encode([
        "success" => true,
        "message" => "Login successful",
        "user" => array_merge([
            "id" => $user['id'],
            "email" => $user['email'],
            "role" => $user['userType']
        ], $profile)
    ]);

} catch (\Exception $e) {
    echo json_encode(["success" => false, "message" => "Server error: " . $e->getMessage()]);
}
