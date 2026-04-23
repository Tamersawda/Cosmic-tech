<?php
/**
 * DEPRECATED: This file has been replaced by ClientProfile.php.
 */
namespace Backend\Models;

class PatientProfile {
    public function __construct() {
        error_log('Access to deprecated model PatientProfile detected.');
        throw new \Exception('PatientProfile model is deprecated. Use ClientProfile instead.');
    }
}
