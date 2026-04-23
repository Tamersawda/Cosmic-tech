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
}