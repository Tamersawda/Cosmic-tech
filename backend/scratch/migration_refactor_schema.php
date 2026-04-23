<?php
require_once 'config/Database.php';
use Backend\Config\Database;

/**
 * Migration Script: Refactor Schema for Identity vs Profile Separation
 * 
 * Objectives:
 * 1. Remove firstName, lastName, age, medical_history from all tables.
 * 2. Remove fullName from profile tables (already in users table).
 * 3. Ensure no 'patient' terminology remains.
 */

try {
    $db = Database::getInstance();
    echo "Starting Migration...\n";

    // --- 1. Cleanup client_profiles ------------------------------------------
    echo "Cleaning up client_profiles...\n";
    
    // Check if columns exist before dropping
    $stmt = $db->query("SHOW COLUMNS FROM client_profiles");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $drops = [];
    if (in_array('full_name', $columns)) $drops[] = "DROP COLUMN full_name";
    if (in_array('first_name', $columns)) $drops[] = "DROP COLUMN first_name";
    if (in_array('last_name', $columns)) $drops[] = "DROP COLUMN last_name";
    if (in_array('age', $columns)) $drops[] = "DROP COLUMN age";
    if (in_array('medical_history', $columns)) $drops[] = "DROP COLUMN medical_history";

    if (!empty($drops)) {
        $sql = "ALTER TABLE client_profiles " . implode(", ", $drops);
        $db->exec($sql);
        echo "✅ client_profiles cleaned up.\n";
    } else {
        echo "ℹ️ client_profiles already clean.\n";
    }

    // --- 2. Cleanup doctor_profiles ------------------------------------------
    echo "Cleaning up doctor_profiles...\n";
    
    $stmt = $db->query("SHOW COLUMNS FROM doctor_profiles");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $drops = [];
    if (in_array('full_name', $columns)) $drops[] = "DROP COLUMN full_name";
    if (in_array('age', $columns)) $drops[] = "DROP COLUMN age";

    if (!empty($drops)) {
        $sql = "ALTER TABLE doctor_profiles " . implode(", ", $drops);
        $db->exec($sql);
        echo "✅ doctor_profiles cleaned up.\n";
    } else {
        echo "ℹ️ doctor_profiles already clean.\n";
    }

    // --- 3. Final Verification -----------------------------------------------
    echo "\nVerification:\n";
    $tables = ['users', 'client_profiles', 'doctor_profiles'];
    foreach ($tables as $table) {
        echo "Table: $table\n";
        $stmt = $db->query("DESCRIBE $table");
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo " - {$row['Field']} ({$row['Type']})\n";
        }
    }

    echo "\n🎯 Migration completed successfully!\n";

} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
}
