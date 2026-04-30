<?php
/**
 * Safe Migration Runner
 * Detects current DB state and applies only what is needed.
 * Run once via: php run_migration.php
 */

// Load .env
if (file_exists(__DIR__ . '/.env')) {
    foreach (file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos($line, '#') === 0 || strpos($line, '=') === false) continue;
        [$k, $v] = explode('=', $line, 2);
        putenv(trim($k) . '=' . trim($v));
    }
}

$host = getenv('DB_HOST') ?: 'localhost';
$port = getenv('DB_PORT') ?: '3306';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';
$name = getenv('DB_NAME') ?: 'therapy_booking';

echo "=== Therapy Booking — Migration Runner ===\n";
echo "Connecting to $host:$port database '$name'...\n\n";

try {
    $pdo = new PDO("mysql:host=$host;port=$port;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    // ── Step 1: Ensure database exists ──────────────────────────────────────
    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$name` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("USE `$name`");
    echo "[OK] Database '$name' selected.\n";

    // ── Step 2: Detect current state ────────────────────────────────────────
    $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    $hasPatient  = in_array('patient_profiles', $tables);
    $hasClient   = in_array('client_profiles',  $tables);
    $hasUsers    = in_array('users', $tables);

    echo "[INFO] Tables found: " . implode(', ', $tables ?: ['(none)']) . "\n\n";

    // ── Step 3: Fresh install — run full schema ──────────────────────────────
    if (!$hasUsers) {
        echo "[ACTION] No existing tables — running full combined_schema.sql...\n";
        $sql = file_get_contents(__DIR__ . '/db/combined_schema.sql');
        // Split by statement
        foreach (array_filter(array_map('trim', explode(';', $sql))) as $stmt) {
            if ($stmt) {
                try {
                    $pdo->exec($stmt);
                } catch (PDOException $e) {
                    echo "  [WARN] " . $e->getMessage() . "\n";
                }
            }
        }
        echo "[OK] Full schema applied.\n";
        exit(0);
    }

    // ── Step 4: Migrate patient → client (old schema) ───────────────────────
    if ($hasPatient && !$hasClient) {
        echo "[ACTION] Old schema detected (patient_profiles). Running migration...\n";

        $pdo->exec("SET FOREIGN_KEY_CHECKS = 0");

        // 4a. Rename table
        $pdo->exec("RENAME TABLE patient_profiles TO client_profiles");
        echo "  [OK] Renamed patient_profiles → client_profiles\n";

        // 4b. Rename column in appointments
        if (in_array('appointments', $tables)) {
            $cols = $pdo->query("SHOW COLUMNS FROM appointments")->fetchAll(PDO::FETCH_COLUMN);
            if (in_array('patient_id', $cols)) {
                $pdo->exec("ALTER TABLE appointments CHANGE patient_id client_id CHAR(36) NOT NULL");
                echo "  [OK] Renamed appointments.patient_id → client_id\n";
            }
        }

        // 4c. Rename column in reviews
        if (in_array('reviews', $tables)) {
            $cols = $pdo->query("SHOW COLUMNS FROM reviews")->fetchAll(PDO::FETCH_COLUMN);
            if (in_array('patient_id', $cols)) {
                $pdo->exec("ALTER TABLE reviews CHANGE patient_id client_id CHAR(36) NOT NULL");
                echo "  [OK] Renamed reviews.patient_id → client_id\n";
            }
        }

        // 4d. Fix users.user_type enum
        // First expand to include all values safely
        $pdo->exec("ALTER TABLE users MODIFY COLUMN user_type ENUM('admin','doctor','user','client') NOT NULL");
        // Migrate existing 'user' values to 'client'
        $updated = $pdo->exec("UPDATE users SET user_type = 'client' WHERE user_type IN ('user', 'patient')");
        echo "  [OK] Migrated $updated user row(s): user_type 'user'/'patient' → 'client'\n";
        // Shrink enum to final set
        $pdo->exec("ALTER TABLE users MODIFY COLUMN user_type ENUM('admin','doctor','client') NOT NULL");
        echo "  [OK] users.user_type enum set to ('admin','doctor','client')\n";

        $pdo->exec("SET FOREIGN_KEY_CHECKS = 1");
        echo "\n[OK] Migration complete.\n";

    } elseif ($hasUsers) {
        echo "[OK] users table exists — checking for profile columns...\n";

        // Check for is_profile_completed
        $userCols = $pdo->query("SHOW COLUMNS FROM users")->fetchAll(PDO::FETCH_COLUMN);
        if (!in_array('is_profile_completed', $userCols)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN is_profile_completed BOOLEAN DEFAULT FALSE AFTER is_active");
            echo "  [OK] Added missing column: is_profile_completed\n";
        }

        if (!in_array('onboarding_step', $userCols)) {
            $pdo->exec("ALTER TABLE users ADD COLUMN onboarding_step INT DEFAULT 0 AFTER is_profile_completed");
            echo "  [OK] Added missing column: onboarding_step\n";
        }

        // Remove medical_history from client_profiles
        if (in_array('client_profiles', $tables)) {
            $clientCols = $pdo->query("SHOW COLUMNS FROM client_profiles")->fetchAll(PDO::FETCH_COLUMN);
            if (in_array('medical_history', $clientCols)) {
                $pdo->exec("ALTER TABLE client_profiles DROP COLUMN medical_history");
                echo "  [OK] Removed column: medical_history from client_profiles\n";
            }
        }

        // Ensure enum is correct even if already migrated
        $enumRow = $pdo->query("SHOW COLUMNS FROM users LIKE 'user_type'")->fetch(PDO::FETCH_ASSOC);
        $enumDef = $enumRow['Type'] ?? '';
        if (strpos($enumDef, "'client'") === false) {
            $pdo->exec("ALTER TABLE users MODIFY COLUMN user_type ENUM('admin','doctor','user','client') NOT NULL");
            $pdo->exec("UPDATE users SET user_type = 'client' WHERE user_type = 'user'");
            $pdo->exec("ALTER TABLE users MODIFY COLUMN user_type ENUM('admin','doctor','client') NOT NULL");
            echo "  [OK] Fixed user_type enum.\n";
        } else {
            echo "  [OK] user_type enum already correct: $enumDef\n";
        }
    }

    // ── Step 5: Ensure available_slots table exists ──────────────────────────
    if (!in_array('available_slots', $tables)) {
        echo "\n[ACTION] available_slots table missing — creating...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS available_slots (
                id              CHAR(36)        NOT NULL DEFAULT (UUID()),
                doctor_id       CHAR(36)        NOT NULL,
                slot_date       DATE            NOT NULL,
                slot_time       TIME            NOT NULL,
                end_time        TIME            NOT NULL,
                duration_minutes SMALLINT       NOT NULL DEFAULT 60,
                is_available    TINYINT(1)      NOT NULL DEFAULT 1,
                created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                UNIQUE KEY uq_slot_doctor_date_time (doctor_id, slot_date, slot_time),
                INDEX idx_slot_doctor_date (doctor_id, slot_date),
                INDEX idx_slot_available (is_available),
                CONSTRAINT fk_slot_doctor
                    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
                    ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ");
        echo "  [OK] available_slots table created.\n";
    } else {
        echo "[OK] available_slots table already exists.\n";
    }

    echo "\n=== All done. Database is ready. ===\n";

} catch (PDOException $e) {
    echo "\n[ERROR] " . $e->getMessage() . "\n";
    exit(1);
}
