<?php
namespace Backend\Utils;
class Validator
{
    public function validate($data, $rules)
    {
        $errors = [];

        foreach ($rules as $field => $fieldRules) {

            $valueExists = array_key_exists($field, $data);
            $value = $valueExists ? $data[$field] : null;

            foreach ($fieldRules as $rule) {

                // 🔴 REQUIRED
                if ($rule === 'required') {
                    if (!$valueExists || $value === '' || $value === null) {
                        $errors[$field][] = "$field is required";
                        continue;
                    }
                }

                // 🟡 NULLABLE (skip further validation if empty)
                if ($rule === 'nullable') {
                    if ($value === null || $value === '') {
                        continue 2;
                    }
                }

                // Skip further validation if field not present
                if (!$valueExists) {
                    continue;
                }

                // 🟢 STRING
                if ($rule === 'string') {
                    if (!is_string($value)) {
                        $errors[$field][] = "$field must be a string";
                    }
                }

                // 🟢 NUMERIC
                if ($rule === 'numeric') {
                    if (!is_numeric($value)) {
                        $errors[$field][] = "$field must be numeric";
                    }
                }

                // 🟢 BOOLEAN
                if ($rule === 'boolean') {
                    if (!is_bool($value)) {
                        $errors[$field][] = "$field must be boolean";
                    }
                }

                // 🟢 ARRAY
                if ($rule === 'array') {
                    if (!is_array($value)) {
                        $errors[$field][] = "$field must be an array";
                    }
                }

                // 🟢 EMAIL
                if ($rule === 'email') {
                    if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                        $errors[$field][] = "$field must be a valid email";
                    }
                }

                // 🟢 DATE
                if ($rule === 'date') {
                    if (strtotime($value) === false) {
                        $errors[$field][] = "$field must be a valid date";
                    }
                }

                // 🟢 MIN (string length or numeric)
                if (is_array($rule) && $rule[0] === 'min') {
                    $min = $rule[1];

                    if (is_string($value) && strlen($value) < $min) {
                        $errors[$field][] = "$field must be at least $min characters";
                    }

                    if (is_numeric($value) && $value < $min) {
                        $errors[$field][] = "$field must be at least $min";
                    }
                }

                // 🟢 MAX (string length or numeric)
                if (is_array($rule) && $rule[0] === 'max') {
                    $max = $rule[1];

                    if (is_string($value) && strlen($value) > $max) {
                        $errors[$field][] = "$field must be at most $max characters";
                    }

                    if (is_numeric($value) && $value > $max) {
                        $errors[$field][] = "$field must be at most $max";
                    }
                }

                // 🟢 ENUM / IN
                if (is_array($rule) && $rule[0] === 'in') {
                    $allowed = array_slice($rule, 1);

                    if (!in_array($value, $allowed)) {
                        $errors[$field][] = "$field must be one of: " . implode(', ', $allowed);
                    }
                }
            }
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }

    /**
     * Validate phone number format
     */
    public function validatePhoneNumber(string $phone): bool
    {
        // Remove common formatting characters
        $cleaned = preg_replace('/[^\d+\-\s]/', '', $phone);
        // Check if at least 10 digits remain
        $digits = preg_replace('/[^\d]/', '', $cleaned);
        return strlen($digits) >= 10;
    }

    /**
     * Validate date of birth (must be 18+ years old and in past)
     */
    public function validateDateOfBirth(string $dob): array
    {
        $errors = [];
        
        // Parse date
        $date = strtotime($dob);
        if ($date === false) {
            $errors[] = 'Invalid date format';
            return $errors;
        }

        // Must be in past
        if ($date > time()) {
            $errors[] = 'Date of birth cannot be in the future';
        }

        // Must be 18+ years old
        $age = date_diff(date_create($dob), date_create('today'))->y;
        if ($age < 18) {
            $errors[] = 'You must be at least 18 years old';
        }

        return $errors;
    }

    /**
     * Validate PAN number (Indian PAN format)
     */
    public function validatePANNumber(string $pan): bool
    {
        // PAN format: AAAAA9999A where A is letter and 9 is digit
        return preg_match('/^[A-Z]{5}[0-9]{4}[A-Z]$/', strtoupper($pan)) === 1;
    }

    /**
     * Validate GST number (Indian GST format)
     */
    public function validateGSTNumber(string $gst): bool
    {
        // GST format: 15 alphanumeric characters
        return preg_match('/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$/', strtoupper($gst)) === 1;
    }

