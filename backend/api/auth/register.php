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
    $role = trim($data['role'] ?? '');

    // Validation Rules
    if (empty($email)) {
        echo json_encode(["success" => false, "message" => "Email is required"]);
        exit;
    }
    if (empty($password)) {
        echo json_encode(["success" => false, "message" => "Password is required"]);
        exit;
    }
    if (empty($role)) {
        echo json_encode(["success" => false, "message" => "Role is required"]);
        exit;
    }
    if (!in_array($role, ['patient', 'doctor'])) {
        echo json_encode(["success" => false, "message" => "Invalid role"]);
        exit;
    }

    $db = \Backend\Config\Database::getInstance();

    // Check if email exists
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        echo json_encode(["success" => false, "message" => "Email already exists"]);
        exit;
    }

    // Begin transaction
    $db->beginTransaction();

    // 5. PASSWORD HANDLING
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);
    
    // Step 2: Insert into users table
    $stmt = $db->prepare("INSERT INTO users (email, password, userType) VALUES (?, ?, ?)");
    $stmt->execute([$email, $passwordHash, $role]);

    // Step 3: Get inserted userId
    $userId = $db->lastInsertId();

    // Step 4: Insert into patients OR doctors
    if ($role === 'patient') {
        $firstName = trim($data['firstName'] ?? '');
        $lastName = trim($data['lastName'] ?? '');
        if (empty($firstName) || empty($lastName)) {
            $db->rollBack();
            echo json_encode(["success" => false, "message" => "Patient requires firstName and lastName"]);
            exit;
        }
        $stmt = $db->prepare("INSERT INTO patients (userId, firstName, lastName) VALUES (?, ?, ?)");
        $stmt->execute([$userId, $firstName, $lastName]);
    } else if ($role === 'doctor') {
        $fullName = trim($data['fullName'] ?? '');
        if (empty($fullName)) {
            $db->rollBack();
            echo json_encode(["success" => false, "message" => "Doctor requires fullName"]);
            exit;
        }
        $stmt = $db->prepare("INSERT INTO doctors (userId, fullName) VALUES (?, ?)");
        $stmt->execute([$userId, $fullName]);
    }

    $db->commit();

    echo json_encode([
        "success" => true,
        "message" => "Registration successful",
        "userId" => $userId
    ]);

} catch (\Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    echo json_encode(["success" => false, "message" => "Server error: " . $e->getMessage()]);
}
