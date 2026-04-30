<?php

namespace Backend\Utils;

class Response {
    /**
     * Wrapped success response:
     * {
     *   "success": true,
     *   "message": "...",
     *   "data": {...}
     * }
     */
    public static function success(array $data = [], string $message = 'Success', int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ]);
        exit;
    }

    /**
     * Error response:
     * {
     *   "error": {
     *     "code": "ERROR_CODE",
     *     "message": "...",
     *     "details": {...}
     *   }
     * }
     */
    public static function error(string $message, int $statusCode = 400, string $errorCode = 'BAD_REQUEST', array $details = []): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');

        echo json_encode([
            'error' => [
                'code'    => $errorCode,
                'message' => $message,
                'details' => $details
            ]
        ]);
        exit;
    }

    /**
     * Validation error shorthand.
     */
    public static function validation(array $errors): void {
        self::error('Validation failed', 400, 'VALIDATION_ERROR', $errors);
    }
}
