**Cosmic-tech Backend — Overview & API Reference**

This document summarizes the backend in this workspace: its structure, API surface, database models/tables, control flow, utilities, migration scripts, and a short progress report.

**Repository Root**: [backend](backend)

**Quick summary**: PHP-based REST API using procedural route files that map to controller classes in `controllers/`, models in `models/`, DB configuration in `config/`, middleware in `middleware/`, and utilities in `utils/`.

**File structure (key folders)**
- **Config**: [backend/config](backend/config)
  - Database connection and JWT helpers: [Database.php](backend/config/Database.php), [JWT.php](backend/config/JWT.php)
- **Routes**: [backend/routes](backend/routes)
  - Route group files: [auth.php](backend/routes/auth.php), [appointments.php](backend/routes/appointments.php), [clients.php](backend/routes/clients.php), [consultations.php](backend/routes/consultations.php), [doctors.php](backend/routes/doctors.php), [messages.php](backend/routes/messages.php), [slots.php](backend/routes/slots.php), [admin.php](backend/routes/admin.php)
- **Controllers**: [backend/controllers](backend/controllers) — e.g., `AuthController.php`, `AppointmentController.php`, `DoctorProfileController.php`, etc.
- **Models**: [backend/models](backend/models) — data-layer classes like `Appointment.php`, `AvailableSlots.php`, `ClientProfile.php`, `Consultation.php`, `DoctorProfile.php`, `Message.php`, `PatientProfile.php`, `User.php`.
- **Middleware**: [backend/middleware](backend/middleware) — `AuthMiddleware.php` handles authentication checks and JWT verification.
- **Utils**: [backend/utils](backend/utils) — `EmailService.php`, `FileUploadHandler.php`, `OtpManager.php`, `Response.php`, `Validator.php`.
- **DB & migrations**: [backend/db](backend/db) — SQL schemas and migration scripts (e.g., `combined_schema.sql`, `migration_doctor_updates.sql`, `onboarding_migration.sql`, `seed_admin_v2.sql`).
- **Scripts**: [backend/scripts](backend/scripts) — `run-tests.bat`, `run-tests.sh`.
- **Vendor & Composer**: `composer.json` and `vendor/` autoload support.

**Application flow (high level)**
1. Entry: `index.php` dispatches requests to route files under [backend/routes](backend/routes).
2. Routes parse HTTP method and path, then call the corresponding controller method.
3. Controllers handle validation, call model methods (or DB queries via `config/Database.php`), perform business logic, and return JSON responses using `utils/Response.php`.
4. Middleware (`AuthMiddleware.php`) protects routes requiring authentication by validating JWT tokens via `config/JWT.php`.
5. Utilities provide common services: file uploads, email, OTP generation, and input validation.

**API endpoints (overview per route file)**
- [backend/routes/auth.php](backend/routes/auth.php): login, register, token refresh, OTP endpoints (handled by `AuthController.php`).
- [backend/routes/appointments.php](backend/routes/appointments.php): create/update/list appointments (`AppointmentController.php`).
- [backend/routes/slots.php](backend/routes/slots.php): available slot listing and reservation (`AvailableSlotController.php`).
- [backend/routes/clients.php](backend/routes/clients.php): client/profile CRUD (`ClientProfileController.php`).
- [backend/routes/doctors.php](backend/routes/doctors.php): doctor profile and availability endpoints (`DoctorProfileController.php`).
- [backend/routes/consultations.php](backend/routes/consultations.php): consultation lifecycle (`ConsultationController.php`).
- [backend/routes/messages.php](backend/routes/messages.php): messaging endpoints between users (`MessageController.php`).
- [backend/routes/admin.php](backend/routes/admin.php): administrative endpoints (`AdminController.php`).

For exact route paths and parameter details, open each route file linked above and the corresponding controller implementation.

**Database models & tables mapping**
- `User` (`backend/models/User.php`) — user authentication and credentials.
- `PatientProfile` / `ClientProfile` (`backend/models/PatientProfile.php`, `backend/models/ClientProfile.php`) — patient/client demographic and profile fields.
- `DoctorProfile` (`backend/models/DoctorProfile.php`) — doctor info, specialties, availability.
- `AvailableSlots` (`backend/models/AvailableSlots.php`) — slot date/time and booking status.
- `Appointment` (`backend/models/Appointment.php`) — appointment records linking clients, doctors, slots.
- `Consultation` (`backend/models/Consultation.php`) — consultation records, notes, outcomes.
- `Message` (`backend/models/Message.php`) — message threads between users.

The exact SQL DDL is available in [backend/db/combined_schema.sql](backend/db/combined_schema.sql) and migration scripts in the same folder.

**Authentication & Security**
- JWT-based auth implemented with helpers in [backend/config/JWT.php](backend/config/JWT.php). Protected routes use `AuthMiddleware.php`.
- Input validation utilities live in `utils/Validator.php`. Responses are formatted with `utils/Response.php`.

**Migrations & seed data**
- Migrations and schema updates: [backend/db](backend/db).
- Admin seeding: [backend/db/seed_admin_v2.sql](backend/db/seed_admin_v2.sql).
- Scripts that automate migration or onboarding: `migrate_db.php`, `migrate_onboarding.php`, `run_migration.php` at repo root.

**Developer tooling & testing**
- Composer-based dependencies in `composer.json` and autoload in `vendor/`.
- Postman collection for manual API testing: [backend/postman/Therapy-Booking-MVP-API.postman_collection.json](backend/postman/Therapy-Booking-MVP-API.postman_collection.json).
- Test helpers and quick scripts: `test_login.php`, `test_register.php`, `test_phase3.php`, `validate_phase3.php`, and `scripts/run-tests.*`.

**How to run locally (quick)**
1. Ensure PHP and Composer are installed.
2. Configure DB credentials in [backend/config/Database.php](backend/config/Database.php) or environment variables used by it.
3. Run migrations with `php migrate_db.php` (or inspect `run_migration.php` for the project-specific sequence).
4. Install PHP deps with `composer install` from `backend/` if needed.
5. Start the PHP server or use WAMP/Apache with document root pointing to `backend/` and `index.php` as entry.

**Progress report (current state snapshot)**
- Implemented: route files for main API groups, controllers for core features (`Auth`, `Appointment`, `AvailableSlot`, `Consultation`, `Message`, `DoctorProfile`, `ClientProfile`), models for main tables, basic JWT auth + middleware, utilities for email/file uploads/OTP/validation, migration SQL and seed data, Postman collection.
- Available scripts: migration scripts, quick tests, and composer autoload.
- Known gaps / suggested next work items:
  - Add complete API docs (per-endpoint request/response examples) — can be generated from route/controller comments or written in `api_documentation.md`.
  - Add automated tests (unit + integration) and a CI pipeline.
  - Add more robust error handling and input sanitization audits.
  - Document environment variable requirements and example `.env` file.

**Next steps I can take for you**
- Expand `api_documentation.md` with endpoint-level examples and expected JSON schemas.
- Generate a Postman environment and publish runnable examples.
- Add a short `backend/DEV_SETUP.md` with step-by-step local dev instructions and `.env.example`.

If you'd like, I can now extract each route and controller method to produce a detailed per-endpoint spec and add it to `api_documentation.md`.
