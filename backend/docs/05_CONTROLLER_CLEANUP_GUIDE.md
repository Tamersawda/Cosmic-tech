# PHASE 4: CONTROLLER CLEANUP GUIDE

## Overview
This guide outlines the controller layer updates required to support new onboarding fields and remove deprecated fields from the Cosmic Tech application.

## 1. Controllers to Update

### 1.1 OnboardingBasicInfoController.php
- Primary controller for basic information onboarding
- Handles: name, email, phone, profile picture, date of birth

### 1.2 OnboardingProfessionalDetailsController.php
- Manages professional information
- Handles: headline, bio, industry, employment type

### 1.3 OnboardingQualificationsController.php
- Controls educational and certification data
- Handles: degrees, certifications, institutions

### 1.4 OnboardingExperiencesController.php
- Manages work experience information
- Handles: job titles, companies, employment duration

### 1.5 OnboardingPayoutController.php
- Handles payment and banking information
- Manages: bank details, payment methods, tax information

---

## 2. Controller Update Details

### 2.1 OnboardingBasicInfoController.php

#### Current Field Mappings
\\\php
'first_name'      => required|string|max:255
'last_name'       => required|string|max:255
'email'           => required|email|unique:users
'phone'           => required|regex:/^[0-9\-\+\s\(\)]+$/
'profile_picture' => nullable|image|mimes:jpeg,png,jpg|max:2048
'date_of_birth'   => required|date|before_or_equal:today
\\\

#### Deprecated Fields to Remove
- phone_country_code - Consolidate into phone field
- profile_picture_old_path - Legacy storage reference
- 	emporary_email_verification_id - Obsolete verification method

#### New Fields to Add
\\\php
'middle_name'          => nullable|string|max:255
'gender'               => nullable|in:male,female,other,prefer_not_to_say
'nationality'          => nullable|string|max:100
'preferred_language'   => nullable|in:en,es,fr,de,pt,ja,zh
'timezone'             => nullable|timezone
'linkedin_profile_url' => nullable|url|max:500
\\\

#### Required Code Changes

**1. Update Validation Rules in store() method:**
\\\php
public function store(Request \)
{
    \ = \->validate([
        'first_name'          => 'required|string|max:255',
        'last_name'           => 'required|string|max:255',
        'middle_name'         => 'nullable|string|max:255',
        'email'               => 'required|email|unique:users,email',
        'phone'               => 'required|regex:/^[0-9\-\+\s\(\)]+\$/|min:10',
        'gender'              => 'nullable|in:male,female,other,prefer_not_to_say',
        'date_of_birth'       => 'required|date|before_or_equal:today',
        'nationality'         => 'nullable|string|max:100',
        'preferred_language'  => 'nullable|in:en,es,fr,de,pt,ja,zh',
        'timezone'            => 'nullable|timezone',
        'profile_picture'     => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        'linkedin_profile_url'=> 'nullable|url|max:500',
    ]);

    // Remove deprecated fields if present
    unset(\['phone_country_code']);
    unset(\['profile_picture_old_path']);
    unset(\['temporary_email_verification_id']);

    // Store in database
    \ = auth()->user();
    \->basicInfo()->updateOrCreate(
        ['user_id' => \->id],
        \
    );

    return response()->json(['message' => 'Basic info updated successfully']);
}
\\\

**2. Update update() method:**
\\\php
public function update(Request \, \)
{
    \ = \->validate([
        'first_name'          => 'sometimes|required|string|max:255',
        'last_name'           => 'sometimes|required|string|max:255',
        'middle_name'         => 'nullable|string|max:255',
        'email'               => 'sometimes|required|email|unique:users,email,' . \,
        'phone'               => 'sometimes|required|regex:/^[0-9\-\+\s\(\)]+\$/|min:10',
        'gender'              => 'nullable|in:male,female,other,prefer_not_to_say',
        'date_of_birth'       => 'sometimes|required|date|before_or_equal:today',
        'nationality'         => 'nullable|string|max:100',
        'preferred_language'  => 'nullable|in:en,es,fr,de,pt,ja,zh',
        'timezone'            => 'nullable|timezone',
        'profile_picture'     => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        'linkedin_profile_url'=> 'nullable|url|max:500',
    ]);

    \ = BasicInfo::findOrFail(\);
    \->update(\);

    return response()->json(['message' => 'Basic info updated successfully', 'data' => \]);
}
\\\

---

### 2.2 OnboardingProfessionalDetailsController.php

