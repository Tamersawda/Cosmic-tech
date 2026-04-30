<?php
$envPaths = [
    __DIR__ . '/.env',
    'C:/wamp64/www/Cosmic-tech/backend/.env',
    'C:/wamp64/www/Therapy Booking/backend/.env',
];
foreach ($envPaths as $envPath) {
    if (file_exists($envPath)) {
        foreach (file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
            if (strpos($line, '#') === 0 || strpos($line, '=') === false) continue;
            [$k, $v] = explode('=', $line, 2);
            putenv(trim($k) . '=' . trim($v));
        }
        break;
    }
}

$host = getenv('DB_HOST') ?: 'localhost';
$port = getenv('DB_PORT') ?: '3306';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';
$name = getenv('DB_NAME') ?: 'therapy_booking';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$name;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    echo "--- Admin Users in DB ---\n";
    $stmt = $pdo->query("SELECT id, email, full_name, user_type FROM users WHERE user_type = 'admin'");
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($admins)) {
        echo "No admin users found in the database!\n";
        
        // Auto-create one
        echo "\nCreating a default admin user...\n";
        $email = 'admin@cosmic.com';
        $password = 'adminpass';
        $hash = password_hash($password, PASSWORD_BCRYPT);
        
        $insert = $pdo->prepare("INSERT INTO users (id, email, password, full_name, user_type, is_active) VALUES (UUID(), ?, ?, 'Super Admin', 'admin', 1)");
        $insert->execute([$email, $hash]);
        
        echo "Created admin! Email: $email | Password: $password\n";
    } else {
        foreach ($admins as $a) {
            echo "- Email: {$a['email']} | Name: {$a['full_name']}\n";
        }
        
        // Force reset the password for the first admin found to 'adminpass'
        $firstAdmin = $admins[0];
        $newPass = 'adminpass';
        $hash = password_hash($newPass, PASSWORD_BCRYPT);
        
        $update = $pdo->prepare("UPDATE users SET password = ? WHERE id = ?");
        $update->execute([$hash, $firstAdmin['id']]);
        
        echo "\n=> Password for {$firstAdmin['email']} has been forcibly reset to: $newPass\n";
    }

} catch (PDOException $e) {
    echo "DB Error: " . $e->getMessage() . "\n";
}
