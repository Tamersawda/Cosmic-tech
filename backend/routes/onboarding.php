<?php

/**
 * Doctor Onboarding Routes
 * Step-based onboarding workflow endpoints
 *
 * Canonical step slugs (matching frontend Flutter screens):
 *   Step 1  -> basic-info
 *   Step 2  -> professional-details
 *   Step 3  -> qualifications          (CRUD)
 *   Step 4  -> professional-registration
 *   Step 5  -> work-experience         (CRUD)
 *   Step 6  -> session-fee
 *   Step 7  -> availability
 *   Step 8  -> payout
 *   Action  -> submit | status
 *
 * Legacy alias slugs (deprecated, kept for backwards compatibility):
 *   verification -> professional-registration
 *   experiences  -> work-experience
 *   pricing      -> session-fee
 */

namespace Backend\Routes;

use Backend\Config\JWT;
use Backend\Controllers\OnboardingBasicInfoController;
use Backend\Controllers\OnboardingProfessionalDetailsController;
use Backend\Controllers\OnboardingQualificationsController;
use Backend\Controllers\OnboardingVerificationController;
use Backend\Controllers\OnboardingExperiencesController;
use Backend\Controllers\OnboardingPricingController;
use Backend\Controllers\OnboardingAvailabilityController;
use Backend\Controllers\OnboardingPayoutController;
use Backend\Controllers\OnboardingSubmissionController;

require_once __DIR__ . '/../config/JWT.php';
require_once __DIR__ . '/../controllers/OnboardingBasicInfoController.php';
require_once __DIR__ . '/../controllers/OnboardingProfessionalDetailsController.php';
require_once __DIR__ . '/../controllers/OnboardingQualificationsController.php';
require_once __DIR__ . '/../controllers/OnboardingVerificationController.php';
require_once __DIR__ . '/../controllers/OnboardingExperiencesController.php';
require_once __DIR__ . '/../controllers/OnboardingPricingController.php';
require_once __DIR__ . '/../controllers/OnboardingAvailabilityController.php';
require_once __DIR__ . '/../controllers/OnboardingPayoutController.php';
require_once __DIR__ . '/../controllers/OnboardingSubmissionController.php';

class OnboardingRoutes
{
    private $method;
    private $path;
    private $user;

    public function __construct($method, $path, $user)
    {
        $this->method = $method;
        $this->path   = $path;
        $this->user   = $user;
    }

    public function handle(): void
    {
        // Parse path — strip version prefix and known namespace segments.
        // Supports both /api/doctors/onboarding/... and /api/v1/doctors/onboarding/...
        $segments = array_values(array_filter(
            explode('/', trim($this->path, '/')),
            fn($s) => !in_array($s, ['api', 'v1', 'doctors'])
        ));

        if (empty($segments) || $segments[0] !== 'onboarding') {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Not found']);
            return;
        }

        $step = $segments[1] ?? null;

        // ── Step 1: Basic Information ─────────────────────────────────────────
        if ($step === 'basic-info') {
            $controller = new OnboardingBasicInfoController();
            if ($this->method === 'POST') {
                $controller->saveBasicInfo($this->user);
            } elseif ($this->method === 'GET') {
                $controller->getBasicInfo($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 2: Professional Details ──────────────────────────────────────
        if ($step === 'professional-details') {
            $controller = new OnboardingProfessionalDetailsController();
            if ($this->method === 'POST') {
                $controller->saveProfessionalDetails($this->user);
            } elseif ($this->method === 'GET') {
                $controller->getProfessionalDetails($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 3: Qualifications (CRUD) ─────────────────────────────────────
        if ($step === 'qualifications') {
            $controller = new OnboardingQualificationsController();
            $id = $segments[2] ?? null;
            if ($this->method === 'POST') {
                $controller->addQualification($this->user);
            } elseif ($this->method === 'GET' && !$id) {
                $controller->listQualifications($this->user);
            } elseif ($this->method === 'PUT' && $id) {
                $controller->updateQualification($this->user);
            } elseif ($this->method === 'DELETE' && $id) {
                $controller->deleteQualification($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 4: Professional Registration (RCI / Self-declaration) ────────
        // Canonical: professional-registration | Legacy alias: verification
        if ($step === 'professional-registration' || $step === 'verification') {
            $controller = new OnboardingVerificationController();
            if ($this->method === 'POST') {
                $controller->saveVerification($this->user);
            } elseif ($this->method === 'GET') {
                $controller->getVerification($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 5: Work Experience (CRUD) ────────────────────────────────────
        // Canonical: work-experience | Legacy alias: experiences
        if ($step === 'work-experience' || $step === 'experiences') {
            $controller = new OnboardingExperiencesController();
            $id = $segments[2] ?? null;
            if ($this->method === 'POST') {
                $controller->addExperience($this->user);
            } elseif ($this->method === 'GET' && !$id) {
                $controller->listExperiences($this->user);
            } elseif ($this->method === 'PUT' && $id) {
                $controller->updateExperience($this->user);
            } elseif ($this->method === 'DELETE' && $id) {
                $controller->deleteExperience($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 6: Session Fee ───────────────────────────────────────────────
        // Canonical: session-fee | Legacy alias: pricing
        if ($step === 'session-fee' || $step === 'pricing') {
            $controller = new OnboardingPricingController();
            if ($this->method === 'POST') {
                $controller->savePricing($this->user);
            } elseif ($this->method === 'GET') {
                $controller->getPricing($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 7: Availability ──────────────────────────────────────────────
        if ($step === 'availability') {
            $controller = new OnboardingAvailabilityController();
            $id = $segments[2] ?? null;
            if ($this->method === 'POST') {
                $controller->saveAvailability($this->user);
            } elseif ($this->method === 'GET' && !$id) {
                $controller->getAvailability($this->user);
            } elseif ($this->method === 'PUT' && $id) {
                $controller->updateSlot($this->user, $id);
            } elseif ($this->method === 'DELETE' && $id) {
                $controller->deleteSlot($this->user, $id);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Step 8: Payout Setup ──────────────────────────────────────────────
        if ($step === 'payout') {
            $controller = new OnboardingPayoutController();
            if ($this->method === 'POST') {
                $controller->savePayout($this->user);
            } elseif ($this->method === 'GET') {
                $controller->getPayout($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Final Submission ──────────────────────────────────────────────────
        if ($step === 'submit') {
            $controller = new OnboardingSubmissionController();
            if ($this->method === 'POST') {
                $controller->submitOnboarding($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // ── Status / Progress ─────────────────────────────────────────────────
        if ($step === 'status') {
            $controller = new OnboardingSubmissionController();
            if ($this->method === 'GET') {
                $controller->getOnboardingStatus($this->user);
            } else {
                $this->methodNotAllowed();
            }
            return;
        }

        // Not found
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Onboarding endpoint not found.',
            'validSteps' => [
                'basic-info', 'professional-details', 'qualifications',
                'professional-registration', 'work-experience', 'session-fee',
                'availability', 'payout', 'submit', 'status'
            ]
        ]);
    }

    private function methodNotAllowed(): void
    {
        http_response_code(405);
        echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    }
}

return OnboardingRoutes::class;