#### Current Field Mappings
\\\php
'headline'       => required|string|max:120
'bio'            => nullable|string|max:500
'industry'       => required|string
'employment_type'=> required|in:full_time,part_time,contract,freelance
\\\

#### Deprecated Fields to Remove
- job_category_id - Use industry directly
- experience_level_old - Replace with years_of_experience
- skills_comma_separated - Use skills relationship

#### New Fields to Add
\\\php
'years_of_experience'  => nullable|integer|min:0|max:70
'specialization'       => nullable|string|max:255
'certifications'       => nullable|array
'certifications.*'     => 'string|max:500'
'availability_status'  => nullable|in:available,unavailable,open_to_opportunities
'work_authorization'   => nullable|in:citizen,permanent_resident,visa_required
'portfolio_url'        => nullable|url|max:500
'company_name'         => nullable|string|max:255
\\\

#### Required Code Changes

**1. Validation Rules:**
\\\php
public function store(Request \)
{
    \ = \->validate([
        'headline'              => 'required|string|max:120',
        'bio'                   => 'nullable|string|max:500',
        'industry'              => 'required|string|max:100',
        'employment_type'       => 'required|in:full_time,part_time,contract,freelance',
        'years_of_experience'   => 'nullable|integer|min:0|max:70',
        'specialization'        => 'nullable|string|max:255',
        'certifications'        => 'nullable|array',
        'certifications.*'      => 'string|max:500',
        'availability_status'   => 'nullable|in:available,unavailable,open_to_opportunities',
        'work_authorization'    => 'nullable|in:citizen,permanent_resident,visa_required',
        'portfolio_url'         => 'nullable|url|max:500',
        'company_name'          => 'nullable|string|max:255',
    ]);

    // Remove deprecated fields
    unset(\['job_category_id']);
    unset(\['experience_level_old']);
    unset(\['skills_comma_separated']);

    \ = auth()->user();
    \ = \->professionalDetails()->updateOrCreate(
        ['user_id' => \->id],
        \
    );

    return response()->json(['message' => 'Professional details updated', 'data' => \]);
}
\\\

---

### 2.3 OnboardingQualificationsController.php

#### Current Field Mappings
\\\php
'degree_type'     => required|in:high_school,associate,bachelor,master,phd
'institution_name'=> required|string|max:255
'field_of_study'  => required|string|max:255
'graduation_year' => required|integer|min:1900|max:current_year+5
\\\

#### Deprecated Fields to Remove
- graduation_month - Consolidate to graduation_year for privacy
- gpa_score - Privacy concern, optional flag instead
- 	ranscript_uploaded_path - Legacy file reference

#### New Fields to Add
\\\php
'start_year'               => nullable|integer|min:1900
'still_studying'           => nullable|boolean
'institution_country'      => nullable|string|max:100
'institution_state'        => nullable|string|max:100
'honors_distinction'       => nullable|string|max:255
'relevant_coursework'      => nullable|array
'relevant_coursework.*'    => 'string|max:200'
'additional_qualifications'=> nullable|string|max:500
\\\

#### Required Code Changes

**1. Validation & Storage:**
\\\php
public function store(Request \)
{
    \ = \->validate([
        'degree_type'              => 'required|in:high_school,associate,bachelor,master,phd',
        'institution_name'         => 'required|string|max:255',
        'field_of_study'           => 'required|string|max:255',
        'start_year'               => 'nullable|integer|min:1900',
        'graduation_year'          => 'required|integer|min:1900',
        'still_studying'           => 'nullable|boolean',
        'institution_country'      => 'nullable|string|max:100',
        'institution_state'        => 'nullable|string|max:100',
        'honors_distinction'       => 'nullable|string|max:255',
        'relevant_coursework'      => 'nullable|array',
        'relevant_coursework.*'    => 'string|max:200',
        'additional_qualifications'=> 'nullable|string|max:500',
    ]);

    unset(\['graduation_month']);
    unset(\['gpa_score']);
    unset(\['transcript_uploaded_path']);

    \ = auth()->user();
    \ = Qualification::create(array_merge(\, ['user_id' => \->id]));

    return response()->json(['message' => 'Qualification added', 'data' => \]);
}
\\\

---

### 2.4 OnboardingExperiencesController.php

#### Current Field Mappings
\\\php
'job_title'       => required|string|max:255
'company_name'    => required|string|max:255
'employment_type' => required|in:full_time,part_time,contract,freelance
'start_date'      => required|date
'end_date'        => nullable|date|after:start_date
'currently_working'=> nullable|boolean
\\\

