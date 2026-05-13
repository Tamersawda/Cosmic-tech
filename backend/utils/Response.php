<?php

namespace Backend\Utils;

/**
 * Response — Standardised JSON envelope helpers
 *
 * Success:  { "success": true,  "message": "...", "data": { ... } }
 * Error:    { "success": false, "error": { "code": "...", "message": "...", "details": {} } }
 */
class Response {

    /**
     * Send a successful JSON response.
     *
     * @param array  $data
     * @param string $message
     * @param int    $statusCode
     */
    public static function success(array $data = [], string $message = 'Success', int $statusCode = 200): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Send an error JSON response.
     *
     * @param string $message
     * @param int    $statusCode
     * @param string $errorCode
     * @param array  $details
     */
    public static function error(
        string $message,
        int    $statusCode = 400,
        string $errorCode  = 'BAD_REQUEST',
        array  $details    = []
    ): void {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'error'   => [
                'code'    => $errorCode,
                'message' => $message,
                'details' => $details,
            ],
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Validation error shorthand.
     * Accepts either a flat array of messages or a ['valid'=>…, 'errors'=>…] result from Validator.
     */
    public static function validation(array $errorsOrResult): void {
        // Accept Validator::validate() result directly
        $errors = isset($errorsOrResult['errors']) ? $errorsOrResult['errors'] : $errorsOrResult;
        self::error('Validation failed', 422, 'VALIDATION_ERROR', $errors);
    }

    /**
     * Convenience: 404 Not Found.
     */
    public static function notFound(string $message = 'Resource not found'): void {
        self::error($message, 404, 'NOT_FOUND');
    }

    /**
     * Convenience: 401 Unauthorized.
     */
    public static function unauthorized(string $message = 'Unauthorized'): void {
        self::error($message, 401, 'UNAUTHORIZED');
    }

    /**
     * Convenience: 403 Forbidden.
     */
    public static function forbidden(string $message = 'Forbidden'): void {
        self::error($message, 403, 'FORBIDDEN');
    }
}
