<?php
require_once __DIR__ . '/vendor/autoload.php';

// Load environment variables manually
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        [$key, $value] = explode('=', $line, 2);
        putenv(trim($key) . '=' . trim($value));
    }
}

try {
    $db = \Backend\Config\Database::getInstance();
    
    // First, add 'patient' to the ENUM if it's not already there
    $db->exec("ALTER TABLE users MODIFY user_type ENUM('admin', 'doctor', 'user', 'patient')");
    
    // Update existing 'user' rows to 'patient'
    $stmt = $db->query("UPDATE users SET user_type = 'patient' WHERE user_type = 'user'");
    echo "Updated " . $stmt->rowCount() . " rows from 'user' to 'patient'.\n";
    
    // Modify ENUM to strictly ('patient', 'doctor')
    // Note: I will keep 'admin' just in case, or as requested by user plan: "ALTER TABLE users MODIFY user_type ENUM('patient','doctor');"
    // The user plan specifically says: ENUM('patient','doctor')
    $db->exec("ALTER TABLE users MODIFY user_type ENUM('patient', 'doctor')");
    echo "Successfully updated user_type ENUM to ('patient', 'doctor').\n";
    
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