#### Deprecated Fields to Remove
- company_website - Privacy concern, remove
- manager_contact - Privacy concern, remove
- eference_phone - Privacy concern, remove
- contract_hours_per_week - Consolidate to employment_type

#### New Fields to Add
\\\php
'country'                  => nullable|string|max:100
'state'                    => nullable|string|max:100
'city'                     => nullable|string|max:100
'job_description'          => nullable|string|max:1000
'responsibilities'         => nullable|array
'responsibilities.*'       => 'string|max:300'
'achievements'             => nullable|array
'achievements.*'           => 'string|max:300'
'skills_used'              => nullable|array
'skills_used.*'            => 'string|max:100'
'industry'                 => nullable|string|max:100
\\\

#### Required Code Changes

**1. Validation & Storage:**
\\\php
public function store(Request \)
{
    \ = \->validate([
        'job_title'             => 'required|string|max:255',
        'company_name'          => 'required|string|max:255',
        'employment_type'       => 'required|in:full_time,part_time,contract,freelance',
        'start_date'            => 'required|date',
        'end_date'              => 'nullable|date|after_or_equal:start_date',
        'currently_working'     => 'nullable|boolean',
        'country'               => 'nullable|string|max:100',
        'state'                 => 'nullable|string|max:100',
        'city'                  => 'nullable|string|max:100',
        'job_description'       => 'nullable|string|max:1000',
        'responsibilities'      => 'nullable|array',
        'responsibilities.*'    => 'string|max:300',
        'achievements'          => 'nullable|array',
        'achievements.*'        => 'string|max:300',
        'skills_used'           => 'nullable|array',
        'skills_used.*'         => 'string|max:100',
        'industry'              => 'nullable|string|max:100',
    ]);

    // Remove deprecated fields
    unset(\['company_website']);
    unset(\['manager_contact']);
    unset(\['reference_phone']);
    unset(\['contract_hours_per_week']);

    // Handle boolean for currently_working
    if (\['currently_working']) {
        \['end_date'] = null;
    }

    \ = auth()->user();
    \ = Experience::create(array_merge(\, ['user_id' => \->id]));

    return response()->json(['message' => 'Experience added', 'data' => \]);
}
\\\

---

### 2.5 OnboardingPayoutController.php

#### Current Field Mappings
\\\php
'account_holder_name' => required|string|max:255
'account_number'      => required|string|max:34
'routing_number'      => required|string|max:9
'bank_name'           => required|string|max:255
\\\

#### Deprecated Fields to Remove
- ssn_last_four - Security concern, remove storage
- ank_phone_number - Unnecessary
- legacy_payout_method - Old integration

#### New Fields to Add
\\\php
'bank_code'                => nullable|string|max:20
'account_type'             => required|in:checking,savings,business
'country'                  => required|string|max:100
'currency'                 => required|in:USD,EUR,GBP,CAD,AUD
'swift_code'               => nullable|string|max:11
'iban'                     => nullable|string|max:34
'tax_id'                   => nullable|string|max:50
'tax_id_type'              => nullable|in:ssn,ein,vat_number,company_registration
'w9_form_uploaded'         => nullable|boolean
'verified_at'              => nullable|timestamp
\\\

#### Required Code Changes

**1. Validation & Storage:**
\\\php
public function store(Request \)
{
    \ = \->validate([
        'account_holder_name'    => 'required|string|max:255',
        'account_number'         => 'required|string|max:34',
        'routing_number'         => 'required|string|max:9',
        'bank_name'              => 'required|string|max:255',
        'bank_code'              => 'nullable|string|max:20',
        'account_type'           => 'required|in:checking,savings,business',
        'country'                => 'required|string|max:100',
        'currency'               => 'required|in:USD,EUR,GBP,CAD,AUD',
        'swift_code'             => 'nullable|string|max:11',
        'iban'                   => 'nullable|string|max:34',
        'tax_id'                 => 'nullable|string|max:50',
        'tax_id_type'            => 'nullable|in:ssn,ein,vat_number,company_registration',
        'w9_form_uploaded'       => 'nullable|boolean',
    ]);

    // Encrypt sensitive data before storage
    \['account_number'] = encrypt(\['account_number']);
    \['routing_number'] = encrypt(\['routing_number']);
    if (isset(\['iban'])) {
        \['iban'] = encrypt(\['iban']);
    }

    // Remove deprecated fields
    unset(\['ssn_last_four']);
    unset(\['bank_phone_number']);
    unset(\['legacy_payout_method']);

    \ = auth()->user();
    \ = PayoutMethod::create(array_merge(\, ['user_id' => \->id]));

    return response()->json(['message' => 'Payout method added', 'data' => \]);
}
\\\

