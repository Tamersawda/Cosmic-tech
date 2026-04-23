<?php
$filePath = 'c:\\wamp64\\www\\Therapy Booking\\backend\\postman\\Therapy-Booking-MVP-API.postman_collection.json';
$jsonStr = file_get_contents($filePath);
$data = json_decode($jsonStr, true);

if (!$data) {
    die("Failed to parse JSON\n");
}

function replaceInString($str) {
    // Description replacements
    $str = str_replace("role must be 'doctor'", "userType must be 'doctor'", $str);
    $str = str_replace("role must be 'user' (not 'patient')", "userType must be 'patient'", $str);
    $str = str_replace("Role: user", "Role: patient", $str);
    $str = str_replace("Role: doctor or user", "Role: doctor or patient", $str);
    $str = str_replace("Roles: admin|doctor|user", "Roles: doctor|patient", $str);
    $str = str_replace("Invalid Role (patient)", "Invalid Role (admin)", $str);
    $str = str_replace("role must be one of admin, doctor, or user", "userType must be one of patient or doctor", $str);
    $str = str_replace("Uses fullName (NOT firstName/lastName)", "Uses fullName", $str);
    return $str;
}

function processArray(&$arr) {
    if (!is_array($arr)) return;
    foreach ($arr as $key => &$value) {
        if (is_array($value)) {
            processArray($value);
        } else if (is_string($value)) {
            if ($key === 'description' || $key === 'name') {
                $value = replaceInString($value);
            }
            
            if ($key === 'raw' && (strpos($value, '{') !== false)) {
                // Try to parse raw body as JSON and modify
                $bodyData = json_decode($value, true);
                if (json_last_error() === JSON_ERROR_NONE && is_array($bodyData)) {
                    if (isset($bodyData['name'])) {
                        $bodyData['fullName'] = $bodyData['name'];
                        unset($bodyData['name']);
                    }
                    if (isset($bodyData['role'])) {
                        $bodyData['userType'] = $bodyData['role'] === 'user' ? 'patient' : $bodyData['role'];
                        unset($bodyData['role']);
                    }
                    // For error cases testing
                    if (isset($bodyData['userType']) && $bodyData['userType'] === 'patient' && strpos($arr['name'] ?? '', 'Invalid Role') !== false) {
                        $bodyData['userType'] = 'admin';
                    }
                    $value = json_encode($bodyData, JSON_UNESCAPED_SLASHES);
                }
            }
        }
    }
}

processArray($data);

file_put_contents($filePath, json_encode($data, JSON_UNESCAPED_SLASHES));
echo "Successfully updated Postman collection.\n";
