<?php

/**
 * Integration Test: Registration & Qualification Upload
 */

$baseUrl = "http://localhost/Cosmic-tech/backend";

echo "1. Testing Registration...\n";
$registerPayload = json_encode([
    'name' => 'Dr Test',
    'email' => 'drtest_' . time() . '@example.com',
    'password' => 'SecurePass123!',
    'role' => 'doctor'
]);

$ch = curl_init("$baseUrl/api/auth/register");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $registerPayload);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$registerResponse = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Register Response ($httpCode): $registerResponse\n\n";

$registerData = json_decode($registerResponse, true);
if (!$registerData || empty($registerData['success'])) {
    echo "FAILED: Registration did not succeed.\n";
    exit(1);
}

$token = $registerData['data']['token'] ?? '';
$doctorId = $registerData['data']['userId'] ?? '';

if (!$token || !$doctorId) {
    echo "FAILED: Missing token or userId in response.\n";
    exit(1);
}

echo "2. Testing Qualification Upload (Multipart)...\n";
// Create a dummy PDF file for upload
$dummyPdf = __DIR__ . '/dummy.pdf';
file_put_contents($dummyPdf, '%PDF-1.4 dummy content');

$cfile = new CURLFile($dummyPdf, 'application/pdf', 'dummy.pdf');
$postData = [
    'title' => 'MBBS',
    'institution' => 'Test University',
    'year' => '2015',
    'document' => $cfile
];

$ch = curl_init("$baseUrl/api/doctors/$doctorId/qualifications");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer $token"]);
$qualResponse = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Qualification Upload Response ($httpCode): $qualResponse\n\n";

$qualData = json_decode($qualResponse, true);
if (!$qualData || empty($qualData['success'])) {
    echo "FAILED: Qualification upload did not succeed.\n";
    exit(1);
}

echo "3. Testing Qualification List (GET)...\n";
$ch = curl_init("$baseUrl/api/doctors/$doctorId/qualifications");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer $token"]);
$listResponse = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Qualification List Response ($httpCode): $listResponse\n\n";

@unlink($dummyPdf);

echo "ALL TESTS COMPLETED.\n";
