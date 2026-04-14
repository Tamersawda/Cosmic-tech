<?php

namespace Backend\Utils;

class Response {
    public static function success(array $data, int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'data' => $data,
        ]);
        exit;
    }

    public static function error(string $message, int $statusCode = 400, ?array $data = null): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        
        $response = [
            'success' => false,
            'message' => $message,
        ];
        
        if ($data) {
            $response['errors'] = $data;
        }
        
        echo json_encode($response);
        exit;
    }

    public static function validation(array $errors): void {
        self::error('Validation failed', 400, $errors);
    }
}
