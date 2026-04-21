<?php

namespace Backend\Utils;

/**
 * OtpManager
 * 
 * Handles OTP generation, hashing, and validation
 */
class OtpManager {
    private const OTP_LENGTH = 6;
    private const OTP_EXPIRY_MINUTES = 10;
    private const MAX_OTP_ATTEMPTS = 5;
    private const RESEND_COOLDOWN_SECONDS = 30;

    /**
     * Generate a 6-digit OTP
     */
    public static function generateOtp(): string {
        return str_pad((string)random_int(0, 999999), self::OTP_LENGTH, '0', STR_PAD_LEFT);
    }

    /**
     * Hash OTP using bcrypt
     */
    public static function hashOtp(string $otp): string {
        return password_hash($otp, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify OTP against hash
     */
    public static function verifyOtp(string $otp, string $hash): bool {
        return password_verify($otp, $hash);
    }

    /**
     * Get OTP expiry timestamp (10 minutes from now)
     */
    public static function getOtpExpiry(): string {
        $expiry = new \DateTime('now', new \DateTimeZone('UTC'));
        $expiry->add(new \DateInterval('PT' . self::OTP_EXPIRY_MINUTES . 'M'));
        return $expiry->format('Y-m-d H:i:s');
    }

    /**
     * Check if OTP is expired
     */
    public static function isOtpExpired(string $expiryTime): bool {
        try {
            $expiry = new \DateTime($expiryTime, new \DateTimeZone('UTC'));
            $now = new \DateTime('now', new \DateTimeZone('UTC'));
            return $now > $expiry;
        } catch (\Exception $e) {
            error_log("OTP expiry check error: " . $e->getMessage());
            return true; // Consider expired if we can't parse
        }
    }

    /**
     * Get cooldown timestamp for resend (30 seconds)
     */
    public static function getResendCooldownExpiry(): string {
        $cooldown = new \DateTime('now', new \DateTimeZone('UTC'));
        $cooldown->add(new \DateInterval('PT' . self::RESEND_COOLDOWN_SECONDS . 'S'));
        return $cooldown->format('Y-m-d H:i:s');
    }

    /**
     * Check if resend is within cooldown period
     */
    public static function isWithinResendCooldown(string $lastOtpTime): bool {
        try {
            $lastTime = new \DateTime($lastOtpTime, new \DateTimeZone('UTC'));
            $now = new \DateTime('now', new \DateTimeZone('UTC'));
            
            // Get the difference in seconds
            $interval = $now->getTimestamp() - $lastTime->getTimestamp();
            return $interval < self::RESEND_COOLDOWN_SECONDS;
        } catch (\Exception $e) {
            error_log("Cooldown check error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Validate OTP format (6 digits, numeric only)
     */
    public static function validateOtpFormat(string $otp): bool {
        return preg_match('/^\d{' . self::OTP_LENGTH . '}$/', $otp) === 1;
    }

    /**
     * Get maximum OTP attempts allowed
     */
    public static function getMaxAttempts(): int {
        return self::MAX_OTP_ATTEMPTS;
    }

    /**
     * Get OTP expiry time in minutes
     */
    public static function getOtpExpiryMinutes(): int {
        return self::OTP_EXPIRY_MINUTES;
    }

    /**
     * Get resend cooldown time in seconds
     */
    public static function getResendCooldownSeconds(): int {
        return self::RESEND_COOLDOWN_SECONDS;
    }
}
