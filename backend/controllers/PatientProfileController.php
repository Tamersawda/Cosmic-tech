<?php
/**
 * DEPRECATED: This file has been replaced by ClientProfileController.php.
 * All routing for patients should now point to /api/clients.
 */
http_response_code(410);
echo json_encode([
    'success' => false,
    'message' => 'This endpoint is deprecated. Use /api/clients instead.'
]);
exit;