---

## 3. Validation Rule Updates

### 3.1 Custom Validation Rules to Create

**1. Create: app/Rules/ValidPhoneNumber.php**
\\\php
namespace App\Rules;

use Illuminate\Contracts\Validation\Rule;

class ValidPhoneNumber implements Rule
{
    public function passes(\, \)
    {
        return preg_match('/^[0-9\-\+\s\(\)]{10,}$/', \);
    }

    public function message()
    {
        return 'The :attribute must be a valid phone number.';
    }
}
\\\

**2. Create: app/Rules/ValidLinkedInUrl.php**
\\\php
namespace App\Rules;

use Illuminate\Contracts\Validation\Rule;

class ValidLinkedInUrl implements Rule
{
    public function passes(\, \)
    {
        return preg_match('/^https:\/\/(www\.)?linkedin\.com\/in\/[\w\-]+\/?$/', \);
    }

    public function message()
    {
        return 'The :attribute must be a valid LinkedIn profile URL.';
    }
}
\\\

**3. Create: app/Rules/ValidBankAccount.php**
\\\php
namespace App\Rules;

use Illuminate\Contracts\Validation\Rule;

class ValidBankAccount implements Rule
{
    private \;

    public function __construct(\ = 'US')
    {
        \->country = \;
    }

    public function passes(\, \)
    {
        if (\->country === 'US') {
            return strlen(\) >= 8 && strlen(\) <= 17 && is_numeric(\);
        }
        return strlen(\) >= 8 && strlen(\) <= 34;
    }

    public function message()
    {
        return 'The :attribute contains an invalid bank account number.';
    }
}
\\\

---

## 4. Model Binding Updates

### 4.1 Update Routes with Model Binding

**routes/api.php:**
\\\php
Route::middleware('auth:sanctum')->group(function () {
    // Basic Info
    Route::post('/onboarding/basic-info', [OnboardingBasicInfoController::class, 'store']);
    Route::get('/onboarding/basic-info', [OnboardingBasicInfoController::class, 'show']);
    Route::put('/onboarding/basic-info/{basicInfo}', [OnboardingBasicInfoController::class, 'update']);

    // Professional Details
    Route::post('/onboarding/professional-details', [OnboardingProfessionalDetailsController::class, 'store']);
    Route::put('/onboarding/professional-details/{professionalDetail}', [OnboardingProfessionalDetailsController::class, 'update']);

    // Qualifications
    Route::post('/onboarding/qualifications', [OnboardingQualificationsController::class, 'store']);
    Route::get('/onboarding/qualifications', [OnboardingQualificationsController::class, 'index']);
    Route::put('/onboarding/qualifications/{qualification}', [OnboardingQualificationsController::class, 'update']);
    Route::delete('/onboarding/qualifications/{qualification}', [OnboardingQualificationsController::class, 'destroy']);

    // Experiences
    Route::post('/onboarding/experiences', [OnboardingExperiencesController::class, 'store']);
    Route::get('/onboarding/experiences', [OnboardingExperiencesController::class, 'index']);
    Route::put('/onboarding/experiences/{experience}', [OnboardingExperiencesController::class, 'update']);
    Route::delete('/onboarding/experiences/{experience}', [OnboardingExperiencesController::class, 'destroy']);

    // Payout Methods
    Route::post('/onboarding/payout', [OnboardingPayoutController::class, 'store']);
    Route::put('/onboarding/payout/{payoutMethod}', [OnboardingPayoutController::class, 'update']);
});
\\\

---

## 5. Response Transformation Examples

### 5.1 BasicInfo Response Transformer

\\\php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class BasicInfoResource extends JsonResource
{
    public function toArray(\)
    {
        return [
            'id'                    => \->id,
            'first_name'            => \->first_name,
            'last_name'             => \->last_name,
            'middle_name'           => \->middle_name,
            'email'                 => \->email,
            'phone'                 => \->phone,
            'gender'                => \->gender,
            'date_of_birth'         => \->date_of_birth?->format('Y-m-d'),
            'nationality'           => \->nationality,
            'preferred_language'    => \->preferred_language,
            'timezone'              => \->timezone,
            'profile_picture_url'   => \->profile_picture ? url('storage/' . \->profile_picture) : null,
            'linkedin_profile_url'  => \->linkedin_profile_url,
            'created_at'            => \->created_at,
            'updated_at'            => \->updated_at,
        ];
    }
}
\\\

