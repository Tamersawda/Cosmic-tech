# Doctor Registration Flow - Backend Schema Blueprint

This document outlines all the data fields collected across the 7-step Doctor Registration flow. You can use this to design your backend database schema (e.g., your `doctors` table, or related tables like `doctor_qualifications` and `doctor_experiences`).

---

## 1. Basic Information (`basic_information.dart`)
This page collects the doctor's personal identity and contact details.

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Profile Photo** | Image Upload | `VARCHAR` (URL/Path) |
| **Full Name** | Text Field | `VARCHAR` |
| **Email Address** | Text Field (Email) | `VARCHAR` (Unique) |
| **Phone Number** | Text Field (Phone) | `VARCHAR` |
| **Gender** | Dropdown Select | `ENUM` (Male, Female, Other, Prefer not to say) |
| **Date of Birth** | Date Picker | `DATE` |

---

## 2. Professional Details (`professional_details.dart`)
This page captures the doctor's clinical expertise, languages, and identity verification.

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Primary Title** | Dropdown Select | `VARCHAR` / `ENUM` (e.g., Clinical Psychologist) |
| **Secondary Title** | Text Field | `VARCHAR` (Nullable) |
| **Specializations** | Multi-Select Chips (2-layer) | `JSON` array of strings (Categories & Sub-categories) |
| **Therapy Approaches** | Multi-Select Chips | `JSON` array of strings (Includes custom inputs) |
| **Languages Spoken** | Multi-Select Chips | `JSON` array of strings |
| **Professional Bio** | Text Area (Max 600 chars) | `TEXT` |
| **Govt ID Front Side** | Document/Image Upload | `VARCHAR` (URL/Path) |
| **Govt ID Back Side** | Document/Image Upload | `VARCHAR` (URL/Path) |

---

## 3. Qualifications (`qualification.dart`)
This page allows the doctor to add multiple educational qualifications dynamically. 
*Recommendation: Store this as a separate table (e.g., `doctor_qualifications`) with a One-to-Many relationship.*

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Degree / Qualification Name** | Text Field | `VARCHAR` |
| **University / Institute** | Text Field | `VARCHAR` |
| **Passing Year** | Date/Year Picker | `INT` or `DATE` |
| **Certificate / Proof** | Document Upload | `VARCHAR` (URL/Path) |

---

## 4. Professional Registration (`professional_registration.dart`)
This page verifies the doctor's regulatory body registration (e.g., RCI).

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Registration Type** | Radio Options | `ENUM` ('rci', 'none') |
| **RCI CRR Number** | Text Field | `VARCHAR` (Nullable, if 'rci') |
| **RCI Certificate** | Document Upload | `VARCHAR` (URL/Path) (Nullable, if 'rci') |
| **Agreed to Self-Declaration** | Checkbox | `BOOLEAN` (Required true if 'none') |

---

## 5. Work Experience (`work_experience_page.dart`)
This page captures the doctor's employment history dynamically.
*Recommendation: Store this as a separate table (e.g., `doctor_experiences`) with a One-to-Many relationship.*

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Role / Position** | Text Field | `VARCHAR` |
| **Organization Name** | Text Field | `VARCHAR` |
| **Work Type** | Chip Select | `ENUM` (Hospital, Private Practice, NGO, Online Platform, Other) |
| **Custom Work Type** | Text Field | `VARCHAR` (Nullable, if Work Type is 'Other') |
| **Start Date** | Date Picker | `DATE` |
| **End Date** | Date Picker | `DATE` (Nullable if currently working) |
| **Currently Working Here** | Checkbox | `BOOLEAN` |
| **Description** | Text Area | `TEXT` (Nullable) |
| **Experience Proof (Cert)** | Document Upload | `VARCHAR` (URL/Path) |

---

## 6. Session Fee (`session_fee_page.dart`)
This page captures the pricing tier the doctor selects.

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Session Fee Tier** | Card Selection | `INT` or `ENUM` (e.g., 799, 999, 1499, 1999, 2499) |
| **Pricing Justification** | Text Area | `TEXT` (Nullable) |

---

## 7. Payout Details (`payout_page.dart`)
This page collects banking and tax compliance information for transferring earnings.

| Field Name | Frontend Input Type | Recommended Backend Data Type |
| :--- | :--- | :--- |
| **Account Holder Name** | Text Field | `VARCHAR` |
| **Account Number** | Text Field (Hidden toggle)| `VARCHAR` |
| **IFSC Code** | Text Field | `VARCHAR` |
| **Bank Name** | Auto-resolved text | `VARCHAR` |
| **Branch Name** | Auto-resolved text | `VARCHAR` |
| **PAN Number** | Text Field | `VARCHAR` |
| **Is GST Registered?** | Radio/Toggle | `BOOLEAN` |
| **GST Number** | Text Field | `VARCHAR` (Nullable, required if GST registered) |
| **Terms & Consent Agreed** | Checkbox | `BOOLEAN` |

---

### Additional Metadata Fields for Backend
To manage the lifecycle of the registration, you will likely need the following fields in the user/doctor model:
* `registration_step` (Integer: Tracks where they left off, 1 to 7)
* `is_profile_completed` (Boolean: Becomes true after Payout submission)
* `verification_status` (Enum: 'pending', 'approved', 'rejected', 'action_required' - used by `profile_completed_page.dart`)
