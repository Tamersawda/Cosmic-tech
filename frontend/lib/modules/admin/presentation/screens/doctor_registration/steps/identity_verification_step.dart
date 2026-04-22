// lib/modules/admin/screens/doctor_registration/steps/identity_verification_step.dart
//
// Syncs picked file paths to controller.governmentIdFile /
// controller.medicalLicenseFile / controller.selfieFile.

import 'package:frontend/modules/admin/presentation/controllers/registration_controller.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IdentityVerificationStep extends StatefulWidget {
  final RegistrationController controller;

  const IdentityVerificationStep({super.key, required this.controller});

  @override
  State<IdentityVerificationStep> createState() =>
      _IdentityVerificationStepState();
}

class _IdentityVerificationStepState extends State<IdentityVerificationStep> {
  String? _govIdFile;
  String? _medLicenseFile;
  String? _selfieFile;


  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      widget.controller.adminVerifiedDate.text = DateFormat(
        'dd MMM yyyy',
      ).format(date);
      setState(() {});
    }
  }

  Widget _uploadBox({
    required String title,
    required String? file,
    required Function(String) onFilePicked,
  }) {
    return DropTarget(
      onDragDone: (d) => setState(() => onFilePicked(d.files.first.name)),
      child: GestureDetector(
        onTap: () async {
          
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$title\nDrag & Drop or Click to Upload',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        file,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identity Verification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload identity documents and verify doctor credentials.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 25),

          // Gov ID + Medical License
          Row(
            children: [
              Expanded(
                child: _uploadBox(
                  title: 'Government ID Proof',
                  file: _govIdFile,
                  onFilePicked: (name) {
                    _govIdFile = name;
                    widget.controller.governmentIdFile = name;
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _uploadBox(
                  title: 'Medical License',
                  file: _medLicenseFile,
                  onFilePicked: (name) {
                    _medLicenseFile = name;
                    widget.controller.medicalLicenseFile = name;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Selfie
          _uploadBox(
            title: 'Profile Selfie Verification',
            file: _selfieFile,
            onFilePicked: (name) {
              _selfieFile = name;
              widget.controller.selfieFile = name;
            },
          ),

          const SizedBox(height: 25),

          // Admin verified date
          const Text('Admin Verified Date'),
          const SizedBox(height: 6),
          AdminTextField(
            controller: widget.controller.adminVerifiedDate,
            readOnly: true,
            label: 'Select Date',
            suffixIcon: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }
}