### 5.2 ProfessionalDetails Response Transformer

\\\php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ProfessionalDetailsResource extends JsonResource
{
    public function toArray(\)
    {
        return [
            'id'                    => \->id,
            'headline'              => \->headline,
            'bio'                   => \->bio,
            'industry'              => \->industry,
            'employment_type'       => \->employment_type,
            'years_of_experience'   => \->years_of_experience,
            'specialization'        => \->specialization,
            'certifications'        => \->certifications ?? [],
            'availability_status'   => \->availability_status,
            'work_authorization'    => \->work_authorization,
            'portfolio_url'         => \->portfolio_url,
            'company_name'          => \->company_name,
        ];
    }
}
\\\

### 5.3 Experience Response Transformer

\\\php
namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ExperienceResource extends JsonResource
{
    public function toArray(\)
    {
        return [
            'id'                => \->id,
            'job_title'         => \->job_title,
            'company_name'      => \->company_name,
            'employment_type'   => \->employment_type,
            'start_date'        => \->start_date,
            'end_date'          => \->end_date,
            'currently_working' => \->currently_working,
            'location'          => [
                'country'       => \->country,
                'state'         => \->state,
                'city'          => \->city,
            ],
            'job_description'   => \->job_description,
            'responsibilities'  => \->responsibilities ?? [],
            'achievements'      => \->achievements ?? [],
            'skills_used'       => \->skills_used ?? [],
            'industry'          => \->industry,
            'duration_months'   => \->calculateDuration(),
        ];
    }

    private function calculateDuration()
    {
        \ = \->start_date;
        \ = \->currently_working ? now() : \->end_date;
        return \->diffInMonths(\);
    }
}
\\\

---

## 6. Migration Checklist

### 6.1 Pre-Migration Tasks
- [ ] Backup production database
- [ ] Document current field usage in all controllers
- [ ] Identify any third-party integrations using deprecated fields
- [ ] Create database migrations for new fields
- [ ] Create database migrations to drop deprecated fields (future: Phase 5)
- [ ] Update all API documentation
- [ ] Create custom validation rules

### 6.2 Migration Execution
- [ ] Run database migrations in staging environment
- [ ] Test all controller endpoints in staging
- [ ] Verify request/response formats
- [ ] Test error handling for deprecated fields
- [ ] Run automated test suite

### 6.3 Testing Checklist

**For Each Controller:**
- [ ] Test storing new records with all new fields
- [ ] Test updating existing records with new fields
- [ ] Test that deprecated fields are ignored/removed
- [ ] Test validation rules for all fields
- [ ] Test response transformations
- [ ] Test error responses (400, 422, 500)
- [ ] Test authorization/authentication
- [ ] Test with missing required fields
- [ ] Test with invalid field formats
- [ ] Test with edge case values

### 6.4 Post-Migration Tasks
- [ ] Monitor error logs for deprecated field references
- [ ] Verify all frontend applications handle new response format
- [ ] Update mobile app integrations (if applicable)
- [ ] Notify all API consumers of changes
- [ ] Archive old controller versions (backup)
- [ ] Update internal documentation
- [ ] Conduct team knowledge sharing session

### 6.5 Rollback Plan
- [ ] Keep database backup for point-in-time recovery
- [ ] Maintain old controller versions in version control
- [ ] Create rollback migration script
- [ ] Document rollback procedures
- [ ] Test rollback in staging environment

---

## 7. Common Issues and Solutions

### 7.1 Deprecated Field Still Being Sent
**Problem:** Client still sends deprecated fields that cause errors

**Solution:**
\\\php
public function sanitizeInput(array \)
{
    \ = [
        'phone_country_code',
        'profile_picture_old_path',
        'temporary_email_verification_id',
        'job_category_id',
        'experience_level_old',
        'skills_comma_separated',
        'graduation_month',
        'gpa_score',
        'transcript_uploaded_path',
        'company_website',
        'manager_contact',
        'reference_phone',
        'contract_hours_per_week',
        'ssn_last_four',
        'bank_phone_number',
        'legacy_payout_method',
    ];

    return collect(\)->except(\)->toArray();
}
\\\

### 7.2 Validation Errors for New Fields
**Problem:** Strict validation prevents field storage

