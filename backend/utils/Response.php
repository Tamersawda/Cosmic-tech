<?php

namespace Backend\Utils;

class Response {
    /**
     * Wrapped success response: {"success": true, "data": {...}}
     */
    public static function success(array $data, int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'data' => $data,
        ]);
        exit;
    }

    /**
     * Flat response: outputs array directly as JSON root (no wrapper).
     * Used by register and login to match frontend expectations.
     */
    public static function flat(array $data, int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    /**
     * Error response: {"message": "..."}  (flat, frontend reads .message)
     */
    public static function error(string $message, int $statusCode = 400, ?array $data = null): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');

        $response = ['message' => $message];

        if ($data) {
            $response['errors'] = $data;
        }

        echo json_encode($response);
        exit;
    }

    public static function validation(array $errors): void {
        self::error('Invalid input', 400, $errors);
    }
}
