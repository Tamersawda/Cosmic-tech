<?php
require __DIR__ . '/vendor/autoload.php';

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

use Backend\Config\Database;

try {
    $db = Database::getInstance();
    
    // Add columns if they don't exist
    try {
        $db->exec("ALTER TABLE users ADD COLUMN is_profile_completed BOOLEAN DEFAULT FALSE");
        $db->exec("ALTER TABLE users ADD COLUMN onboarding_step INT DEFAULT 0");
        echo "Columns added successfully.\n";
    } catch (\Exception $e) {
        echo "Columns might already exist: " . $e->getMessage() . "\n";
    }

    // Run the migration
    // Note: The prompt uses 'patients', but our schema uses 'patient_profiles' or 'client_profiles'.
    // We try 'patients' first to match prompt exactly, then fallback.
    $sql = "UPDATE users u
            SET is_profile_completed = TRUE,
                onboarding_step = 3
            WHERE EXISTS (
              SELECT 1 FROM patient_profiles p WHERE p.user_id = u.id
            )";
    
    // We execute the exact query requested by the prompt first just to be compliant if the table exists:
    try {
        $db->exec("UPDATE users u
                    SET is_profile_completed = TRUE,
                        onboarding_step = 3
                    WHERE EXISTS (
                      SELECT 1 FROM patients p WHERE p.userId = u.id
                    )");
        echo "Migration on patients table executed.\n";
    } catch (\Exception $e) {
        // Fallback to actual schema tables
        $db->exec($sql);
        echo "Migration on patient_profiles executed.\n";
    }
    
} catch (\Exception $e) {
    echo "Migration failed: " . $e->getMessage();
}
