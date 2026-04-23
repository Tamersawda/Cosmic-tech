<?php

namespace Backend\Config;

class JWT {
    
    public static function encode(array $payload, ?int $customExpiry = null): string {
        $secret = getenv('JWT_SECRET');
        $expiry = $customExpiry ?? (int)(getenv('JWT_EXPIRY') ?: 3600);
        
        if ($secret === false || $secret === '') {
            throw new \Exception('JWT_SECRET not configured. Check .env file.');
        }

        $payload['iat'] = time();
        $payload['exp'] = time() + $expiry;

        // Create header
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload_json = json_encode($payload);
        
        // Encode to base64url
        $encodedHeader = self::base64urlEncode($header);
        $encodedPayload = self::base64urlEncode($payload_json);
        
        // Create signature
        $signature = hash_hmac('sha256', $encodedHeader . '.' . $encodedPayload, $secret, true);
        $encodedSignature = self::base64urlEncode($signature);
        
        return $encodedHeader . '.' . $encodedPayload . '.' . $encodedSignature;
    }

    public static function decode(string $token) {
        $secret = getenv('JWT_SECRET');
        
        if ($secret === false || $secret === '') {
            throw new \Exception('JWT_SECRET not configured. Check .env file.');
        }

        try {
            // Remove "Bearer " prefix if present
            $token = str_replace('Bearer ', '', $token);
            $parts = explode('.', $token);
            
            if (count($parts) !== 3) {
                throw new \Exception('Invalid token format');
            }
            
            [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;
            
            // Verify signature
            $expectedSignature = hash_hmac('sha256', $encodedHeader . '.' . $encodedPayload, $secret, true);
            $expectedSignatureEncoded = self::base64urlEncode($expectedSignature);
            
            if (!hash_equals($encodedSignature, $expectedSignatureEncoded)) {
                throw new \Exception('Invalid token signature');
            }
            
            // Decode payload
            $payload = json_decode(self::base64urlDecode($encodedPayload), true);
            
            if ($payload === null) {
                throw new \Exception('Invalid token payload');
            }
            
            // Check expiration
            if (isset($payload['exp']) && $payload['exp'] < time()) {
                throw new \Exception('Token expired');
            }
            
            return (object)$payload;
        } catch (\Exception $e) {
            throw new \Exception("Token validation failed: " . $e->getMessage());
        }
    }

    public static function getTokenFromHeader(): ?string {
        // Try different header methods
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $auth = $_SERVER['HTTP_AUTHORIZATION'];
        } elseif (isset($_SERVER['Authorization'])) {
            $auth = $_SERVER['Authorization'];
        } else {
            if (function_exists('getallheaders')) {
                $headers = getallheaders();
                $auth = $headers['Authorization'] ?? null;
            } else {
                return null;
            }
        }
        
        if ($auth && preg_match('/Bearer\s+(.+)/', $auth, $matches)) {
            return $matches[1];
        }
        
        return null;
    }
    
    private static function base64urlEncode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
    
    private static function base64urlDecode($data) {
        return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', 4 - strlen($data) % 4));
    }
}
