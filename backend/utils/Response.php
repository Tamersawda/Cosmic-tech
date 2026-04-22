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
            'data'    => $data,
        ]);
        exit;
    }

    /**
     * Flat response — outputs the array directly as the JSON root (no wrapper).
     * Used by register and login to match the exact Flutter frontend contract.
     */
    public static function flat(array $data, int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    /**
     * Error response: {"success": false, "message": "..."}
     * The frontend reads .message for display.
     */
    public static function error(string $message, int $statusCode = 400, ?array $errors = null): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');

        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errors !== null) {
            $response['errors'] = $errors;
        }

        echo json_encode($response);
        exit;
    }

    /**
     * Validation error shorthand.
     */
    public static function validation(array $errors): void {
        self::error('Validation failed', 400, $errors);
    }
}
