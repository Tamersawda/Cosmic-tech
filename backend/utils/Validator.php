<?php

namespace Backend\Utils;

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
                if (empty($value)) {
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
        }
    }

    private function applyRuleWithParams(string $field, mixed $value, string $rule, array $params): void {
        switch ($rule) {
            case 'min':
                if ($value && strlen($value) < $params[0]) {
                    $this->addError($field, "{$field} must be at least {$params[0]} characters");
                }
                break;

            case 'in':
                if ($value && !in_array($value, $params)) {
                    $this->addError($field, "{$field} must be one of: " . implode(', ', $params));
                }
                break;
        }
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