**Solution:** Use sometimes and 
ullable wisely:
\\\php
// Use 'sometimes' for optional updates
'middle_name' => 'sometimes|nullable|string|max:255',

// Use 'nullable' for truly optional fields
'specialization' => 'nullable|string|max:255',

// Require for creation, optional for updates
'headline' => 'required_on:store|string|max:120',
\\\

### 7.3 Sensitive Data Exposure
**Problem:** Banking/personal information being exposed in logs

**Solution:** Encrypt before storage and mask in responses:
\\\php
// In Model
protected \ = [
    'account_number' => 'encrypted',
    'routing_number' => 'encrypted',
    'iban'           => 'encrypted',
];

// In Resource
'account_number' => mask(\->account_number, 4),

private function mask(\, \ = 4)
{
    \ = strlen(\);
    return str_repeat('*', \ - \) . substr(\, -\);
}
\\\

---

## 8. Testing Examples

### 8.1 Unit Test Template

\\\php
namespace Tests\Unit\Controllers;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

class OnboardingBasicInfoControllerTest extends TestCase
{
    use RefreshDatabase;

    protected \;

    protected function setUp(): void
    {
        parent::setUp();
        \->user = User::factory()->create();
    }

    /** @test */
    public function it_can_store_basic_info()
    {
        \ = \->actingAs(\->user)
            ->postJson('/api/onboarding/basic-info', [
                'first_name' => 'John',
                'last_name' => 'Doe',
                'email' => 'john@example.com',
                'phone' => '+1-555-0123',
                'date_of_birth' => '1990-01-15',
                'gender' => 'male',
                'nationality' => 'US',
                'preferred_language' => 'en',
                'timezone' => 'America/New_York',
            ]);

        \->assertStatus(200);
        \->assertDatabaseHas('basic_infos', [
            'first_name' => 'John',
            'user_id' => \->user->id,
        ]);
    }

    /** @test */
    public function it_ignores_deprecated_fields()
    {
        \ = \->actingAs(\->user)
            ->postJson('/api/onboarding/basic-info', [
                'first_name' => 'John',
                'last_name' => 'Doe',
                'email' => 'john@example.com',
                'phone' => '+1-555-0123',
                'date_of_birth' => '1990-01-15',
                'phone_country_code' => '+1',  // Deprecated
                'profile_picture_old_path' => '/old/path', // Deprecated
            ]);

        \->assertStatus(200);
        \->assertDatabaseMissing('basic_infos', [
            'phone_country_code' => '+1',
        ]);
    }

    /** @test */
    public function it_validates_required_fields()
    {
        \ = \->actingAs(\->user)
            ->postJson('/api/onboarding/basic-info', [
                'first_name' => 'John',
                // Missing required fields
            ]);

        \->assertStatus(422);
        \->assertJsonValidationErrors(['last_name', 'email', 'phone', 'date_of_birth']);
    }
}
\\\

---

## 9. Deployment Instructions

### 9.1 Step-by-Step Deployment
1. Create feature branch: git checkout -b feature/phase-4-controller-cleanup
2. Create database migration for new fields
3. Update all controller classes with new validation rules
4. Create/update validation rule classes
5. Create response transformer/resource classes
6. Update routes if needed
7. Write unit tests for each controller
8. Create integration tests for workflow
9. Document API changes in Postman collection
10. Submit pull request for code review
11. After approval, merge to development branch
12. Deploy to staging environment
13. Run full test suite in staging
14. Deploy to production (during low-traffic period)
15. Monitor logs for errors

### 9.2 Rollback Instructions
1. Identify issue causing rollback need
2. Revert changes: git revert <commit-hash>
3. Run database rollback migration
4. Clear application cache: php artisan cache:clear
5. Monitor application behavior
6. Notify stakeholders of rollback status

---

## 10. References & Related Documentation

- **Phase 1:** Database Schema Update - see 01_PHASE_1_DATABASE_SCHEMA.md
- **Phase 2:** Model Updates - see 02_MODEL_UPDATES_GUIDE.md
- **Phase 3:** Postman Collection - see 04_POSTMAN_UPDATE_GUIDE.md
- **Phase 5:** Migration Cleanup - see 06_DATA_MIGRATION_GUIDE.md (upcoming)
- **API Documentation:** /docs/api/v1/onboarding
- **Database Schema:** /database/schema.sql

---

**Document Version:** 1.0
**Last Updated:** 2024
**Status:** Ready for Implementation
**Reviewed By:** Development Team
