#!/usr/bin/env php
<?php

/**
 * Backend Setup and Installation Script
 * 
 * Automatically:
 * 1. Checks PHP version
 * 2. Verifies Composer is installed
 * 3. Installs PHP dependencies
 * 4. Checks database connection
 * 5. Verifies schema is imported
 * 6. Sets up environment variables
 */

echo "\n";
echo "╔══════════════════════════════════════════════════════════╗\n";
echo "║  Therapy Booking Platform - Backend Setup Wizard         ║\n";
echo "╚══════════════════════════════════════════════════════════╝\n\n";

$errors = [];
$warnings = [];

// ============================================================
// 1. Check PHP Version
// ============================================================
echo "[1/6] Checking PHP version...\n";
$phpVersion = phpversion();
$requiredVersion = '7.4.0';

if (version_compare($phpVersion, $requiredVersion, '>=')) {
    echo "  ✓ PHP {$phpVersion} (required: >= {$requiredVersion})\n\n";
} else {
    $errors[] = "PHP version {$phpVersion} is too old. Minimum required: {$requiredVersion}";
    echo "  ✗ PHP {$phpVersion} (required: >= {$requiredVersion})\n\n";
}

// ============================================================
// 2. Check Composer
// ============================================================
echo "[2/6] Checking Composer...\n";
exec('composer --version 2>&1', $composerOutput, $composerCode);

if ($composerCode === 0) {
    $version = $composerOutput[0] ?? 'Unknown';
    echo "  ✓ {$version}\n\n";
} else {
    $errors[] = "Composer is not installed. Install from https://getcomposer.org/";
    echo "  ✗ Composer not found\n\n";
}

// ============================================================
// 3. Install Dependencies
// ============================================================
echo "[3/6] Installing PHP dependencies...\n";

$backendDir = __DIR__;
$composerFile = "{$backendDir}/composer.json";

if (file_exists($composerFile)) {
    echo "  Running: composer install\n";
    
    $oldDir = getcwd();
    chdir($backendDir);
    $output = shell_exec('composer install 2>&1');
    chdir($oldDir);
    
    if (strpos($output, 'completed') !== false || strpos($output, 'up to date') !== false) {
        echo "  ✓ Dependencies installed\n\n";
    } else {
        $warnings[] = "Composer output:\n{$output}";
        echo "  ⚠ Check composer output above\n\n";
    }
} else {
    $errors[] = "composer.json not found in {$backendDir}";
    echo "  ✗ composer.json not found\n\n";
}

// ============================================================
// 4. Check Environment File
// ============================================================
echo "[4/6] Checking environment configuration...\n";

$envFile = "{$backendDir}/.env";
$envExampleFile = "{$backendDir}/.env.example";

if (!file_exists($envFile)) {
    if (file_exists($envExampleFile)) {
        echo "  Creating .env from .env.example...\n";
        copy($envExampleFile, $envFile);
        echo "  ✓ .env created\n";
    } else {
        $errors[] = ".env and .env.example not found";
        echo "  ✗ .env file not found\n";
    }
} else {
    echo "  ✓ .env file exists\n";
}

// Load environment
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0 || strpos($line, '=') === false) continue;
        [$key, $value] = explode('=', $line, 2);
        putenv(trim($key) . '=' . trim($value));
    }
    echo "  ✓ Environment variables loaded\n\n";
} else {
    echo "  ⚠ Could not load .env\n\n";
}

// ============================================================
// 5. Check Database Connection
// ============================================================
echo "[5/6] Checking database connection...\n";

$dbConfig = [
    'host' => getenv('DB_HOST') ?: 'localhost',
    'port' => getenv('DB_PORT') ?: 3306,
    'user' => getenv('DB_USER') ?: 'root',
    'password' => getenv('DB_PASSWORD') ?: '',
    'database' => getenv('DB_NAME'),
];

if (!$dbConfig['database']) {
    echo "  ⚠ DB_NAME not set in .env\n\n";
    $warnings[] = "Update .env with your database name";
} else {
    try {
        $dsn = "mysql:host={$dbConfig['host']};port={$dbConfig['port']};charset=utf8mb4";
        $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        ]);
        
        // Check if database exists
        $stmt = $pdo->query("SELECT 1 FROM information_schema.schemata WHERE schema_name = '{$dbConfig['database']}'");
        if ($stmt && $stmt->fetch()) {
            echo "  ✓ Database '{$dbConfig['database']}' exists\n";
            
            // Check if users table exists
            $db = new PDO(
                "mysql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['database']};charset=utf8mb4",
                $dbConfig['user'],
                $dbConfig['password'],
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );
            
            $stmt = $db->query("SHOW TABLES LIKE 'users'");
            if ($stmt->fetch()) {
                echo "  ✓ 'users' table exists\n";
            } else {
                $warnings[] = "Schema not imported. Run: mysql -u {$dbConfig['user']} {$dbConfig['database']} < schema.sql";
                echo "  ⚠ 'users' table not found (schema not imported)\n";
            }
        } else {
            echo "  ⚠ Database '{$dbConfig['database']}' does not exist\n";
            $warnings[] = "Create database: CREATE DATABASE {$dbConfig['database']};";
        }
        
        echo "\n";
    } catch (PDOException $e) {
        $errors[] = "Database connection failed: " . $e->getMessage();
        echo "  ✗ Connection failed: " . $e->getMessage() . "\n\n";
    }
}

// ============================================================
// 6. Verify Core Files
// ============================================================
echo "[6/6] Verifying core files...\n";

$requiredFiles = [
    '/config/Database.php' => 'Database configuration',
    '/config/JWT.php' => 'JWT handler',
    '/controllers/AuthController.php' => 'Auth controller',
    '/middleware/AuthMiddleware.php' => 'Auth middleware',
    '/models/User.php' => 'User model',
    '/routes/auth.php' => 'Auth routes',
    '/utils/Response.php' => 'Response helper',
    '/utils/Validator.php' => 'Validator utility',
    '/index.php' => 'Entry point',
];

$allFilesExist = true;
foreach ($requiredFiles as $file => $description) {
    if (file_exists($backendDir . $file)) {
        echo "  ✓ {$description}\n";
    } else {
        echo "  ✗ {$description} NOT FOUND: {$file}\n";
        $allFilesExist = false;
    }
}

if ($allFilesExist) {
    echo "\n";
} else {
    echo "\n";
    $errors[] = "Some required files are missing";
}

// ============================================================
// Summary
// ============================================================
echo "╔══════════════════════════════════════════════════════════╗\n";
echo "║  SETUP SUMMARY                                           ║\n";
echo "╚══════════════════════════════════════════════════════════╝\n\n";

if (empty($errors)) {
    echo "✓ All checks passed!\n\n";
} else {
    echo "✗ Setup encountered errors:\n";
    foreach ($errors as $i => $error) {
        echo "  " . ($i + 1) . ". {$error}\n";
    }
    echo "\n";
}

if (!empty($warnings)) {
    echo "⚠ Warnings:\n";
    foreach ($warnings as $i => $warning) {
        echo "  " . ($i + 1) . ". {$warning}\n";
    }
    echo "\n";
}

// ============================================================
// Next Steps
// ============================================================
echo "Next Steps:\n";
echo "  1. Update .env with your database credentials\n";
echo "  2. Import schema: mysql -u root therapy_booking < schema.sql\n";
echo "  3. Start server: php -S localhost:8000 index.php\n";
echo "  4. Test: curl http://localhost:8000/api/auth/register\n\n";

echo "Documentation: See README.md and QUICK_START.md\n\n";

if (!empty($errors)) {
    exit(1);
}

exit(0);
