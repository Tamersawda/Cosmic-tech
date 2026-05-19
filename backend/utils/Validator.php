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
}