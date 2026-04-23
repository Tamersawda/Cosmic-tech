<?php
$url = 'http://localhost/Therapy%20Booking/backend/api/auth/login';
$data = [
    'email' => 'test_client4@example.com',
    'password' => 'password123'
];

$options = [
    'http' => [
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data)
    ]
];
$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

if ($result === FALSE) {
    echo "Error making request";
}

echo "Response:\n$result\n";
