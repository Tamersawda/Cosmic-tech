## Plan: Backend Consolidation Implementation

TL;DR: Implement a small, prioritized set of backend changes to make the API frontend-ready and production-robust: 1) normalize auth inputs (unblocks onboarding), 2) standardize API responses, 3) add qualifications & experiences CRUD with secure uploads, 4) add pricing/payout fields and endpoints, 5) admin verification workflow, migrations, docs, and Postman updates. Deliver work as small, reviewable PRs with migrations and tests.

**Steps**
1. **Auth normalization**: Modify [backend/controllers/AuthController.php](backend/controllers/AuthController.php) `register()` to accept both `name`/`role` and `fullName`/`userType`, normalize into DB fields; add input validation and unit test. *Depends on:* none. *Acceptance:* frontend registration payload (`name`,`role`) succeeds.
2. **API response standardization**: Implement wrappers in [backend/utils/Response.php](backend/utils/Response.php) producing standardized success/error shapes; update controllers to use wrappers. *Depends on:* step 1 for immediate controllers changed. *Acceptance:* all API endpoints return the agreed JSON envelope.
3. **Qualifications CRUD**:
   - Add migration SQL to `backend/db/migrations/` to create `doctor_qualifications` table (reversible).
   - Add model [backend/models/DoctorQualification.php].
   - Add controller [backend/controllers/DoctorQualificationController.php] and route entries in [backend/routes/doctors.php] exposing POST/GET/PUT/DELETE endpoints.
   - Use [backend/utils/FileUploadHandler.php] for document uploads; enforce MIME/type/size checks and store secure paths.
   *Depends on:* step 2 for consistent responses. *Acceptance:* frontend can create/list/update/delete qualifications; uploaded docs validated and stored.
4. **Experiences CRUD**: Mirror qualifications (migration, model, controller, routes). *Depends on:* step 3. *Acceptance:* experiences lifecycle endpoints working.
5. **Pricing & Payout fields**: Extend [backend/models/DoctorProfile.php] and [backend/controllers/DoctorProfileController.php] to persist `session_fee`, `payout_account`; create migration if needed. *Acceptance:* doctor setup pages save fee and payout account successfully.
6. **Verification workflow & Admin tooling**: Add admin endpoints in [backend/controllers/AdminController.php] to review and change `verification_status` on doctor profiles, trigger notifications via [backend/utils/EmailService.php]. *Acceptance:* admins can list pending verifications and approve/reject.
7. **Postman & docs**: Update [backend/postman/Therapy-Booking-MVP-API.postman_collection.json] and [backend/api_documentation.md](backend/api_documentation.md) to reflect new endpoints and payloads.
8. **Testing & rollout**: Add minimal integration scripts under `backend/test/` for critical flows (registration, qualification upload, appointment create). Run migrations on a staging DB before production.

**Relevant files**
- [backend/config/Database.php](backend/config/Database.php)
- [backend/config/JWT.php](backend/config/JWT.php)
- [backend/controllers/AuthController.php](backend/controllers/AuthController.php)
- [backend/controllers/AppointmentController.php](backend/controllers/AppointmentController.php)
- [backend/controllers/DoctorProfileController.php](backend/controllers/DoctorProfileController.php)
- [backend/utils/Response.php](backend/utils/Response.php)
- [backend/utils/FileUploadHandler.php](backend/utils/FileUploadHandler.php)
- [backend/db/combined_schema.sql](backend/db/combined_schema.sql)
- [backend/routes/doctors.php](backend/routes/doctors.php)
- [backend/postman/Therapy-Booking-MVP-API.postman_collection.json](backend/postman/Therapy-Booking-MVP-API.postman_collection.json)

**Verification**
1. Send registration payload `{"name":"Dr A","email":"a@x.com","password":"P@ss","role":"doctor"}` — expect standardized success response and `user_id`.
2. Create qualification (multipart form with `document`) — expect file saved, DB row created, and standardized response.
3. Attempt invalid upload (disallowed MIME or oversize) — expect standardized error with details.

**Decisions**
- Backwards compatibility: accept both `name`/`fullName` and `role`/`userType` during transition.
- API payloads: camelCase expected from frontend; controllers map to snake_case for DB.
- Responses: adopt envelope forms:
  - Success: `{"success":true,"message":"","data":{}}`
  - Error: `{"success":false,"error":{"code":"","message":"","details":{}}}`

**Further Considerations**
1. Migration format: prefer raw SQL files under `backend/db/migrations/` for simplicity.
2. Tests: add minimal integration tests first, then expand.
3. Order: start with auth normalization and response standardization (fast unblock), then qualifications, experiences, pricing/payout, admin/verification.


