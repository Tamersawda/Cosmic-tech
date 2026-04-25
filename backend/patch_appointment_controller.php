<?php
$file = 'c:\wamp64\www\Cosmic-tech\backend\controllers\AppointmentController.php';
$content = file_get_contents($file);

$target = '            // Doctor must exist
            if (!$this->doctorModel->exists($doctorId)) {
                Response::error(\'Doctor not found\', 404);
                return;
            }';

$replacement = '            // Doctor must exist and be active
            $doctor = $this->doctorModel->findByUserId($doctorId);
            if (!$doctor) {
                Response::error(\'Doctor not found\', 404);
                return;
            }
            if (!$doctor[\'is_active\']) {
                Response::error(\'This doctor is currently inactive\', 400);
                return;
            }';

// Try with spaces first, then try with tabs if that fails
$newContent = str_replace($target, $replacement, $content);

if ($newContent === $content) {
    // Try replacing spaces with tabs in target
    $targetTabs = str_replace('    ', "\t", $target);
    $newContent = str_replace($targetTabs, $replacement, $content);
}

if ($newContent !== $content) {
    file_put_contents($file, $newContent);
    echo "Successfully updated AppointmentController.php\n";
} else {
    echo "Failed to find target content in AppointmentController.php\n";
}
