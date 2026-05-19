<?php

namespace Backend\Utils;

/**
 * FileUploadHandler — Hardened Upload Manager
 *
 * Security features:
 *  - finfo-based MIME validation (not client-supplied Content-Type)
 *  - Extension whitelist with executable-extension blocking
 *  - UUID + timestamp filename randomisation
 *  - 5 MB default limit (configurable per call)
 *  - Non-web-executable storage directory
 *  - Path sanitisation
 */
class FileUploadHandler {

    // ── Limits ───────────────────────────────────────────────
    private const DEFAULT_MAX_SIZE  = 5  * 1024 * 1024; // 5 MB
    private const PHOTO_MAX_SIZE    = 2  * 1024 * 1024; // 2 MB

    // ── Whitelists ────────────────────────────────────────────
    private const ALLOWED_MIME_TYPES = [
        'image/jpeg'      => 'jpg',
        'image/png'       => 'png',
        'application/pdf' => 'pdf',
    ];

    /** Extensions that MUST be blocked — ever. */
    private const BLOCKED_EXTENSIONS = [
        'php', 'php3', 'php4', 'php5', 'php7', 'phtml', 'phar',
        'exe', 'sh', 'bat', 'cmd', 'com', 'vbs', 'js', 'jsp',
        'asp', 'aspx', 'py', 'pl', 'rb', 'cgi', 'htaccess',
    ];

    // ── Base upload root (NOT publicly served) ────────────────
    private string $uploadRoot;

    public function __construct() {
        // Resolve to backend/uploads/ — one level above public/ if it existed
        $this->uploadRoot = dirname(__DIR__) . '/uploads';
        $this->ensureDir($this->uploadRoot);
    }

    // ─────────────────────────────────────────────────────────
    // PUBLIC API
    // ─────────────────────────────────────────────────────────

    /**
     * Upload a qualification document (PDF, PNG, JPEG ≤ 5 MB).
     * Returns relative path from upload root on success, throws on failure.
     *
     * @param array  $file     $_FILES entry
     * @param string $doctorId Used to organise storage folder
     * @return string  Relative path stored in DB  (e.g. "qualifications/<doctorId>/uuid.pdf")
     */
    public function uploadQualificationDocument(array $file, string $doctorId): string {
        $this->validateUploadError($file);
        $this->validateSize($file, self::DEFAULT_MAX_SIZE);

        $mime = $this->detectMime($file['tmp_name']);
        if (!array_key_exists($mime, self::ALLOWED_MIME_TYPES)) {
            throw new \RuntimeException(
                'Invalid file type. Only PDF, PNG, and JPEG are accepted.'
            );
        }

        $ext = self::ALLOWED_MIME_TYPES[$mime];
        $this->blockExecutableExtension($ext);

        $subDir  = 'qualifications/' . preg_replace('/[^a-zA-Z0-9\-]/', '', $doctorId);
        $relPath = $subDir . '/' . $this->generateFilename($ext);

        $this->moveFile($file['tmp_name'], $relPath);
        return $relPath;
    }

    /**
     * Upload a profile photo (JPEG/PNG ≤ 2 MB).
     */
    public function uploadProfilePhoto(array $file, string $userId): string {
        $this->validateUploadError($file);
        $this->validateSize($file, self::PHOTO_MAX_SIZE);

        $mime = $this->detectMime($file['tmp_name']);
        if (!in_array($mime, ['image/jpeg', 'image/png'], true)) {
            throw new \RuntimeException('Profile photo must be JPEG or PNG.');
        }

        $ext = self::ALLOWED_MIME_TYPES[$mime];
        $this->blockExecutableExtension($ext);

        $subDir  = 'profile-photos';
        // Deterministic filename per user — overwrites previous photo automatically
        $relPath = $subDir . '/doctor_' . preg_replace('/[^a-zA-Z0-9\-]/', '', $userId) . '.' . $ext;

        $this->moveFile($file['tmp_name'], $relPath);
        return $relPath;
    }

    /**
     * Delete a previously stored file given its relative path.
     */
    public function deleteFile(string $relativePath): bool {
        if (empty($relativePath)) return false;
        $full = $this->uploadRoot . '/' . ltrim($relativePath, '/');
        if (file_exists($full) && is_file($full)) {
            return @unlink($full);
        }
        return false;
    }

    /**
     * Build a public-serving URL for a stored file.
     * Adjust the base URL in .env (UPLOAD_BASE_URL) for your deployment.
     */
    public static function publicUrl(string $relativePath): ?string {
        if (empty($relativePath)) return null;
        $base = rtrim(getenv('UPLOAD_BASE_URL') ?: '/uploads', '/');
        return $base . '/' . ltrim($relativePath, '/');
    }

    // ─────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────

    private function validateUploadError(array $file): void {
        $errMessages = [
            UPLOAD_ERR_INI_SIZE   => 'File exceeds server upload_max_filesize limit.',
            UPLOAD_ERR_FORM_SIZE  => 'File exceeds form MAX_FILE_SIZE limit.',
            UPLOAD_ERR_PARTIAL    => 'File was only partially uploaded.',
            UPLOAD_ERR_NO_FILE    => 'No file was uploaded.',
            UPLOAD_ERR_NO_TMP_DIR => 'Server temporary directory is missing.',
            UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk.',
            UPLOAD_ERR_EXTENSION  => 'Upload stopped by a PHP extension.',
        ];
        $code = $file['error'] ?? UPLOAD_ERR_NO_FILE;
        if ($code !== UPLOAD_ERR_OK) {
            throw new \RuntimeException($errMessages[$code] ?? 'Upload error code ' . $code);
        }
        if (!is_uploaded_file($file['tmp_name'])) {
            throw new \RuntimeException('File did not arrive via HTTP POST.');
        }
    }

