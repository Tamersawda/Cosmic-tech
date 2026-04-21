<?php

namespace Backend\Utils;

/**
 * FileUploadHandler - Document and Media Upload Management
 * 
 * Supports:
 * - Doctor profile photos
 * - Qualification certificates
 * - Identity documents (front/back)
 * - License documents
 */
class FileUploadHandler {
    
    // File size limits (in bytes)
    private const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private const MAX_PHOTO_SIZE = 5 * 1024 * 1024; // 5MB for photos
    
    // Allowed file types
    private const ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'pdf'];
    private const ALLOWED_MIME_TYPES = [
        'image/jpeg',
        'image/png',
        'application/pdf'
    ];
    
    // Upload directories
    private const BASE_UPLOAD_DIR = '/uploads';
    private const PROFILE_PHOTOS_DIR = '/uploads/profile-photos';
    private const DOCUMENTS_DIR = '/uploads/documents';
    private const CERTIFICATES_DIR = '/uploads/certificates';
    
    private string $uploadDir;
    private string $publicDir;

    public function __construct() {
        // Get public/uploads directory path
        $this->publicDir = dirname(__DIR__, 2) . '/public';
        $this->uploadDir = $this->publicDir . self::BASE_UPLOAD_DIR;
        
        // Create upload directories if they don't exist
        $this->ensureUploadDirectories();
    }

    /**
     * Ensure upload directories exist with proper permissions
     */
    private function ensureUploadDirectories(): void {
        $dirs = [
            $this->uploadDir,
            $this->publicDir . self::PROFILE_PHOTOS_DIR,
            $this->publicDir . self::DOCUMENTS_DIR,
            $this->publicDir . self::CERTIFICATES_DIR,
        ];

        foreach ($dirs as $dir) {
            if (!is_dir($dir)) {
                mkdir($dir, 0755, true);
            }
        }
    }

    /**
     * Upload profile photo
     * 
     * @param array $file From $_FILES
     * @param string $userId User ID for organizing files
     * @return string File URL or empty string on failure
     */
    public function uploadProfilePhoto(array $file, string $userId): string {
        return $this->uploadFile(
            $file,
            $userId,
            self::PROFILE_PHOTOS_DIR,
            self::MAX_PHOTO_SIZE
        );
    }

    /**
     * Upload qualification certificate
     * 
     * @param array $file From $_FILES
     * @param string $doctorId Doctor ID
     * @param string $qualificationId Qualification ID
     * @return string File URL or empty string on failure
     */
    public function uploadCertificate(array $file, string $doctorId, string $qualificationId): string {
        $uploadPath = self::CERTIFICATES_DIR . '/' . $doctorId;
        
        return $this->uploadFile(
            $file,
            $qualificationId,
            $uploadPath,
            self::MAX_FILE_SIZE
        );
    }

    /**
     * Upload identity/license document
     * 
     * @param array $file From $_FILES
     * @param string $userId User ID
     * @param string $documentType Type of document (identity, license, etc.)
     * @return string File URL or empty string on failure
     */
    public function uploadDocument(array $file, string $userId, string $documentType): string {
        $uploadPath = self::DOCUMENTS_DIR . '/' . $userId . '/' . $documentType;
        
        return $this->uploadFile(
            $file,
            uniqid('doc_'),
            $uploadPath,
            self::MAX_FILE_SIZE
        );
    }

    /**
     * Generic file upload with validation
     * 
     * @param array $file From $_FILES
     * @param string $identifier Unique identifier for the file
     * @param string $uploadPath Relative upload path
     * @param int $maxSize Maximum file size
     * @return string File URL on success, empty string on failure
     */
    private function uploadFile(
        array $file,
        string $identifier,
        string $uploadPath,
        int $maxSize
    ): string {
        try {
            // Validate file exists and is uploaded
            if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
                error_log("File upload: File not found or not properly uploaded");
                return '';
            }

            // Validate file size
            if ($file['size'] > $maxSize) {
                error_log("File upload: File size exceeds limit ({$file['size']} > {$maxSize})");
                return '';
            }

            // Validate file extension
            $extension = $this->getFileExtension($file['name']);
            if (!in_array(strtolower($extension), self::ALLOWED_EXTENSIONS)) {
                error_log("File upload: Invalid file extension: {$extension}");
                return '';
            }

            // Validate MIME type
            $mimeType = $this->getFileMimeType($file['tmp_name']);
            if (!in_array($mimeType, self::ALLOWED_MIME_TYPES)) {
                error_log("File upload: Invalid MIME type: {$mimeType}");
                return '';
            }

            // Create upload directory if it doesn't exist
            $fullUploadPath = $this->publicDir . $uploadPath;
            if (!is_dir($fullUploadPath)) {
                mkdir($fullUploadPath, 0755, true);
            }

            // Generate unique filename
            $filename = $this->generateFilename($identifier, $extension);
            $filepath = $fullUploadPath . '/' . $filename;

            // Move uploaded file
            if (!move_uploaded_file($file['tmp_name'], $filepath)) {
                error_log("File upload: Failed to move uploaded file to {$filepath}");
                return '';
            }

            // Set proper permissions
            chmod($filepath, 0644);

            // Return URL relative to public directory
            return $uploadPath . '/' . $filename;

        } catch (\Exception $e) {
            error_log("File upload error: " . $e->getMessage());
            return '';
        }
    }

    /**
     * Delete a file
     * 
     * @param string $relativeFilePath Path relative to uploads directory
     * @return bool True if deleted, false otherwise
     */
    public function deleteFile(string $relativeFilePath): bool {
        try {
            $fullPath = $this->publicDir . $relativeFilePath;
            
            if (file_exists($fullPath) && is_file($fullPath)) {
                return unlink($fullPath);
            }
            
            return false;
        } catch (\Exception $e) {
            error_log("File deletion error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Get file extension
     */
    private function getFileExtension(string $filename): string {
        return strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    }

    /**
     * Get MIME type of file
     */
    private function getFileMimeType(string $filepath): string {
        // Try using finfo first (most reliable)
        if (function_exists('finfo_open')) {
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mimeType = finfo_file($finfo, $filepath);
            finfo_close($finfo);
            return $mimeType ?: 'application/octet-stream';
        }

        // Fallback to mime_content_type (deprecated but available)
        if (function_exists('mime_content_type')) {
            return mime_content_type($filepath);
        }

        // Last resort: guess by extension
        $extension = $this->getFileExtension($filepath);
        return $this->guessExtensionMimeType($extension);
    }

    /**
     * Guess MIME type by file extension
     */
    private function guessExtensionMimeType(string $extension): string {
        $mimeTypes = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'pdf' => 'application/pdf',
        ];

        return $mimeTypes[strtolower($extension)] ?? 'application/octet-stream';
    }

    /**
     * Generate unique filename
     */
    private function generateFilename(string $identifier, string $extension): string {
        $timestamp = time();
        $random = bin2hex(random_bytes(6));
        return "{$identifier}_{$timestamp}_{$random}.{$extension}";
    }

    /**
     * Validate file from $_FILES
     * 
     * @param array $file From $_FILES
     * @return array Validation result ['valid' => bool, 'error' => string]
     */
    public static function validateFile(array $file): array {
        // Check if file was uploaded without errors
        if (!isset($file['error']) || $file['error'] !== UPLOAD_ERR_OK) {
            $errors = [
                UPLOAD_ERR_INI_SIZE => 'File exceeds upload_max_filesize',
                UPLOAD_ERR_FORM_SIZE => 'File exceeds MAX_FILE_SIZE',
                UPLOAD_ERR_PARTIAL => 'File was only partially uploaded',
                UPLOAD_ERR_NO_FILE => 'No file was uploaded',
                UPLOAD_ERR_NO_TMP_DIR => 'Server temp directory unavailable',
                UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
            ];
            $error = $errors[$file['error']] ?? 'Unknown upload error';
            return ['valid' => false, 'error' => $error];
        }

        // Check file size limit (10MB)
        if ($file['size'] > 10 * 1024 * 1024) {
            return ['valid' => false, 'error' => 'File size exceeds 10MB limit'];
        }

        // Check file extension
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($extension, self::ALLOWED_EXTENSIONS)) {
            return ['valid' => false, 'error' => 'File type not allowed. Allowed: ' . implode(', ', self::ALLOWED_EXTENSIONS)];
        }

        return ['valid' => true, 'error' => null];
    }
}