    /**
     * Validate IFSC code (Indian IFSC format)
     */
    public function validateIFSCCode(string $ifsc): bool
    {
        // IFSC format: 4 letters, 0, 6 alphanumeric characters (11 total)
        return preg_match('/^[A-Z]{4}0[A-Z0-9]{6}$/', strtoupper($ifsc)) === 1;
    }

    /**
     * Validate account number (basic validation)
     */
    public function validateAccountNumber(string $accountNumber): bool
    {
        // Account numbers are typically 9-18 digits
        $cleaned = preg_replace('/[^\d]/', '', $accountNumber);
        return strlen($cleaned) >= 9 && strlen($cleaned) <= 18;
    }

    /**
     * Validate professional bio length (max 600 chars)
     */
    public function validateBioLength(string $bio): bool
    {
        return strlen($bio) <= 600;
    }

    /**
     * Validate session price (must be positive decimal)
     */
    public function validateSessionPrice($price): bool
    {
        if (!is_numeric($price)) return false;
        $numPrice = floatval($price);
        return $numPrice > 0 && $numPrice <= 99999.99;
    }

    /**
     * Validate session fee tier (must be one of allowed enum values)
     * 
     * @param mixed $tier The fee tier value (should be string)
     * @return string|null Error message if invalid, null if valid
     */
    public function validateSessionFeeTier($tier): ?string
    {
        $allowed = ['799', '999', '1499', '1999', '2499'];
        if (!in_array((string)$tier, $allowed, true)) {
            return "Invalid session fee tier. Allowed values: " . implode(', ', $allowed);
        }
        return null;
    }

    /**
     * Validate file upload MIME type against blocklist
     * 
     * @param string $mimeType The MIME type to validate
     * @return string|null Error message if blocked, null if allowed
     */
    public function validateUploadMimeType(string $mimeType): ?string
    {
        // Blocked MIME types for security
        $blocked = [
            'application/x-php',
            'application/x-phar',
            'application/x-msdownload',
            'application/x-executable',
            'application/x-phtml',
            'text/x-php',
            'text/plain',  // .php files can be served as text/plain
        ];

        // Also check file extensions that might be dangerous
        $blockedExtensions = ['php', 'phar', 'exe', 'phtml', 'pht', 'phps', 'php3', 'php4', 'php5', 'php7'];

        if (in_array($mimeType, $blocked)) {
            return "File type not allowed: $mimeType";
        }

        return null;
    }

    /**
     * Validate file upload size
     * 
     * @param int $fileSizeBytes The file size in bytes
     * @param int $maxMB Maximum allowed size in megabytes (default: 5)
     * @return string|null Error message if too large, null if valid
     */
    public function validateUploadSize(int $fileSizeBytes, int $maxMB = 5): ?string
    {
        $maxBytes = $maxMB * 1024 * 1024;
        if ($fileSizeBytes > $maxBytes) {
            return "File size exceeds $maxMB MB limit (received: " . round($fileSizeBytes / 1024 / 1024, 2) . " MB)";
        }
        return null;
    }

    /**
     * Validate pricing justification (min 10 characters per Blueprint)
     * 
     * @param string $justification The pricing justification text
     * @return string|null Error message if invalid, null if valid
     */
    public function validatePricingJustification(string $justification): ?string
    {
        if (strlen(trim($justification)) < 10) {
            return "Pricing justification must be at least 10 characters long";
        }
        return null;
    }

    /**
     * Validate work type custom value (required if workType='other')
     * 
     * @param string|null $workType The work type value
     * @param string|null $customWorkType The custom work type value (only checked if workType='other')
     * @return string|null Error message if invalid, null if valid
     */
    public function validateWorkTypeConditional(?string $workType, ?string $customWorkType): ?string
    {
        if ($workType === 'other' && empty($customWorkType)) {
            return "Custom work type is required when workType is 'other'";
        }
        return null;
    }

    /**
     * Validate registration type conditional requirements
     * 
     * @param string|null $registrationType The registration type (rci or none)
     * @param bool $hasRciCertificate Whether RCI certificate file was uploaded
     * @param bool $selfDeclarationAccepted Whether self-declaration was accepted
     * @return array Array of error messages (empty if valid)
     */
    public function validateRegistrationTypeConditional(?string $registrationType, bool $hasRciCertificate = false, bool $selfDeclarationAccepted = false): array
    {
        $errors = [];

        if ($registrationType === 'rci') {
            if (!$hasRciCertificate) {
                $errors[] = "RCI certificate upload is required when registrationType is 'rci'";
            }
        } elseif ($registrationType === 'none') {
            if (!$selfDeclarationAccepted) {
                $errors[] = "Self-declaration acceptance is required when registrationType is 'none'";
            }
        }

        return $errors;
    }
}