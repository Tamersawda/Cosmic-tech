<?php

namespace Backend\Utils;

/**
 * EmailService
 * 
 * Handles email sending for OTP and verification purposes.
 * Configure via environment variables:
 * - MAIL_DRIVER (php|smtp|mailgun|sendgrid)
 * - MAIL_FROM
 * - SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD (for SMTP)
 */
class EmailService {
    private string $mailDriver;
    private string $fromEmail;
    private string $fromName;

    public function __construct() {
        $this->mailDriver = getenv('MAIL_DRIVER') ?: 'php';
        $this->fromEmail = getenv('MAIL_FROM') ?: 'noreply@therapeuticsanctuary.com';
        $this->fromName = getenv('MAIL_FROM_NAME') ?: 'Therapy Sanctuary';
    }

    /**
     * Send OTP verification email
     */
    public function sendOtpEmail(string $email, string $otp): bool {
        $subject = 'Your Email Verification Code';
        $htmlBody = $this->getOtpEmailTemplate($otp);
        $textBody = "Your email verification code is: {$otp}\n\nThis code expires in 10 minutes.";

        return $this->send($email, $subject, $htmlBody, $textBody);
    }

    /**
     * Send verification success confirmation
     */
    public function sendVerificationSuccessEmail(string $email): bool {
        $subject = 'Email Verified Successfully';
        $htmlBody = $this->getVerificationSuccessTemplate($email);
        $textBody = "Your email has been verified successfully. You can now log in to your account.";

        return $this->send($email, $subject, $htmlBody, $textBody);
    }

    /**
     * Send OTP resend notification
     */
    public function sendResendOtpEmail(string $email, string $otp): bool {
        $subject = 'New Email Verification Code';
        $htmlBody = $this->getOtpEmailTemplate($otp, true);
        $textBody = "Your new email verification code is: {$otp}\n\nThis code expires in 10 minutes.";

        return $this->send($email, $subject, $htmlBody, $textBody);
    }

    /**
     * Internal send method
     */
    private function send(string $to, string $subject, string $htmlBody, string $textBody): bool {
        try {
            switch ($this->mailDriver) {
                case 'php':
                    return $this->sendViaPhp($to, $subject, $htmlBody, $textBody);
                case 'smtp':
                    return $this->sendViaSmtp($to, $subject, $htmlBody, $textBody);
                case 'mailgun':
                case 'sendgrid':
                    // External service integrations
                    return true; // Placeholder
                default:
                    error_log("Unknown mail driver: {$this->mailDriver}");
                    return false;
            }
        } catch (\Exception $e) {
            error_log("Email sending failed: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Send email using PHP mail()
     */
    private function sendViaPhp(string $to, string $subject, string $htmlBody, string $textBody): bool {
        $headers = [
            'From' => "{$this->fromName} <{$this->fromEmail}>",
            'Reply-To' => $this->fromEmail,
            'Content-Type' => 'text/html; charset=UTF-8',
            'X-Mailer' => 'PHP/' . phpversion(),
        ];

        $headerString = implode("\r\n", array_map(
            fn($k, $v) => "$k: $v",
            array_keys($headers),
            array_values($headers)
        ));

        return mail($to, $subject, $htmlBody, $headerString);
    }

    /**
     * Send email via SMTP
     * Requires: SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD
     */
    private function sendViaSmtp(string $to, string $subject, string $htmlBody, string $textBody): bool {
        // Simple SMTP implementation
        // For production, use PHPMailer or SwiftMailer library
        $host = getenv('SMTP_HOST');
        $port = getenv('SMTP_PORT') ?: 587;
        $username = getenv('SMTP_USERNAME');
        $password = getenv('SMTP_PASSWORD');

        if (!$host) {
            error_log("SMTP_HOST not configured");
            return false;
        }

        try {
            $socket = @fsockopen($host, $port, $errno, $errstr, 10);
            if (!$socket) {
                error_log("SMTP connection failed: $errstr");
                return false;
            }

            stream_set_timeout($socket, 5);
            fgets($socket);

            // Send HELO
            fputs($socket, "HELO therapy-sanctuary.com\r\n");
            fgets($socket);

            // AUTH LOGIN if credentials provided
            if ($username && $password) {
                fputs($socket, "AUTH LOGIN\r\n");
                fgets($socket);
                fputs($socket, base64_encode($username) . "\r\n");
                fgets($socket);
                fputs($socket, base64_encode($password) . "\r\n");
                fgets($socket);
            }

            // Send message
            fputs($socket, "MAIL FROM: <{$this->fromEmail}>\r\n");
            fgets($socket);
            fputs($socket, "RCPT TO: <{$to}>\r\n");
            fgets($socket);
            fputs($socket, "DATA\r\n");
            fgets($socket);

            $message = "From: {$this->fromName} <{$this->fromEmail}>\r\n";
            $message .= "To: {$to}\r\n";
            $message .= "Subject: {$subject}\r\n";
            $message .= "Content-Type: text/html; charset=UTF-8\r\n";
            $message .= "MIME-Version: 1.0\r\n\r\n";
            $message .= $htmlBody . "\r\n";

            fputs($socket, $message . "\r\n.\r\n");
            fgets($socket);

            fputs($socket, "QUIT\r\n");
            fclose($socket);

            return true;
        } catch (\Exception $e) {
            error_log("SMTP error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Get OTP email template
     */
    private function getOtpEmailTemplate(string $otp, bool $isResend = false): string {
        $title = $isResend ? 'New Verification Code' : 'Verify Your Email';
        $message = $isResend 
            ? 'A new verification code has been requested.' 
            : 'Welcome! Please verify your email to get started.';

        return <<<HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
        .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
        .otp-box { background-color: #fff; border: 2px solid #4CAF50; padding: 20px; text-align: center; margin: 20px 0; border-radius: 5px; }
        .otp-code { font-size: 32px; font-weight: bold; color: #4CAF50; letter-spacing: 5px; font-family: monospace; }
        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{$title}</h1>
        </div>
        <div class="content">
            <p>Hello,</p>
            <p>{$message}</p>
            <p>Please use the following verification code:</p>
            <div class="otp-box">
                <div class="otp-code">{$otp}</div>
            </div>
            <p>This code will expire in 10 minutes.</p>
            <p>If you did not request this email, please ignore it.</p>
            <div class="footer">
                <p>&copy; 2026 Therapy Sanctuary. All rights reserved.</p>
            </div>
        </div>
    </div>
</body>
</html>
HTML;
    }

    /**
     * Get verification success email template
     */
    private function getVerificationSuccessTemplate(string $email): string {
        return <<<HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
        .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
        .success-box { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Email Verified Successfully</h1>
        </div>
        <div class="content">
            <p>Hello,</p>
            <div class="success-box">
                <strong>✓ Your email has been verified successfully!</strong>
            </div>
            <p>You can now log in to your Therapy Sanctuary account with:</p>
            <p><strong>Email:</strong> {$email}</p>
            <p>Click the link below to proceed to login:</p>
            <p><a href="https://therapeuticsanctuary.com/login" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">Go to Login</a></p>
            <div class="footer">
                <p>&copy; 2026 Therapy Sanctuary. All rights reserved.</p>
            </div>
        </div>
    </div>
</body>
</html>
HTML;
    }
}
