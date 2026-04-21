<?php

namespace Backend\Utils;

/**
 * Validator - MVP Implementation
 * Provides comprehensive validation for therapy booking platform
 */
class Validator {
    private array $errors = [];

    public function validate(array $data, array $rules): bool {
        $this->errors = [];

        foreach ($rules as $field => $fieldRules) {
            $value = $data[$field] ?? null;

            foreach ($fieldRules as $rule) {
                if (is_string($rule)) {
                    $this->applyRule($field, $value, $rule);
                } elseif (is_array($rule)) {
                    $ruleName = $rule[0];
                    $params = array_slice($rule, 1);
                    $this->applyRuleWithParams($field, $value, $ruleName, $params);
                }
            }
        }

        return empty($this->errors);
    }

    private function applyRule(string $field, mixed $value, string $rule): void {
        switch ($rule) {
            case 'required':
                if (empty($value) && $value !== 0 && $value !== '0') {
                    $this->addError($field, "{$field} is required");
                }
                break;

            case 'email':
                if ($value && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $this->addError($field, "{$field} must be a valid email");
                }
                break;

            case 'string':
                if ($value !== null && !is_string($value)) {
                    $this->addError($field, "{$field} must be a string");
                }
                break;

            case 'numeric':
                if ($value !== null && !is_numeric($value)) {
                    $this->addError($field, "{$field} must be numeric");
                }
                break;

            case 'array':
                if ($value !== null && !is_array($value)) {
                    $this->addError($field, "{$field} must be an array");
                }
                break;

            case 'integer':
                if ($value !== null && !is_int($value) && !is_numeric($value)) {
                    $this->addError($field, "{$field} must be an integer");
                }
                break;
        }
    }

    private function applyRuleWithParams(string $field, mixed $value, string $rule, array $params): void {
        switch ($rule) {
            case 'min':
                if ($value && strlen((string)$value) < $params[0]) {
                    $this->addError($field, "{$field} must be at least {$params[0]} characters");
                }
                break;

            case 'max':
                if ($value && strlen((string)$value) > $params[0]) {
                    $this->addError($field, "{$field} must not exceed {$params[0]} characters");
                }
                break;

            case 'in':
                if ($value && !in_array($value, $params)) {
                    $this->addError($field, "{$field} must be one of: " . implode(', ', $params));
                }
                break;

            case 'range':
                // range: [min, max]
                if ($value !== null && (intval($value) < $params[0] || intval($value) > $params[1])) {
                    $this->addError($field, "{$field} must be between {$params[0]} and {$params[1]}");
                }
                break;

            case 'date':
                // Validate YYYY-MM-DD format
                if ($value && !$this->isValidDateFormat($value)) {
                    $this->addError($field, "{$field} must be in YYYY-MM-DD format");
                }
                break;

            case 'phone':
                // Basic phone validation (10-15 digits, +, -, spaces)
                if ($value && !preg_match('/^[\d\s\-\+\(\)]{10,15}$/', $value)) {
                    $this->addError($field, "{$field} must be a valid phone number");
                }
                break;

            case 'age':
                // age: [min, max]
                if ($value !== null) {
                    $age = intval($value);
                    if ($age < $params[0] || $age > $params[1]) {
                        $this->addError($field, "{$field} must be between {$params[0]} and {$params[1]}");
                    }
                }
                break;

            case 'minLength':
                if ($value && strlen((string)$value) < $params[0]) {
                    $this->addError($field, "{$field} must be at least {$params[0]} characters");
                }
                break;

            case 'maxLength':
                if ($value && strlen((string)$value) > $params[0]) {
                    $this->addError($field, "{$field} must not exceed {$params[0]} characters");
                }
                break;
        }
    }

    /**
     * Validate YYYY-MM-DD date format
     */
    private function isValidDateFormat(string $date): bool {
        $pattern = '/^\d{4}-\d{2}-\d{2}$/';
        if (!preg_match($pattern, $date)) {
            return false;
        }

        // Check if it's a valid date
        [$year, $month, $day] = explode('-', $date);
        return checkdate((int)$month, (int)$day, (int)$year);
    }

    private function addError(string $field, string $message): void {
        if (!isset($this->errors[$field])) {
            $this->errors[$field] = [];
        }
        $this->errors[$field][] = $message;
    }

    public function getErrors(): array {
        return $this->errors;
    }
}
