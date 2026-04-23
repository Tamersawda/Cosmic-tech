<?php
require_once 'config/Database.php';
use Backend\Config\Database;

function fail($message) {
    echo "❌ FAIL: $message\n";
    exit;
}

function pass($message) {
    echo "✅ $message\n";
}

try {
    $db = Database::getInstance();

    echo "🔍 Running schema validation...\n\n";

    // 1. Check tables exist
    $requiredTables = ['users', 'client_profiles', 'doctor_profiles'];
    foreach ($requiredTables as $table) {
        $stmt = $db->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() === 0) {
            fail("Table missing: $table");
        }
    }
    pass("All required tables exist");

    // 2. Check forbidden columns
    $forbiddenColumns = ['age', 'medical_history', 'patient_id'];

    foreach ($requiredTables as $table) {
        $stmt = $db->query("SHOW COLUMNS FROM $table");
        $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);

        foreach ($forbiddenColumns as $col) {
            if (in_array($col, $columns)) {
                fail("Forbidden column '$col' found in $table");
            }
        }
    }
    pass("No forbidden columns found");

    // 3. Check ENUM values
    $stmt = $db->query("SELECT DISTINCT user_type FROM users");
    $types = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $invalidTypes = array_diff($types, ['admin', 'doctor', 'client']);
    if (!empty($invalidTypes)) {
        fail("Invalid user_type values found: " . implode(', ', $invalidTypes));
    }
    pass("user_type ENUM values are valid");

    // 4. Check foreign key integrity (client_profiles)
    $stmt = $db->query("
        SELECT cp.user_id 
        FROM client_profiles cp
        LEFT JOIN users u ON cp.user_id = u.id
        WHERE u.id IS NULL
    ");
    if ($stmt->rowCount() > 0) {
        fail("Orphan records found in client_profiles");
    }
    pass("client_profiles FK integrity OK");

    // 5. Check foreign key integrity (doctor_profiles)
    $stmt = $db->query("
        SELECT dp.user_id 
        FROM doctor_profiles dp
        LEFT JOIN users u ON dp.user_id = u.id
        WHERE u.id IS NULL
    ");
    if ($stmt->rowCount() > 0) {
        fail("Orphan records found in doctor_profiles");
    }
    pass("doctor_profiles FK integrity OK");

    echo "\n🎯 FINAL RESULT: SCHEMA VALID ✅\n";

} catch (Exception $e) {
    fail($e->getMessage());
}