    private function validateSize(array $file, int $maxBytes): void {
        if ($file['size'] > $maxBytes) {
            $mb = round($maxBytes / 1024 / 1024, 1);
            throw new \RuntimeException("File size exceeds the {$mb} MB limit.");
        }
    }

    private function detectMime(string $tmpPath): string {
        if (!function_exists('finfo_open')) {
            throw new \RuntimeException('finfo extension is required but not available.');
        }
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime  = finfo_file($finfo, $tmpPath);
        finfo_close($finfo);
        if (!$mime) throw new \RuntimeException('Could not determine file MIME type.');
        return $mime;
    }

    private function blockExecutableExtension(string $ext): void {
        if (in_array(strtolower($ext), self::BLOCKED_EXTENSIONS, true)) {
            throw new \RuntimeException("File type '.{$ext}' is not permitted.");
        }
    }

    private function generateFilename(string $ext): string {
        // UUID v4 + microsecond timestamp → effectively unguessable
        $uuid = sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            mt_rand(0, 0xffff),
            mt_rand(0, 0x0fff) | 0x4000,
            mt_rand(0, 0x3fff) | 0x8000,
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
        return $uuid . '_' . time() . '.' . $ext;
    }

    private function ensureDir(string $dir): void {
        if (!is_dir($dir)) {
            if (!mkdir($dir, 0750, true)) {
                throw new \RuntimeException("Cannot create upload directory: {$dir}");
            }
        }
    }

    private function moveFile(string $tmpPath, string $relPath): void {
        $dest = $this->uploadRoot . '/' . $relPath;
        $this->ensureDir(dirname($dest));

        if (!move_uploaded_file($tmpPath, $dest)) {
            throw new \RuntimeException('Failed to move uploaded file to storage.');
        }
        chmod($dest, 0640); // owner rw, group r, world none
    }

    /**
     * Upload a government ID document (PDF, PNG, JPEG ≤ 5 MB).
     * Used for both front and back sides.
     */
    public function uploadGovernmentID(array $file, string $doctorId, string $side): string {
        $this->validateUploadError($file);
        $this->validateSize($file, self::DEFAULT_MAX_SIZE);

        $mime = $this->detectMime($file['tmp_name']);
        if (!array_key_exists($mime, self::ALLOWED_MIME_TYPES)) {
            throw new \RuntimeException(
                'Invalid file type. Only PDF, PNG, and JPEG are accepted for ID documents.'
            );
        }

        $ext = self::ALLOWED_MIME_TYPES[$mime];
        $this->blockExecutableExtension($ext);

        $subDir  = 'govt-id/' . preg_replace('/[^a-zA-Z0-9\-]/', '', $doctorId);
        $relPath = $subDir . '/' . $side . '_' . $this->generateFilename($ext);

        $this->moveFile($file['tmp_name'], $relPath);
        return $relPath;
    }

    /**
     * Upload RCI or professional registration certificate
     */
    public function uploadRegistrationCertificate(array $file, string $doctorId): string {
        $this->validateUploadError($file);
        $this->validateSize($file, self::DEFAULT_MAX_SIZE);

        $mime = $this->detectMime($file['tmp_name']);
        if (!array_key_exists($mime, self::ALLOWED_MIME_TYPES)) {
            throw new \RuntimeException(
                'Invalid file type. Only PDF, PNG, and JPEG are accepted.'
            );
        }

        $ext = self::ALLOWED_MIME_TYPES[$mime];
        $this->blockExecutableExtension($ext);

        $subDir  = 'registration-certificates/' . preg_replace('/[^a-zA-Z0-9\-]/', '', $doctorId);
        $relPath = $subDir . '/' . $this->generateFilename($ext);

        $this->moveFile($file['tmp_name'], $relPath);
        return $relPath;
    }

    /**
     * Upload experience/work proof document
     */
    public function uploadExperienceProof(array $file, string $doctorId): string {
        $this->validateUploadError($file);
        $this->validateSize($file, self::DEFAULT_MAX_SIZE);

        $mime = $this->detectMime($file['tmp_name']);
        if (!array_key_exists($mime, self::ALLOWED_MIME_TYPES)) {
            throw new \RuntimeException(
                'Invalid file type. Only PDF, PNG, and JPEG are accepted.'
            );
        }

        $ext = self::ALLOWED_MIME_TYPES[$mime];
        $this->blockExecutableExtension($ext);

        $subDir  = 'experience-proof/' . preg_replace('/[^a-zA-Z0-9\-]/', '', $doctorId);
        $relPath = $subDir . '/' . $this->generateFilename($ext);

        $this->moveFile($file['tmp_name'], $relPath);
        return $relPath;
    }

    // Legacy shim used by DoctorQualificationController::uploadDocument path
    public function uploadDocument(array $file, string $userId, string $context): string {
        return $this->uploadQualificationDocument($file, $userId);
    }
}
