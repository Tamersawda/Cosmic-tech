// lib/modules/admin/screens/doctor_registration/doctor_registration_form.dart

import 'package:frontend/modules/admin/controllers/registration_controller.dart';
import 'package:frontend/modules/admin/models/doctor_model.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/appointment_settings_step.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/basic_information_page.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/identity_verification_step.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/professional_details_page.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/qualifications_page.dart';
import 'package:frontend/modules/admin/screens/doctor_registration/steps/consultation_page.dart';
import 'package:frontend/modules/shared/doctor_data_store.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/widgets/doctor/step_menu.dart';
import 'package:flutter/material.dart';

class RegisterDoctorForm extends StatefulWidget {
  final VoidCallback onCancel;

  /// Optional callback — if provided, the parent controls storage.
  /// If null (default) this form writes directly to DoctorDataStore.
  final Function(DoctorModel)? onSaveDoctor;

  const RegisterDoctorForm({
    super.key,
    required this.onCancel,
    this.onSaveDoctor,
  });

  @override
  State<RegisterDoctorForm> createState() => _RegisterDoctorFormState();
}

class _RegisterDoctorFormState extends State<RegisterDoctorForm> {
  final _controller = RegistrationController();
  int _step = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _stepWidget() {
    return switch (_step) {
      0 => BasicInformationStep(controller: _controller),
      1 => ProfessionalDetailsStep(controller: _controller),
      2 => QualificationsStep(controller: _controller),
      3 => ConsultationStep(controller: _controller),
      4 => IdentityVerificationStep(controller: _controller),
      _ => AppointmentSettingsStep(controller: _controller),
    };
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  void _save() {
    final doctor = _controller.buildDoctorModel();

    if (widget.onSaveDoctor != null) {
      // Parent manages storage (e.g. DoctorManagement passes its own callback)
      widget.onSaveDoctor!(doctor);
    } else {
      // Default: write directly to store
      DoctorDataStore.instance.addDoctor(doctor);
    }

    _controller.reset();
    widget.onCancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${doctor.name} has been submitted for review.')),
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Form'),
        content: const Text(
          'Are you sure you want to clear all entered information?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () {
              _controller.reset();
              Navigator.pop(ctx);
              setState(() => _step = 0);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onCancel,
                tooltip: 'Back',
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register Doctor',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create and manage doctor profile information',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Reset
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _confirmReset,
                icon: const Icon(Icons.refresh, color: Color(0xFF475569)),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: Color(0xFF475569)),
                ),
              ),

              const SizedBox(width: 10),

              // Save
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _save,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Submit for Review',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Form card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 30,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isMobile
                  ? Column(
                      children: [
                        StepMenu(
                          currentStep: _step,
                          onStepChanged: (i) => setState(() => _step = i),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: _stepWidget()),
                      ],
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: 240,
                          child: StepMenu(
                            currentStep: _step,
                            onStepChanged: (i) => setState(() => _step = i),
                          ),
                        ),
                        const SizedBox(width: 30),
                        const VerticalDivider(),
                        const SizedBox(width: 30),
                        Expanded(child: _stepWidget()),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
